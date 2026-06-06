-- Customer Behaviour Analysis (Products, Activity & Engagement)

-- 07 — Churn by Number of Products
-- product count has a non-linear relationship with churn.
SELECT
    products_number                                      AS products_held,
    COUNT(*)                                             AS total_customers,
    SUM(churn)                                           AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)           AS churn_rate_pct,
    ROUND(AVG(balance), 2)                              AS avg_balance
FROM bank_churn
GROUP BY products_number
ORDER BY products_number;


-- 08 — Churn by Active Member Status
-- Active engagement is one of the strongest early-warning signals for churn risk.
SELECT
    CASE WHEN active_member = 1 THEN 'Active' ELSE 'Inactive' END AS member_status,
    COUNT(*)                                              AS total_customers,
    SUM(churn)                                            AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)             AS churn_rate_pct,
    ROUND(AVG(balance), 2)                               AS avg_balance
FROM bank_churn
GROUP BY active_member
ORDER BY churn_rate_pct DESC;


-- 09 — Churn by Activity + Products (Combined)
-- Combines two strong churn signals to identify the highest-risk customer segment with precision.
SELECT
    CASE WHEN active_member = 1 THEN 'Active' ELSE 'Inactive' END AS member_status,
    products_number                                       AS products_held,
    COUNT(*)                                              AS total,
    SUM(churn)                                            AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)             AS churn_rate_pct
FROM bank_churn
GROUP BY active_member, products_number
ORDER BY churn_rate_pct DESC
LIMIT 8;