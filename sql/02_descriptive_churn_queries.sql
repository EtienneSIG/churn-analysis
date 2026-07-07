-- =============================================================================
-- Contoso Banque — Churn Analysis Workshop
-- SQL Script 02: Descriptive Churn Queries
-- Target: Fabric Lakehouse SQL Analytics Endpoint
-- =============================================================================
-- Prerequisites: Run 01_customer_churn_views.sql first
-- =============================================================================

-- =============================================================================
-- SECTION 1: OVERALL KPIs
-- =============================================================================

-- Query 1.1: Overall churn rate
-- Expected: ~18–22% overall churn rate
SELECT
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    COUNT(*) - SUM(churned_90d)                           AS retained_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS overall_churn_rate_pct
FROM customer_360;

GO

-- Query 1.2: Churned vs. retained — average profile comparison
-- Shows how churned customers differ from retained ones on key metrics
SELECT
    CASE churned_90d WHEN 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(*)                                               AS customer_count,
    ROUND(AVG(age), 1)                                     AS avg_age,
    ROUND(AVG(tenure_months), 1)                           AS avg_tenure_months,
    ROUND(AVG(avg_balance_90d), 0)                         AS avg_balance_eur,
    ROUND(AVG(CAST(active_product_count AS FLOAT)), 2)     AS avg_products,
    ROUND(AVG(CAST(transaction_count_90d AS FLOAT)), 1)    AS avg_txn_count,
    ROUND(AVG(CAST(digital_active_flag AS FLOAT)) * 100, 1) AS pct_digital
FROM customer_360
GROUP BY churned_90d
ORDER BY churned_90d DESC;

GO

-- =============================================================================
-- SECTION 2: CHURN BY ACTIVITY
-- =============================================================================

-- Query 2.1: Churn rate by activity tier (sorted worst to best)
-- Expected: Inactive customers have highest churn rate (>40%)
SELECT
    activity_tier,
    total_customers,
    churned_customers,
    retained_customers,
    churn_rate_pct,
    avg_balance_eur,
    avg_txn_count,
    avg_product_count
FROM vw_churn_by_activity
ORDER BY churn_rate_pct DESC;

GO

-- Query 2.2: Transaction count distribution for churned vs. retained
SELECT
    CASE churned_90d WHEN 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(CASE WHEN transaction_count_90d = 0 THEN 1 END)       AS no_transactions,
    COUNT(CASE WHEN transaction_count_90d BETWEEN 1 AND 3 THEN 1 END) AS low_1_to_3,
    COUNT(CASE WHEN transaction_count_90d BETWEEN 4 AND 9 THEN 1 END) AS medium_4_to_9,
    COUNT(CASE WHEN transaction_count_90d >= 10 THEN 1 END)     AS high_10_plus
FROM customer_360
GROUP BY churned_90d
ORDER BY churned_90d DESC;

GO

-- =============================================================================
-- SECTION 3: CHURN BY BALANCE
-- =============================================================================

-- Query 3.1: Churn rate by balance band
SELECT
    balance_band,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_balance_eur,
    min_balance_eur,
    max_balance_eur
FROM vw_churn_by_balance_band
ORDER BY churn_rate_pct DESC;

GO

-- Query 3.2: Churn rate by balance trend
SELECT
    balance_trend,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_balance_eur
FROM vw_churn_by_balance_trend
ORDER BY churn_rate_pct DESC;

GO

-- Query 3.3: Average balance for churned vs. retained by region
SELECT
    region,
    SUM(churned_90d)                                      AS churned_count,
    ROUND(AVG(CASE WHEN churned_90d = 1 THEN avg_balance_90d END), 0) AS churned_avg_balance,
    ROUND(AVG(CASE WHEN churned_90d = 0 THEN avg_balance_90d END), 0) AS retained_avg_balance
FROM customer_360
GROUP BY region
ORDER BY churned_count DESC;

GO

