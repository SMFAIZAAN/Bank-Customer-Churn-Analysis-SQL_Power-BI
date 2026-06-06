-- Who Is Churning?

-- 01 — Churn by Country
-- Which geography has the highest churn rate?
SELECT
    country,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(balance), 2)                              AS avg_balance
FROM bank_churn
GROUP BY country
ORDER BY churn_rate_pct DESC;


-- 02 — Churn by Gender
-- Does gender influence churn probability?
SELECT
    gender,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(estimated_salary), 2)                     AS avg_salary
FROM bank_churn
GROUP BY gender
ORDER BY churn_rate_pct DESC;


-- 03 — Churn by Age Group
-- Which age cohort is most at risk?
SELECT
    CASE
        WHEN age < 30              THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39  THEN '30–39'
        WHEN age BETWEEN 40 AND 49  THEN '40–49'
        WHEN age BETWEEN 50 AND 59  THEN '50–59'
        ELSE                              '60+'
    END                                  AS age_group,
    COUNT(*)                             AS total_customers,
    SUM(churn)                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(balance), 2)              AS avg_balance
FROM bank_churn
GROUP BY age_group
ORDER BY churn_rate_pct DESC;