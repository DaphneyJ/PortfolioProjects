-- Cleaning Data

SELECT *
FROM layoffs;

-- Create a copy of the table before making edits 
CREATE TABLE layoffs_copy
LIKE layoffs; 
 
 INSERT layoffs_copy
 SELECT *
 FROM layoffs;

-- check new table
SELECT *
FROM layoffs_copy;


-- Remove Duplicates: 

-- identify the duplicates  
WITH duplicate_cte AS (
SELECT *, 
row_number() over(partition by company, location, industry, `date`, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions) AS row_name
FROM layoffs_copy
)
SELECT * 
FROM duplicate_cte
WHERE row_name > 1;

-- verify duplicates
SELECT *
FROM layoffs_copy
WHERE company = 'Yahoo';

-- create new table with new row to delete duplicates
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_name` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_copy2;

INSERT INTO layoffs_copy2
SELECT *, 
row_number() over(partition by company, location, industry, `date`, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions) AS row_name
FROM layoffs_copy;

SELECT * 
FROM layoffs_copy2
WHERE row_name > 1;

-- disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- delete duplicates
DELETE
FROM layoffs_copy2 
WHERE row_name > 1;

-- verify deletion
SELECT *
FROM layoffs_copy2 
WHERE row_name > 1;

-- Standardizing Data:

-- remove spaces 
SELECT DISTINCT company, TRIM(company)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company = TRIM(company);

-- combine groups that are the same but have different spellings
SELECT DISTINCT industry 
FROM layoffs_copy2
ORDER BY 1;

SELECT * 
FROM layoffs_copy2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- verify change 
SELECT DISTINCT industry 
FROM layoffs_copy2
ORDER BY 1;

-- chceking other columns for mistakes
SELECT DISTINCT location 
FROM layoffs_copy2
ORDER BY 1;

SELECT DISTINCT country 
FROM layoffs_copy2
ORDER BY 1;

-- fix mispellings 
SELECT DISTINCT country,  TRIM(TRAILING '.' FROM country)
FROM layoffs_copy2
WHERE country LIKE 'United St%';

UPDATE layoffs_copy2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United St%';

-- Changing Data Types
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_copy2;

-- change date format
UPDATE layoffs_copy2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- change data type
ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;


-- Remove Missing Values:
SELECT *
FROM layoffs_copy2
WHERE industry IS NULL or industry = "";

UPDATE layoffs_copy2
SET industry = NULL
WHERE industry = "";

SELECT *
FROM layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;   
    
UPDATE layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_copy2
WHERE industry IS NULL;
 
 
-- Remove irrelevant columns 
DELETE 
FROM layoffs_copy2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL; 

SELECT *
FROM layoffs_copy2;

ALTER TABLE layoffs_copy2
DROP COLUMN row_name;

SELECT *
FROM layoffs_copy2


