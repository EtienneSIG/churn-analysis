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

## Workshop Screenshot Placeholders

SVG placeholders are provided for each workshop step. **Replace each `.svg` with a real `.png` screenshot** after completing the workshop to help future participants follow along.

| Placeholder file | Replace with screenshot from |
|---|---|
| [`01_workspace_overview.svg`](01_workspace_overview.svg) | Fabric workspace showing all created items |
| [`02_lakehouse_tables.svg`](02_lakehouse_tables.svg) | ChurnAnalysisLH — Tables section after notebook 01 |
| [`03_onelake_explorer.svg`](03_onelake_explorer.svg) | Windows File Explorer showing OneLake folder |
| [`04_notebook_01_run_all.svg`](04_notebook_01_run_all.svg) | Notebook 01 after successful Run All |
| [`05_notebook_02_run_all.svg`](05_notebook_02_run_all.svg) | Notebook 02 after successful Run All |
| [`06_sql_endpoint_query.svg`](06_sql_endpoint_query.svg) | SQL analytics endpoint running a churn query |
| [`07_powerbi_report.svg`](07_powerbi_report.svg) | Completed Power BI churn dashboard |
| [`08_data_agent_question.svg`](08_data_agent_question.svg) | Data Agent answering a business question |
| [`09_onelake_raw_files.svg`](09_onelake_raw_files.svg) | OneLake Explorer showing Files/churn/raw/ after ingestion |

When replacing a placeholder with a real screenshot:
1. Capture the screenshot as a `.png`.
2. Compress it to under 500 KB (use [Squoosh](https://squoosh.app) or similar).
3. Name it with the same number prefix (e.g., `01_workspace_overview.png`).
4. Update any Markdown `![...]()` references to point to the `.png` file.
5. You may delete the corresponding `.svg` placeholder once the real screenshot is in place.

> **Note:** Keep asset file sizes reasonable (< 500 KB per image) to keep the repository lightweight.
