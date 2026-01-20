with source as (
    select * from {{ source('jaffle_shop', 'order_items') }}
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
    source.order_item_id as order_item_source_id,
    source.order_id as order_source_id,
    source.product_id as product_source_id,
    source.quantity,
    source.unit_price,
    source.quantity * source.unit_price as line_total,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.deleted_at is not null as is_deleted
from source
left join orders
    on source.order_id = orders.order_source_id
left join products
    on source.product_id = products.product_source_id
