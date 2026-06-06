CREATE DATABASE IF NOT EXISTS bank_churn_db;
USE bank_churn_db;


-- Verify the data
SELECT COUNT(*) FROM bank_churn;

SELECT * FROM bank_churn;


-- Verification
SELECT
    COUNT(*) AS total_rows,
    SUM(churn) AS churned,
    COUNT(*) - SUM(churn) AS retained,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM bank_churn;


-- Understanding the Dataset Before Analysis

-- Dataset Overview
SELECT
    COUNT(*)                         AS total_customers,
    ROUND(AVG(age), 1)              AS avg_age,
    ROUND(AVG(credit_score), 1)     AS avg_credit_score,
    ROUND(AVG(balance), 2)          AS avg_balance,
    ROUND(AVG(estimated_salary), 2)  AS avg_salary,
    MIN(tenure)                      AS min_tenure,
    MAX(tenure)                      AS max_tenure,
    ROUND(AVG(products_number), 2)  AS avg_products
FROM bank_churn;


-- Distinct Value Check
SELECT
    COUNT(DISTINCT country)          AS unique_countries,
    COUNT(DISTINCT gender)           AS unique_genders,
    COUNT(DISTINCT products_number)  AS unique_product_counts,
    COUNT(DISTINCT tenure)           AS unique_tenure_values,
    SUM(CASE WHEN balance = 0 THEN 1 ELSE 0 END) AS zero_balance_customers,
    SUM(CASE WHEN active_member = 1 THEN 1 ELSE 0 END) AS active_members
FROM bank_churn;
