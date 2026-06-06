-- Financial Profile Analysis (Balance, Credit Score & Salary)

-- 4 - Average Financials: Churned vs Retained
-- Direct financial comparison between customers who left and those who stayed.
SELECT
    CASE WHEN churn = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*)                                              AS total,
    ROUND(AVG(balance), 2)                               AS avg_balance,
    ROUND(AVG(credit_score), 1)                          AS avg_credit_score,
    ROUND(AVG(estimated_salary), 2)                      AS avg_salary,
    ROUND(AVG(age), 1)                                   AS avg_age,
    ROUND(AVG(tenure), 2)                                AS avg_tenure_yrs
FROM bank_churn
GROUP BY churn
ORDER BY churn DESC;


-- 5 - Churn by Credit Score Tier
-- Credit score is a bank's primary indicator of customer quality. Does it predict churn?
SELECT
    CASE
        WHEN credit_score >= 750                    THEN 'Excellent (750+)'
        WHEN credit_score BETWEEN 650 AND 749       THEN 'Good (650–749)'
        WHEN credit_score BETWEEN 550 AND 649       THEN 'Fair (550–649)'
        ELSE                                             'Poor (Below 550)'
    END                                                  AS credit_tier,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct
FROM bank_churn
GROUP BY credit_tier
ORDER BY
    CASE credit_tier
        WHEN 'Excellent (750+)'  THEN 1
        WHEN 'Good (650–749)'    THEN 2
        WHEN 'Fair (550–649)'    THEN 3
        ELSE 4
    END;


-- 06 — Churn by Balance Tier
-- How does account balance segment influence churn? Identifies which wealth band is most at risk.
SELECT
    CASE
        WHEN balance = 0                         THEN 'Zero Balance'
        WHEN balance BETWEEN 1 AND 49999         THEN 'Low (1–49K)'
        WHEN balance BETWEEN 50000 AND 99999    THEN 'Mid (50K–99K)'
        WHEN balance >= 100000                   THEN 'High (100K+)'
    END                                           AS balance_tier,
    COUNT(*)                                      AS total_customers,
    SUM(churn)                                    AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)    AS churn_rate_pct,
    ROUND(AVG(balance), 2)                       AS avg_balance
FROM bank_churn
GROUP BY balance_tier
ORDER BY churn_rate_pct DESC;