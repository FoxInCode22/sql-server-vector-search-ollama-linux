# Configuring a Local AI Model on Linux for SQL Server 2025

SQL Server 2025 supports integration with external AI models for tasks such as embedding generation.  
There is, however, an important requirement:
- All external model endpoints must be exposed over HTTPS.
  
Since most local model runtimes (like Ollama) expose HTTP-only endpoints by default, we need an HTTPS reverse proxy in front of them. This guide walks through the complete setup on Ubuntu 22.04.

## Architecture
```
SQL Server 2025
   |
   |  HTTPS (trusted)
   v
Caddy (11435, TLS internal)
   |
   |  HTTP
   v
Ollama (11434)
```
---
### Prerequisites: SQL Server 2025 installed and configured on Ubuntu 22.04
---
### Step 1: Install and Configure Ollama

Ollama is a lightweight runtime for running local LLMs and embedding models.
- Install Ollama
```
curl -fsSL https://ollama.com/install.sh | sh
```
<img width="982" height="228" alt="image" src="https://github.com/user-attachments/assets/8f2ef97a-0380-4707-bfa7-0bb86d753de7" />

This installs the Ollama service and CLI.

Next, we pull the embedding model.

```
ollama pull nomic-embed-text
```

<img width="1489" height="144" alt="image" src="https://github.com/user-attachments/assets/cb60a195-78b0-4f6c-a590-3d2b1e6a229f" />


### Step 2: Install Caddy (HTTPS Reverse Proxy)
- Install Caddy
```
sudo apt install -y caddy
```
Backup the default configuration
```
sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bak
```
### Step 3: Configure Caddy to Proxy Ollama over HTTPS
Replace the Caddy configuration with the following:
```
sudo tee /etc/caddy/Caddyfile >/dev/null <<'EOF'
https://localhost:11435 {
  tls internal
  reverse_proxy 127.0.0.1:11434
}
EOF
```

Reload Caddy:
```
sudo systemctl reload caddy
```
### Step 4: Trust Caddy’s Certificate (Critical Step)
Caddy generates a local root CA, which must be trusted by:
- The Linux OS
- SQL Server’s SQLPAL layer


#### Trust the certificate at OS level
```
sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt \
    /usr/local/share/ca-certificates/caddy-local-ca.crt
sudo update-ca-certificates
```
<img width="1650" height="210" alt="image" src="https://github.com/user-attachments/assets/bb2b14ec-1f5b-46d8-ace1-fa1b22374b2d" />

#### Trust the Certificate for SQL Server (SQLPAL)
SQL Server on Linux maintains a separate trusted certificate store through the SQLPAL layer.

Create the certificate directory
```
sudo mkdir -p /var/opt/mssql/security/ca-certificates
```
Copy Caddy’s root certificate
```
sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt \
    /var/opt/mssql/security/ca-certificates/caddy-root.crt
```
Fix permissions
```
sudo chown -R mssql:mssql /var/opt/mssql/security
sudo chmod 744 /var/opt/mssql/security/ca-certificates
sudo chmod 644 /var/opt/mssql/security/ca-certificates/caddy-root.crt
```
<img width="1169" height="600" alt="image" src="https://github.com/user-attachments/assets/0c0a331f-3d75-4924-80ee-cb7d69d4e687" />



### Step 5: Restart SQL Server
SQL Server reads trusted certificates only at startup.
```
sudo systemctl restart mssql-server
```
### Step 6: Validate HTTPS Endpoints

Check model availability
```
curl https://localhost:11435/api/tags
```
<img width="1661" height="66" alt="image" src="https://github.com/user-attachments/assets/b9a34487-1101-4ecf-bdec-1d9f540d3fcb" />

Test embedding generation over HTTPS
```
curl https://localhost:11435/api/embed \
  -H "Content-Type: application/json" \
  -d '{ "model":"nomic-embed-text", "input":"hello from caddy" }'
```
<img width="900" height="435" alt="image" src="https://github.com/user-attachments/assets/592d0e90-de63-44fe-8fed-6a47b576ea23" />

If this succeeds:
- HTTPS is correctly configured
- The certificates are trusted
- SQL Server can securely access this endpoint

After configuring the Ollama embedding model on the local server, the next step is the SQL Server workflow: ingesting unstructured text, generating embeddings, storing them in native vector columns, and performing vector similarity search.

This repository contains a complete, step-by-step set of SQL scripts to implement the entire workflow:

```
/
├── README.md
└── ollama/
    ├── 00_enable_features.sql
    ├── 01_create_staging_table.sql
    ├── 02_bulk_insert_csv.sql
    ├── 03_create_embed_table.sql
    ├── 04_load_into_table.sql
    ├── 05_generate_embeddings.sql
    ├── 06_create_vector_index.sql      (optional but recommended)
    └── 07_vector_search.sql

```

Note: The following Kaggle dataset is used for the vector search demonstration in SQL Server:
Dataset : https://www.kaggle.com/datasets/ashishkumarak/netflix-reviews-playstore-daily-updated/data

The following shows the results of our vector search test in SQL Server 2025.
![vector_search](https://github.com/user-attachments/assets/3052613f-18c7-4323-9af2-2eb987e26f1e)

## Summary
This repository demonstrates how to integrate a locally hosted AI embedding model with SQL Server 2025 on Linux while meeting the platform’s strict HTTPS requirements for external model access. The solution uses Ollama as the local model runtime and Caddy as an HTTPS reverse proxy to securely expose the model endpoint.

The walkthrough covers end-to-end setup, including installing and configuring Ollama, securing the model endpoint with Caddy’s internal TLS, and correctly establishing certificate trust at both the Linux OS level and within SQL Server’s SQLPAL certificate store. This ensures SQL Server can securely invoke the external model without bypassing platform security constraints.

The repository also includes a complete set of SQL scripts that implement a full vector search workflow in SQL Server 2025. This workflow ingests unstructured text data, generates embeddings using the external model, stores them in native vector columns, optionally creates a vector index, and executes vector similarity queries. A real-world dataset is used to validate the approach and demonstrate search results.

Overall, the repository provides a practical, security-compliant reference architecture for running local AI models alongside SQL Server 2025 on Linux and performing native vector search without relying on managed cloud AI services.


