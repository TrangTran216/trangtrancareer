# California Procurement Intelligence
## SQLite Analysis and Data-Quality Audit of Public Purchase Orders, FY 2012–2015

### Overview

This portfolio project analyzes 344,504 California public purchase-order line records in SQLite. The workflow preserves the raw import, standardizes analysis fields through a reusable view, audits missing and repeated records, creates analytical summaries, demonstrates relational joins, and reconciles the final reporting table to the source.

### Public data source

California Department of General Services, **Purchase Order Data 2012–2015**, California Open Data Portal:

https://lab.data.ca.gov/dataset/purchase-order-data

The dataset is historical public procurement information. Monetary totals in this project are reported source-line values and should not be interpreted as audited cash expenditures.

### Database objects

- `purchase_orders`: raw imported source table
- `vw_purchase_orders_clean`: reusable cleaning and standardization view
- `department_lookup`: normalized department lookup table
- `purchase_order_cleaned_summary`: grouped reporting table
- Four indexes supporting fiscal-year, department, supplier, and UNSPSC filters

### SQL techniques demonstrated

- `CREATE VIEW` and raw-to-clean architecture
- `TRIM`, `NULLIF`, `COALESCE`, `CAST`, and currency parsing
- `CASE WHEN` for quality flags and amount buckets
- CTEs, `GROUP BY`, `HAVING`, ranking, and aggregate statistics
- Primary keys, unique constraints, lookup-table design, and `LEFT JOIN`
- Row-count and monetary-total reconciliation
- Summary-table indexing

### Verified results

- Source records: **344,504**
- Distinct purchase-order numbers: **197,000**
- Departments: **111**
- Missing departments: **0**
- Missing supplier code and name: **36**
- Missing purchase amounts: **30**
- Repeated purchase-order identifiers: **33,956 groups**
- Exact duplicate audit: **1,305 groups / 2,087 extra rows**
- Reporting-summary rows: **150,297**
- Reconciled reported source-line value: **$150,517,871,463.40**
- Unmatched nonmissing departments after lookup join: **0**

### Files in this project package

- `california_procurement_sqlite_analysis.sql`: reproducible SQL workflow
- `outputs/`: selected CSV result exports
- `screenshots/`: database and query-result evidence

The 164 MB raw source CSV is intentionally not bundled with the website package. Retrieve it from the official source above when reproducing the analysis.
