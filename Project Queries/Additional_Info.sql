-- top 10 companies with most funds
CREATE TEMPORARY TABLE most_funds
SELECT company
FROM layoffs_staging
WHERE funds_raised_millions IS NOT NULL AND percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY AVG(funds_raised_millions) DESC
LIMIT 10;
    
-- does each of these top ten companies have high or low layoffs
WITH avg_funds_and_layoffs AS 
(
	SELECT company, AVG(percentage_laid_off) AS average_laid_off
	FROM layoffs_staging
	WHERE company IN (SELECT * FROM most_funds)
	GROUP BY company
)
         SELECT company,
		 CASE 
             WHEN average_laid_off > (SELECT AVG(percentage_laid_off) AS avg_funds
			 FROM layoffs_staging) THEN 'high layoffs'
			 
			 WHEN average_laid_off < (SELECT AVG(percentage_laid_off) AS avg_funds
			 FROM layoffs_staging) THEN 'low layoffs'
		 END AS layoffs_and_funds
FROM avg_funds_and_layoffs
ORDER BY layoffs_and_funds;


-- top 10 lowest funds per company
CREATE TEMPORARY TABLE least_funds
SELECT company
FROM layoffs_staging
WHERE funds_raised_millions IS NOT NULL AND percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY AVG(funds_raised_millions)
LIMIT 10;
    
-- does each of these top ten companies have high or low layoffs 
WITH avg_funds_and_layoffs AS 
(
	SELECT company, AVG(percentage_laid_off) AS average_laid_off
	FROM layoffs_staging
	WHERE company IN (SELECT * FROM least_funds)
	GROUP BY company
)
         SELECT company,
		 CASE 
             WHEN average_laid_off > (SELECT AVG(percentage_laid_off) AS avg_funds
			 FROM layoffs_staging) THEN 'high layoffs'
			 
			 WHEN average_laid_off < (SELECT AVG(percentage_laid_off) AS avg_funds
			 FROM layoffs_staging) THEN 'low layoffs'
		 END AS layoffs_and_funds
FROM avg_funds_and_layoffs
ORDER BY layoffs_and_funds;





-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





-- location where most of media in 2022 made funds
SELECT location, SUM(funds_raised_millions) sum_of_funds
FROM layoffs_staging
WHERE industry = 'media' AND YEAR(date) = 2022
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;


    
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    

-- what percentage of the total layoffs did media make up each year?
WITH total_layoffs AS 
(
	SELECT YEAR(date) AS years, SUM(total_laid_off) AS total_off
    FROM layoffs_staging
    WHERE YEAR(date) IS NOT NULL
    GROUP BY YEAR(date)
),
total_layoffs_media AS
(
	SELECT YEAR(date) AS years, SUM(total_laid_off) AS total_off_media
    FROM layoffs_staging
    WHERE YEAR(date) IS NOT NULL AND industry = 'media'
    GROUP BY YEAR(date)
)
SELECT c1.years, total_off_media, total_off, (total_off_media/total_off*100) AS percent_off
FROM total_layoffs c1
JOIN total_layoffs_media c2
ON c1.years = c2.years;



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- rolling total
WITH rolling_total AS
(
	SELECT SUBSTRING(date,1,7) AS month, SUM(total_laid_off) AS total_off
	FROM layoffs_staging
	WHERE SUBSTRING(date,1,7) IS NOT NULL
	GROUP BY month
	ORDER BY month
)
SELECT month, total_off, SUM(total_off) OVER(ORDER BY month)
FROM rolling_total;





-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- company with most layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY company
ORDER BY total_layoffs DESC;

-- companies who went out of business
SELECT *
FROM layoffs_staging 
WHERE percentage_laid_off = 1;

-- years ordered descending by amount of layoffs
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY YEAR(date) 
ORDER BY total_layoffs DESC;



