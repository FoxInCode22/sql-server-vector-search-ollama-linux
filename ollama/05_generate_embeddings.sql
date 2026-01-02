SET NOCOUNT ON;

DECLARE @BatchSize INT = 1000;
DECLARE @RowsAffected INT = 1;

WHILE (@RowsAffected > 0)
BEGIN
    ;WITH NextBatch AS
    (
        SELECT TOP (@BatchSize) DocumentId
        FROM dbo.DocumentsRag
        WHERE Embedding IS NULL
        ORDER BY DocumentId
    )
    UPDATE d
    SET Embedding = AI_GENERATE_EMBEDDINGS(d.Content USE MODEL ollama)
    FROM dbo.DocumentsRag d
    INNER JOIN NextBatch b
        ON d.DocumentId = b.DocumentId;

    SET @RowsAffected = @@ROWCOUNT;

    -- Optional: small pause to avoid overloading Ollama
    WAITFOR DELAY '00:00:01';
END