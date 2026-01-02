DROP TABLE IF EXISTS dbo.DocumentsRag;
GO

CREATE TABLE dbo.DocumentsRag
(
    DocumentId INT IDENTITY PRIMARY KEY,
    reviewId NVARCHAR(200),
    userName NVARCHAR(500),
    score INT,
    thumbsUpCount INT,
    reviewCreatedVersion NVARCHAR(200),
    at DATETIME2,
    appVersion NVARCHAR(100),

    Content NVARCHAR(MAX),               -- review text
    Embedding VECTOR(1536) NULL,         -- vector
    InsertedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO