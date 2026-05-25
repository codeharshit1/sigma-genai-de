
    
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
),  __dbt__cte__mart_transaction_summary as (
WITH completed_transactions AS (
    SELECT
        merchant_id,
        SUM(amount) AS total_revenue
    FROM __dbt__cte__stg_transactions
    WHERE status = 'completed'
    GROUP BY merchant_id
),

transaction_counts AS (
    SELECT
        merchant_id,
        COUNT(*) AS transaction_count,
        COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_count
    FROM __dbt__cte__stg_transactions
    GROUP BY merchant_id
),

failure_rates AS (
    SELECT
        merchant_id,
        (failed_count::DECIMAL / transaction_count) * 100 AS failure_rate_pct
    FROM transaction_counts
),

final_summary AS (
    SELECT
        dm.merchant_id,
        dm.merchant_name,
        COALESCE(ct.total_revenue, 0) AS total_revenue,
        COALESCE(fr.failure_rate_pct, 0) AS failure_rate_pct,
        COALESCE(tc.transaction_count, 0) AS transaction_count
    FROM SIGMA_DE.PUBLIC.dim_merchant dm
    LEFT JOIN completed_transactions ct ON dm.merchant_id = ct.merchant_id
    LEFT JOIN failure_rates fr ON dm.merchant_id = fr.merchant_id
    LEFT JOIN transaction_counts tc ON dm.merchant_id = tc.merchant_id
)

SELECT * FROM final_summary
) select merchant_name
from __dbt__cte__mart_transaction_summary
where merchant_name is null



  
  
      
    ) dbt_internal_test