-- High-Value Customer Churn (Revenue at Risk)

-- 12 — High-Value Customers Who Have Already Churned
-- Identifies churned customers with above-average balances — the most valuable losses.
SELECT
    customer_id,
    country,
    gender,
    age,
    tenure,
    balance,
    products_number,
    CASE WHEN active_member = 1 THEN 'Yes' ELSE 'No' END AS was_active
FROM bank_churn
WHERE
    churn = 1
    AND balance > (
        SELECT AVG(balance) FROM bank_churn WHERE churn = 1
    )
ORDER BY balance DESC
LIMIT 10;


-- 13 — Total Revenue at Risk (High-Risk Active Customers)
-- Calculates the total balance at risk from currently active customers who share the same profile as the churned customers above.
WITH avg_churned_balance AS (
    SELECT AVG(balance) AS avg_bal
    FROM bank_churn
    WHERE churn = 1
),
high_risk_active AS (
    SELECT
        bc.customer_id,
        bc.balance,
        bc.age,
        bc.country,
        bc.products_number,
        bc.active_member
    FROM bank_churn bc
    CROSS JOIN avg_churned_balance acb
    WHERE
        bc.churn = 0                          -- Currently retained
        AND bc.balance > acb.avg_bal          -- High balance
        AND bc.products_number = 1            -- Single product (highest risk)
        AND bc.active_member = 0             -- Inactive (highest risk)
)
SELECT
    COUNT(*)                                     AS at_risk_customers,
    ROUND(SUM(balance), 2)                      AS total_balance_at_risk,
    ROUND(AVG(balance), 2)                      AS avg_balance_at_risk,
    ROUND(AVG(age), 1)                          AS avg_age
FROM high_risk_active;