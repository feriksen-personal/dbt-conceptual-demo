with bronze as (
    select * from {{ ref('orders') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'bronze.order_id']) }} as order_tk,
    customers.customer_tk,
    bronze.order_id as order_source_id,
    bronze.customer_id as customer_source_id,
    bronze.order_date,
    bronze.status as order_status,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted,
    md5(coalesce(cast(bronze.customer_id as varchar), '') || '|' || coalesce(cast(bronze.order_date as varchar), '') || '|' || coalesce(bronze.status, '')) as order_hd,
    -- metadata
    bronze._loaded_at as load_ts,
    'erp.jaffle_shop.' || bronze._pipeline_run_id as record_source
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
