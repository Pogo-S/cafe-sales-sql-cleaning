-- Raw data :
SELECT * 
FROM dirty_cafe_sales;

-- Creating a backup of raw data to preserve original records :

CREATE TABLE `cleaning_sales` (
  `Transaction ID` text,
  `Item` text,
  `Quantity` int DEFAULT NULL,
  `Price Per Unit` double DEFAULT NULL,
  `Total Spent` text,
  `Payment Method` text,
  `Location` text,
  `Transaction Date` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO cleaning_sales
SELECT * 
FROM dirty_cafe_sales;

SELECT *
from cleaning_sales;

-- removing duplicates :

SELECT COUNT(DISTINCT `Transaction ID`), COUNT(`Transaction ID`)
FROM cleaning_sales;
# Checked 'Transaction ID' is already unique, so skipping de-duplication

-- replacing placeholder values like 'ERROR', 'UNKNOWN', or empty strings with NULLs :

WITH Placeholder_values AS
(
SELECT *
FROM cleaning_sales
WHERE
item IN ('', 'Unknown', 'Error') OR
`Price Per Unit` = 0 OR
`Total Spent` IN ('', 'Unknown', 'Error') OR
`Payment Method` IN ('', 'Unknown', 'Error') OR
Location IN ('', 'Unknown', 'Error') OR
`Transaction Date` IN ('', 'Unknown', 'Error')
) SELECT *
from Placeholder_values;

Update cleaning_sales
Set
	`Item` = CASE WHEN `item` IN ('', 'Unknown', 'Error') THEN Null Else `item` END,
	`Price Per Unit` = CASE WHEN `Price Per Unit` = 0 THEN Null Else `Price Per Unit` END,
	`Total Spent` = CASE WHEN `Total Spent` IN ('', 'Unknown', 'Error') THEN Null Else `Total Spent` END,
	`Payment Method` = CASE WHEN `Payment Method` IN ('', 'Unknown', 'Error') THEN Null Else `Payment Method` END,
	`Location` = CASE WHEN `Location` IN ('', 'Unknown', 'Error') THEN Null Else `Location` END,
	`Transaction Date` = CASE WHEN `Transaction Date` IN ('', 'Unknown', 'Error') THEN Null Else `Transaction Date` END;

select *
from cleaning_sales;

-- Handling Missing Values which can be filled :

# used the one-to-one relationship between item and price to fill missing items, except where the price maps to multiple items
SELECT distinct(item),`price per unit`
FROM cleaning_sales;

/*  For my personal reference
Coffee 2 
Cake 3
Juice 3
Cookie 1
Salad 5
Smoothie 4
Sandwich 4
Tea 1.5
*/

# Checking 
WITH chck as 
(
Select *
from cleaning_sales
where 
	item = "Coffee" and `price per unit` = 2 or
    item = "Cake" and `price per unit` = 3 or
    item = "Cookie" and `price per unit` = 1 or
    item = "Salad" and `price per unit` = 5 or
    item = "Smoothie" and `price per unit` = 4 or
    item = "Sandwich" and `price per unit` = 4 or
    item = "Juice" and `price per unit` = 3 or
    item = "Tea" and `price per unit` = 1.5 
)SELECT DISTINCT(item), `price per unit`
from chck
order by item;

# Filling missing 'Item' names using known 1:1 mappings with 'Price Per Unit'
UPDATE cleaning_sales
SET item = CASE 
	WHEN item is null and `price per unit` = 1 THEN "Cookie"
	WHEN item is null and `price per unit` = 1.5 THEN "Tea"
    WHEN item is null and `price per unit` = 2 THEN "Coffee"
    WHEN item is null and `price per unit` = 5 THEN "Salad"
    ELSE item
END;

/*
NOTE : For prices like 3 and 4, multiple items share the same price (e.g: Cake/Juice and Sandwich/Smoothie)
	   because of this one-to-many relationship, it's not possible to accurately fill the missing item names using price alone.
	   These rows have been left as NULL to preserve data integrity and avoid incorrect assumptions.
*/


SELECT *
FROM cleaning_sales; 

-- Filling missing 'Total Spent' values using Quantity × Price Per Unit
# checking is there any null value for `Quantity` and we do know for `price per unit` from out last steps
Select Quantity
FROM cleaning_sales
WHERE Quantity IS NULL;

# checking how many null values are there in `total spend`
SELECT COUNT(*) 
FROM cleaning_sales
WHERE `Total Spent` IS NULL;
# Result: 462 missing values

-- Imputed 462 missing 'Total Spent' values using Quantity × Price Per Unit to maintain consistency and enable accurate financial analysis

-- Previewing what the expected 'Total Spent' should look like
-- This step confirms our formula is working before we update anything
SELECT 
  Item, 
  Quantity,
  `Price Per Unit`,
  `Total Spent`, 
  FORMAT(Quantity * `Price Per Unit`, 1) AS Expected_Total
FROM cleaning_sales
WHERE `Total Spent` IS NULL
LIMIT 20;

#Updating
# Applies to all rows; only mismatched or null values get updated
UPDATE cleaning_sales
SET `Total Spent` = FORMAT(quantity * `Price Per Unit`,1 );

SELECT `Total Spent`
FROM cleaning_sales;

-- As our `Price Per Unit` is of type DOUBLE and `Total Spent` is TEXT by default, 
# it's important to convert them to DECIMAL for accurate financial analysis.

SELECT *
FROM cleaning_sales
WHERE CAST(`Price Per Unit` AS DECIMAL(5,2)) IS NULL
   OR CAST(`Total Spent` AS DECIMAL(5,2)) IS NULL;
# Result: 0 rows returned — safe to proceed.

-- Modifying `Price Per Unit` to DECIMAL(5,2)
ALTER TABLE cleaning_sales
MODIFY COLUMN `Price Per Unit` DECIMAL(5,2);

-- Modifying `Total Spent` to DECIMAL(5,2)
ALTER TABLE cleaning_sales
MODIFY COLUMN `Total Spent` DECIMAL(5,2);
-- 🔍 Exploring distinct values in remaining columns
SELECT DISTINCT(`Payment Method`) FROM cleaning_sales;
SELECT DISTINCT(Location) FROM cleaning_sales;
SELECT DISTINCT(`Transaction Date`) FROM cleaning_sales;

-- Observation:
# These columns were already cleaned earlier — placeholders like 'Unknown', 'Error', and empty strings were replaced with NULL.
# Now only valid values or NULL remain.

# 'Payment Method' includes: 'Credit Card', 'Cash', 'Digital Wallet', and NULL.
# 'Location' includes: 'In-store', 'Takeaway', and NULL.
# 'Transaction Date' values are already in the correct 'YYYY-MM-DD' format, with only NULLs remaining.

-- Converting `Transaction Date` from TEXT to DATE datatype for better date-based analysis
ALTER TABLE cleaning_sales
MODIFY COLUMN `Transaction Date` DATE;

-- Final check to confirm changes
SELECT * FROM cleaning_sales;
DESC cleaning_sales;


--  Data cleaning complete!
/* 
- All placeholder values handled
- Nulls filled where applicable
- Data types standardized for accuracy
- Table `cleaning_sales` is now ready for analysis and visualization
*/