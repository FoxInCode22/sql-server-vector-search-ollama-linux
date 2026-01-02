DROP TABLE IF EXISTS dbo.StagingNetflixReviews;
GO

CREATE TABLE dbo.StagingNetflixReviews
(
    reviewId NVARCHAR(200) NULL,
    userName NVARCHAR(500) NULL,
    content NVARCHAR(MAX) NULL,
    score FLOAT NULL,
    thumbsUpCount INT NULL,
    reviewCreatedVersion NVARCHAR(200) NULL,
    at DATETIME2 NULL,
    appVersion NVARCHAR(100) NULL
);
GO