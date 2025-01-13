-- 4. Did this leading company layoff a smaller percent of there employees compared to other companies?

-- inner query showing all ranks
SELECT company, AVG(percentage_laid_off) AS lay_offs
FROM layoffs_staging
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY lay_offs DESC;

-- inner query inside of CTE to target netflix's ranking
WITH ranks AS 
(
	SELECT company, ROUND(avg_layoff_percentage,2)*100 AS avg_layoff_percentage, DENSE_RANK() OVER(ORDER BY avg_layoff_percentage DESC) AS `rank`
	FROM
		(SELECT company, AVG(percentage_laid_off) AS avg_layoff_percentage
		FROM layoffs_staging
		WHERE percentage_laid_off IS NOT NULL
		GROUP BY company
		ORDER BY avg_layoff_percentage DESC) AS sub
)
SELECT *
FROM ranks 
WHERE company = 'Netflix';
