CREATE VECTOR INDEX IX_DocumentsRag_Embedding
ON dbo.DocumentsRag (Embedding)
WITH (
    METRIC = 'cosine',
    TYPE = 'DiskANN'
);
GO