-- =============================================================================
-- Contoso Banque — Churn Analysis Workshop
-- SQL Script 01: Customer Churn Views
-- Target: Fabric Lakehouse SQL Analytics Endpoint
-- =============================================================================
-- Instructions:
--   1. Navigate to your ChurnAnalysisLH Lakehouse
--   2. Click "SQL analytics endpoint" (top-right dropdown)
--   3. Open a new query window
--   4. Copy and run this script to create the views
-- =============================================================================

-- -----------------------------------------------------------------------------
-- View 1: vw_customer_360_enriched
-- Full customer view with all segmentation dimensions
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_customer_360_enriched AS
SELECT
    c360.customer_id,
    c360.age,
    c360.region,
    c360.tenure_months,
    c360.income_band,
    c360.risk_profile,
    c360.digital_active_flag,
    c360.churned_90d,
    c360.avg_balance_90d,
    c360.balance_trend,
    c360.active_product_count,
    c360.transaction_count_90d,
    c360.total_spend_90d,
    c360.activity_tier,
    c360.balance_band,
    c360.product_count_tier,
    -- Derived age group
    CASE
        WHEN c360.age < 30  THEN 'Under 30'
        WHEN c360.age < 45  THEN '30-44'
        WHEN c360.age < 60  THEN '45-59'
        WHEN c360.age < 70  THEN '60-69'
        ELSE '70+'
    END AS age_group,
    -- Churn label as text
    CASE c360.churned_90d
        WHEN 1 THEN 'Churned'
        ELSE 'Retained'
    END AS churn_status,
    -- Digital label
    CASE c360.digital_active_flag
        WHEN 1 THEN 'Digital'
        ELSE 'Non-Digital'
    END AS digital_label
FROM customer_360 AS c360;

GO

-- -----------------------------------------------------------------------------
-- View 2: vw_churn_by_activity
-- Churn KPIs aggregated by activity tier
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_activity AS
SELECT
    activity_tier,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    COUNT(*) - SUM(churned_90d)                           AS retained_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur,
    ROUND(AVG(CAST(transaction_count_90d AS FLOAT)), 1)   AS avg_txn_count,
    ROUND(AVG(CAST(active_product_count AS FLOAT)), 2)    AS avg_product_count
FROM customer_360
GROUP BY activity_tier;

GO

-- -----------------------------------------------------------------------------
-- View 3: vw_churn_by_balance_band
-- Churn KPIs aggregated by balance band
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_balance_band AS
SELECT
    balance_band,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur,
    ROUND(MIN(avg_balance_90d), 2)                        AS min_balance_eur,
    ROUND(MAX(avg_balance_90d), 2)                        AS max_balance_eur
FROM customer_360
GROUP BY balance_band;

GO

-- -----------------------------------------------------------------------------
-- View 4: vw_churn_by_product_tier
-- Churn KPIs aggregated by product count tier
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_product_tier AS
SELECT
    product_count_tier,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(CAST(active_product_count AS FLOAT)), 2)    AS avg_active_products,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur
FROM customer_360
GROUP BY product_count_tier;

GO

-- -----------------------------------------------------------------------------
-- View 5: vw_churn_by_income_band
-- Churn KPIs aggregated by income band
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_income_band AS
SELECT
    income_band,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur,
    ROUND(AVG(CAST(active_product_count AS FLOAT)), 2)    AS avg_product_count
FROM customer_360
GROUP BY income_band;

GO

-- -----------------------------------------------------------------------------
-- View 6: vw_churn_digital_vs_nondigital
-- Churn KPIs comparing digital vs. non-digital customers
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_digital_vs_nondigital AS
SELECT
    CASE digital_active_flag
        WHEN 1 THEN 'Digital'
        ELSE 'Non-Digital'
    END                                                   AS digital_segment,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur,
    ROUND(AVG(CAST(transaction_count_90d AS FLOAT)), 1)   AS avg_txn_count
FROM customer_360
GROUP BY digital_active_flag;

GO

-- -----------------------------------------------------------------------------
-- View 7: vw_churn_by_region
-- Churn KPIs by geographic region
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_region AS
SELECT
    region,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur
FROM customer_360
GROUP BY region;

GO

-- -----------------------------------------------------------------------------
-- View 8: vw_churn_by_balance_trend
-- Churn KPIs by balance trend (Growing / Stable / Declining)
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_churn_by_balance_trend AS
SELECT
    balance_trend,
    COUNT(*)                                              AS total_customers,
    SUM(churned_90d)                                      AS churned_customers,
    ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2)         AS churn_rate_pct,
    ROUND(AVG(avg_balance_90d), 2)                        AS avg_balance_eur
FROM customer_360
GROUP BY balance_trend;

GO

-- =============================================================================
-- Validation query — run after creating views
-- =============================================================================
-- SELECT 'vw_customer_360_enriched' AS view_name, COUNT(*) AS row_count FROM vw_customer_360_enriched
-- UNION ALL
-- SELECT 'vw_churn_by_activity',    COUNT(*) FROM vw_churn_by_activity
-- UNION ALL
-- SELECT 'vw_churn_by_balance_band', COUNT(*) FROM vw_churn_by_balance_band
-- UNION ALL
-- SELECT 'vw_churn_by_product_tier', COUNT(*) FROM vw_churn_by_product_tier
-- UNION ALL
-- SELECT 'vw_churn_by_income_band',  COUNT(*) FROM vw_churn_by_income_band
-- UNION ALL
-- SELECT 'vw_churn_digital_vs_nondigital', COUNT(*) FROM vw_churn_digital_vs_nondigital
-- UNION ALL
-- SELECT 'vw_churn_by_region',       COUNT(*) FROM vw_churn_by_region
-- UNION ALL
-- SELECT 'vw_churn_by_balance_trend', COUNT(*) FROM vw_churn_by_balance_trend;
