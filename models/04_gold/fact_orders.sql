{{
    config(
        alias='fact_orders',
        materialized='incremental',
        unique_key='order_sk'
    )
}}

with orders as (
    select * from {{ ref('fact_orders_erp') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

dim_date as (
    select * from {{ ref('dim_date') }}
)

select
    orders.order_tk as order_sk,
    orders.customer_tk as customer_sk,
    dim_date.date_sk as order_date_sk,
    orders.order_source_id,
    orders.order_date,
    orders.order_status,
    orders.line_count,
    orders.total_quantity,
    orders.order_total,
    orders.created_at,
    orders.updated_at,
    orders.deleted_at,
    orders.is_deleted
from orders
left join dim_date
    on cast(orders.order_date as date) = dim_date.date_day