-- =============================================================================
-- SECTION 4: CHURN BY PRODUCT DEPTH
-- =============================================================================

-- Query 4.1: Churn rate by product count tier
-- Expected: Single-product customers have materially higher churn
SELECT
    product_count_tier,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_active_products,
    avg_balance_eur
FROM vw_churn_by_product_tier
ORDER BY churn_rate_pct DESC;

GO

-- Query 4.2: Churn rate by exact number of active products (0–5+)
SELECT
    CASE
        WHEN active_product_count = 0 THEN '0 products'
        WHEN active_product_count = 1 THEN '1 product'
        WHEN active_product_count = 2 THEN '2 products'
        WHEN active_product_count = 3 THEN '3 products'
        ELSE '4+ products'
    END                                                   AS product_bucket,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct
FROM customer_360
GROUP BY
    CASE
        WHEN active_product_count = 0 THEN '0 products'
        WHEN active_product_count = 1 THEN '1 product'
        WHEN active_product_count = 2 THEN '2 products'
        WHEN active_product_count = 3 THEN '3 products'
        ELSE '4+ products'
    END
ORDER BY churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 5: CHURN BY DIGITAL ENGAGEMENT
-- =============================================================================

-- Query 5.1: Digital vs. non-digital churn comparison
SELECT
    digital_segment,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_balance_eur,
    avg_txn_count
FROM vw_churn_digital_vs_nondigital;

GO

-- Query 5.2: Churn rate by digital status AND activity tier (cross-segment)
SELECT
    CASE digital_active_flag WHEN 1 THEN 'Digital' ELSE 'Non-Digital' END AS digital_label,
    activity_tier,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct
FROM customer_360
GROUP BY digital_active_flag, activity_tier
ORDER BY churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 6: CHURN BY DEMOGRAPHICS
-- =============================================================================

-- Query 6.1: Churn rate by income band
SELECT
    income_band,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_balance_eur,
    avg_product_count
FROM vw_churn_by_income_band
ORDER BY churn_rate_pct DESC;

GO

-- Query 6.2: Churn rate by age group
SELECT
    CASE
        WHEN age < 30  THEN '1. Under 30'
        WHEN age < 45  THEN '2. 30-44'
        WHEN age < 60  THEN '3. 45-59'
        WHEN age < 70  THEN '4. 60-69'
        ELSE           '5. 70+'
    END                                                   AS age_group,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 0)                        AS avg_balance_eur
FROM customer_360
GROUP BY
    CASE
        WHEN age < 30  THEN '1. Under 30'
        WHEN age < 45  THEN '2. 30-44'
        WHEN age < 60  THEN '3. 45-59'
        WHEN age < 70  THEN '4. 60-69'
        ELSE           '5. 70+'
    END
ORDER BY age_group;

GO

-- Query 6.3: Churn rate by region (geographic breakdown)
SELECT
    region,
    total_customers,
    churned_customers,
    churn_rate_pct,
    avg_balance_eur
FROM vw_churn_by_region
ORDER BY churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 7: COMBINED / ADVANCED QUERIES
-- =============================================================================

-- Query 7.1: Risk matrix — activity tier × balance band
-- Shows churn rate for each combination of activity and balance
SELECT
    activity_tier,
    balance_band,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct
FROM customer_360
GROUP BY activity_tier, balance_band
ORDER BY churn_rate_pct DESC;

GO

-- Query 7.2: Top 10 highest-churn micro-segments
-- Most granular view — combine 3 dimensions
-- Note: GROUP BY + HAVING are evaluated before the final ORDER BY
SELECT TOP 10
    activity_tier,
    balance_band,
    product_count_tier,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct
FROM customer_360
GROUP BY activity_tier, balance_band, product_count_tier
HAVING COUNT(*) >= 50   -- Only show segments with meaningful size
ORDER BY churn_rate_pct DESC;

GO

