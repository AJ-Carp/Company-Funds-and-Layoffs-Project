-- creating staging table
CREATE TABLE layoffs_staging(
   company               VARCHAR(29) NOT NULL 
  ,location              VARCHAR(16) NOT NULL
  ,industry              VARCHAR(15)
  ,total_laid_off        INTEGER 
  ,percentage_laid_off   NUMERIC(6,4)
  ,date                  VARCHAR(20) 
  ,stage                 VARCHAR(14)
  ,country               VARCHAR(20) NOT NULL
  ,funds_raised_millions NUMERIC(10,4)
  ,row_id                INTEGER -- adding row_id to help with the removal of dupes
);

INSERT layoffs_staging
SELECT *, ROW_NUMBER() OVER()
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- removing dupes
DELETE FROM layoffs_staging
WHERE row_id IN (
SELECT row_id
FROM
(SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging) AS sub
WHERE row_num > 1);

-- standardizing
UPDATE layoffs_staging 
SET company = TRIM(company);


SELECT *
FROM layoffs_staging
WHERE company LIKE 'Clear%'
ORDER BY 1;

UPDATE layoffs_staging
SET company = 'ClearCo'
WHERE company = 'Clearco'
OR company = 'Clear'
OR company = 'Clearbanc';


SELECT DISTINCT(industry)
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging
WHERE industry LIKE 'Crypto%'
ORDER BY 1;

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(Country)
FROM layoffs_staging
ORDER BY country;

UPDATE layoffs_staging
SET Country = 'United States'
WHERE Country = 'United States.';

SELECT DISTINCT(location)
FROM layoffs_staging
ORDER BY location;

SELECT DISTINCT(stage)
FROM layoffs_staging
ORDER BY stage;

SELECT date, STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging;

UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;

-- NULLS and blanks
SELECT *
FROM layoffs_staging;

SELECT DISTINCT(industry)
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging 
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



SELECT DISTINCT(stage)
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging
WHERE stage IS NULL;

SELECT *
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE t1.stage IS NULL 
AND t2.stage IS NOT NULL;


-- removing uneeded data
DELETE FROM layoffs_staging 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_staging
DROP COLUMN row_id;




