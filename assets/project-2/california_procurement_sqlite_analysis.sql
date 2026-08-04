/*
====================================================================
CALIFORNIA PURCHASE ORDER PROJECT — DETAILED SQL FROM STEP 7 ONWARD
Database engine: SQLite
Raw table required: purchase_orders
====================================================================

RUNNING RULE
1. Select one numbered block at a time in your SQL editor.
2. Execute the selected block.
3. Read the validation query immediately after that block.
4. Do not edit the raw purchase_orders table.
*/

/* ==================================================================
   STEP 7 — CREATE THE REUSABLE CLEANED VIEW
   ================================================================== */

DROP VIEW IF EXISTS vw_purchase_orders_clean;

CREATE VIEW vw_purchase_orders_clean AS
SELECT
    rowid AS source_row_id,

    NULLIF(TRIM("Creation Date"), '') AS creation_date_raw,
    NULLIF(TRIM("Purchase Date"), '') AS purchase_date_raw,
    NULLIF(TRIM("Fiscal Year"), '') AS fiscal_year,
    NULLIF(TRIM("LPA Number"), '') AS lpa_number,
    NULLIF(TRIM("Purchase Order Number"), '') AS purchase_order_number,
    NULLIF(TRIM("Requisition Number"), '') AS requisition_number,

    NULLIF(TRIM("Acquisition Type"), '') AS acquisition_type,
    NULLIF(TRIM("Sub-Acquisition Type"), '') AS sub_acquisition_type,
    NULLIF(TRIM("Acquisition Method"), '') AS acquisition_method,
    NULLIF(TRIM("Sub-Acquisition Method"), '') AS sub_acquisition_method,

    NULLIF(TRIM("Department Name"), '') AS department_name,
    NULLIF(TRIM("Supplier Code"), '') AS supplier_code,
    NULLIF(TRIM("Supplier Name"), '') AS supplier_name,
    NULLIF(TRIM("Supplier Qualifications"), '') AS supplier_qualifications,
    NULLIF(TRIM("Supplier Zip Code"), '') AS supplier_zip_code,

    CASE UPPER(NULLIF(TRIM("CalCard"), ''))
        WHEN 'YES' THEN 1
        WHEN 'NO' THEN 0
        ELSE NULL
    END AS is_calcard,

    NULLIF(TRIM("Item Name"), '') AS item_name,
    NULLIF(TRIM("Item Description"), '') AS item_description,
    CAST(NULLIF(TRIM("Quantity"), '') AS REAL) AS quantity,

    CASE
        WHEN NULLIF(TRIM("Unit Price"), '') IS NULL THEN NULL
        WHEN TRIM("Unit Price") LIKE '(%' THEN
            -CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(TRIM("Unit Price"), '(', ''),
                            ')', ''
                        ),
                        '$', ''
                    ),
                    ',', ''
                ) AS REAL
            )
        ELSE
            CAST(
                REPLACE(
                    REPLACE(TRIM("Unit Price"), '$', ''),
                    ',', ''
                ) AS REAL
            )
    END AS unit_price,

    CASE
        WHEN NULLIF(TRIM("Total Price"), '') IS NULL THEN NULL
        WHEN TRIM("Total Price") LIKE '(%' THEN
            -CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(TRIM("Total Price"), '(', ''),
                            ')', ''
                        ),
                        '$', ''
                    ),
                    ',', ''
                ) AS REAL
            )
        ELSE
            CAST(
                REPLACE(
                    REPLACE(TRIM("Total Price"), '$', ''),
                    ',', ''
                ) AS REAL
            )
    END AS purchase_amount,

    NULLIF(TRIM("Classification Codes"), '') AS classification_codes,
    NULLIF(TRIM("Normalized UNSPSC"), '') AS normalized_unspsc,
    NULLIF(TRIM("Commodity Title"), '') AS commodity_title,
    NULLIF(TRIM("Class"), '') AS class_code,
    NULLIF(TRIM("Class Title"), '') AS class_title,
    NULLIF(TRIM("Family"), '') AS family_code,
    NULLIF(TRIM("Family Title"), '') AS family_title,
    NULLIF(TRIM("Segment"), '') AS segment_code,
    NULLIF(TRIM("Segment Title"), '') AS segment_title,

    COALESCE(
        NULLIF(TRIM("Commodity Title"), ''),
        NULLIF(TRIM("Class Title"), ''),
        NULLIF(TRIM("Family Title"), ''),
        NULLIF(TRIM("Segment Title"), ''),
        'Unclassified'
    ) AS commodity_category,

    NULLIF(TRIM("Location"), '') AS supplier_location_raw,

    CASE
        WHEN NULLIF(TRIM("Department Name"), '') IS NULL THEN 1
        ELSE 0
    END AS missing_department_flag,

    CASE
        WHEN NULLIF(TRIM("Supplier Code"), '') IS NULL
         AND NULLIF(TRIM("Supplier Name"), '') IS NULL THEN 1
        ELSE 0
    END AS missing_supplier_flag,

    CASE
        WHEN NULLIF(TRIM("Total Price"), '') IS NULL THEN 1
        ELSE 0
    END AS missing_amount_flag,

    CASE
        WHEN TRIM(COALESCE("Total Price", '')) LIKE '(%' THEN 1
        ELSE 0
    END AS negative_amount_flag

FROM purchase_orders;

/* 7A. Confirm that the view exists. */
SELECT type, name
FROM sqlite_master
WHERE type = 'view'
  AND name = 'vw_purchase_orders_clean';

/* 7B. Preview selected cleaned columns. */
SELECT
    source_row_id,
    creation_date_raw,
    fiscal_year,
    purchase_order_number,
    department_name,
    supplier_name,
    quantity,
    unit_price,
    purchase_amount,
    commodity_category
FROM vw_purchase_orders_clean
LIMIT 20;

/* 7C. Confirm that the view did not add or remove rows. */
SELECT
    (SELECT COUNT(*) FROM purchase_orders) AS raw_row_count,
    (SELECT COUNT(*) FROM vw_purchase_orders_clean) AS clean_view_row_count;

/* 7D. Compare raw currency text with the parsed numeric amount. */
SELECT
    p.rowid AS source_row_id,
    p."Total Price" AS raw_total_price,
    v.purchase_amount AS cleaned_purchase_amount
FROM purchase_orders AS p
JOIN vw_purchase_orders_clean AS v
  ON p.rowid = v.source_row_id
WHERE NULLIF(TRIM(p."Total Price"), '') IS NOT NULL
LIMIT 20;

/* 7E. Verify parenthesized negative amounts. */
SELECT
    p."Total Price" AS raw_total_price,
    v.purchase_amount AS cleaned_purchase_amount,
    v.negative_amount_flag
FROM purchase_orders AS p
JOIN vw_purchase_orders_clean AS v
  ON p.rowid = v.source_row_id
WHERE TRIM(p."Total Price") LIKE '(%'
LIMIT 20;


/* ==================================================================
   STEP 8 — DATA-QUALITY BASELINE
   ================================================================== */

/* 8.1 Total source records. Expected: 344,504. */
SELECT COUNT(*) AS total_records
FROM purchase_orders;

