USE superstore


#Get an understanding of the dataset
SELECT * FROM shopee_final sf LIMIT 100



# Check the number of rows
SELECT COUNT(*) as no_of_rows
FROM shopee_final sf 

# Check for duplicates
SELECT idHash, idElastic , COUNT(*) as Number_of_counts
FROM shopee_final sf 
GROUP BY idHash, idElastic 
HAVING COUNT(*) > 1

# From the query above, it looks like they are no duplicates

# My analyis only cares about certain columns, so create a new table (since I dont want to mess with original data), and only keep the columns I care about

DROP TABLE IF EXISTS shoping_staged;

# Manually Creating Table as it is faster
CREATE TABLE shoping_staged (
    price_ori DOUBLE,
    delivery VARCHAR(50),
    category_detail VARCHAR(128),
    date_delivered VARCHAR(50),
    item_rating VARCHAR(50),
    price_actual DOUBLE,
    total_rating VARCHAR(50),
    total_sold VARCHAR(50),
    favorite VARCHAR(50)
) ENGINE=InnoDB;

INSERT INTO shoping_staged (price_ori, delivery, category_detail, date_delivered, item_rating, price_actual, total_rating, total_sold, favorite)
SELECT price_ori, delivery, item_category_detail, w_date, item_rating, price_actual, total_rating, total_sold, favorite
FROM shopee_final;


# Now the data we are interested in is in Shoping_staged table

SELECT * FROM shoping_staged
ORDER BY date_delivered 


# Things we need to change
# 1. Change the datetime type from string to datetime
# 2. Item_rating and total_rating for now look the same, I need to double check if one is just a duplicate
# 3. In Favorites, extract the number and fix N/A Values
# 4. Convert Price Actual, total_sold into numeric data types
# 5. Extract Cateogory, SubCategory 1, and SubCategory 2 From Category_detail

# See how the dates are
SELECT DISTINCT date_delivered
FROM shoping_staged ss 
# It is one digit even in the day

# Add a date time column
ALTER TABLE shoping_staged
ADD DeliveryDate DATE;

# Change into the right date format
UPDATE shoping_staged 
SET DeliveryDate = STR_TO_DATE(date_delivered, "%c/%e/%y")

# And now we remove the colun
ALTER TABLE shoping_staged 
DROP COLUMN date_delivered

# Check if it all works
SELECT * FROM shoping_staged
LIMIT 100


# Now we want to see if total_sold and total_rating are the same
SELECT SUM(same_or_not)
FROM
	(SELECT 
	CASE WHEN total_rating = total_sold THEN 0
	ELSE 1 END AS same_or_not
	FROM shoping_staged ss) AS test
	
# So there are 11 cases where they are not the same, lets investigate these
SELECT * FROM shoping_staged ss 
WHERE total_rating <> total_sold

# In those 11 places, it just seems like N/A values and NULL
# So next case is to handle

# This means we can remove the total_rating columns
ALTER TABLE shoping_staged 
DROP COLUMN total_rating


# Check if it all works
SELECT * FROM shoping_staged
LIMIT 100


# The last error reminds me that there are places where there NULL values are stores as N/A

SELECT * FROM shoping_staged ss 
WHERE delivery = 'N/A'
OR category_detail = 'N/A'
OR item_rating = 'No ratings yet'
OR total_sold = 'N/A'
OR favorite = 'N/A'


# Looks like favorite and item_ratings needs to be fixed, but lets make sure the others are good
SELECT * FROM shoping_staged ss 
WHERE delivery = 'N/A'
OR category_detail = 'N/A'
OR total_sold = 'N/A'
# yeah the other seems to be good

UPDATE shoping_staged 
SET item_rating = NULLIF(item_rating, 'No ratings yet'),
favorite = NULLIF(favorite, 'N/A')

# Check if it all works

SELECT * FROM shoping_staged ss 
WHERE delivery = 'N/A'
OR category_detail = 'N/A'
OR item_rating = 'No ratings yet'
OR total_sold = 'N/A'
OR favorite = 'N/A'

# Yep, they all look better now

SELECT * FROM shoping_staged
LIMIT 100

# One issue is that the total_sold has k in the end, lets look at those places
SELECT total_sold
FROM shoping_staged ss 
WHERE total_sold LIKE '%k'

DESCRIBE shoping_staged 

# Now lets try to fix it
SELECT total_sold, REPLACE(total_sold, 'k', '')
FROM shoping_staged ss 

# But the problem with this is that k means to multiply by 1000
SELECT total_sold, CAST(REPLACE(total_sold, 'k', '') AS double) * 1000
FROM shoping_staged ss 
WHERE total_sold LIKE '%k'

