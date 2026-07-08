# Data Model — Contoso Banque Churn Analysis

> All data is **synthetic and fictional**. No real customer data, PII, or financial data is used. "Contoso Banque" is a fictional bank used for educational purposes only.

This folder documents the data model used in the workshop. No actual data files are stored here — all data is generated on-the-fly inside the Fabric notebook (`notebooks/01_generate_and_ingest_banking_data.ipynb`).

---

## Entity Relationship Overview

```
customers (1) ──────< accounts (many)
customers (1) ──────< customer_products (many) >────── products (1)
accounts  (1) ──────< transactions (many)
customers (1) ──────< transactions (many)
```

---

## Table Schemas

### `customers`

One row per customer. The main entity.

| Column | Type | Description |
|---|---|---|
| `customer_id` | STRING | Unique customer identifier (e.g., `CUST-00001`) |
| `age` | INTEGER | Customer age in years (18–85) |
| `region` | STRING | French administrative region (e.g., `Île-de-France`, `Auvergne-Rhône-Alpes`) |
| `customer_since_date` | DATE | Date the customer joined Contoso Banque |
| `tenure_months` | INTEGER | Number of months since customer joined |
| `income_band` | STRING | `"Low"`, `"Medium"`, `"High"`, `"Very High"` |
| `risk_profile` | STRING | `"Conservative"`, `"Moderate"`, `"Aggressive"` |
| `digital_active_flag` | INTEGER | `1` = uses digital banking; `0` = branch/phone only |
| `churned_90d` | INTEGER | **Target label** — `1` = churned in last 90 days (synthetic heuristic) |

---

### `accounts`

One row per bank account. Customers can have multiple accounts.

| Column | Type | Description |
|---|---|---|
| `account_id` | STRING | Unique account identifier (e.g., `ACC-00001`) |
| `customer_id` | STRING | Foreign key → `customers.customer_id` |
| `account_type` | STRING | `"Checking"`, `"Savings"`, `"Joint"`, `"Business"` |
| `open_date` | DATE | Date the account was opened |
| `current_balance` | DOUBLE | Current balance in EUR |
| `avg_balance_90d` | DOUBLE | Average balance over the last 90 days in EUR |
| `balance_trend` | STRING | `"Growing"`, `"Stable"`, `"Declining"` |

---

### `products`

Product catalogue — one row per product offered by Contoso Banque.

| Column | Type | Description |
|---|---|---|
| `product_id` | STRING | Unique product identifier |
| `product_category` | STRING | `"Savings"`, `"Credit"`, `"Insurance"`, `"Investment"`, `"Lending"` |
| `product_name` | STRING | Friendly product name (e.g., `"Livret Contoso"`, `"Carte Platinum"`) |
| `product_family` | STRING | `"Retail Banking"`, `"Wealth Management"`, `"Consumer Finance"` |

---

### `customer_products`

Junction table — which products each customer holds.

| Column | Type | Description |
|---|---|---|
| `customer_id` | STRING | Foreign key → `customers.customer_id` |
| `product_id` | STRING | Foreign key → `products.product_id` |
| `product_start_date` | DATE | Date the customer subscribed to this product |
| `active_product_flag` | INTEGER | `1` = currently active; `0` = cancelled |

---

### `transactions`

One row per transaction. This is the largest table (~175,000 rows).

| Column | Type | Description |
|---|---|---|
| `transaction_id` | STRING | Unique transaction identifier |
| `account_id` | STRING | Foreign key → `accounts.account_id` |
| `customer_id` | STRING | Foreign key → `customers.customer_id` (denormalized for convenience) |
| `transaction_date` | DATE | Date of the transaction |
| `transaction_type` | STRING | `"Debit"`, `"Credit"`, `"Transfer"`, `"Direct Debit"` |
| `channel` | STRING | `"Online"`, `"Mobile"`, `"ATM"`, `"Branch"`, `"POS"` |
| `amount` | DOUBLE | Transaction amount in EUR (positive = credit, negative = debit) |
| `merchant_category` | STRING | Category of merchant (e.g., `"Grocery"`, `"Travel"`, `"Utilities"`) |

---

## Derived / Curated Tables

These tables are produced by `notebooks/02_transform_segment_analyze_churn.ipynb`.

### `customer_360`

One row per customer — a denormalized, enriched view combining all source tables.

