SET SQL_SAFE_UPDATES = 0;

-- Date Functions & Date Arithmetic

-- 20a — Add a Synthetic join_date Column

-- 1: Add the column
ALTER TABLE bank_churn
ADD COLUMN join_date DATE;

-- 2: Populate it using tenure
-- Logic: if a customer has tenure = 3, they joined ~3 years ago from today
UPDATE bank_churn
SET join_date = DATE_SUB(CURDATE(), INTERVAL tenure YEAR);

-- 3: Verify
SELECT
    customer_id,
    tenure,
    join_date,
    DATEDIFF(CURDATE(), join_date)      AS days_as_customer,
    TIMESTAMPDIFF(MONTH, join_date, CURDATE()) AS months_as_customer
FROM bank_churn
LIMIT 5;


-- 20b — Churn Rate by Year of Joining
-- Extracts the join year from the date column and groups churn by customer acquisition cohort.
SELECT
    YEAR(join_date)                                      AS join_year,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(balance), 2)                              AS avg_balance
FROM bank_churn
GROUP BY YEAR(join_date)
ORDER BY join_year;


-- 20c — Customers Who Joined in the Last 2 Years
SELECT
    CASE WHEN join_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
         THEN 'Last 2 Years'
         ELSE 'Before 2 Years Ago'
    END                                                  AS joining_period,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(balance), 2)                              AS avg_balance,
    ROUND(AVG(TIMESTAMPDIFF(MONTH, join_date, CURDATE())), 1) AS avg_months_enrolled
FROM bank_churn
GROUP BY joining_period
ORDER BY churn_rate_pct DESC;

SET SQL_SAFE_UPDATES = 1;
