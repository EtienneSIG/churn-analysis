-- =============================================================================
-- Contoso Banque — Churn Analysis Workshop
-- SQL Script 03: Custom Segmentation Queries
-- Target: Fabric Lakehouse SQL Analytics Endpoint
-- =============================================================================
-- Prerequisites:
--   1. Run 01_customer_churn_views.sql first (creates helper views).
--   2. Upload data/customer_custom_segment.csv via OneLake Explorer and load
--      it as the Delta table "customer_custom_segment" (see Step 3 of the
--      workshop guide).
-- =============================================================================

-- =============================================================================
-- SECTION 1: OVERVIEW OF CUSTOM SEGMENTS
-- =============================================================================

-- Query 1.1: Distribution of customers across custom segments
SELECT
    custom_segment,
    COUNT(*)                                              AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)   AS pct_of_total
FROM customer_custom_segment
GROUP BY custom_segment
ORDER BY customer_count DESC;

GO

-- Query 1.2: Cross-reference — churn rate by custom segment
-- Join customer_custom_segment with customer_360 to analyse churn per segment
SELECT
    cs.custom_segment,
    COUNT(*)                                              AS total_customers,
    SUM(c360.churned_90d)                                 AS churned_customers,
    COUNT(*) - SUM(c360.churned_90d)                      AS retained_customers,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)    AS churn_rate_pct,
    ROUND(AVG(c360.avg_balance_90d), 0)                   AS avg_balance_eur,
    ROUND(AVG(CAST(c360.active_product_count AS FLOAT)), 2) AS avg_product_count,
    ROUND(AVG(CAST(c360.transaction_count_90d AS FLOAT)), 1) AS avg_txn_count
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
GROUP BY cs.custom_segment
ORDER BY churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 2: CUSTOM SEGMENT × INTERNAL SEGMENTS (CROSS-ANALYSIS)
-- =============================================================================

-- Query 2.1: Custom segment × activity tier — heatmap-ready cross-tab
SELECT
    cs.custom_segment,
    c360.activity_tier,
    COUNT(*)                                              AS customer_count,
    SUM(c360.churned_90d)                                 AS churned_customers,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)    AS churn_rate_pct
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
GROUP BY cs.custom_segment, c360.activity_tier
ORDER BY cs.custom_segment, churn_rate_pct DESC;

GO

-- Query 2.2: Custom segment × balance band
SELECT
    cs.custom_segment,
    c360.balance_band,
    COUNT(*)                                              AS customer_count,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)    AS churn_rate_pct,
    ROUND(AVG(c360.avg_balance_90d), 0)                   AS avg_balance_eur
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
GROUP BY cs.custom_segment, c360.balance_band
ORDER BY cs.custom_segment, churn_rate_pct DESC;

GO

-- Query 2.3: Custom segment × income band
SELECT
    cs.custom_segment,
    c360.income_band,
    COUNT(*)                                              AS customer_count,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)    AS churn_rate_pct
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
GROUP BY cs.custom_segment, c360.income_band
ORDER BY cs.custom_segment, churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 3: SEGMENT-LEVEL PROFILE CARDS
-- =============================================================================

-- Query 3.1: Full profile for each custom segment
-- Use this to understand what makes each segment different
SELECT
    cs.custom_segment,
    COUNT(*)                                              AS total_customers,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)   AS churn_rate_pct,
    ROUND(AVG(c360.age), 1)                               AS avg_age,
    ROUND(AVG(c360.tenure_months), 1)                     AS avg_tenure_months,
    ROUND(AVG(c360.avg_balance_90d), 0)                   AS avg_balance_eur,
    ROUND(AVG(CAST(c360.active_product_count AS FLOAT)), 2) AS avg_product_count,
    ROUND(AVG(CAST(c360.transaction_count_90d AS FLOAT)), 1) AS avg_txn_count,
    ROUND(AVG(CAST(c360.digital_active_flag AS FLOAT)) * 100, 1) AS pct_digital
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
GROUP BY cs.custom_segment
ORDER BY churn_rate_pct DESC;

GO

-- Query 3.2: "At Risk" segment — deep dive
-- Focus on customers the business has already flagged as at risk
SELECT
    c360.activity_tier,
    c360.balance_band,
    c360.product_count_tier,
    c360.income_band,
    COUNT(*)                                              AS customer_count,
    SUM(c360.churned_90d)                                 AS churned_customers,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)   AS churn_rate_pct
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
WHERE cs.custom_segment = 'At Risk'
GROUP BY c360.activity_tier, c360.balance_band, c360.product_count_tier, c360.income_band
HAVING COUNT(*) >= 10
ORDER BY churn_rate_pct DESC;

GO

-- =============================================================================
-- SECTION 4: CUSTOM SEGMENT DELTA vs BASELINE
-- =============================================================================

-- Query 4.1: How much does each custom segment deviate from the overall churn rate?
WITH overall AS (
    SELECT ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2) AS baseline_churn_rate
    FROM customer_360 AS c360
)
SELECT
    cs.custom_segment,
    COUNT(*)                                              AS total_customers,
    ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2)   AS segment_churn_rate_pct,
    overall.baseline_churn_rate,
    ROUND(
        ROUND(100.0 * SUM(c360.churned_90d) / COUNT(*), 2) - overall.baseline_churn_rate,
        2
    )                                                     AS delta_vs_baseline
FROM customer_custom_segment AS cs
INNER JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id
CROSS JOIN overall
GROUP BY cs.custom_segment, overall.baseline_churn_rate
ORDER BY delta_vs_baseline DESC;

GO

-- =============================================================================
-- SECTION 5: VALIDATION
-- =============================================================================

-- Query 5.1: Row count and join coverage check
-- All 10,000 customers in customer_custom_segment should join to customer_360
SELECT
    COUNT(*)                                              AS total_in_custom_segment,
    COUNT(c360.customer_id)                               AS matched_in_customer_360,
    COUNT(*) - COUNT(c360.customer_id)                    AS unmatched_customers
FROM customer_custom_segment AS cs
LEFT JOIN customer_360 AS c360
    ON cs.customer_id = c360.customer_id;

GO
