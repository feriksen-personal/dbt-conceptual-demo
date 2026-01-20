{{
    config(
        alias='fact_orders'
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
),

-- SCD2 dimension lookup: customer
cte_customer as (
    select
        customer_tk,
        customer_hk,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by customer_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_customer_erp') }}
)

select
    orders.order_tk,
    orders.customer_tk,
    cte_customer.customer_hk,
    orders.order_source_id,
    orders.order_date,
    orders.order_status,
    coalesce(order_item_agg.line_count, 0) as line_count,
    coalesce(order_item_agg.total_quantity, 0) as total_quantity,
    coalesce(order_item_agg.order_total, 0) as order_total,
    orders.created_at,
    orders.updated_at,
    orders.deleted_at,
    orders.is_deleted,
    orders.order_hd,
    -- metadata
    orders.load_ts,
    orders.record_source
from orders
left join order_item_agg
    on orders.order_tk = order_item_agg.order_tk
left join cte_customer
    on orders.customer_tk = cte_customer.customer_tk
    and orders.order_date between cte_customer.valid_from and cte_customer.valid_to
