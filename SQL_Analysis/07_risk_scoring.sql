-- (Churn Risk Scoring System)

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