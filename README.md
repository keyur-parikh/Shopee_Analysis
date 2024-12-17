# Shopee_Analysis
This is a project that cleans data in SQL and uses clean data in Tableau to gain insights at the product level

Dataset is from a retail store in Malaysia called Shopee. The purpose of this dashboard was to conduct product analysis throughout each category and understanding the categories that generate the most revenue and which subcategories contribute most to the revenue. The dashboard is interactive and can be found here: https://public.tableau.com/shared/J8THNDKFQ?:display_count=n&:origin=viz_share_link

The SQL code demonstrates data cleaning, as the initial dataset consisted of unclean and non-standardized data.

In SQL, I first created another table as a staging table to ensure that none of the original data was changed or altered. 

After some initial inspecting and ensuring that the table contained no duplicates, I decided to only focus on only subsets of columns that I was interested in for further analysis.

My next step was to convert the columns into proper datatypes:
- The Deliver Date column was in string format, so I had to first alter the table to create a new column that accepts date time objects, and then converted the string object and added it into the new column that I created
- There were also some strings that should have been numeric datatypes, I first had to add some logic to ensure that any number that had k to be multiplied by 1000 as to ensure data integrity.

Then I had to convert some strings into NULL Values:
- There were some strings that were just empty strings rather than being considered NULL values, so I had to write logic to fix those.
- There were also some values that had the word 'N/A', I had to write logic to convert these into NULL Values

Then I had to extract new columns from category_detail, The main category and the sub categories were all in one string. I had to write some string manipulation logic to extract these information and then add new columns in the table to store these

I also calculated new fields from existing field, for example, I multiplied Product_Sales * Amount_Sold to get the Revenue generated from that product. 

Then finally do some additional data validation to ensure there were no errors and all the columns made logical sense. Removed rows that didn't have sufficient data for analysis. And assume that if there was no actual price, that original price should be used. 

