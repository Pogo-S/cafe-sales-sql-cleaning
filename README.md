# Cafe Sales SQL Cleaning Project

This project focuses on cleaning a raw and unstructured cafe sales dataset using SQL. The goal was to prepare the dataset for meaningful analysis by identifying and fixing inconsistencies, handling missing values, and ensuring appropriate data types for each column.

## Dataset

The original dataset was downloaded from [Kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and contains daily sales transactions from a fictional cafe. The dataset includes fields such as item sold, quantity, unit price, total amount, location type, payment method, and date.

## What Was Done

- Created a copy of the raw dataset to preserve the original.
- Replaced placeholders like `Unknown`, `Error`, and empty strings with `NULL`.
- Imputed missing values using logic (e.g., item based on unique price).
- Corrected and recalculated missing `Total Spent` values.
- Cleaned the `Transaction Date` column and converted it to `DATE` type.
- Converted appropriate numeric fields (e.g., `Price Per Unit`, `Total Spent`) from text/double to `DECIMAL(5,2)` for financial precision.
- Cleaned `Payment Method` and `Location` columns and verified integrity.

## Final Output

The final cleaned dataset is available as `cleaned_cafe_sales.csv` for use in future data analysis or visualization projects.

## Author

**Pragun Sapotra**
