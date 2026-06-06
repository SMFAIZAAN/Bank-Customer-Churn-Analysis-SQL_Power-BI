-- Customer Lifetime Value (CLV) (Quantifying What Each Customer Is Worth)

-- 22a — CLV Estimate for Every Customer
-- CLV estimate for each customer using balance, a net interest margin proxy, and estimated years remaining.
SELECT
    customer_id,
    country,
    age,
    tenure,
    balance,
    churn,
    -- Estimated remaining banking years: assume customers bank until age 70
    GREATEST(70 - age, 0)                              AS est_years_remaining,

    -- CLV = Balance × 2% NIM × Estimated Years Remaining
    -- 2% NIM is a conservative retail banking net interest margin
    ROUND(
        balance * 0.02 * GREATEST(70 - age, 0),
    2)                                                   AS estimated_clv,

    -- CLV Tier
    CASE
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 100000 THEN 'Platinum'
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 50000  THEN 'Gold'
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 20000  THEN 'Silver'
        ELSE                                                        'Standard'
    END                                                  AS clv_tier
FROM bank_churn
ORDER BY estimated_clv DESC
LIMIT 10;


-- 24b — Average CLV: Churned vs Retained by Tier
-- Summarises CLV by churn status and tier — the executive-level view of what churn is costing the bank in lifetime value terms.
WITH clv_base AS (
    SELECT
        customer_id,
        churn,
        balance,
        age,
        ROUND(
            balance * 0.02 * GREATEST(70 - age, 0),
        2)                                               AS estimated_clv,
        CASE
            WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 100000 THEN 'Platinum'
            WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 50000  THEN 'Gold'
            WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 20000  THEN 'Silver'
            ELSE                                                        'Standard'
        END                                                AS clv_tier
    FROM bank_churn
)
SELECT
    clv_tier,
    CASE WHEN churn = 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(*)                                              AS customers,
    ROUND(AVG(estimated_clv), 2)                        AS avg_clv,
    ROUND(SUM(estimated_clv), 2)                        AS total_clv_lost_or_held
FROM clv_base
GROUP BY clv_tier, churn
ORDER BY
    CASE clv_tier
        WHEN 'Platinum' THEN 1
        WHEN 'Gold'     THEN 2
        WHEN 'Silver'   THEN 3
        ELSE 4
    END,
    churn;