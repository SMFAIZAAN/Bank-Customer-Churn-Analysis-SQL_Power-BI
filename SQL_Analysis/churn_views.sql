USE bank_churn_db;

-- View 1: Churn by country
CREATE VIEW v_churn_by_country AS
SELECT
    country,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(balance), 2) AS avg_balance
FROM bank_churn
GROUP BY country;

-- View 2: Churn by age group
CREATE VIEW v_churn_by_age AS
SELECT
    CASE
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM bank_churn
GROUP BY age_group;

-- View 3: Risk scored customers
CREATE VIEW v_risk_scores AS
SELECT
    customer_id, country, gender, age, balance,
    products_number, active_member, credit_score,
    (
        CASE WHEN active_member = 0   THEN 1 ELSE 0 END
      + CASE WHEN products_number = 1 THEN 1 ELSE 0 END
      + CASE WHEN age >= 40           THEN 1 ELSE 0 END
      + CASE WHEN balance > 100000    THEN 1 ELSE 0 END
      + CASE WHEN country = 'Germany' THEN 1 ELSE 0 END
    ) AS risk_score,
    CASE
        WHEN (
            CASE WHEN active_member=0 THEN 1 ELSE 0 END
          + CASE WHEN products_number=1 THEN 1 ELSE 0 END
          + CASE WHEN age>=40 THEN 1 ELSE 0 END
          + CASE WHEN balance>100000 THEN 1 ELSE 0 END
          + CASE WHEN country='Germany' THEN 1 ELSE 0 END
        ) >= 4 THEN 'HIGH'
        WHEN (
            CASE WHEN active_member=0 THEN 1 ELSE 0 END
          + CASE WHEN products_number=1 THEN 1 ELSE 0 END
          + CASE WHEN age>=40 THEN 1 ELSE 0 END
          + CASE WHEN balance>100000 THEN 1 ELSE 0 END
          + CASE WHEN country='Germany' THEN 1 ELSE 0 END
        ) = 3 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS churn_risk
FROM bank_churn
WHERE churn = 0;

SHOW FULL TABLES IN bank_churn_db WHERE TABLE_TYPE = 'VIEW';
