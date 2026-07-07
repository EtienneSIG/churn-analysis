# Power BI Report Design Guide
## Contoso Banque — Customer Churn Analysis Dashboard

This guide describes the recommended layout and visuals for the Power BI report built on top of the Fabric Lakehouse data.

---

## Before You Start

Ensure the following are ready:
1. Notebooks 01 and 02 have run successfully.
2. `customer_360` and `churn_by_segment` tables exist in `ChurnAnalysisLH`.
3. You have created a semantic model from the Lakehouse (see Step 7 in the main README).

---

## Semantic Model Setup

### Tables to Include

| Table | Role |
|---|---|
| `customer_360` | Main analytical table — one row per customer |
| `churn_by_segment` | Pre-aggregated KPIs by segment |
| `customers` | Source demographics |
| `accounts` | Balance and account type data |

### Recommended Measures (DAX)

Create these measures in the semantic model or in the Power BI report editor:

```dax
-- Overall churn rate (decimal, 0–1) divided by total rows, then * 100 to express as percentage.
-- DIVIDE returns 0 when the denominator is zero, so 0 * 100 = 0 (correct, no division-by-zero risk).
Churn Rate % = 
    DIVIDE(
        CALCULATE(COUNTROWS(customer_360), customer_360[churned_90d] = 1),
        COUNTROWS(customer_360),
        0
    ) * 100

-- Total churned customers
Churned Customers = 
    CALCULATE(COUNTROWS(customer_360), customer_360[churned_90d] = 1)

-- Total retained customers
Retained Customers = 
    CALCULATE(COUNTROWS(customer_360), customer_360[churned_90d] = 0)

-- Average balance (all customers)
Avg Balance = AVERAGE(customer_360[avg_balance_90d])

-- Average balance — churned only
Avg Balance Churned = 
    CALCULATE(AVERAGE(customer_360[avg_balance_90d]), customer_360[churned_90d] = 1)

-- Average balance — retained only
Avg Balance Retained = 
    CALCULATE(AVERAGE(customer_360[avg_balance_90d]), customer_360[churned_90d] = 0)

-- Average active products
Avg Products = AVERAGE(customer_360[active_product_count])

-- % Digital customers (among all)
% Digital = 
    DIVIDE(
        CALCULATE(COUNTROWS(customer_360), customer_360[digital_active_flag] = 1),
        COUNTROWS(customer_360),
        0
    ) * 100
```

---

## Report Pages

### Page 1 — Executive Summary

**Purpose:** Give a one-glance overview of the churn situation.

| Visual | Type | Fields | Notes |
|---|---|---|---|
| Overall Churn Rate | KPI Card | `[Churn Rate %]` | Show trend if multi-period data |
| Churned Customers | KPI Card | `[Churned Customers]` | Big number display |
| Retained Customers | KPI Card | `[Retained Customers]` | For reference |
| Avg Balance — Churned | KPI Card | `[Avg Balance Churned]` | Compare vs. retained |
| Avg Balance — Retained | KPI Card | `[Avg Balance Retained]` | Benchmark |
| Churn by Activity Tier | Bar chart | `activity_tier` / `[Churn Rate %]` | Sort descending by churn rate |
| Churn by Product Tier | Bar chart | `product_count_tier` / `[Churn Rate %]` | Single-product risk visible |
| Churn by Digital Status | Donut/Bar | `digital_label` / `[Churn Rate %]` | Digital vs. non-digital |
| Slicer — Region | Slicer | `region` | Multi-select |
| Slicer — Income Band | Slicer | `income_band` | Multi-select |

**Layout tip:** Place 4 KPI cards in the top row, then 3 charts below. Add slicers on the right side panel.

---

### Page 2 — Segment Deep Dive

**Purpose:** Let users explore churn across multiple segment dimensions.