# Update the table
UPDATE shoping_staged 
SET total_sold = CAST(CAST(REPLACE(total_sold, 'k', '') AS double) * 1000 AS CHAR)
WHERE total_sold LIKE '%k'


SELECT total_sold
FROM shoping_staged ss 

# Now it all looks good, we can convert into a numeric type
#ALTER TABLE shoping_staged 
#MODIFY total_sold FLOAT;


# It looks like there was an error in row 1185
SELECT *
FROM
	(SELECT *, ROW_NUMBER() OVER () AS row_no
	FROM shoping_staged ss ) AS test
WHERE row_no = 1185

# It looks like the total_sold values are not NULL but jsut empty strings
SELECT *
FROM shoping_staged ss 
WHERE total_sold is NULL

# Yep thats the issue

SELECT * 
FROM shoping_staged ss 
WHERE total_sold = ''

UPDATE shoping_staged 
SET total_sold = NULLIF(total_sold, '')

# It works now


# Now it all looks good, we can convert into a numeric type
ALTER TABLE shoping_staged 
MODIFY total_sold FLOAT;

SELECT * from shoping_staged ss 

# We can also convert item rating to float
#ALTER TABLE shoping_staged 
#MODIFY item_rating FLOAT;

# Oh, it looks like there were also places where the value is N/A
SELECT * FROM shoping_staged ss 
WHERE item_rating = 'N/A'


# Here is updating to NUll
UPDATE shoping_staged 
SET item_rating = NULLIF(item_rating, 'N/A')

# Lets see if this works
ALTER TABLE shoping_staged 
MODIFY item_rating FLOAT;


SELECT * FROM shoping_staged ss 

DESCRIBE shoping_staged 

# Okay that seems to work now

# Now, I want to remove Favorite
SELECT favorite
FROM shoping_staged

# Only want the digit and the letter k
SELECT REGEXP_REPLACE(favorite, '[^0-9k]', '') AS digits_with_k
FROM shoping_staged;

# Now I do it to the whole thing
UPDATE shoping_staged
SET favorite = REGEXP_REPLACE(favorite, '[^0-9k]', '');

SELECT favorite
FROM shoping_staged


# Do the same where I multiply the ones with a  k with 1000
SELECT favorite, CAST(REPLACE(favorite, 'k', '') AS double) * 1000
FROM shoping_staged ss 
WHERE favorite LIKE '%k'


# Okay this works, so now update the table
UPDATE shoping_staged
SET favorite = CAST(CAST(REPLACE(favorite, 'k', '') AS double) * 1000 AS CHAR)
WHERE favorite LIKE '%k';


SELECT favorite
FROM shoping_staged


# Perfect, so now favorite looks good, now we can change it into a float
#ALTER TABLE shoping_staged
#MODIFY favorite FLOAT;

SELECT * FROM shoping_staged

#Looks like row 18892 is a problem,

SELECT *
FROM
	(SELECT *, ROW_NUMBER() OVER () AS row_no
	FROM shoping_staged ss ) AS test
WHERE row_no = 18892


# Okay, looks like there is also places where there is an empty string
UPDATE shoping_staged
SET favorite = NULLIF(favorite, '');


SELECT *
FROM
	(SELECT *, ROW_NUMBER() OVER () AS row_no
	FROM shoping_staged ss ) AS test
WHERE row_no = 18892



ALTER TABLE shoping_staged
MODIFY favorite FLOAT;


SELECT * FROM shoping_staged


# Okay, so now for the hard part,
# The category detail is in pieces and first word is Shopee, Second Word is The main cateogory Then it is category 1, and category 2

# I am going to use substring index for this


# Example for reference Shopee | Category | SubCategory1 | SubCategory2

SELECT MAX(LENGTH(`Main Category`)) FROM
	(SELECT
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(category_detail, '|', 2), '|', -1)) AS `Main Category`,
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(category_detail, '|', 3), '|', -1)) AS `Sub Category 1`,
		TRIM(SUBSTRING_INDEX(category_detail, '|', -1)) AS `Sub Category 2`
	FROM shoping_staged) AS test


# Perfect, this gets me exaclty what I want, just to make sure, I am going to change the table now
ALTER TABLE shoping_staged
ADD COLUMN main_category VARCHAR(50),
ADD COLUMN sub_category_1 VARCHAR(50),
ADD COLUMN sub_cateogory_2 VARCHAR(50)


