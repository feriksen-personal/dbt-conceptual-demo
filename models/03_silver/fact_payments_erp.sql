{{
    config(
        alias='fact_payments'
    )
}}

with payments as (
    select * from {{ ref('stg_payment') }}
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
        customer_tk,
        order_date,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by order_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_order_erp') }}
)

select
    -- dimension keys (customer -> order)
    cte_order.customer_tk,
    cte_customer.customer_hk,
    payments.order_tk,
    cte_order.order_hk,
    -- fact timeline
    cte_order.order_date,
    -- measures
    payments.payment_method,
    payments.amount,
    -- metadata
    payments.load_ts,
    payments.record_source
from payments
left join cte_order
    on payments.order_tk = cte_order.order_tk
left join cte_customer
    on cte_order.customer_tk = cte_customer.customer_tk
    and cte_order.order_date between cte_customer.valid_from and cte_customer.valid_to
