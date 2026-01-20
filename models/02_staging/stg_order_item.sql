with bronze as (
    select * from {{ ref('order_items') }}
),

orders as (
    select * from {{ ref('stg_order') }}
),

products as (
    select * from {{ ref('stg_product') }}
)

select
    orders.order_tk,
    products.product_tk,
    bronze.order_item_id as order_item_source_id,
    bronze.order_id as order_source_id,
    bronze.product_id as product_source_id,
    bronze.quantity,
    bronze.unit_price,
    bronze.quantity * bronze.unit_price as line_total,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted,
    md5(coalesce(cast(bronze.quantity as varchar), '') || '|' || coalesce(cast(bronze.unit_price as varchar), '')) as order_item_hd,
    -- metadata
    bronze._loaded_at as load_ts,
    'erp.jaffle_shop.' || bronze._pipeline_run_id as record_source
from bronze
left join orders
    on bronze.order_id = orders.order_source_id
left join products
    on bronze.product_id = products.product_source_id
