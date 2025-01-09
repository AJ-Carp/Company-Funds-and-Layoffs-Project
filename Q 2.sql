-- 2. Which company raised the most funds and which industry is it part of?

SELECT company, SUM(funds_raised_millions) AS sum_of_funds
FROM layoffs_staging
GROUP BY company 
ORDER BY 2 DESC
LIMIT 10;