/* 8.2 Missing department. Expected: 0. */
SELECT
    SUM(missing_department_flag) AS missing_department_records,
    ROUND(
        100.0 * SUM(missing_department_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS missing_department_pct
FROM vw_purchase_orders_clean;

/* 8.3 Missing supplier code and supplier name. Expected: 36. */
SELECT
    SUM(missing_supplier_flag) AS missing_supplier_records,
    ROUND(
        100.0 * SUM(missing_supplier_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS missing_supplier_pct
FROM vw_purchase_orders_clean;

/* 8.4 Missing purchase amount. Expected: 30. */
SELECT
    SUM(missing_amount_flag) AS missing_amount_records,
    ROUND(
        100.0 * SUM(missing_amount_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS missing_amount_pct
FROM vw_purchase_orders_clean;

/* 8.5 Repeated purchase-order numbers.
   These are possible multi-line orders, not automatically bad duplicates. */
SELECT
    purchase_order_number,
    COUNT(*) AS line_record_count,
    COUNT(DISTINCT item_name) AS distinct_item_count,
    COUNT(DISTINCT supplier_name) AS distinct_supplier_count,
    COUNT(DISTINCT department_name) AS distinct_department_count,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount
FROM vw_purchase_orders_clean
WHERE purchase_order_number IS NOT NULL
GROUP BY purchase_order_number
HAVING COUNT(*) > 1
ORDER BY line_record_count DESC, total_purchase_amount DESC
LIMIT 100;

/* Count all repeated purchase-order-number groups. Expected: 33,956. */
WITH repeated_purchase_orders AS (
    SELECT purchase_order_number
    FROM vw_purchase_orders_clean
    WHERE purchase_order_number IS NOT NULL
    GROUP BY purchase_order_number
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS repeated_purchase_order_number_count
FROM repeated_purchase_orders;

/* Optional professional check: exact duplicate source rows.
   Expected: 1,305 duplicate groups and 2,087 extra copies beyond the
   first row in each group. The permanently blank REMOVE AMERISOURCE
   column is intentionally excluded. */
WITH duplicate_groups AS (
    SELECT
        "Creation Date",
        "Purchase Date",
        "Fiscal Year",
        "LPA Number",
        "Purchase Order Number",
        "Requisition Number",
        "Acquisition Type",
        "Sub-Acquisition Type",
        "Acquisition Method",
        "Sub-Acquisition Method",
        "Department Name",
        "Supplier Code",
        "Supplier Name",
        "Supplier Qualifications",
        "Supplier Zip Code",
        "CalCard",
        "Item Name",
        "Item Description",
        "Quantity",
        "Unit Price",
        "Total Price",
        "Classification Codes",
        "Normalized UNSPSC",
        "Commodity Title",
        "Class",
        "Class Title",
        "Family",
        "Family Title",
        "Segment",
        "Segment Title",
        "Location",
        COUNT(*) AS copies
    FROM purchase_orders
    GROUP BY
        "Creation Date",
        "Purchase Date",
        "Fiscal Year",
        "LPA Number",
        "Purchase Order Number",
        "Requisition Number",
        "Acquisition Type",
        "Sub-Acquisition Type",
        "Acquisition Method",
        "Sub-Acquisition Method",
        "Department Name",
        "Supplier Code",
        "Supplier Name",
        "Supplier Qualifications",
        "Supplier Zip Code",
        "CalCard",
        "Item Name",
        "Item Description",
        "Quantity",
        "Unit Price",
        "Total Price",
        "Classification Codes",
        "Normalized UNSPSC",
        "Commodity Title",
        "Class",
        "Class Title",
        "Family",
        "Family Title",
        "Segment",
        "Segment Title",
        "Location"
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS exact_duplicate_group_count,
    SUM(copies - 1) AS extra_duplicate_rows
FROM duplicate_groups;


/* ==================================================================
   STEP 9 — PURCHASE AMOUNT BY DEPARTMENT
   ================================================================== */
SELECT
    COALESCE(department_name, 'Unknown Department') AS department_name,
    COUNT(*) AS line_record_count,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY COALESCE(department_name, 'Unknown Department')
ORDER BY total_purchase_amount DESC;


/* ==================================================================
   STEP 10 — PURCHASE AMOUNT BY SUPPLIER
   ================================================================== */
SELECT
    COALESCE(supplier_code, 'UNKNOWN') AS supplier_code,
    COALESCE(supplier_name, 'Unknown Supplier') AS supplier_name,
    COUNT(*) AS line_record_count,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    COUNT(DISTINCT department_name) AS departments_served,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY
    COALESCE(supplier_code, 'UNKNOWN'),
    COALESCE(supplier_name, 'Unknown Supplier')
ORDER BY total_purchase_amount DESC;


/* ==================================================================
   STEP 11 — PURCHASE AMOUNT BY COMMODITY / CATEGORY
   ================================================================== */
SELECT
    COALESCE(normalized_unspsc, 'UNCLASSIFIED') AS normalized_unspsc,
    commodity_category,
    COUNT(*) AS line_record_count,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY
    COALESCE(normalized_unspsc, 'UNCLASSIFIED'),
    commodity_category
ORDER BY total_purchase_amount DESC;


/* ==================================================================
   STEP 12 — PURCHASE ORDERS BY FISCAL YEAR
   ================================================================== */
SELECT
    COALESCE(fiscal_year, 'Unknown Fiscal Year') AS fiscal_year,
    COUNT(*) AS line_record_count,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY COALESCE(fiscal_year, 'Unknown Fiscal Year')
ORDER BY fiscal_year;


/* ==================================================================
   STEP 13 — OVERALL PURCHASE-AMOUNT STATISTICS
   ================================================================== */
SELECT
    COUNT(purchase_amount) AS records_with_amount,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount,
    ROUND(MIN(purchase_amount), 2) AS minimum_purchase_amount,
    ROUND(MAX(purchase_amount), 2) AS maximum_purchase_amount,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount
FROM vw_purchase_orders_clean;


/* ==================================================================
   STEP 14 — AMOUNT BUCKETS WITH CASE WHEN
   ================================================================== */
WITH bucketed AS (
    SELECT
        purchase_amount,
        CASE
            WHEN purchase_amount IS NULL THEN 'Missing amount'
            WHEN purchase_amount < 0 THEN 'Negative / adjustment'
            WHEN purchase_amount = 0 THEN '$0'
            WHEN purchase_amount < 100 THEN '$0.01-$99.99'
            WHEN purchase_amount < 1000 THEN '$100-$999.99'
            WHEN purchase_amount < 10000 THEN '$1,000-$9,999.99'
            WHEN purchase_amount < 100000 THEN '$10,000-$99,999.99'
            ELSE '$100,000 and above'
        END AS amount_bucket,
        CASE
            WHEN purchase_amount IS NULL THEN 1
            WHEN purchase_amount < 0 THEN 2
            WHEN purchase_amount = 0 THEN 3
            WHEN purchase_amount < 100 THEN 4
            WHEN purchase_amount < 1000 THEN 5
            WHEN purchase_amount < 10000 THEN 6
            WHEN purchase_amount < 100000 THEN 7
            ELSE 8
        END AS bucket_sort_order
    FROM vw_purchase_orders_clean
)
SELECT
    amount_bucket,
    COUNT(*) AS record_count,
    ROUND(SUM(COALESCE(purchase_amount, 0)), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM bucketed
GROUP BY amount_bucket, bucket_sort_order
ORDER BY bucket_sort_order;


/* ==================================================================
   STEP 15 — TOP 10 SUPPLIERS
   ================================================================== */
SELECT
    COALESCE(supplier_code, 'UNKNOWN') AS supplier_code,
    COALESCE(supplier_name, 'Unknown Supplier') AS supplier_name,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    COUNT(DISTINCT department_name) AS departments_served,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY
    COALESCE(supplier_code, 'UNKNOWN'),
    COALESCE(supplier_name, 'Unknown Supplier')
ORDER BY total_purchase_amount DESC
LIMIT 10;


/* ==================================================================
   STEP 16 — TOP 10 DEPARTMENTS
   ================================================================== */
SELECT
    COALESCE(department_name, 'Unknown Department') AS department_name,
    COUNT(DISTINCT purchase_order_number) AS purchase_order_count,
    COUNT(DISTINCT supplier_code) AS supplier_count,
    ROUND(SUM(purchase_amount), 2) AS total_purchase_amount,
    ROUND(AVG(purchase_amount), 2) AS average_line_amount
FROM vw_purchase_orders_clean
GROUP BY COALESCE(department_name, 'Unknown Department')
ORDER BY total_purchase_amount DESC
LIMIT 10;


/* ==================================================================
   STEP 17 — CREATE AND JOIN THE DEPARTMENT LOOKUP
   ================================================================== */
DROP TABLE IF EXISTS department_lookup;

CREATE TABLE department_lookup (
    department_id INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE
);

INSERT INTO department_lookup (department_name)
SELECT DISTINCT department_name
FROM vw_purchase_orders_clean
WHERE department_name IS NOT NULL
ORDER BY department_name;

/* Expected: 111 lookup rows. */
SELECT COUNT(*) AS department_lookup_count
FROM department_lookup;

/* Inspect the assigned IDs. */
SELECT department_id, department_name
FROM department_lookup
ORDER BY department_name
LIMIT 25;

/* Join the clean view to the lookup. */
SELECT
    p.source_row_id,
    d.department_id,
    d.department_name,
    p.purchase_order_number,
    p.creation_date_raw,
    p.fiscal_year,
    p.supplier_code,
    p.supplier_name,
    p.item_name,
    p.purchase_amount
FROM vw_purchase_orders_clean AS p
LEFT JOIN department_lookup AS d
    ON p.department_name = d.department_name
ORDER BY d.department_name, p.purchase_order_number
LIMIT 100;

/* Expected: 0 unmatched nonmissing department names. */
SELECT
    COUNT(*) AS unmatched_nonmissing_departments
FROM vw_purchase_orders_clean AS p
LEFT JOIN department_lookup AS d
    ON p.department_name = d.department_name
WHERE p.department_name IS NOT NULL
  AND d.department_id IS NULL;


/* ==================================================================
   STEP 18 — CREATE THE FINAL CLEANED SUMMARY TABLE

   Grain: one row per unique combination of
   fiscal year + department + supplier + UNSPSC/category.

   Full numeric precision is stored. ROUND() is used only when results
   are displayed, which is safer for later aggregation.
   ================================================================== */
DROP TABLE IF EXISTS purchase_order_cleaned_summary;

CREATE TABLE purchase_order_cleaned_summary AS
SELECT
    p.fiscal_year,
    d.department_id,
    COALESCE(p.department_name, 'Unknown Department') AS department_name,
    COALESCE(p.supplier_code, 'UNKNOWN') AS supplier_code,
    COALESCE(p.supplier_name, 'Unknown Supplier') AS supplier_name,
    COALESCE(p.normalized_unspsc, 'UNCLASSIFIED') AS normalized_unspsc,
    COALESCE(p.commodity_category, 'Unclassified') AS commodity_category,
    COUNT(*) AS source_line_count,
    COUNT(DISTINCT p.purchase_order_number) AS purchase_order_count,
    SUM(p.purchase_amount) AS total_purchase_amount,
    AVG(p.purchase_amount) AS average_line_amount
FROM vw_purchase_orders_clean AS p
LEFT JOIN department_lookup AS d
    ON p.department_name = d.department_name
GROUP BY
    p.fiscal_year,
    d.department_id,
    COALESCE(p.department_name, 'Unknown Department'),
    COALESCE(p.supplier_code, 'UNKNOWN'),
    COALESCE(p.supplier_name, 'Unknown Supplier'),
    COALESCE(p.normalized_unspsc, 'UNCLASSIFIED'),
    COALESCE(p.commodity_category, 'Unclassified');

/* Expected: 150,297 grouped rows. */
SELECT COUNT(*) AS summary_row_count
FROM purchase_order_cleaned_summary;

/* Preview, rounding only for display. */
SELECT
    fiscal_year,
    department_id,
    department_name,
    supplier_code,
    supplier_name,
    normalized_unspsc,
    commodity_category,
    source_line_count,
    purchase_order_count,
    ROUND(total_purchase_amount, 2) AS total_purchase_amount,
    ROUND(average_line_amount, 2) AS average_line_amount
FROM purchase_order_cleaned_summary
ORDER BY total_purchase_amount DESC
LIMIT 100;

/* Reconcile source rows and monetary totals.
   Expected:
   344,504 | 344,504 | 150,517,871,463.40 | 150,517,871,463.40
*/
SELECT
    (SELECT COUNT(*)
     FROM vw_purchase_orders_clean) AS clean_source_line_count,

    (SELECT SUM(source_line_count)
     FROM purchase_order_cleaned_summary) AS summarized_source_line_count,

    (SELECT ROUND(SUM(purchase_amount), 2)
     FROM vw_purchase_orders_clean) AS clean_source_total_amount,

    (SELECT ROUND(SUM(total_purchase_amount), 2)
     FROM purchase_order_cleaned_summary) AS summarized_total_amount;


/* ==================================================================
   STEP 19 — CREATE INDEXES ON THE SUMMARY TABLE
   ================================================================== */
CREATE INDEX IF NOT EXISTS idx_summary_fiscal_year
    ON purchase_order_cleaned_summary(fiscal_year);

CREATE INDEX IF NOT EXISTS idx_summary_department
    ON purchase_order_cleaned_summary(department_id);

CREATE INDEX IF NOT EXISTS idx_summary_supplier
    ON purchase_order_cleaned_summary(supplier_code);

CREATE INDEX IF NOT EXISTS idx_summary_unspsc
    ON purchase_order_cleaned_summary(normalized_unspsc);

/* Confirm the indexes. */
SELECT name, tbl_name
FROM sqlite_master
WHERE type = 'index'
  AND tbl_name = 'purchase_order_cleaned_summary'
ORDER BY name;


/* ==================================================================
   STEP 20 — FINAL PROJECT OBJECT CHECK
   ================================================================== */
SELECT
    type,
    name,
    tbl_name
FROM sqlite_master
WHERE name IN (
    'purchase_orders',
    'vw_purchase_orders_clean',
    'department_lookup',
    'purchase_order_cleaned_summary',
    'idx_summary_fiscal_year',
    'idx_summary_department',
    'idx_summary_supplier',
    'idx_summary_unspsc'
)
ORDER BY type, name;