UPDATE shoping_staged
SET main_category = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(category_detail, '|', 2), '|', -1)),
sub_category_1 = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(category_detail, '|', 3), '|', -1)),
sub_cateogory_2 = TRIM(SUBSTRING_INDEX(category_detail, '|', -1))



SELECT * FROM shoping_staged

# This looks great, I am now going to remove category_detail
ALTER TABLE shoping_staged
DROP COLUMN category_detail


SELECT * FROM shoping_staged






# One thing I do want to do is to check all character columns to see if anything is weird
SELECT DISTINCT (delivery)
FROM shoping_staged


# Change instance
UPDATE shoping_staged
SET delivery = 'Other'
WHERE delivery = '';

#Check
SELECT DISTINCT (delivery)
FROM shoping_staged

# Looks like it works


# Now I am going to look at the categories
SELECT main_category, COUNT(*) AS number_of_rows
FROM shoping_staged
GROUP BY main_category
ORDER BY number_of_rows 


# The categories look fine, no obvious duplicates or misinputs it seems like
SELECT sub_category_1, COUNT(*) AS number_of_rows
FROM shoping_staged
GROUP BY sub_category_1
ORDER BY number_of_rows 

# Same with subcatgory 1

SELECT sub_cateogory_2, COUNT(*) AS number_of_rows
FROM shoping_staged
GROUP BY sub_cateogory_2
ORDER BY number_of_rows

# It all looks good, there are too many to manually check so I just check the ones with fewer rows

SELECT * FROM shoping_staged


# Now I want to have new columns called sales which multiply price_actual with total_sold

SELECT (price_actual * total_sold) AS total_sales
FROM shoping_staged


# Change the Table
ALTER TABLE superstore.shoping_staged 
ADD COLUMN total_sales FLOAT

UPDATE superstore.shoping_staged 
SET total_sales = (price_actual * total_sold)


SELECT * FROM shoping_staged



# This is me seeing what really is favorite
SELECT COUNT(*) AS where_favorite_greater
FROM superstore.shoping_staged
WHERE favorite > total_sold


# Looks like about half the favorite is greater than the total sold
SELECT * FROM superstore.shoping_staged


# Add another column that is Discount, which is the (price_original - price_actual) / price_actual
SELECT ABS (ROUND((price_actual - price_ori)/price_ori,4) * 100)  AS discount_percentage
FROM superstore.shoping_staged ss 


# See if there are NULLS
SELECT price_ori, price_actual 
FROM superstore.shoping_staged
WHERE price_ori IS NULL

SELECT price_ori, price_actual 
FROM superstore.shoping_staged
WHERE price_actual IS NULL


SELECT *
FROM superstore.shoping_staged
WHERE price_ori IS NULL
AND price_actual IS NULL


# Okay there are some where they are both NULLS, we need to remove those entries
DELETE FROM superstore.shoping_staged
WHERE price_ori IS NULL AND price_actual IS NULL

# Okay, One assumption I am going to make is that if price_actual is NULL
# Then they sold it at the price original

UPDATE superstore.shoping_staged 
SET price_actual = price_ori 
WHERE price_actual IS NULL

# Now, I am going to run the total sales code again
UPDATE superstore.shoping_staged 
SET total_sales = (price_actual * total_sold)


SELECT *
FROM superstore.shoping_staged ss 
WHERE total_sales IS NULL


# Hmm, there are place where price_actual is 0, need to investigate this
SELECT * 
FROM superstore.shoping_staged ss 
WHERE price_ori <= 0 OR price_actual <= 0


# These seem like errors and almost all of them have no total_sold
# In a organizational setting, I would make sure to ask to get more information on this data
DELETE FROM superstore.shoping_staged 
WHERE price_ori <= 0 OR price_actual <= 0


SELECT *
FROM superstore.shoping_staged ss 
WHERE total_sales IS NULL

# This made sure to delete the places where total_sold and total_sales is NULL, so thats perfect

SELECT * FROM superstore.shoping_staged ss 

# More just looking at the data
SELECT COUNT(*) FROM superstore.shoping_staged ss 
WHERE sub_category_1 = sub_cateogory_2 

SELECT COUNT(*) FROM superstore.shoping_staged ss 

SELECT COUNT(DISTINCT main_category) AS no_of_categories
FROM superstore.shoping_staged ss 

# THeres 24 categories, thats not bad

SELECT COUNT(DISTINCT sub_category_1) AS no_of_categories
FROM superstore.shoping_staged ss 

# About 222 subcategory 1s

SELECT COUNT(DISTINCT sub_cateogory_2) AS no_of_categories
FROM superstore.shoping_staged ss 

# ABout 902 subcategories 2


# I think the dataset looks good and its ready to move into Tableau

