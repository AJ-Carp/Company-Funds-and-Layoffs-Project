# Introduction
As job hunting grows more challenging, I started to consider whether data analysis could enhance my chances of securing a position by examining historical layoff data. Through this project, I aim to uncover key factors contributing to workforce reductions, as well as identify companies and industries that might offer better opportunities.

🚿 Data Cleaning? Check it out here: [Cleaning File](cleaning.sql)

🔍 SQL queries? Check them out here: [Project Queries](https://github.com/AJ-Carp/Company-Funds-and-Layoffs-Project/tree/main/Project%20Queries)

📊 Tableau Dashboard? Check it out here: [Dashboard] (add link)
# Questions

1. Which industry raised the most funds?
2. Which company raised the most funds and which industry is it part of?
3. What percent does this leading company make up of it industries total funds raised?
4. Did this leading company layoff a smaller percent of there employees compared to other companies?
5. Throughout the companies, is there a correlation between layoffs and funds raised?
6. What are the top 5 companies and industries with the most layoffs per year?

# Tools I Used

- **MySQL:** Cleaning and exploring data set.
- **Excel:** Formatting outputs of qeuries.
- **Tableau:** Formatting outputs of qeuries and creating dashboard.
- **Git & GitHub:** Version control and sharing my SQL scripts and analysis.

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
Output formated in Excel:

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
Output formated in Tableau:

<img width="875" alt="Screenshot 2025-01-02 at 9 20 59 AM" src="https://github.com/user-attachments/assets/3795f7a0-60e7-47bb-a605-94df87f9e2cc" />


Here's the breakdown:
- The companies are grouped together, showing the sum of all funds for each company.
- The legend on the right tells us the industry each company is part of.
- Netflix takes the lead with more then 3 times the funds the runner up had!
- Unsurprisingly, Netflix is considered part of the media industry.
- I must investigate futher!


### 3.  What percent does this leading company make up of it industries total funds raised?


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

The additional query below reveals that media contains a staggering 65 companies!

```sql
SELECT COUNT(DISTINCT company) AS media_companies
FROM layoffs_staging
WHERE industry = 'media';
```
Output:

<img width="101" alt="Screenshot 2025-01-08 at 1 53 41 PM" src="https://github.com/user-attachments/assets/44043732-09c5-428e-8794-9fbcd8d9955e" />

The additional query below reveals that Netflix only raised funds in 2022.

```sql
SELECT *
FROM layoffs_staging
WHERE company = 'Netflix'
ORDER BY funds_raised_millions DESC;
```

Output formated in Excel:

<img width="694" alt="Screenshot 2025-01-08 at 3 10 33 PM" src="https://github.com/user-attachments/assets/0a501c86-5018-4103-bad3-00c1e5697eea" />


Here's the breakdown:

- Media contains 65 companies and altogether raised $504,783.2 in funds.
- With a total of $487,600, Netflix raised 96.6% of those funds!
- Recall the output of question 1 where we found that media only made the top 5 for funds in 2022.
- Netflix only has entries for 2022 and makes up 96.6% of the total media funds. From this we can deduce that Netfix is the sole reason that media only made the
top 5 for the year 2022.

### 4. Did this leading company layoff a smaller percent of there employees compared to other companies?

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
```

Output of CTE:

<img width="296" alt="Screenshot 2025-01-08 at 2 08 28 PM" src="https://github.com/user-attachments/assets/d7b333d0-14eb-44c4-b105-f3a8c8775d63" />

Here's the breakdown:

- The inner query groups by company and finds the average percent of employees that was laid off.
- I then put this query inside of a CTE to assign ranks to each company based on layoff percentages, with a higher rank indicating a larger percentage of the company was laid off.
- If executed without the WHERE statement to target Netlix, the output shows a total of 118 ranks.
- With the WHERE statement, I found that Netflix ranked 116 out of 118 ranks, making them one of the companies with the lowest percentage laid off!

### 5. Throughout the companies, is there a correlation between layoffs and funds raised?

<img width="694" alt="Screenshot 2025-01-13 at 4 37 31 PM" src="https://github.com/user-attachments/assets/5acbe794-deb8-4df2-b689-715076ee6999" />

Here's the breakdown: 

- Almost all of the companies that raised lots of funds fall below the average percent laid off line.
- Most companies fall directly on the average funds line and below the average percent laid off line.
- This suggests that if the funds are very high then the company probably has low layoffs as well.
- However, since most companies fall below the average percent laid off line and directly on the average funds line, low layoffs is not a strong indication of high funds.

The additional query below verifies that a lot more companies have below average layoff percentages then above average layoff percentages.

```sql
-- created temp table to group companies with below average layoff percentages and above average layoff percentages
CREATE TEMPORARY TABLE layoffs_bins
	WITH avg_funds_and_layoffs AS 
	(
		SELECT company, AVG(percentage_laid_off) AS average_laid_off
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
    
DROP TABLE layoffs_bins;
       
-- counting how many in each category
SELECT layoffs_and_funds, COUNT(layoffs_and_funds) AS category_count
FROM layoffs_bins
GROUP BY layoffs_and_funds;
```
Output:

<img width="201" alt="Screenshot 2025-01-08 at 3 57 57 PM" src="https://github.com/user-attachments/assets/a6c4a56e-0b54-4afc-b78a-6ea8b0b3d0fc" />

I further explored this correlation with the first 4 queries in this file. Click [here](https://github.com/AJ-Carp/Company-Funds-and-Layoffs-Project/blob/main/Project%20Queries/Additional_Info.sql) to check it out!


### 6. What are the top 5 companies and industries with the most layoffs per year?

```sql
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
```
Output formatted in Tableau:

<img width="789" alt="Screenshot 2025-01-07 at 12 46 44 PM" src="https://github.com/user-attachments/assets/6255d5b2-d046-4e5f-b92f-1be98ca5a28c" />

```sql
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
```

Output formatted in Tableau:

<img width="856" alt="Screenshot 2025-01-09 at 11 03 04 AM" src="https://github.com/user-attachments/assets/a2168ad9-9395-4bc3-a207-b662b95ace72" />

Here's the breakdown:

- Unlike are prevoius question, we are now looking at total layoffs rather then what percent of the company was laid off.
- The first graph shows the top 5 companies with most layoffs per year and the second shows the top 5 industries with most layoffs per year.
- Many big name companies made the top 5 for most layoffs. I expected this, as they have more employees.
- Notice many of the same industries that had high funds (question 1) also have lots of layoffs.
- Finally, we see that 2021 had the least amount of layoffs in both company and industry chart.

# Conclusions

### Insights
From the analysis, several general insights emerged:

1. **Industry that raised the most funds**: Media in 2022 alone made up 31.07% of the total funds raised for all 4 years and therefore rasied the most funds. Interestingly, media did not even make the top 5 for any other year.
2. **Company that raised the most funds**: Netflix takes the lead with more then 3 times the funds the runner up had! Unsuprisingly, Netflix is part of the media industry.
3. **Percent of total industry funds that leading company makes up**: Netflix only has entries for 2022 and makes up 96.6% of the total media funds. From this we can deduce that Netfix is the sole reason that media only made the top 5 for the year 2022. The craziest part is media contains a total of 65 companies!
4. **Layoffs for leading company compared to other companies**: I wrote my qeury to rank companies by percentage laid off with higher ranks denoting a lower percent laid off. Netflix ranked 116 out of 118 ranks, making them one of the companies with the lowest percentage laid off!
5. **Correlation between funds and layoffs**: Most companies have a below average layoff percentage and raised an average amount of funds. Also, the companies who raised very high funds are almost all below average in terms of layoffs. Therefore, low layoffs is not a strong indication of high funds, but high funds likely means low layoffs.
6. **Top 5 companies and industries with most layoffs per year**: Many big name companies made the top 5 for most layoffs. Also, many of the same industries that had high funds (question 1) also have lots of layoffs. Finally, 2021 had the least amount of layoffs in terms of both companies and industries.


