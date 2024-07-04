##Data Cleaning 
use world_layoffs; 

SELECT * 
FROM layoffs;

## 1. Remove Duplicates
## 2. Standardize the Data 
## 3. Null Values or blanks values 
## 4. Remove Any Columns 



CREATE TABLE layoffs_staging 
like layoffs;


SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

# begin the process of removing duplicates, assign a rownumber to filter out repeated data.
#A The CTE selects all columns from the layoffs_staging table and adds a new column row_num that
# assigns a row number to each row within the partition defined by the combination of columns\

SELECT *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date') AS  row_num 
FROM layoffs_staging;
 
 WITH duplicate_cte AS
 (
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, 
    industry, total_laid_off, percentage_laid_off, date, stage,
    country, funds_raised_millions
) AS row_num 
FROM layoffs_staging
)
select *
from duplicate_cte 
where row_num > 1; 


#  The first query assigns row numbers within a broader partition, while the CTE assigns row numbers within a more specific partition.
#  The outer query then selects only the rows that have a row_num greater than 1, which are considered duplicates within the specified partition.

SELECT * 
FROM layoffs_staging
WHERE company = 'casper'; 

# Moment where we delete uneeded rows--THEN HANDLE ERROR-CREATE NEW DB THEN DELETE/FILTER -
# one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column


WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, 
        industry, total_laid_off, percentage_laid_off, date, stage,
        country, funds_raised_millions 
        ORDER BY company
    ) AS row_num 
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;


#Ran into error so we adjust and go with new plan, 

#Create Table, assign data type and add 'rownum' 

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
##  Now we can see all the rows with a number, if more then 2 it may be uneeded data-filter with where clause--


