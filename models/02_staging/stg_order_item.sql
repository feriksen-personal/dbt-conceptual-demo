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
    bronze.deleted_at is not null as is_deleted
from bronze
left join orders
    on bronze.order_id = orders.order_source_id
left join products
    on bronze.product_id = products.product_source_id
