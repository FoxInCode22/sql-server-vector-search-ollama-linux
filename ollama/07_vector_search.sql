DECLARE @query NVARCHAR(MAX) = N'What billing problems do users frequently complain? ';
DECLARE @qVec VECTOR(768);

-- Generate embedding for the query
SET @qVec = AI_GENERATE_EMBEDDINGS(@query USE MODEL ollama);

-- Exact similarity search
SELECT TOP (5)
    DocumentId,
    Content,
    VECTOR_DISTANCE('cosine', Embedding, @qVec) AS similarity
FROM dbo.DocumentsRag
WHERE Embedding IS NOT NULL
ORDER BY VECTOR_DISTANCE('cosine', Embedding, @qVec);
