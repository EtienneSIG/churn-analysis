# Fabric Data Agent Setup Guide

## Contoso Banque — Churn Analysis Workshop

This guide walks you through creating and configuring a **Microsoft Fabric Data Agent** for the Contoso Banque churn analysis workshop.

A Fabric Data Agent lets business users and analysts ask questions about data in plain, everyday English — no SQL required. The agent uses the tables in your Lakehouse (or semantic model) as its knowledge base and generates the answers automatically.

---

## What Is a Fabric Data Agent?

A **Fabric Data Agent** is an AI-powered conversational interface that:

- Connects to your Fabric data sources (Lakehouse, Warehouse, or Semantic Model).
- Understands natural language questions.
- Generates and executes SQL queries behind the scenes.
- Returns answers with the underlying query for transparency.

It is powered by Azure OpenAI Service and is integrated directly into the Fabric experience — no external setup required.

> **Note:** The Data Agent feature requires Copilot / AI features to be enabled for your tenant. Check with your Fabric administrator if you are unsure.

---

## Prerequisites

Before starting:

- [ ] Notebooks 01 and 02 have run successfully.
- [ ] Tables `customer_360`, `churn_by_segment`, `customers`, `accounts`, `transactions` exist in `ChurnAnalysisLH`.
- [ ] Copilot / AI features are enabled in your tenant (Fabric Admin Portal → Tenant Settings → Copilot and Azure OpenAI Service Settings).
- [ ] You have **at least Viewer** access to the Lakehouse.
- [ ] Your capacity is in a supported region. Check the [Fabric Copilot region availability](https://learn.microsoft.com/fabric/data-science/copilot-fabric-overview#available-regions) page.

---

## Step 1 — Create the Data Agent

1. Open [Microsoft Fabric](https://app.fabric.microsoft.com) and navigate to your workspace.
2. Click **+ New item**.
3. In the search box, type **"Data agent"**.
4. If you see the Data Agent item, click it. If it does not appear, the feature may not yet be enabled for your tenant or region — check the prerequisites above.
5. Name the agent: **`Contoso Banque Churn Agent`**.
6. Click **Create**.

---

## Step 2 — Add Data Sources

1. In the Data Agent editor, look for the **Data sources** panel (usually on the left or in a setup wizard).
2. Click **+ Add data source** (or **+ Connect**).
3. Select **Lakehouse**.
4. From the list, choose **`ChurnAnalysisLH`**.
5. Select the tables to include:
   - [x] `customer_360`
   - [x] `churn_by_segment`
   - [x] `customers`
   - [x] `accounts`
   - [x] `customer_custom_segment`
   - [ ] `transactions` (optional — adds query complexity; include if you want transaction-level questions)
6. Click **Confirm** or **Save**.

> **Tip:** Including fewer tables makes the agent faster and more accurate. Start with `customer_360` and `churn_by_segment`, then add more tables if needed.

---

## Step 3 — Add Business Context Instructions

The **Instructions** field tells the agent what it is, what the data means, and how to interpret business terms. Good instructions dramatically improve answer quality.

In the **Instructions / System prompt** text box, enter:

```
You are an analytics assistant for Contoso Banque, a fictional European retail bank.
Your purpose is to help the analytics team explore customer churn patterns.

KEY DEFINITIONS:
- 'churned_90d' = 1 means the customer has been flagged as churned in the last 90 days.
- 'churned_90d' = 0 means the customer is retained.
- 'activity_tier' groups customers by 90-day transaction frequency:
    "High" (≥10 txns), "Medium" (4–9 txns), "Low" (1–3 txns), "Inactive" (0 txns).
- 'balance_band' groups customers by avg 90-day balance:
    "High" (≥€25,000), "Medium" (€5,000–€24,999), "Low" (€500–€4,999), "Very Low" (<€500).
- 'product_count_tier' groups by number of active products:
    "Multi-product" (≥3), "Dual" (2), "Single" (1), "No product" (0).
- 'digital_active_flag' = 1 means the customer uses digital banking channels.
- 'custom_segment' is a business-defined label from an external CRM segmentation:
    "VIP" = high-value customers prioritised for premium service.
    "Loyal" = long-standing customers with stable engagement.
    "At Risk" = customers flagged by the business team as potentially churning.
    "New Joiner" = recently acquired customers.
    "Dormant" = customers with very low or no recent activity.
  To use it, JOIN customer_custom_segment ON customer_id with customer_360 or customers.

IMPORTANT:
- All data is synthetic and fictional, used for a learning workshop.
- All monetary amounts are in EUR.
- "Churn rate" means churned_90d = 1 divided by total customers, as a percentage.
- When asked about "risk", refer to activity_tier or churn_rate_pct, not risk_profile.

TONE:
- Be concise and helpful.
- Always show the churn rate as a percentage (e.g., "23.4%").
- Round balances to the nearest euro.
- When comparing segments, highlight the most significant difference.
```

Click **Save instructions**.

---

## Step 4 — Test the Agent

Switch to the **Chat** tab in the Data Agent editor and test the following questions. Compare the answers to what you found in your SQL queries and Power BI report.

### Basic Questions

1. **"What is the overall churn rate?"**
   - Expected: ~18–22%

2. **"How many customers are in the dataset?"**
   - Expected: 10,000

3. **"How many customers have churned?"**
   - Expected: ~1,800–2,200

### Segment Questions

4. **"Which activity tier has the highest churn rate?"**
   - Expected: "Inactive" tier (~40%+)

5. **"What is the churn rate for single-product customers compared to multi-product customers?"**
   - Expected: Single-product significantly higher than multi-product

6. **"Show me churn rate by balance band."**
   - Expected: Table or breakdown by High / Medium / Low / Very Low

7. **"Is there a difference in churn rate between digital and non-digital customers?"**
   - Expected: Non-digital higher churn rate

### Business Insight Questions

8. **"What is the average balance of churned customers vs. retained customers?"**
   - Expected: Churned customers have lower average balance

9. **"Which region has the highest churn rate?"**
   - Expected: One of the French regions, varies by random seed

10. **"What are the top 3 segments I should focus on to reduce churn?"**
    - Expected: Inactive customers, single-product customers, declining balance customers

### Custom Segment Questions

11. **"What is the churn rate for each custom segment?"**
    - Expected: A table with 5 rows (VIP, Loyal, At Risk, New Joiner, Dormant) and their respective churn rates

12. **"Which custom segment has the highest churn rate?"**
    - Expected: One of the segments — compare with your SQL results from `sql/03_custom_segment_queries.sql`

13. **"How many 'At Risk' customers are in the dataset and what is their churn rate?"**
    - Expected: ~1,960 customers; the agent should JOIN `customer_custom_segment` with `customer_360`

14. **"Compare the average balance of VIP customers vs. Dormant customers."**
    - Expected: The agent joins both tables on `customer_id` and groups by `custom_segment`

### Validation Questions (from `notebooks/03_data_agent_validation_questions.md`)

See the full list of validation questions and expected answers in [`notebooks/03_data_agent_validation_questions.md`](../notebooks/03_data_agent_validation_questions.md).

---

## Step 5 — Review the Generated SQL

For each question, the Data Agent shows the SQL query it generated. This is useful for:
- **Validating accuracy** — compare to your known SQL queries.
- **Learning** — see how natural language maps to SQL.
- **Debugging** — if an answer seems wrong, inspect the SQL.

Click **"View query"** or **"Show SQL"** next to any answer to see the generated query.

---

## Step 6 — Publish the Data Agent

The Data Agent must be **published** before it can be consumed by other tools — including the **Microsoft Foundry** agent in Part 2. An unpublished (draft) agent is not visible as a data source in Foundry.

1. In the Data Agent editor, click **Publish** (top-right).
2. In the **Publish data agent** dialog, confirm the **Name** (e.g., `Contoso Churn Analysis Agent`).
3. In **Description of purpose and capabilities**, paste the following:

```
Answers natural-language questions about Contoso Banque customer churn. It queries the ChurnAnalysisLH Lakehouse (customer_360, churn_by_segment, customer_custom_segment, customers, accounts) to report churn rates, customer counts, and segment breakdowns by activity tier, balance band, product-count tier, digital activity, region, and custom CRM segments (VIP, Loyal, At Risk, New Joiner, Dormant). Use it for questions like "What is the overall churn rate?", "Which activity tier has the highest churn?", or "Compare churn between VIP and At Risk customers." All data is synthetic and used for a learning workshop; monetary amounts are in EUR.
```

4. Leave **Also publish to the Agent Store in Microsoft 365 Copilot** set to **Off** (not needed for this workshop).
5. Click **Publish**.

> 💡 **Why publish?** Publishing creates a stable, shareable version of the agent and exposes it to downstream consumers. In Part 2, the Foundry agent connects to this **published** Data Agent using its workspace ID and artifact ID (see the **Microsoft Foundry** part of the main [`README.md`](../README.md#step-12--create-the-fabric-connection)).

### 6.1 Validate

- The agent item shows a **Published** status in the workspace.
- Re-running a test question still returns the expected answer.

---

## Step 7 — Share the Agent (Optional)

1. In the Fabric workspace, find the **Contoso Banque Churn Agent** item.
2. Click the **...** menu → **Share**.
3. Enter the email addresses of colleagues you want to share it with.
4. Choose permission level: **Can use** (for end users) or **Can edit** (for collaborators).
5. Click **Share**.

Shared users can ask questions through the same Data Agent interface.

---

## Troubleshooting

| Problem | Solution |
|---|---|
| "Data Agent" not found in New Item | Feature may not be enabled in your tenant. Check Fabric Admin Portal → Tenant Settings → Copilot and AI settings. |
| Agent not finding tables | Ensure tables exist in the Lakehouse and were included when adding the data source. |
| Wrong or surprising answers | Improve the Instructions text — add more explicit business definitions. |
| Agent times out | Large tables (like `transactions`) can slow queries. Remove `transactions` from data sources if not needed. |
| Agent answers in a different language | Add to instructions: "Always respond in English regardless of the question language." |
| Capacity not supported | Data Agent requires Fabric capacity (F-SKU or P-SKU). Power BI Premium P1 alone is not sufficient in all regions. |

---

## Data Agent Architecture (How It Works)

```
User asks a question in plain English
        ↓
Fabric Data Agent (Azure OpenAI Service)
  → Reads table schemas and instructions
  → Generates a SQL query
  → Executes query against SQL analytics endpoint
  → Formats the result
        ↓
Agent returns the answer + the SQL query (for transparency)
```

The agent never directly accesses your raw data — it queries the **SQL analytics endpoint** of your Lakehouse, which only has access to the Delta tables you selected as data sources.

---

## Additional Resources

- [Fabric Data Agent overview](https://learn.microsoft.com/fabric/data-science/data-agent-overview)
- [Fabric Copilot and AI features](https://learn.microsoft.com/fabric/data-science/copilot-fabric-overview)
- [Fabric Admin Portal — Tenant Settings](https://learn.microsoft.com/fabric/admin/tenant-settings-index)
- [Copilot region availability](https://learn.microsoft.com/fabric/data-science/copilot-fabric-overview#available-regions)
