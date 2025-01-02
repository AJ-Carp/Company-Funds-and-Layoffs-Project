# Introduction
As job hunting grows more challenging, I started to consider whether data analysis could enhance my chances of securing a position by examining historical layoff data. Through this project, I aim to uncover key factors contributing to workforce reductions, as well as identify companies and industries that might offer better opportunities.

🚿 Data Cleaning? Check it out here: [Project_queries](https://github.com/AJ-Carp/Data-Science-Job-Analysis-Project/tree/main/Project_queries) (change this link)

🔍 SQL queries? Check them out here: [Project_queries](https://github.com/AJ-Carp/Data-Science-Job-Analysis-Project/tree/main/Project_queries) (change this link)

📊 Tableau Dashboard? Check it out here: [Dashboard] (add link)
# Questions

1. Which industry raised the most funds?
2. Which company raised the most funds?
3. Is there a correlation between the leading company and industry for funds raised?
4. Did this leading company have significantly higher or lower amount of layoffs then other companies?
5. 

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
		SELECT YEAR(date) AS year, Industry, ROUND(SUM(funds_raised_millions),0) AS sum_funds
		FROM layoffs_staging 
		WHERE funds_raised_millions IS NOT NULL AND YEAR(date) IS NOT NULL AND Industry IS NOT NULL
		GROUP BY YEAR(date), Industry
	)
	SELECT *, ROW_NUMBER() OVER(PARTITION BY year ORDER BY sum_funds DESC) AS row_num
	FROM (
		SELECT sum_for_industry_year.*, sum_funds_for_year, sum_funds/sum_funds_for_year*100 AS `sum_funds_%_of_total_for_year`,
			SUM(sum_funds) OVER() AS all_total,(sum_funds/SUM(sum_funds) OVER())*100 AS `sum_funds_%_of_all_years_total`
		FROM sum_for_industry_year 
		JOIN
			(SELECT YEAR(date) AS year, ROUND(SUM(funds_raised_millions),0) AS sum_funds_for_year
			FROM layoffs_staging
			WHERE funds_raised_millions IS NOT NULL AND YEAR(date) IS NOT NULL AND Industry IS NOT NULL 
			GROUP BY YEAR(date)) AS sub
		ON sub.year = sum_for_industry_year.year) AS sub2
	ORDER BY year DESC, sum_funds DESC
)
SELECT *
FROM top_5_per_year
WHERE row_num <= 5;
```
Output of query formated in Excel:

<img width="1166" alt="Screenshot 2025-01-02 at 9 08 28 AM" src="https://github.com/user-attachments/assets/63a37d90-424e-4f86-a37f-b3dd98db4d51" />


Here's the breakdown:
- In our first 2 columns, the top 5 industries leading in funds for each year are shown.
- In the 3rd column the sum of funds for each undustry per year is shown. Then in the 4th column the sum of funds for the whole year is shown.
- The 5th column shows what percent of funds each industry makes up for each year.
- Finally, the 6th column shows the total sum of all funds for all 4 years. Then in the last column we see that media in 2022 alone makes up 31% of the whole total, clearly indicating that media is our winner.
  

### 2. Which company raised the most funds? 
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


### 3. Is there a correlation between the leading company and industry for funds raised?


```sql
-- location where most of media in 2022 made funds
SELECT location, SUM(funds_raised_millions) AS sum_of_funds
FROM layoffs_staging
WHERE industry = 'media' AND YEAR(date) = 2022
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;
```
Output of query formated in Excel:

<img width="181" alt="Screenshot 2025-01-02 at 10 26 34 AM" src="https://github.com/user-attachments/assets/7f0201be-96bc-4246-bd33-3186a183932c" />

Here's the breakdown:
- This qeury returns the locations where most of the funds were raised by the media industry in 2022.
- It is ordered descending by sum_of_funds and so we can cleary see the San Fransisco Bay area raised the most.

This additional query connects everything together regarding the correlation between Netlfix and the media industries high funds in 2022.
```sql
-- most funds raised in media
SELECT *
FROM layoffs_staging
WHERE industry = 'media'
ORDER BY funds_raised_millions DESC;
```
Output of query formated in Excel:

<img width="1264" alt="Screenshot 2025-01-02 at 10 34 04 AM" src="https://github.com/user-attachments/assets/9f0ac649-1c05-4281-915d-9486e7a7d833" />

Here's the breakdown:
- This query shows all data for the media industry ordered descending by the funds_raised_millions.
- Highlighted in green we see Netflix under company, SF Bay Area under location, media under industry, 2022 under date and very high funds under funds_raised_millions.



### 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.
```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
Here's a breakdown of the results for top paying skills for Data Analysts:
- **High Demand for Big Data & ML Skills:** Top salaries are commanded by analysts skilled in big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy), reflecting the industry's high valuation of data processing and predictive modeling capabilities.
- **Software Development & Deployment Proficiency:** Knowledge in development and deployment tools (GitLab, Kubernetes, Airflow) indicates a lucrative crossover between data analysis and engineering, with a premium on skills that facilitate automation and efficient data pipeline management.
- **Cloud Computing Expertise:** Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) underscores the growing importance of cloud-based analytics environments, suggesting that cloud proficiency significantly boosts earning potential in data analytics.

| Skills        | Average Salary ($) |
|---------------|-------------------:|
| pyspark       |            208,172 |
| bitbucket     |            189,155 |
| couchbase     |            160,515 |
| watson        |            160,515 |
| datarobot     |            155,486 |
| gitlab        |            154,500 |
| swift         |            153,750 |
| jupyter       |            152,777 |
| pandas        |            151,821 |
| elasticsearch |            145,000 |

*Table of the average salary for the top 10 paying skills for data analysts*

### 5. Most Optimal Skills to Learn

Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.

```sql
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```

| Skill ID | Skills     | Demand Count | Average Salary ($) |
|----------|------------|--------------|-------------------:|
| 8        | go         | 27           |            115,320 |
| 234      | confluence | 11           |            114,210 |
| 97       | hadoop     | 22           |            113,193 |
| 80       | snowflake  | 37           |            112,948 |
| 74       | azure      | 34           |            111,225 |
| 77       | bigquery   | 13           |            109,654 |
| 76       | aws        | 32           |            108,317 |
| 4        | java       | 17           |            106,906 |
| 194      | ssis       | 12           |            106,683 |
| 233      | jira       | 20           |            104,918 |

*Table of the most optimal skills for data analyst sorted by salary*

Here's a breakdown of the most optimal skills for Data Analysts in 2023: 
- **High-Demand Programming Languages:** Python and R stand out for their high demand, with demand counts of 236 and 148 respectively. Despite their high demand, their average salaries are around $101,397 for Python and $100,499 for R, indicating that proficiency in these languages is highly valued but also widely available.
- **Cloud Tools and Technologies:** Skills in specialized technologies such as Snowflake, Azure, AWS, and BigQuery show significant demand with relatively high average salaries, pointing towards the growing importance of cloud platforms and big data technologies in data analysis.
- **Business Intelligence and Visualization Tools:** Tableau and Looker, with demand counts of 230 and 49 respectively, and average salaries around $99,288 and $103,795, highlight the critical role of data visualization and business intelligence in deriving actionable insights from data.
- **Database Technologies:** The demand for skills in traditional and NoSQL databases (Oracle, SQL Server, NoSQL) with average salaries ranging from $97,786 to $104,534, reflects the enduring need for data storage, retrieval, and management expertise.

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