| Column | Type | Description |
|---|---|---|
| `customer_id` | STRING | Unique customer identifier |
| `age` | INTEGER | Customer age |
| `region` | STRING | Customer region |
| `tenure_months` | INTEGER | Months as a customer |
| `income_band` | STRING | Income band |
| `risk_profile` | STRING | Risk profile |
| `digital_active_flag` | INTEGER | Digital activity flag |
| `churned_90d` | INTEGER | Churn label |
| `avg_balance_90d` | DOUBLE | Average balance across all accounts |
| `balance_trend` | STRING | Dominant balance trend |
| `active_product_count` | INTEGER | Number of active products |
| `transaction_count_90d` | INTEGER | Number of transactions in last 90 days |
| `total_spend_90d` | DOUBLE | Total debit amount in last 90 days |
| `activity_tier` | STRING | Segmentation: `"High"`, `"Medium"`, `"Low"`, `"Inactive"` |
| `balance_band` | STRING | Segmentation: `"High"`, `"Medium"`, `"Low"`, `"Very Low"` |
| `product_count_tier` | STRING | Segmentation: `"Multi-product"`, `"Dual"`, `"Single"`, `"No product"` |

---

### `churn_by_segment`

Aggregated churn KPIs grouped by segment.

| Column | Type | Description |
|---|---|---|
| `segment_dimension` | STRING | Which axis: `"activity_tier"`, `"balance_band"`, `"product_count_tier"`, `"income_band"` |
| `segment_value` | STRING | The segment label (e.g., `"Inactive"`) |
| `total_customers` | LONG | Count of customers in this segment |
| `churned_customers` | LONG | Count of churned customers in this segment |
| `churn_rate_pct` | DOUBLE | `churned / total × 100` |
| `avg_balance` | DOUBLE | Average `avg_balance_90d` for this segment |
| `avg_product_count` | DOUBLE | Average active product count for this segment |
| `avg_transaction_count` | DOUBLE | Average transaction count for this segment |

---

## Data Volume Summary

| Table | Approximate Row Count |
|---|---|
| `customers` | 10,000 |
| `accounts` | ~15,000 |
| `products` | 10 |
| `customer_products` | ~30,000 |
| `transactions` | ~175,000 |
| `customer_360` | 10,000 |
| `churn_by_segment` | ~16 (4 dimensions × ~4 values each) |

---

### `customer_custom_segment`

External custom segmentation provided as a CSV file (`data/customer_custom_segment.csv`). One row per customer. This file is uploaded to OneLake via OneLake Explorer and registered as a Delta table in Step 3 of the workshop.

It represents the kind of enrichment data a business analyst or CRM team might prepare outside the main data pipeline — for example, from a marketing system or manual classification exercise.

| Column | Type | Description |
|---|---|---|
| `customer_id` | STRING | Foreign key → `customers.customer_id` |
| `custom_segment` | STRING | Business-defined segment: `"VIP"`, `"Loyal"`, `"At Risk"`, `"New Joiner"`, `"Dormant"` |

**Segment definitions:**

| Value | Description |
|---|---|
| `VIP` | High-value customers prioritised for premium service (~10% of customers) |
| `Loyal` | Long-standing customers with stable engagement (~30%) |
| `At Risk` | Customers flagged by the business team as potentially churning (~20%) |
| `New Joiner` | Customers who joined recently (~15%) |
| `Dormant` | Customers with very low or no recent activity (~25%) |

> **Note:** This segmentation is synthetic and randomly assigned (seed 42) — it does not derive from the actual balance, activity, or churn data. It is designed to illustrate how an external segmentation enriches the existing analytical tables when joined on `customer_id`.

---

## Churn Label Generation Logic

The `churned_90d` flag is generated in `notebooks/01_generate_and_ingest_banking_data.ipynb` using the following business heuristics:

```
Base churn probability: 10%

Adjustments (additive):
  + 25% if transaction_count_90d == 0 (inactive)
  + 15% if balance_trend == "Declining"
  + 20% if active_product_count == 1
  + 10% if digital_active_flag == 0
  + 5%  if age > 70
  - 15% if active_product_count >= 3
  - 10% if digital_active_flag == 1 and transaction_count_90d >= 10

Final: churned_90d = 1 if random draw < adjusted_probability, else 0
```

This logic produces a realistic **overall churn rate of approximately 18–22%**, with significant variation by segment — which is exactly what the workshop is designed to uncover.
