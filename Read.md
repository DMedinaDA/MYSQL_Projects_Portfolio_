Data Cleaning Project: Layoffs Dataset

## Overview
This project focuses on cleaning a dataset related to layoffs across various companies. The goal is to prepare the data for analysis by removing duplicates, standardizing entries, handling null values, and ensuring data integrity.

## Key Steps

1. **Remove Duplicates**: 
   - Utilized Common Table Expressions (CTEs) to identify and eliminate duplicate records based on key attributes such as company name, industry, and date.

2. **Standardize Data**:
   - Trimmed whitespace from company names and standardized industry classifications (e.g., grouping 'cryptocurrency' under 'Crypto').

3. **Handle Null Values**:
   - Identified and filled null values in critical columns using JOIN operations to pull relevant data from existing records.

4. **Data Integrity Checks**:
   - Ensured that all columns were correctly formatted, including converting date strings into proper DATE types.

5. **Final Cleanup**:
   - Removed unnecessary columns and rows with unreliable data to finalize a clean dataset ready for exploratory analysis.

## Technologies Used
- MySQL for database management and data manipulation.
- SQL queries for data cleaning and transformation processes.

## Conclusion
The cleaned layoffs dataset is now structured for further analysis, allowing for insightful visualizations and reports on trends in layoffs across industries.
