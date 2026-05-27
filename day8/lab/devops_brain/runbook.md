# Pipeline Overview

This pipeline ingests transaction data, transforms it, and loads it into bronze, silver, and gold tables. It also computes merchant performance and daily summaries.

## Why it runs
To ensure up-to-date transaction data is available for analysis.

## What breaks if it stops
Downstream analytics and reporting will be out of date.

---

## Pipeline Steps

1. Connect to DuckDB using `get_connection()`.
2. Set up tables using `setup_tables(con)`.
3. Load merchants using `load_merchants(con)`.
4. Load transactions into bronze table using `load_bronze(con, transactions)`.
5. Transform bronze to silver using `transform_bronze_to_silver(transactions, merchants)`.
6. Load transformed data into silver table using `load_silver(con, silver_rows)`.
7. Compute merchant performance using `compute_merchant_performance(silver_rows)`.
8. Compute daily summary using `compute_daily_summary(silver_rows)`.
9. Load merchant performance and daily summary into gold tables using `load_gold(con, merchant_perf, daily_summary)`.

---

## Schedule / Trigger

This pipeline runs every hour, triggered by a cron job.

---

## Failure Modes

1. **DuckDB Connection Failure**
   - **Root Cause:** Database server is down.
   - **Symptom:** `get_connection()` fails.
2. **Table Creation Failure**
   - **Root Cause:** Syntax error in SQL.
   - **Symptom:** `setup_tables(con)` throws an exception.
3. **Merchant Data Load Failure**
   - **Root Cause:** Corrupt merchant data.
   - **Symptom:** `load_merchants(con)` fails.
4. **Bronze Table Load Failure**
   - **Root Cause:** Invalid transaction data.
   - **Symptom:** `load_bronze(con, transactions)` fails.
5. **Silver Table Transformation Failure**
   - **Root Cause:** Missing merchant data for a transaction.
   - **Symptom:** `transform_bronze_to_silver(transactions, merchants)` fails.

---

## Recovery Actions

1. **DuckDB Connection Failure**
   - Check DB server status.
   - Restart DB server if necessary.
   - Retry pipeline.
2. **Table Creation Failure**
   - Review SQL syntax in `setup_tables(con)`.
   - Fix syntax error.
   - Retry pipeline.
3. **Merchant Data Load Failure**
   - Validate merchant data.
   - Correct corrupt data.
   - Retry pipeline.
4. **Bronze Table Load Failure**
   - Validate transaction data.
   - Correct invalid data.
   - Retry pipeline.
5. **Silver Table Transformation Failure**
   - Ensure all merchants are loaded.
   - Retry pipeline.

---

## Known Bugs

- Hardcoded AWS credentials in `main()`.
- Lack of null handling in `transform_bronze_to_silver()`.

---

## Escalation Contacts

1. **On-call DE:** Priya Nair (priya.nair@sigmadatatech.in, +91-98400-11111)
2. **Tech Lead:** Arjun Mehta (arjun.mehta@sigmadatatech.in)
3. **Platform Manager:** Kavya Reddy (kavya.reddy@sigmadatatech.in)

---

## Data Quality Checks

- Verify the number of records in bronze, silver, and gold tables.
- Check for any 'DIRTY' flags in silver table.
- Ensure merchant performance and daily summary data is up-to-date.