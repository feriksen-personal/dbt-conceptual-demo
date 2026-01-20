with bronze as (
    select * from {{ ref('payments') }}
),

orders as (
    select * from {{ ref('stg_order') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'bronze.payment_id']) }} as payment_tk,
    orders.order_tk,
    bronze.payment_id as payment_source_id,
    bronze.order_id as order_source_id,
    bronze.payment_method,
    bronze.amount,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted,
    md5(coalesce(cast(bronze.order_id as varchar), '') || '|' || coalesce(bronze.payment_method, '') || '|' || coalesce(cast(bronze.amount as varchar), '')) as payment_hd,
    -- metadata
    bronze._loaded_at as load_ts,
    'erp.jaffle_shop.' || bronze._pipeline_run_id as record_source
from bronze
left join orders
    on bronze.order_id = orders.order_source_id
