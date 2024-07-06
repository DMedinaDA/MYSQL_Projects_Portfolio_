## Exploratory Data Analysis 

## Gained insight on laid_off column 
## Company Info, and when layoff started (years)
## Checked per month lay off 
## Mutliple CTEs in Company 


SELECT * 
FROM layoffs_staging3;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;          ## Some company laid 1200 ppl off in one day, 1% would mean the whole company went under

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1;   ## Do we see any companys we know, just being curious about it 

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
order by total_laid_off desc;    ## 2434 people laid off from a constr. company 


SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
order by funds_raised_millions desc;   ## lots of funding but still went under 

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging3
GROUP BY company
order by 2 desc;                         ## 2 = SUM(total_laid_off)


SELECT MIN(date), MAX(date)                    ## take a look at the date ranges-2020-03-11 to 2023-03-06
from layoffs_staging3;


SELECT country, SUM(total_laid_off) 
FROM layoffs_staging3
GROUP BY country
order by 2 desc;                        
 
 ## alot of layoffs in the US 
 
 SELECT YEAR(date), SUM(total_laid_off) 
FROM layoffs_staging3
GROUP BY YEAR(date)
order by 1 desc;                        ### we can see the years and the layoffs for those years 


SELECT YEAR(date), SUM(total_laid_off) 
FROM layoffs_staging3
GROUP BY YEAR(date)
order by 1 desc;  



SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
order by 2 desc;   # which had the most, large company layoffs
 

SELECT company, SUM(percentage_laid_off)     ## using SUM may not be best for this data because % refer to a % of the compan, may not be relevant.
FROM layoffs_staging3
GROUP BY company
order by 2 desc; 




SELECT  substring(date,6,2) AS 'MONTH'
FROM layoffs_staging3;


##  Lets take a look at the progression of layoffs, a rolling sum--keeps tracks--
## start at earliest of layoffs  and do rolling sum until the end of these layoffs 
## start with month 


SELECT  substring(date,6,2) AS 'MONTH',SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY `MONTH`;


## issue only shows months, we need to change where it gives year and month
## change the substring(1,7) 



SELECT  substring(date,1,7) 'MONTH',SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY `MONTH`;

## ^^ too messy, need to order to get clearer view, group by substring to start a better rolling total(SUM) 

SELECT  substring(date,1,7) AS `MONTH` , SUM(total_laid_off)
FROM layoffs_staging3
where substring(date,1,7) IS NOT NULL 
GROUP BY  `MONTH` 
ORDER BY 1 ASC ; 


# we  are takinglayoffs from 1st month and so on and grouping those then the following year 
## now we can do the rolling sum, use cte 
  

SELECT  substring(`date` ,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
where substring(date,1,7) IS NOT NULL 
GROUP BY  `MONTH` 
ORDER BY 1 ASC 
;  

WITH Rolling_total AS
(      
SELECT  substring(`date` ,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
where substring(date,1,7) IS NOT NULL 
GROUP BY  `MONTH` 
ORDER BY 1 ASC 
)
   Select `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) as Rolling_total
   FROM Rolling_total; 

## what we get we the layoffs then the next total was added along with the month of each total layoffs 
## Shows month by month progession, we can narrow down with country if need and see the range of months that had the most layoffs 


SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
order by 2 desc; 

## start point, find company and date group by year, use this to start a ranking of who(companies) laid the most people off 


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
order by company ASC; 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
order by 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(Select *,
 DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5
;

## lets remove the null, and show the ranking. Biggest layoffs by years , company shown 
## added second CTE to query off that, top 5 company that laid ppl off by year 
## good snapshot that can have many changes to show more, industry, months, large tech took big hits 
