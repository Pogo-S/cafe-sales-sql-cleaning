-- Raw data
SELECT * 
FROM dirty_cafe_sales;

-- Creating a duplicate table to keep the raw data safe

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

-- removing duplicates
SELECT COUNT(DISTINCT `Transaction ID`), COUNT(`Transaction ID`)
FROM cleaning_sales;
-- skipped, since all values in 'Transaction ID' are already unique

-- replacing placeholder values like 'ERROR', 'UNKNOWN', and empty strings or 0 in numberic columns with NULLs

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

# Handling Missing Values which can be filled
-- used the one-to-one relationship between item and price to fill missing items, except where the price maps to multiple items
SELECT distinct(item),`price per unit`
FROM cleaning_sales;

/* 
Coffee 2 
Cake 3
Cookie 1
Salad 5
Smoothie 4
Sandwich 4
Juice 3
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

-- imputing missing item values using price-based logic where price uniquely identifies the item
UPDATE cleaning_sales
SET item = CASE 
	WHEN item is null and `price per unit` = 1 THEN "Cookie"
	WHEN item is null and `price per unit` = 1.5 THEN "Tea"
    WHEN item is null and `price per unit` = 2 THEN "Coffee"
    WHEN item is null and `price per unit` = 5 THEN "Salad"
    ELSE item
END;

-- 🕓 Progress checkpoint: 4:50 AM (3 July 2025)
