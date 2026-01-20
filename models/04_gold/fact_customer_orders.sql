with source as (
    select * from {{ ref('fact_orders_erp') }}
),

dim_date as (
    select * from {{ ref('dim_date') }}
)

select
    -- dimension keys (customer -> order -> product -> date)
    source.customer_hk as customer_sk,
    source.order_hk as order_sk,
    source.product_hk as product_sk,
    dim_date.date_sk as order_date_sk,
    -- fact timeline
    source.order_date,
    -- measures
    source.quantity,
    source.unit_price,
    source.line_total
from source
left join dim_date
    on source.order_date = dim_date.date_day
