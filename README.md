# 🏦 Bank Customer Churn Analysis — SQL + Power BI

_Full-cycle churn analysis on 10,000 bank customers — identifying who is leaving, what financial profile they share, how much revenue is at risk, and which retained customers to prioritise for intervention — built in MySQL with a 5-tab Power BI dashboard._

---

## 📌 Table of Contents
- <a href="#overview">Overview</a>
- <a href="#business-problem">Business Problem</a>
- <a href="#dataset">Dataset</a>
- <a href="#tools--technologies">Tools & Technologies</a>
- <a href="#project-structure">Project Structure</a>
- <a href="#data-cleaning--preparation">Data Cleaning & Preparation</a>
- <a href="#exploratory-data-analysis-eda">Exploratory Data Analysis (EDA)</a>
- <a href="#research-questions--key-findings">Research Questions & Key Findings</a>
- <a href="#dashboard">Dashboard</a>
- <a href="#how-to-run-this-project">How to Run This Project</a>
- <a href="#final-recommendations">Final Recommendations</a>

---

<h2><a class="anchor" id="overview"></a>Overview</h2>

This project analyses churn behaviour across 10,000 bank customers to answer four business-critical questions: who is churning, what financial profile they share, how much deposit revenue is currently at risk, and which retained customers should a retention team contact first. The full pipeline runs in MySQL — from raw ingestion through segmentation, risk scoring, and CLV estimation — and outputs to a 5-tab Power BI dashboard connected via live SQL views. Overall churn rate: **20.37%** (2,037 of 10,000 customers).

---

<h2><a class="anchor" id="business-problem"></a>Business Problem</h2>

Banks lose significant revenue when high-value customers close accounts or switch providers. This project answers four business-critical questions:

1. **Who is churning?** — by country, age group, and gender
2. **What financial profile do churners share?** — balance tier, credit score, product count
3. **How much revenue is at risk right now?** — from retained customers matching the churn profile
4. **Which specific customers should the retention team contact first?** — ranked by balance

The output is an actionable risk-scored customer list ready for a retention campaign, with **682 HIGH-risk customers** holding a combined **$89.33M** in deposits.

---

<h2><a class="anchor" id="dataset"></a>Dataset</h2>

