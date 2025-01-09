-- 3. What percent does this leading company make up of it industries overall funds raised?

WITH media_total AS
(
	SELECT ROUND(SUM(funds_raised_millions),1) AS sum_funds_media
	FROM layoffs_staging
	WHERE industry = 'media'
),
netflix_total AS
(
	SELECT ROUND(SUM(funds_raised_millions),1) AS sum_funds_netflix
	FROM layoffs_staging
	WHERE company = 'Netflix'
)
SELECT sum_funds_netflix, sum_funds_media, ROUND(sum_funds_netflix/sum_funds_media*100,1) AS `%_of_total`
FROM media_total
JOIN netflix_total;

-- query below reveals that media contains 65 companies
SELECT COUNT(DISTINCT company) AS media_companies
FROM layoffs_staging
WHERE industry = 'media';

-- query below reveals that Netflix only raised funds in 2022
SELECT *
FROM layoffs_staging
WHERE company = 'Netflix'
ORDER BY funds_raised_millions DESC;