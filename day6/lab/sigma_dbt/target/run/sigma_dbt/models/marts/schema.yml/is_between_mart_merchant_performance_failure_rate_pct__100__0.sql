
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

with __dbt__cte__stg_transactions as (
WITH raw_transactions AS (
    SELECT 
        transaction_id,
        amount,
        status,
        merchant_id,
        customer_id,
        transaction_date,
        payment_method
    FROM 
        SIGMA_DE.PUBLIC.fact_transactions
    WHERE 
        merchant_id NOT LIKE 'TEST_%'
),

cleaned_transactions AS (
    SELECT 
        LOWER(transaction_id) AS transaction_id,
        CAST(amount AS DECIMAL(10,2)) AS amount,
        LOWER(status) AS status,
        LOWER(merchant_id) AS merchant_id,
        LOWER(customer_id) AS customer_id,
        CAST(transaction_date AS DATE) AS transaction_date,
        LOWER(payment_method) AS payment_method,
        CURRENT_TIMESTAMP AS loaded_at
    FROM 
        raw_transactions
)

SELECT * FROM cleaned_transactions
),  __dbt__cte__mart_merchant_performance as (
WITH filtered_transactions AS (
    SELECT
        transaction_id,
        amount,
        status,
        merchant_id,
        customer_id,
        transaction_date,
        payment_method
    FROM __dbt__cte__stg_transactions
    WHERE status IN ('completed', 'failed')
),

merchant_details AS (
    SELECT
        merchant_id,
        merchant_name,
        category,
        city
    FROM SIGMA_DE.PUBLIC.dim_merchant
),

revenue_by_merchant AS (
    SELECT
        ft.merchant_id,
        SUM(ft.amount) AS total_revenue
    FROM filtered_transactions ft
    WHERE ft.status = 'completed'
    GROUP BY ft.merchant_id
),

transaction_counts AS (
    SELECT
        merchant_id,
        COUNT(*) AS total_transactions,
        COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_count
    FROM filtered_transactions
    GROUP BY merchant_id
),

avg_transaction_value AS (
    SELECT
        merchant_id,
        AVG(amount) AS avg_transaction_value
    FROM filtered_transactions
    WHERE status = 'completed'
    GROUP BY merchant_id
),

unique_customers AS (
    SELECT
        merchant_id,
        COUNT(DISTINCT customer_id) AS unique_customers
    FROM filtered_transactions
    GROUP BY merchant_id
)

SELECT
    md.merchant_id,
    md.merchant_name,
    md.category,
    md.city,
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(tc.total_transactions, 0) AS total_transactions,
    COALESCE(tc.failed_count, 0) AS failed_count,
    COALESCE(tc.failed_count * 100.0 / NULLIF(tc.total_transactions, 0), 0) AS failure_rate_pct,
    COALESCE(atv.avg_transaction_value, 0) AS avg_transaction_value,
    COALESCE(uc.unique_customers, 0) AS unique_customers
FROM merchant_details md
LEFT JOIN revenue_by_merchant r ON md.merchant_id = r.merchant_id
LEFT JOIN transaction_counts tc ON md.merchant_id = tc.merchant_id
LEFT JOIN avg_transaction_value atv ON md.merchant_id = atv.merchant_id
LEFT JOIN unique_customers uc ON md.merchant_id = uc.merchant_id
) select *
from __dbt__cte__mart_merchant_performance
where failure_rate_pct < 0 or failure_rate_pct > 100


  
  
      
    ) dbt_internal_test