-- NOT IN Logic & Subqueries (Finding Customers Outside the Safe Profile)


-- 21a — Active Customers NOT IN the Low-Risk Profile
-- Find all retained customers who are NOT in the safest profile
-- Safest profile: 2 products AND active member (only 4.4% churn rate)
SELECT
    customer_id,
    country,
    age,
    balance,
    products_number,
    CASE WHEN active_member = 1 THEN 'Yes' ELSE 'No' END AS is_active,
    credit_score
FROM bank_churn
WHERE
    churn = 0
    AND customer_id NOT IN (
        -- Subquery: IDs of customers in the safest profile
        SELECT customer_id
        FROM bank_churn
        WHERE
            products_number = 2
            AND active_member = 1
            AND churn = 0
    )
ORDER BY balance DESC
LIMIT 10;


-- 21b — Retained Customers NOT IN High-Churn Countries
-- Count retained customers in LOWER-risk countries
-- i.e., not from Germany (highest churn country at 32%)
SELECT
    country,
    COUNT(*)                                             AS retained_customers,
    ROUND(AVG(balance), 2)                              AS avg_balance,
    ROUND(AVG(age), 1)                                  AS avg_age,
    ROUND(AVG(products_number), 2)                      AS avg_products
FROM bank_churn
WHERE
    churn = 0
    AND country NOT IN ('Germany')
GROUP BY country
ORDER BY retained_customers DESC;