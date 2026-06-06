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



-- Stretch Goal (Churn Risk Scoring System)

-- 16 — Build a Churn Risk Score for Every Active Customer
-- Assigns a numeric risk score (0–5) to each retained customer based on the churn drivers identified in the analysis.
-- Higher score = higher churn risk.
WITH risk_scored AS (
    SELECT
        customer_id,
        country,
        gender,
        age,
        tenure,
        balance,
        products_number,
        active_member,
        credit_score,

        -- Assign risk points based on proven churn drivers
        (
            -- Risk Point 1: Inactive member (strong churn signal)
            CASE WHEN active_member = 0        THEN 1 ELSE 0 END

            -- Risk Point 2: Single product (highest churn band)
          + CASE WHEN products_number = 1     THEN 1 ELSE 0 END

            -- Risk Point 3: Age 40+ (dramatically higher churn)
          + CASE WHEN age >= 40              THEN 1 ELSE 0 END

            -- Risk Point 4: High balance (high-value customers churn more)
          + CASE WHEN balance > 100000        THEN 1 ELSE 0 END

            -- Risk Point 5: Germany (2x churn rate vs other countries)
          + CASE WHEN country = 'Germany'   THEN 1 ELSE 0 END

        )                                                AS risk_score

    FROM bank_churn
    WHERE churn = 0  -- Only score currently retained customers
),
risk_labelled AS (
    SELECT
        *,
        CASE
            WHEN risk_score >= 4  THEN 'HIGH'
            WHEN risk_score = 3   THEN 'MEDIUM'
            ELSE                       'LOW'
        END                          AS churn_risk
    FROM risk_scored
)
SELECT
    churn_risk,
    COUNT(*)                                             AS customers,
    ROUND(AVG(balance), 2)                              AS avg_balance,
    ROUND(SUM(balance), 2)                              AS total_balance_at_risk
FROM risk_labelled
GROUP BY churn_risk
ORDER BY
    CASE churn_risk
        WHEN 'HIGH'   THEN 1
        WHEN 'MEDIUM' THEN 2
        ELSE 3
    END;


-- 17 — Top 15 Retention Priority Customers
-- Produces the actionable output: the exact list of high-risk customers the retention team should contact first, ranked by balance (value at risk).
WITH scored AS (
    SELECT
        customer_id,
        country,
        gender,
        age,
        tenure,
        balance,
        products_number,
        credit_score,
        CASE WHEN active_member = 1 THEN 'Yes' ELSE 'No' END  AS is_active,
        (
            CASE WHEN active_member   = 0        THEN 1 ELSE 0 END
          + CASE WHEN products_number = 1        THEN 1 ELSE 0 END
          + CASE WHEN age             >= 40       THEN 1 ELSE 0 END
          + CASE WHEN balance         > 100000   THEN 1 ELSE 0 END
          + CASE WHEN country         = 'Germany' THEN 1 ELSE 0 END
        )                                                  AS risk_score
    FROM bank_churn
    WHERE churn = 0
)
SELECT
    customer_id,
    country,
    gender,
    age,
    balance,
    products_number,
    is_active,
    risk_score,
    'HIGH'                                               AS churn_risk
FROM scored
WHERE risk_score >= 4
ORDER BY balance DESC
LIMIT 15;


-- 18 — Validate the Risk Model Against Known Churners
-- Do churned customers actually score higher on our risk model than retained ones?
WITH all_scored AS (
    SELECT
        churn,
        (
            CASE WHEN active_member   = 0        THEN 1 ELSE 0 END
          + CASE WHEN products_number = 1        THEN 1 ELSE 0 END
          + CASE WHEN age             >= 40       THEN 1 ELSE 0 END
          + CASE WHEN balance         > 100000   THEN 1 ELSE 0 END
          + CASE WHEN country         = 'Germany' THEN 1 ELSE 0 END
        )                                                  AS risk_score
    FROM bank_churn
)
SELECT
    CASE WHEN churn = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*)                                              AS total,
    ROUND(AVG(risk_score), 3)                           AS avg_risk_score,
    SUM(CASE WHEN risk_score >= 4 THEN 1 ELSE 0 END)  AS high_risk_count,
    ROUND(
        SUM(CASE WHEN risk_score >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2)                                                    AS pct_high_risk
FROM all_scored
GROUP BY churn;


-- 19 — Rank Top 5 Highest-Balance Churners Per Country
WITH ranked_churners AS (
    SELECT
        customer_id,
        country,
        gender,
        age,
        balance,
        tenure,
        products_number,
        RANK() OVER (
            PARTITION BY country
            ORDER BY balance DESC
        )                            AS rank_within_country
    FROM bank_churn
    WHERE churn = 1
)
SELECT *
FROM ranked_churners
WHERE rank_within_country <= 5
ORDER BY country, rank_within_country;





-- 20a — Add a Synthetic join_date Column





























