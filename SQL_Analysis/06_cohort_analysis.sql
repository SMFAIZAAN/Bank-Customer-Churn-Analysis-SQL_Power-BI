-- Cohort Analysis (Multi-Dimensional Churn Patterns)

-- 14 — Churn Rate by Country and Age Group (Cohort)
-- A full cohort breakdown — which country + age combination churns most.
WITH cohort AS (
    SELECT
        country,
        CASE
            WHEN age < 40            THEN 'Under 40'
            WHEN age BETWEEN 40 AND 54 THEN '40–54'
            ELSE                          '55+'
        END   AS age_cohort,
        churn,
        balance
    FROM bank_churn
)
SELECT
    country,
    age_cohort,
    COUNT(*)                                             AS total,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(balance), 2)                              AS avg_balance
FROM cohort
GROUP BY country, age_cohort
ORDER BY churn_rate_pct DESC;


-- 15 — Churn Rate by Tenure & Product Count (Grid Cohort)
-- Cross-tabs tenure bands against product count to find which combinations are safe vs at-risk.
WITH tenured_products AS (
    SELECT
        CASE
            WHEN tenure BETWEEN 0 AND 3  THEN 'Early (0–3yr)'
            WHEN tenure BETWEEN 4 AND 7  THEN 'Mid (4–7yr)'
            ELSE                              'Long (8–10yr)'
        END                                  AS tenure_band,
        products_number,
        churn
    FROM bank_churn
)
SELECT
    tenure_band,
    products_number,
    COUNT(*)                                             AS total,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct
FROM tenured_products
GROUP BY tenure_band, products_number
ORDER BY tenure_band, products_number;