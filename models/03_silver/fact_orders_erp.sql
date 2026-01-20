{{
    config(
        alias='fact_orders',
        materialized='incremental',
        unique_key='order_tk'
    )
}}

with orders as (
    select * from {{ ref('stg_order') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

order_items as (
    select * from {{ ref('stg_order_item') }}
),

order_item_agg as (
    select
        order_tk,
        count(*) as line_count,
        sum(quantity) as total_quantity,
        sum(line_total) as order_total
    from order_items
    group by order_tk
)

select
    orders.order_tk,
    orders.customer_tk,
    orders.order_source_id,
    orders.order_date,
    orders.order_status,
    coalesce(order_item_agg.line_count, 0) as line_count,
    coalesce(order_item_agg.total_quantity, 0) as total_quantity,
    coalesce(order_item_agg.order_total, 0) as order_total,
    orders.created_at,
    orders.updated_at,
    orders.deleted_at,
    orders.is_deleted
from orders
left join order_item_agg
    on orders.order_tk = order_item_agg.order_tk
