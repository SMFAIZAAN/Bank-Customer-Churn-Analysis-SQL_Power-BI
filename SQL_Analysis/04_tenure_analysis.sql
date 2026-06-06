-- Tenure Analysis (Early-life Churn & Loyalty Patterns)


-- 10 — Churn by Tenure Band
-- Are new customers more likely to churn? Identifies the "danger window" in the customer lifecycle.
SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 2  THEN 'New (0–2 yrs)'
        WHEN tenure BETWEEN 3 AND 5  THEN 'Developing (3–5 yrs)'
        WHEN tenure BETWEEN 6 AND 8  THEN 'Established (6–8 yrs)'
        ELSE                              'Long-term (9–10 yrs)'
    END                                  AS tenure_band,
    COUNT(*)                             AS total_customers,
    SUM(churn)                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(balance), 2)              AS avg_balance
FROM bank_churn
GROUP BY tenure_band
ORDER BY churn_rate_pct DESC;


-- 11 — Average Tenure at Churn by Country
WITH churned_customers AS (
    SELECT
        customer_id,
        country,
        tenure,
        balance,
        age
    FROM bank_churn
    WHERE churn = 1
)
SELECT
    country,
    COUNT(*)                            AS churned_customers,
    ROUND(AVG(tenure), 2)              AS avg_tenure_at_churn,
    ROUND(AVG(balance), 2)             AS avg_balance_at_churn,
    ROUND(AVG(age), 1)                 AS avg_age_at_churn
FROM churned_customers
GROUP BY country
ORDER BY churned_customers DESC;