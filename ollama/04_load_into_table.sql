INSERT INTO dbo.DocumentsRag
(
    reviewId,
    userName,
    score,
    thumbsUpCount,
    reviewCreatedVersion,
    at,
    appVersion,
    Content
)
SELECT
    reviewId,
    userName,
    score,
    thumbsUpCount,
    reviewCreatedVersion,
    at,
    appVersion,
    content    -- the review text
FROM dbo.StagingNetflixReviews
WHERE content IS NOT NULL;
GO