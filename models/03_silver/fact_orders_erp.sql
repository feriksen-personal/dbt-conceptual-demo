{{
    config(
        alias='fact_orders'
    )
}}

with order_items as (
    select * from {{ ref('stg_order_item') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
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
),

-- SCD2 dimension lookup: order
cte_order as (
    select
        order_tk,
        order_hk,
        order_date,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by order_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_order_erp') }}
),

-- SCD2 dimension lookup: product
cte_product as (
    select
        product_tk,
        product_hk,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by product_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_product_erp') }}
)

select
    -- dimension keys (customer -> order -> product)
    cte_order.customer_tk,
    cte_customer.customer_hk,
    order_items.order_tk,
    cte_order.order_hk,
    order_items.product_tk,
    cte_product.product_hk,
    -- fact timeline
    cte_order.order_date,
    -- measures
    order_items.quantity,
    order_items.unit_price,
    order_items.line_total,
    -- metadata
    order_items.load_ts,
    order_items.record_source
from order_items
left join cte_order
    on order_items.order_tk = cte_order.order_tk
left join cte_customer
    on cte_order.customer_tk = cte_customer.customer_tk
    and cte_order.order_date between cte_customer.valid_from and cte_customer.valid_to
left join cte_product
    on order_items.product_tk = cte_product.product_tk
    and cte_order.order_date between cte_product.valid_from and cte_product.valid_to
