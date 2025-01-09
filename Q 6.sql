-- 6. What are the top 5 companies and industries with the most layoffs per year?

-- ranking by layoffs per year and company
WITH Company_Year (company, years, total_laid_off) AS
(
	SELECT company, YEAR(date), SUM(total_laid_off)
    FROM layoffs_staging
    GROUP BY company, YEAR(date)
),
Company_Year_rank AS
(
	SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
	FROM company_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_rank
WHERE Ranking <= 5;



-- ranking by layoffs per year and industry
WITH industry_Year (industry, years, total_laid_off) AS
(
	SELECT industry, YEAR(date), SUM(total_laid_off)
    FROM layoffs_staging
    GROUP BY industry, YEAR(date)
),
industry_Year_rank AS
(
	SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
	FROM industry_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM industry_Year_rank
WHERE Ranking <= 5;