| Property | Detail |
|---|---|
| **Source** | [Kaggle — Bank Customer Churn Dataset](https://www.kaggle.com/datasets/gauravtopre/bank-customer-churn-dataset) |
| **Rows** | 10,000 customers |
| **Key columns** | `customer_id`, `country`, `gender`, `age`, `tenure`, `balance`, `products_number`, `credit_score`, `active_member`, `churn` |
| **Database** | MySQL 8 (MySQL Workbench) |
| **Viz tool** | Power BI Desktop |

A synthetic `join_date` column was engineered from the `tenure` field using `DATE_SUB(CURDATE(), INTERVAL tenure YEAR)` to enable date-function and cohort analysis.

---

<h2><a class="anchor" id="tools--technologies"></a>Tools & Technologies</h2>

- SQL (MySQL 8 — DDL/DML, CTEs, Window Functions, Subqueries, Views)
- MySQL Workbench
- Power BI Desktop (live connection via SQL views)
- GitHub

---

<h2><a class="anchor" id="project-structure"></a>Project Structure</h2>

```
bank_churn_sql_project/
│
├── README.md
├── bank_churn_sql_project.html        # Exported query outputs
│
├── data/
│   └── bank_customer_churn.csv        # Raw dataset (download from Kaggle link above)
│
├── sql/
│   ├── 00_setup.sql                   # DB creation, verification, dataset overview
│   ├── 01_core_churn_analysis.sql     # Churn by country, gender, age group
│   ├── 02_financial_profile.sql       # Balance, credit score, salary analysis
│   ├── 03_behaviour_analysis.sql      # Products, activity, combined segments
│   ├── 04_tenure_analysis.sql         # Tenure bands, avg tenure at churn
│   ├── 05_high_value_churn.sql        # High-value churners, revenue at risk
│   ├── 06_cohort_analysis.sql         # Country × age, tenure × product grid
│   ├── 07_risk_scoring.sql            # Risk score model, top retention targets
│   ├── 08_date_functions.sql          # Synthetic join_date, date arithmetic
│   ├── 09_not_in_logic.sql            # NOT IN subquery patterns
│   ├── 10_clv_analysis.sql            # CLV estimation, churned vs retained by tier
│   └── churn_views.sql                # Reusable SQL views for Power BI connection
│
├── dashboard/
│   └── bank_churn_dashboard.pbix      # Power BI dashboard file
│
├── screenshots/
│   ├── 01_Executive_Overview.png
│   ├── 02_Segment_Analysis.png
│   ├── 03_Financial_Risk.png
│   ├── 04_Risk_Score.png
│   └── 05_Retention_Action_List.png
```

---

<h2><a class="anchor" id="data-cleaning--preparation"></a>Data Cleaning & Preparation</h2>

- Checked for null values in critical columns (`customer_id`, `churn`, `balance`) — none found
- Validated `churn` column as binary (0 = retained, 1 = churned)
- Confirmed `products_number` is within expected range (1–4)
- Confirmed no duplicate `customer_id` entries across 10,000 rows
- Flagged zero-balance customers as a separate segment — retained for analysis, not removed
- Engineered `join_date` from `tenure`: `DATE_SUB(CURDATE(), INTERVAL tenure YEAR)` — enables tenure cohort and date arithmetic queries
- Created reusable views (`v_churn_by_country`, `v_churn_by_age`, `v_risk_scores`) for live Power BI connection

---

<h2><a class="anchor" id="exploratory-data-analysis-eda"></a>Exploratory Data Analysis (EDA)</h2>

**Overall Churn:**
- 10,000 customers total | 2,037 churned | 7,963 retained
- Overall churn rate: **20.37%**

**Churn by Country:**
- Germany: **32.4%** — nearly 2× the rate of Spain (16.7%) and France (16.2%)

**Churn by Age:**
- Highest churn in the 50–59 age band: **56%**
- Lowest in under-30 customers: **8%**

**Churn by Gender:**
- Female customers make up **44.08%** of churned pool — higher proportional churn rate than male

**Balance Profile:**
- Churned customers: avg balance **$91K**
- Retained customers: avg balance **$73K**
- Churners hold higher balances — makes revenue exposure significant

**Product Count:**
- 1-product holders: **28%** churn rate
- 3–4 product holders: **83–100%** churn rate — likely already disengaged before exit

---

<h2><a class="anchor" id="research-questions--key-findings"></a>Research Questions & Key Findings</h2>

### 1. Churn by Country — Where is the problem worst?

```sql
SELECT
    country,
    COUNT(*)                                          AS total_customers,
    SUM(churn)                                        AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)         AS churn_rate_pct
FROM bank_churn
GROUP BY country
ORDER BY churn_rate_pct DESC;
```

**Finding:** Germany churns at **32.4%** — nearly 2× Spain (16.7%) and France (16.2%).

---

### 2. Churn by Age Group — Who's leaving by life stage?

```sql
SELECT
    CASE
        WHEN age < 30              THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30–39'
        WHEN age BETWEEN 40 AND 49 THEN '40–49'
        WHEN age BETWEEN 50 AND 59 THEN '50–59'
        ELSE '60+'
    END                                               AS age_group,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)         AS churn_rate_pct
FROM bank_churn
GROUP BY age_group
ORDER BY churn_rate_pct DESC;
```

**Finding:** The **50–59** age band churns at 56% — the single highest-risk segment.

---

### 3. Churn by Product Count — Non-linear relationship

```sql
SELECT
    products_number,
    COUNT(*)                                          AS total_customers,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2)         AS churn_rate_pct
FROM bank_churn
GROUP BY products_number
ORDER BY products_number;
```

**Finding:** 1-product holders churn at **28%**. 3–4 product holders churn at **83–100%** — likely already disengaged before exit.

---

### 4. Risk Scoring — Scoring every retained customer 0–5

```sql
WITH risk_scored AS (
    SELECT
        customer_id, country, age, balance, products_number,
        (
            CASE WHEN active_member   = 0         THEN 1 ELSE 0 END
          + CASE WHEN products_number = 1         THEN 1 ELSE 0 END
          + CASE WHEN age             >= 40        THEN 1 ELSE 0 END
          + CASE WHEN balance         > 100000    THEN 1 ELSE 0 END
          + CASE WHEN country         = 'Germany' THEN 1 ELSE 0 END
        )                                             AS risk_score
    FROM bank_churn
    WHERE churn = 0
)
SELECT
    CASE
        WHEN risk_score >= 4 THEN 'HIGH'
        WHEN risk_score  = 3 THEN 'MEDIUM'
        ELSE 'LOW'
    END                                               AS churn_risk,
    COUNT(*)                                          AS customers,
    ROUND(SUM(balance), 2)                           AS total_balance_at_risk
FROM risk_scored
GROUP BY churn_risk;
```

**Finding:** **682 HIGH-risk customers** hold a combined **$89.33M** in deposits.

---

### 5. CLV Analysis — What is each customer actually worth?

```sql
SELECT
    customer_id, age, balance,
    ROUND(balance * 0.02 * GREATEST(70 - age, 0), 2) AS estimated_clv,
    CASE
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 100000 THEN 'Platinum'
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 50000  THEN 'Gold'
        WHEN balance * 0.02 * GREATEST(70 - age, 0) >= 20000  THEN 'Silver'
        ELSE 'Standard'
    END                                               AS clv_tier
FROM bank_churn
ORDER BY estimated_clv DESC
LIMIT 10;
```

**Methodology:** CLV = `Balance × 2% NIM × Estimated Years Remaining (to age 70)` — conservative retail banking proxy.

---

<h2><a class="anchor" id="dashboard"></a>Dashboard</h2>

5-tab Power BI dashboard connected directly to MySQL via live views (`v_churn_by_country`, `v_churn_by_age`, `v_risk_scores`).

---

**Tab 1 — Executive Overview**
KPI cards (10K customers, 2K churned, 20.37% churn rate), churn by country bar chart, churned vs retained donut.

<img width="1841" height="874" alt="01_Executive_Overview" src="https://github.com/user-attachments/assets/d81fb03a-31cb-4853-a444-877b3a67f589" />

---

**Tab 2 — Segment Analysis**
Churn by age group, churn by gender, churn by products held, avg balance comparison (churned vs retained).

<img width="1841" height="857" alt="02_Segment_Analysis" src="https://github.com/user-attachments/assets/1a67347c-8900-4fee-a471-4c33a4a56af9" />

---

**Tab 3 — Financial Risk**
Balance at risk KPI ($89.33M), churn rate by balance tier, churn rate by credit score tier.

<img width="1842" height="858" alt="03_Financial_Risk" src="https://github.com/user-attachments/assets/24e39d5d-0b9d-4669-a311-bc9d842c830d" />

---

**Tab 4 — Risk Score Dashboard**
Risk distribution donut (682 HIGH / 1,820 MEDIUM / 5,461 LOW), HIGH risk customer table, risk breakdown by country.

<img width="1843" height="879" alt="04_Risk_Score" src="https://github.com/user-attachments/assets/aa68491b-9217-4140-aa24-ce7c4d63dc73" />

---

**Tab 5 — Retention Action List**
Filterable table by country and balance range — top retention targets sorted by balance, ready for campaign use.

<img width="1843" height="877" alt="05_Retention_Action_List" src="https://github.com/user-attachments/assets/61ad963f-10d7-4bd0-9bab-9bb65b1d4bc2" />

---

<h2><a class="anchor" id="how-to-run-this-project"></a>How to Run This Project</h2>

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bank-churn-sql-project.git
```

2. Set up the database in MySQL Workbench:
```sql
SOURCE sql/00_setup.sql;
```

3. Run the analysis scripts in order:
```sql
SOURCE sql/01_core_churn_analysis.sql;
SOURCE sql/02_financial_profile.sql;
-- ... continue through 10_clv_analysis.sql
```

4. Create the Power BI views:
```sql
SOURCE sql/churn_views.sql;
```

5. Open Power BI Desktop and connect to MySQL:
   - Data Source: MySQL database → `bank_churn_db`
   - Load views: `v_churn_by_country`, `v_churn_by_age`, `v_risk_scores`
   - Open `dashboard/bank_churn_dashboard.pbix`

---

<h2><a class="anchor" id="final-recommendations"></a>Final Recommendations</h2>

**Summary of key findings:**

| Segment | Churn Rate | Key Insight |
|---|---|---|
| Germany | 32.4% | Nearly 2× other countries — investigate product or service gap |
| Age 50–59 | 56% | Highest-risk age band — dedicated retention offers needed |
| 3–4 Products | 83–100% | Counter-intuitive — multi-product holders are already disengaged |
| HIGH Risk customers | 682 customers | $89.33M in deposits at risk — immediate outreach priority |
| Churned avg balance | $91K vs $73K retained | High-balance customers churn more — financial incentives matter |

**Immediate actions:**
- Deploy the Retention Action List (Tab 5) to contact the top 682 HIGH-risk customers, prioritised by balance
- Run a Germany-specific campaign — 32.4% churn rate suggests a regional product or pricing issue worth investigating separately
- Build targeted offers for the 50–59 age segment; a 56% churn rate in this group cannot be treated as noise

**For the next iteration:**
- Add a `churn_reason` column (even synthetic/categorical) to enable root-cause labelling beyond demographics
- Use window functions for percentile-based balance tiers instead of hardcoded CASE thresholds — more robust across different datasets
- Build a stored procedure for the risk scoring model so updates cascade automatically
- Include salary-to-balance ratio as an additional churn driver in the risk score — currently an unused signal in the dataset
- Export the Retention Action List to a scheduled email report via a Python + SMTP layer for automated campaign triggering.
