-- 5. Throughout the companies, is there a correlation between layoffs and funds raised?

-- (question was mostly answered with tableau)

-- created temp table to group companies with below average layoff percentages and above average layoff percentages
CREATE TEMPORARY TABLE funds_layoffs_bins
	WITH avg_funds_and_layoffs AS 
	(
		SELECT company, AVG(funds_raised_millions) AS average_funds, AVG(percentage_laid_off) AS average_laid_off
		FROM layoffs_staging
		WHERE funds_raised_millions IS NOT NULL AND percentage_laid_off IS NOT NULL
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
       
-- counting how many in each category
SELECT layoffs_and_funds, COUNT(layoffs_and_funds) AS category_count
FROM funds_layoffs_bins
GROUP BY layoffs_and_funds;