# Assets

This folder contains the architecture diagram and placeholder visuals for the workshop.

## Architecture Diagram

| File | Description |
|---|---|
| [`architecture_diagram.svg`](architecture_diagram.svg) | End-to-end data architecture — Notebook → Lakehouse → SQL / Power BI / Data Agent |

Embed in a Markdown file with:
```markdown
![Architecture](assets/architecture_diagram.svg)
```

## Workshop Screenshots

Real `.png` screenshots captured during a live end-to-end run of the workshop (Fabric, `sales` capacity) are now embedded in the main [`README.md`](../README.md). The original `.svg` files are kept as fallback placeholders. Steps 03 and 09 relate to **OneLake file explorer**, which was intentionally skipped during this run.

| Screenshot | Status | Source |
|---|---|---|
| [`01_workspace_overview.png`](01_workspace_overview.png) | ✅ Captured | Fabric workspace showing all created items |
| [`02_lakehouse_tables.png`](02_lakehouse_tables.png) | ✅ Captured | ChurnAnalysisLH — Tables section after notebook 01 |
| [`03_onelake_explorer.svg`](03_onelake_explorer.svg) | ⏭️ Skipped (OneLake Explorer) | Windows File Explorer showing OneLake folder |
| [`04_notebook_01_run_all.png`](04_notebook_01_run_all.png) | ✅ Captured | Notebook 01 after successful Run All |
| [`05_notebook_02_run_all.png`](05_notebook_02_run_all.png) | ✅ Captured | Notebook 02 after successful Run All |
| [`06_sql_endpoint_query.png`](06_sql_endpoint_query.png) | ✅ Captured | SQL analytics endpoint running a churn query |
| [`07_powerbi_report.png`](07_powerbi_report.png) | ✅ Captured | Power BI churn visualization (Explore this data) |
| [`08_data_agent_question.png`](08_data_agent_question.png) | ✅ Captured | Data Agent answering a business question |
| [`09_onelake_raw_files.svg`](09_onelake_raw_files.svg) | ⏭️ Skipped (OneLake Explorer) | OneLake Explorer showing Files/churn/raw/ after ingestion |

When replacing a placeholder with a real screenshot:
1. Capture the screenshot as a `.png`.
2. Compress it to under 500 KB (use [Squoosh](https://squoosh.app) or similar).
3. Name it with the same number prefix (e.g., `01_workspace_overview.png`).
4. Update any Markdown `![...]()` references to point to the `.png` file.
5. You may delete the corresponding `.svg` placeholder once the real screenshot is in place.

> **Note:** Keep asset file sizes reasonable (< 500 KB per image) to keep the repository lightweight.
