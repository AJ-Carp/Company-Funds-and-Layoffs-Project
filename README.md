# Introduction
As job hunting grows more challenging, I started to consider whether data analysis could enhance my chances of securing a position by examining historical layoff data. Through this project, I aim to uncover key factors contributing to workforce reductions, as well as identify companies and industries that might offer better opportunities.

🚿 Data Cleaning? Check it out here: [Project_queries](https://github.com/AJ-Carp/Data-Science-Job-Analysis-Project/tree/main/Project_queries) (change this link)

🔍 SQL queries? Check them out here: [Project_queries](https://github.com/AJ-Carp/Data-Science-Job-Analysis-Project/tree/main/Project_queries) (change this link)

📊 Tableau Dashboard? Check it out here: [Dashboard] (add link)
# Questions

1. Which industry raised the most funds?
2. Which company raised the most funds and which industry is it part of?
3. What percent does this leading company make up of it industries overall funds raised?
4. Did this leading company have a significantly higher or lower amount of layoffs then other companies?
5. Throughout the companies and industries, is there a correlation between layoffs and funds raised?
6. What are the top 5 companies with the most layoffs per year?

# Tools I Used

- **MySQL:**
- **Excel:**
- **Tableau:**
- **Git & GitHub:** 

# The Analysis

### 1. Which industry raised the most funds?
A much simpler query could be written to answer this question but I wanted to gain some additional insight to help me make correlations later on.

```sql
WITH top_5_per_year AS 
(
	WITH sum_for_industry_year AS (
		SELECT YEAR(date) AS year, Industry, SUM(funds_raised_millions) AS sum_funds
		FROM layoffs_staging 
		WHERE funds_raised_millions IS NOT NULL AND date IS NOT NULL AND Industry IS NOT NULL
		GROUP BY YEAR(date), Industry
	)
	SELECT *, ROW_NUMBER() OVER(PARTITION BY year ORDER BY sum_funds DESC) AS row_num
	FROM (
		SELECT sum_for_industry_year.year, sum_for_industry_year.industry, sum_for_industry_year.sum_funds, sum_funds_for_year, sum_funds/sum_funds_for_year AS `sum_funds_%_of_total_for_year`, SUM(sum_funds) OVER() AS all_total, (sum_funds/SUM(sum_funds) OVER()) AS `sum_funds_%_of_all_years_total`
		FROM sum_for_industry_year 
		JOIN
			(SELECT YEAR(date) AS year, SUM(funds_raised_millions) AS sum_funds_for_year
			FROM layoffs_staging
			WHERE funds_raised_millions IS NOT NULL AND date IS NOT NULL AND Industry IS NOT NULL 
			GROUP BY YEAR(date)) AS sub
		ON sub.year = sum_for_industry_year.year) AS sub2
	ORDER BY year DESC, sum_funds DESC
)
SELECT *
FROM top_5_per_year
WHERE row_num <= 5;
```
Output of query formated in Excel:

<img width="1277" alt="Screenshot 2025-01-08 at 12 11 17 PM" src="https://github.com/user-attachments/assets/d273fd8c-6c94-4b1e-854b-47f29b3fa9c1" />


Here's the breakdown:
- In our first 2 columns, the top 5 industries leading in funds for each year are shown.
- In the 3rd column the sum of funds for each undustry per year is shown. Then in the 4th column the sum of funds for the whole year is shown. (for ALL industries)
- The 5th column shows what percent of funds each industry makes up for each year.
- Finally, the 6th column shows the total sum of all funds for all 4 years. Then in the last column we see that media in 2022 alone makes up 31% of the whole total, clearly indicating that media is our winner.
  

### 2. Which company raised the most funds and which industry is it part of?
```sql
SELECT company, SUM(funds_raised_millions) AS sum_of_funds
FROM layoffs_staging
GROUP BY company 
ORDER BY 2 DESC
LIMIT 10;
```
Output of query formated in Tableau:

<img width="875" alt="Screenshot 2025-01-02 at 9 20 59 AM" src="https://github.com/user-attachments/assets/3795f7a0-60e7-47bb-a605-94df87f9e2cc" />


Here's the breakdown:
- The companies are grouped together, showing the sum of all funds for each company.
- The legend on the right tells us the industry each company is part of.
- Netflix takes the lead with more then 3 times the funds the runner up had!
- Unsurprisingly, Netflix is considered part of the media industry.
- I must investigate futher!


### 3.  What percent does this leading company make up of it industries overall funds raised?


```sql
-- netflix funds percent of total media funds
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
```
Output:

<img width="275" alt="Screenshot 2025-01-08 at 1 42 38 PM" src="https://github.com/user-attachments/assets/d6082932-ce68-42cb-a1c8-c08b42606804" />

The query below reveals that media contains a staggering 65 companies!

```sql
SELECT COUNT(DISTINCT company) AS media_companies
FROM layoffs_staging
WHERE industry = 'media';
```
Output:

<img width="101" alt="Screenshot 2025-01-08 at 1 53 41 PM" src="https://github.com/user-attachments/assets/44043732-09c5-428e-8794-9fbcd8d9955e" />

The query below reveals that Netflix only raised funds in 2022.

```sql
SELECT *
FROM layoffs_staging
WHERE company = 'Netflix'
ORDER BY funds_raised_millions DESC;
```

<img width="694" alt="Screenshot 2025-01-08 at 3 10 33 PM" src="https://github.com/user-attachments/assets/0a501c86-5018-4103-bad3-00c1e5697eea" />


Here's a breakdown:

- Media contains 65 companies and altogether raised $504,783.2 in funds.
- Netflix raised 96.6% of those funds!

### 4.  Did this leading company have a significantly higher or lower amount of layoffs then other companies?

```sql
-- inner query showing all ranks
SELECT company, AVG(percentage_laid_off) AS lay_offs
FROM layoffs_staging
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY lay_offs DESC;

-- inner query inside of CTE to target netflix's ranking
WITH ranks AS 
(
	SELECT company, ROUND(avg_layoff_percentage,2) AS avg_layoff_percentage, DENSE_RANK() OVER(ORDER BY avg_layoff_percentage DESC) AS `rank`
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
```

Output of CTE:

<img width="296" alt="Screenshot 2025-01-08 at 2 08 28 PM" src="https://github.com/user-attachments/assets/d7b333d0-14eb-44c4-b105-f3a8c8775d63" />

Here's a breakdown:

- The inner query groups by company and finds the average percent of employees that was laid off.
- I then put this query inside of a CTE to assign ranks to each company based on layoff percentages, with a higher rank indicating a larger percentage of the company was laid off.
- If executed without the WHERE statement targeting companies with the name Netlix, the output shows a total of 118 ranks.
- I then added the WHERE statement and found that Netflix ranked 116 out of 118 ranks, making them one of the companies with the lowest percentage laid off!



### 5. Throughout the companies and industries, is there a correlation between layoffs and funds raised?

<img width="690" alt="Screenshot 2025-01-07 at 2 44 02 PM" src="https://github.com/user-attachments/assets/9e6ab198-06c3-4c92-9842-7b6c8c9ae05e" />

Here's the breakdown: 

- Almost all of the companies that raised lots of funds fall below the average percent laid off line.
- Most companies fall directly on the average funds line and below the average percent laid off line.
- This suggests that if the funds are very high then the compnay probably has low layoffs as well.
- However, low layoffs does not mean high funds.

<img width="685" alt="Screenshot 2025-01-07 at 2 41 27 PM" src="https://github.com/user-attachments/assets/1f1b4037-161b-4af5-aa3a-92a00378ff92" />

Here's the breakdown: (maybe do percentage of companies in each catorgy rather then looking at industry)
- Each square represents an industry
- The size of the square represents the average funds raised for that industry, bigger squares indicating higher funds.
- The color of the square represents the average percentage laid off for that industry, darker shades indicating higher percentages.

### 6. What are the top 5 companies with the most layoffs per year?
```sql
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

```
Output of query formated in Tableau:

<img width="789" alt="Screenshot 2025-01-07 at 12 46 44 PM" src="https://github.com/user-attachments/assets/6255d5b2-d046-4e5f-b92f-1be98ca5a28c" />

Here's the breakdown:
- The companies are grouped together, showing the sum of all funds for each company.
- The legend on the right tells us the industry each company is part of.
- Netflix takes the lead with more then 3 times the funds the runner up had!
- Unsurprisingly, Netflix is considered part of the media industry.
- I must investigate futher!
# What I Learned

Throughout this adventure, I've turbocharged my SQL toolkit with some serious firepower:

- **🧩 Complex Query Crafting:** Mastered the art of advanced SQL, merging tables like a pro and wielding WITH clauses for ninja-level temp table maneuvers.
- **📊 Data Aggregation:** Got cozy with GROUP BY and turned aggregate functions like COUNT() and AVG() into my data-summarizing sidekicks.
- **💡 Analytical Wizardry:** Leveled up my real-world puzzle-solving skills, turning questions into actionable, insightful SQL queries.

# Conclusions

### Insights
From the analysis, several general insights emerged:

1. **Top-Paying Data Analyst Jobs**: The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
2. **Skills for Top-Paying Jobs**: High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
3. **Most In-Demand Skills**: SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
4. **Skills with Higher Salaries**: Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
5. **Optimal Skills for Job Market Value**: SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.

### Closing Thoughts

This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.

