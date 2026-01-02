
BULK INSERT dbo.StagingNetflixReviews
FROM '/var/opt/mssql/backup/netflix_reviews.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