-- Query 7.3: Churn "acceleration factors"
-- For each factor, how much does it increase churn vs. the overall rate?
WITH overall AS (
    SELECT ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2) AS baseline_churn_rate
    FROM customer_360
)
SELECT
    factor_name,
    segment_value,
    churn_rate_pct,
    overall.baseline_churn_rate,
    ROUND(churn_rate_pct - overall.baseline_churn_rate, 2) AS churn_delta_vs_baseline
FROM (
    SELECT 'Activity'     AS factor_name, activity_tier AS segment_value,
           ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2) AS churn_rate_pct
    FROM customer_360 GROUP BY activity_tier

    UNION ALL

    SELECT 'Balance',     balance_band,
           ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)
    FROM customer_360 GROUP BY balance_band

    UNION ALL

    SELECT 'Products',    product_count_tier,
           ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)
    FROM customer_360 GROUP BY product_count_tier

    UNION ALL

    SELECT 'Digital',
           CASE digital_active_flag WHEN 1 THEN 'Digital' ELSE 'Non-Digital' END,
           ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)
    FROM customer_360 GROUP BY digital_active_flag
) AS segments
CROSS JOIN overall
ORDER BY ABS(churn_delta_vs_baseline) DESC;

GO

-- =============================================================================
-- SECTION 8: TRANSACTION ANALYSIS FOR CHURNED CUSTOMERS
-- =============================================================================

-- Query 8.1: Top merchant categories for churned vs. retained customers
SELECT
    t.merchant_category,
    c360.churned_90d,
    COUNT(DISTINCT t.customer_id)                         AS unique_customers,
    COUNT(*)                                              AS transaction_count,
    ROUND(AVG(ABS(t.amount)), 2)                          AS avg_transaction_amt_eur
FROM transactions AS t
INNER JOIN customer_360 AS c360
    ON t.customer_id = c360.customer_id
WHERE t.transaction_type = 'Debit'
GROUP BY t.merchant_category, c360.churned_90d
ORDER BY t.merchant_category, c360.churned_90d;

GO

-- Query 8.2: Channel usage — churned vs. retained
SELECT
    t.channel,
    CASE c360.churned_90d WHEN 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT t.customer_id)                         AS unique_customers,
    COUNT(*)                                              AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY c360.churned_90d), 2) AS pct_of_status_txns
FROM transactions AS t
INNER JOIN customer_360 AS c360
    ON t.customer_id = c360.customer_id
GROUP BY t.channel, c360.churned_90d
ORDER BY t.channel, c360.churned_90d;

GO

-- =============================================================================
-- SECTION 9: VALIDATION QUERIES
-- =============================================================================

-- Query 9.1: Sanity check — row counts
SELECT 'customers'        AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'accounts',                       COUNT(*) FROM accounts
UNION ALL
SELECT 'products',                       COUNT(*) FROM products
UNION ALL
SELECT 'customer_products',              COUNT(*) FROM customer_products
UNION ALL
SELECT 'transactions',                   COUNT(*) FROM transactions
UNION ALL
SELECT 'customer_360',                   COUNT(*) FROM customer_360
UNION ALL
SELECT 'churn_by_segment',               COUNT(*) FROM churn_by_segment;

GO

-- Query 9.2: Check for nulls in key columns
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)           AS null_customer_id,
    SUM(CASE WHEN churned_90d IS NULL THEN 1 ELSE 0 END)            AS null_churned_90d,
    SUM(CASE WHEN avg_balance_90d IS NULL THEN 1 ELSE 0 END)        AS null_avg_balance,
    SUM(CASE WHEN activity_tier IS NULL THEN 1 ELSE 0 END)          AS null_activity_tier,
    SUM(CASE WHEN balance_band IS NULL THEN 1 ELSE 0 END)           AS null_balance_band,
    SUM(CASE WHEN product_count_tier IS NULL THEN 1 ELSE 0 END)     AS null_product_tier
FROM customer_360;

GO
