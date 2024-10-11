## US Household Income Data Cleaning & US Household Income Exploratory Data Analysis 


Select *
From us_project.us_household_income;

Select * 
FROM us_project.us_household_income_statistics;

ALTER TABLE us_project.us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`; ## issue in id column, not easy to read, commone import issue 

Select COUNT(id)
From us_project.us_household_income;

Select COUNT(id)
FROM us_project.us_household_income_statistics;


Select id,COUNT(id)
From us_project.us_household_income    ## Start by removing duplicates, sub query  
group by id
having COUNT(id) > 1;

SELECT *
FROM (
Select row_id,
  id, 
  ROW_NUMBER() OVER (Partition by id order by id) row_num
  FROM us_project.us_household_income
) duplicates 
WHERE row_num > 1;                                 ## data we need to delete 




DELETE FROM us_household_income
WHERE row_id IN (
SELECT row_id
FROM (
Select row_id,
  id, 
  ROW_NUMBER() OVER (Partition by id order by id) row_num
  FROM us_project.us_household_income
) duplicates 
WHERE row_num > 1);    

## DATA Delete 

Select id,COUNT(id)
From us_project.us_household_income_statistics    ## Doing the same process now for the next table, no duplicates found   
group by id
having COUNT(id) > 1;


Select DISTINCT State_Name
From us_project.us_household_income
order by 1; 

UPDATE us_project.us_household_income
SET state_name = 'Georgia'
WHERE state_name = 'georia'; 


UPDATE us_project.us_household_income
SET state_name = 'Alabama'
WHERE state_name = 'alabama'; 


Select DISTINCT State_ab
From us_project.us_household_income
order by 1; 

Select *
From us_project.us_household_income
WHERE County = 'Autauga County' 
order by 1 ;                                   ## small error 




UPDATE us_household_income
SET place = 'Autaugaville' 
WHERE county = 'Autauga County' 
AND city = 'Vinemont';



SELECT type, COUNT(type)
From us_project.us_household_income
GROUP BY type
;


  UPDATE us_household_income
  SET type = 'Borough'
  WHERE type = 'Boroughs';

SELECT ALand, AWater
From us_project.us_household_income  
WHERE (Awater = 0 OR Awater = '' OR Awater IS NULL) 
AND  ( Aland = 0 or Aland = '' OR Aland IS NULL ) ;


## Change name of Column 
## Removed duplicates 
## issues in state names, manually changed 
## Found missing values and changes those 
## Clean data set via gov


## US Household Income Exploratory Data Analysis

Select *
From us_household_income_statistics;

SELECT *
FROM us_household_income
; 


SELECT State_Name, ALand, Awater
FROM us_project.us_household_income;


SELECT State_Name, SUM(ALand), sum(Awater)        ## Largest land mass, output TX,CA,MI 
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 desc;

SELECT State_Name, SUM(ALand), sum(Awater)        ## Largest water MasS           
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC;


SELECT State_Name, SUM(ALand), sum(Awater)        ## TOP 10 LARGEST STATES BY LAND 
FROM us_project.us_household_income                ## CHANGE TO 'ORDER BY BY 3' TO FIND LARGEST BY WATER 
GROUP BY State_Name
ORDER BY 2 desc
LIMIT 10; 
                                                ## Join tables 
                                                ## When data was imported we had all the house_income_statistics, but not all the income data
                                                ## Right join, we want all from stats then pull from income if all is not there leave it blank, then filter 

SELECT * 
FROM us_household_income u
JOIN us_household_income_statistics us
   ON u.id = us.id; 


SELECT * 
FROM us_household_income u
 RIGHT JOIN us_household_income_statistics us      ## alot of missing data not populated, we may need to fix or fix the excel sheet or get rid of the data. We will not do anything, use a inner join  
   ON u.id = us.id 
  WHERE u.id is NULL;  
  
  
SELECT * 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us            ## Filter out the Mean, some states not reporting. Start looking a bit more into the data 
   ON u.id = us.id
   WHERE mean <> 0;

  
  SELECT u.State_Name, County , Type, `Primary`, mean, median
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
   WHERE mean <> 0;                                    ## this is most of what we will work with, alot of catergorical data 

  
    SELECT u.State_Name, AVG(mean), AVG(median)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY  u.State_Name;
    
    SELECT u.State_Name, round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY  u.State_Name
  ORDER BY 2;                             ## By state lowest household income to highest use the order by 2, shows households that make the least in US 
  # LIMIT 5                              ## Limit to show the 5 lowest states 
										
                                        
SELECT u.State_Name, round(AVG(mean),1), round(AVG(median),1)          ## We have the highest avg income , use limit to change what you see  
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY  u.State_Name 
  ORDER BY 2 DESC
  LIMIT 20; 
                         
	
    SELECT u.State_Name, round(AVG(mean),1), round(AVG(median),1)                      #Order by is important here, we can change what we see by use '3', gives us which salary shows up the most
FROM us_project.us_household_income u                                                ## Change to ASC to find the lowest salary made in a household 
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY  u.State_Name    
  ORDER BY 3 DESC
  LIMIT 20;
                         

                                          

SELECT u.State_Name, round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY  u.State_Name
  ORDER BY 3 DESC
  LIMIT 10 ;                             ##   Salary that shows up the most, high median, to see lowest change to ASC 
                                          ## high earners above the avg income 
                                           
SELECT type, round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY type
  ORDER BY 2 DESC;                           
  
  ## order by 'type' where what kind of area ppl live in
  
  
  SELECT type, COUNT(TYPE),
  round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY 1 
  order by 3 desc;                          
  
  ## Use COUNT to see how many there where, confirm nothing fishy going on with the data. 
  
  
    
  SELECT type, COUNT(TYPE),
  round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY 1 
  order by 4 desc;                          ## Take a look at median, shows what type of place is home households making alot of money 
    
    
    ## very low income coming from 'type' places labeled urban and community, lets see what states we see this in more. 
  
  
  Select * 
  from us_household_income                  ## output= PR-low income households 
  where type = 'Community';




## We need to filter outliers, get rid of the low counted 'type'. take a look at the higher value type data 
  

   
  SELECT type, COUNT(TYPE),
  round(AVG(mean),1), round(AVG(median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us    
   ON u.id = us.id
     WHERE mean <> 0
  GROUP BY 1 
  Having Count(type) > 100
  order by 4 desc;     
  
  
                                           
                                           
  select * 
  from us_project.us_household_income u
  JOIN us_project.us_household_income_statistics us 
       ON u.id = us.id; 
  
## I want to see the income levels in the big cities in certain states. 



select u.State_Name, city, ROUND(AVG(MEAN),1)
from us_project.us_household_income u
  JOIN us_project.us_household_income_statistics us 
       ON u.id = us.id 
  GROUP BY u.state_name, city; 

## Now we have the states and cities but lets order this by city, start with highest avg household income city

select u.State_Name, city, ROUND(AVG(MEAN),1)
from us_project.us_household_income u
  JOIN us_project.us_household_income_statistics us 
       ON u.id = us.id 
  GROUP BY u.state_name, city
  order by 3 desc;

## Do some more digging and look at median , there may be a cap to reported income 

select u.State_Name, city, ROUND(AVG(MEAN),1), Round(AVG(median),1)
from us_project.us_household_income u
  JOIN us_project.us_household_income_statistics us 
       ON u.id = us.id 
  GROUP BY u.state_name, city
  order by 3 desc;

# We took a look at the area of land and water. Inner join used and a Left join to id there was missing data.
# found dirty data witht he mean of zero,  which mean not reported properly.
# At a state level we look at the highest,lowest and avg. Limit 20 to see top 20.
# Took a look at the 'Type' different type of areas we saw.
# Last we took a look at State_name and cities and found some very wealthy places. 
# just dove straight in, found some intresting aggregation and unique info. 






