| Visual | Type | Fields | Notes |
|---|---|---|---|
| Churn Rate by Balance Band | Clustered bar | `balance_band` / `[Churn Rate %]` | Color-code by churn severity |
| Churn Rate by Activity Tier | Clustered bar | `activity_tier` / `[Churn Rate %]` | |
| Churn Rate by Balance Trend | Bar | `balance_trend` / `[Churn Rate %]` | Growing/Stable/Declining |
| Churn Rate by Age Group | Line / bar | `age_group` / `[Churn Rate %]` | Trend by age |
| Scatter — Avg Balance vs. Churn Rate | Scatter | X: `avg_balance_90d` / Y: `[Churn Rate %]` / Size: `total_customers` | Segment level, use `churn_by_segment` |
| Matrix — Activity × Balance Churn | Matrix | Rows: `activity_tier` / Cols: `balance_band` / Values: `[Churn Rate %]` | Heat-map style conditional formatting |
| Slicer — Income Band | Slicer | `income_band` | |
| Slicer — Region | Slicer | `region` | |

**Tip:** Apply conditional formatting to the Matrix visual — green (low churn) to red (high churn) gradient.

---

### Page 3 — Customer Profile

**Purpose:** Understand who the churned customers are as individuals.

| Visual | Type | Fields | Notes |
|---|---|---|---|
| Age Distribution — Churned vs. Retained | Histogram / bar | `age_group` / count / `churned_90d` | Stacked bar with churn status |
| Region Map | Map visual | `region` / `[Churn Rate %]` | Color by churn rate |
| Income Band × Digital — Churn Rate | Matrix | `income_band` × `digital_label` / `[Churn Rate %]` | |
| Risk Profile Breakdown | Donut | `risk_profile` / count | Churned customers only |
| Customer Table | Table | `customer_id`, `age`, `region`, `activity_tier`, `balance_band`, `product_count_tier`, `churned_90d` | Drill-through enabled |
| Slicer — Churn Status | Slicer | `churn_status` (`"Churned"` / `"Retained"`) | |

---

### Page 4 — Data Agent Companion (Optional)

**Purpose:** Add context for the Fabric Data Agent conversation — not typically a standalone report page, but useful for demos.

| Visual | Type | Fields | Notes |
|---|---|---|---|
| Churn KPI Summary | Table | All `churn_by_segment` rows | Useful as a data reference |
| Churn Rate Ranking | Ranked bar | All segments by `churn_rate_pct` | Quick reference for agent answers |

---

## Formatting Tips

### Color Palette (Contoso Banque theme)

```
Primary:   #003A8C  (dark blue)
Secondary: #0078D4  (Microsoft blue)
Accent:    #E8272E  (red — for high churn alerts)
Neutral:   #F2F2F2  (light grey — background)
Success:   #107C10  (green — low churn / good)
```

### Conditional Formatting for Churn Rate

- Green: churn rate < 10%
- Yellow: churn rate 10%–25%
- Red: churn rate > 25%

Apply this to bar charts and matrix visuals for immediate visual signal.

### Report Settings

- Canvas size: 16:9 (1280×720)
- Font: Segoe UI
- Show gridlines: Off
- Theme: Apply the custom **Contoso Banque** theme — see [`powerbi/contoso_banque_theme.json`](contoso_banque_theme.json).
  - In Power BI Desktop: **View** → **Themes** → **Browse for themes** → select `contoso_banque_theme.json`.
  - In the Fabric report editor: **Format** → **Theme** → **Upload theme**.

---

## Publishing the Report

1. In Power BI Desktop or Fabric report editor, click **Save**.
2. The report is automatically saved to your Fabric workspace.
3. To share: go to the workspace, open the report, and click **Share** → enter email addresses.
4. For a broader audience, consider publishing a link via **Publish to web** (check with your admin first — this makes the report public).

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Semantic model shows no data | Ensure notebooks 01 and 02 have run successfully and Delta tables exist |
| Relationships not auto-detected | Manually create relationships: `customer_360[customer_id]` → `customers[customer_id]` |
| Measures returning blank | Check that the table name in DAX matches exactly (case-sensitive) |
| Map visual shows no regions | Fabric map requires geographic fields to be marked as "Geography" → Data category: City/State/Country |
