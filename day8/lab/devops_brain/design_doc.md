# Data Pipeline Design Document

## What This Pipeline Does
This pipeline ingests transaction data from both clean and dirty sources, processes it through bronze, silver, and gold layers, and computes merchant performance and daily transaction summaries.

## Data Flow Diagram

```
+--------------------+     +------------------+     +------------------+     +------------------+
| Source (Clean/Dirty)| --> |  Bronze Table     | --> |  Silver Table     | --> |  Gold Tables      |
|  TRANSACTIONS       |     |  bronze_transactions |     |  silver_transactions |     |  gold_merchant_performance |
+--------------------+     +------------------+     +------------------+     +------------------+
                                                                                           |
                                                                                           V
+--------------------+     +------------------+     +------------------+     +------------------+
| Source (Merchants) | --> |  Merchants Table  | --> |  Silver Table     | --> |  Gold Tables      |
|  MERCHANTS         |     |  merchants         |     |  silver_transactions |     |  gold_daily_summary |
+--------------------+     +------------------+     +------------------+     +------------------+
```

## Key Design Decisions
- **Layered Data Processing:** The pipeline uses a bronze, silver, and gold layer approach to ensure data integrity and quality.
- **Data Quality Flags:** Introduced quality flags in the silver layer to distinguish between clean and dirty data.
- **Aggregative Summaries:** Computed merchant performance and daily summaries in the gold layer for analytical purposes.
- **Reusability:** Designed functions to be reusable for different data sets and transformations.

## Known Limitations
- **Data Consistency:** The pipeline assumes that the merchant data is static and does not change frequently.
- **Error Handling:** Limited error handling in the data ingestion process, which could lead to data loss.
- **Performance:** The pipeline may face performance issues with very large datasets due to in-memory transformations.
- **Data Freshness:** The gold tables are updated once per day, which might not be suitable for real-time analytics.

## Dependencies
- **DuckDB:** The pipeline relies on DuckDB for data storage and processing.
- **MERCHANTS Data:** External source for merchant information.
- **TRANSACTIONS_CLEAN and TRANSACTIONS_DIRTY:** External sources for transaction data.