SELECT * 
FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT *,
row_number() over(
partition by company, location,
 industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

## now that we have this we can delete rows were row_num is greater than 2

select * 
from layoffs_staging3
where row_num > 1; 


DELETE 
from layoffs_staging3
where row_num > 1; 


select * 
from layoffs_staging3;
   ## Update the layoffs 3 table has no duplicates 

 
 #Looks good, many other ways to remove but the data had us go down this route
 # Removed the duplicates ^^
 # Standarizing Data 

SELECT company, TRIM(company)
FROM layoffs_staging3;

update layoffs_staging3
set company = trim(company);

#  purpose of this query is to display both the original company name and the trimmed version side by side. 
# id any leading or trailing spaces that need to be removed.
# With the Update statment , he company column in the layoffs_staging2 table will have all leading and trailing spaces removed from the company names.

SELECT *
FROM layoffs_staging3;
## lets take a look at the data, deal with nulls 

SELECT distinct industry
FROM layoffs_staging3;

SELECT distinct industry
FROM layoffs_staging3
order by 1;                     
 ## This will show nulls, and other corrections needed-grouping industry--ex.crypto,cryptocurrency--

 SELECT *
FROM layoffs_staging3
where industry like 'Crypto%'; 

# finding all that having any term close to "crypto" it should all say crypto and not cryptocurrency--
# important when doing an exploratory data analysis, visualizing , dont want them to be in there own row or unique thing 
# which is what we dont want, we need them grouped together to accurately look at the data. 

UPDATE layoffs_staging3
SET industry = 'Crypto'
where industry like 'Crypto%'; 

-- Now they should all say "Crypto" run code and check update

 SELECT *
FROM layoffs_staging3
where industry like 'Crypto%';
 
 
## Now the industry column has been order so its all its own thing. The nulls will be solved.

SELECT distinct industry 
FROM layoffs_staging3;

 
SELECT * 
FROM layoffs_staging3;
 
-- check another column, lets look at location&country, use the order by 1 to find any repeated places. 

SELECT distinct location
FROM layoffs_staging3
order by 1;

SELECT distinct country 
FROM layoffs_staging3
order by 1;
 
## Error-An extra (.) was added to a country in the list- not good data, fix and update. 
 


SELECT distinct country, trim(country)
FROM layoffs_staging3
order by 1; 

# Alert-Trim alone will not fix this issue, use TRAILING along with trim to get rid of unwanted text, with this ex. its the 
# extra period (.) that was added to a certain country listed 

SELECT distinct country, trim(TRAILING '.' FROM country)
FROM layoffs_staging3
order by 1; 
-- now update to see results 

update layoffs_staging3
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
 
 --- 12 row(s) affected Rows matched: 4590  Changed: 12  Warnings: 0

SELECT * 
FROM layoffs_staging3;

# Time series 
# change dates column that are in text form 

SELECT date
FROM layoffs_staging3;

SELECT date,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging3;



SELECT `date` 
FROM layoffs_staging2
WHERE `date` NOT LIKE '__/__/____';

UPDATE layoffs_staging3
SET `date` = CASE
    WHEN `date` LIKE '%/%/%' THEN str_to_date(`date`, '%m/%d/%Y')
    WHEN `date` LIKE '%-%' THEN str_to_date(`date`, '%Y-%m-%d')
    -- Add more WHEN clauses for other formats
    ELSE NULL
END;

## This query checks the format of each date string and applies the appropriate str_to_date() function. If the format doesn't match any of the cases, it sets the value to NULL.
##Run a query to identify any invalid date strings that don't match the 'MM/DD/YYYY' format:
#many ways to format dates-- we will use str_to_date, helps us go from a string which is the text, to a date
# format and convert  above is the standard form for SQL, then update with new data  

UPDATE layoffs_staging
SET `date` = str_to_date(`date`, '%m/%d/%Y');

#it worked but now we found some nulls, refresh the schema and the data column is still defined as text
#when its in a date format, error met before but now we can do this and only on stage tables in future never the raw data table. 



ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

# TABLE HAS BEEN ALTERED NOW 

SELECT * 
FROM layoffs_staging3;

## So far, we fixed issues in the company column, issues fixed in idustry column
## country column had issues that where fixed, and column added to id rows with duplicates
## Next are handling the Null and Blanks values

SELECT * 
FROM layoffs_staging3
where total_laid_off is null; 


SELECT * 
FROM layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null;

SELECT distinct industry 
FROM layoffs_staging3;

# we dfound some nulls in the industry column 

SELECT*
FROM layoffs_staging3
where industry is null
or industry = '';

 
SELECT * 
FROM layoffs_staging3
WHERE company = 'Airbnb';

## we found matching info that could be used to fill the nulls

SELECT*
FROM layoffs_staging2
where company ='Airbnb';

## Join 
 
SELECT *
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

# We ran it but noting in our output, change query to find blanks, scroll over and you see T2 where we want to use those industry sectors
# to fill the blank/null cells 

SELECT*
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	on t1.company = t2.company 
    where (t1.industry is null or t1.industry = '')
    and t2.industry is not null; 


##  Better view below of what columns are being used. If its blank then we will populate with the correct data. 

    UPDATE layoffs_staging3 t1
    JOIN layoffs_staging3 t2
	on t1.company = t2.company 
SET t1.industry =  t2.industry
    where (t1.industry is null or t1.industry = '')
    and t2.industry is not null; 
    


# Table has been updated but we still see blanks, we will need to change each blank to a null 
# so the query can work. Set blanks to null then see change. 

UPDATE layoffs_staging3
SET industry = null 
where industry = '';
    
    ## 9 row(s) affected Rows matched: 9  Changed: 9  Warnings: 0
    
    UPDATE layoffs_staging3 t1
    JOIN layoffs_staging3 t2
	on t1.company = t2.company 
SET t1.industry =  t2.industry
    where t1.industry is null 
    and t2.industry is not null; 


select * 
From layoffs_staging3
where company = 'Airbnb';
## we can check and see it work, then next look at AirBnb, the null values have been filled 
    
select * 
From layoffs_staging3;
    
# Remove columns and rows  
    
    
 select * 
    FROM layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null;

    

Delete 
FROM layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null;


## we got rid of that data, we couldnt trust it, ran query to check. Finally we remove the row num to get our final clean data set!
## run the query and see those columns are gone 

ALTER TABLE layoffs_staging3
DROP COLUMN row_num; 

select * 
From layoffs_staging3

# Data clean, ready for Exp. process 
## 1. Remove Duplicates
## 2. Standardize the Data 
## 3. Null Values or blanks values 
## 4. Remove Any Columns 


