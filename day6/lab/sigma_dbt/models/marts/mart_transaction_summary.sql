WITH completed_transactions AS (
    SELECT
        merchant_id,
        SUM(amount) AS total_revenue
    FROM {{ ref('stg_transactions') }}
    WHERE status = 'completed'
    GROUP BY merchant_id
),

transaction_counts AS (
    SELECT
        merchant_id,
        COUNT(*) AS transaction_count,
        COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_count
    FROM {{ ref('stg_transactions') }}
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
    FROM {{ source('sigma_analytics', 'dim_merchant') }} dm
    LEFT JOIN completed_transactions ct ON dm.merchant_id = ct.merchant_id
    LEFT JOIN failure_rates fr ON dm.merchant_id = fr.merchant_id
    LEFT JOIN transaction_counts tc ON dm.merchant_id = tc.merchant_id
)

SELECT * FROM final_summary
