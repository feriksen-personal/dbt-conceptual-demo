with source as (
    select * from {{ source('jaffle_shop', 'payments') }}
),

orders as (
    select * from {{ ref('stg_order') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'source.payment_id']) }} as payment_tk,
    orders.order_tk,
    source.payment_id as payment_source_id,
    source.order_id as order_source_id,
    source.payment_method,
    source.amount,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.deleted_at is not null as is_deleted
from source
left join orders
    on source.order_id = orders.order_source_id
