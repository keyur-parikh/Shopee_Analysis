# Shopee Product Analysis

## Project Overview  
This project focuses on cleaning and transforming raw retail data using **SQL** and leveraging the cleaned dataset in **Tableau** to conduct an in-depth product-level analysis. The goal was to identify categories and subcategories contributing the most to revenue.

**Dataset:**  
The dataset comes from **Shopee**, a retail store in Malaysia. The interactive Tableau dashboard showcasing the final insights can be found here:  
[Interactive Dashboard](https://public.tableau.com/shared/J8THNDKFQ?:display_count=n&:origin=viz_share_link)

---

## Key Steps in SQL Data Cleaning

### 1. Creating a Staging Table
- Created a **staging table** to ensure the original data wasn't altered. 

### 2. Initial Inspection and Deduplication
- Verified the dataset for duplicates using unique identifiers.  
- Focused on a subset of relevant columns for analysis.

### 3. Converting Data Types
- **Datetime Conversion:**
  - The `Delivery Date` column was stored as a string.
  - Steps: Added a new column for datetime values, converted the string format, and removed the original column.
- **String-to-Numeric Conversion:**
  - Standardized columns with values like `2.5k` by removing the 'k' and multiplying by 1000.
  - Converted empty strings and 'N/A' placeholders into `NULL` values for data integrity.

### 4. String Manipulation for Feature Extraction
- Extracted **Main Category**, **Subcategory 1**, and **Subcategory 2** from the `category_detail` column.  
- Created separate columns to store this information for improved granularity.

### 5. Creating New Fields
- Derived a **Revenue** column by multiplying `Product_Sales` with `Amount_Sold`.

### 6. Data Validation and Cleaning
- Removed rows with:
  - Missing or invalid values (e.g., `NULL` prices, zero values).  
- Assumed `Original Price` as a fallback where `Actual Price` was missing.  
- Ensured logical consistency across all columns.

---

## Outcome and Insights  
The cleaned and transformed dataset was exported into Tableau, where an interactive dashboard was created to:  
- Visualize revenue distribution across **categories** and **subcategories**.  
- Enable dynamic exploration of product-level performance.

---

## Skills Highlighted  
- **SQL Data Cleaning & Transformation**:  
  - Staging tables, data type conversion, feature extraction, and logical fixes.  
- **Data Validation**:  
  - Ensured clean, standardized, and reliable data for analysis.  
- **Tableau Dashboarding**:  
  - Presented actionable insights through an interactive and intuitive visualization.

---

## Key Takeaway  
This project demonstrates the ability to clean messy datasets, extract meaningful insights, and deliver an analysis-ready dataset for visualization.  
It highlights strong **problem-solving skills**, **attention to detail**, and **technical proficiency** in SQL and Tableau.
