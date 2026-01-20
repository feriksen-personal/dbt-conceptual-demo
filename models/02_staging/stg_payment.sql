with bronze as (
    select * from {{ ref('payments') }}
),

orders as (
    select * from {{ ref('stg_order') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'bronze.payment_id']) }} as payment_tk,
    orders.order_tk,
    bronze.payment_id as payment_source_id,
    bronze.order_id as order_source_id,
    bronze.payment_method,
    bronze.amount,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted
from bronze
left join orders
    on bronze.order_id = orders.order_source_id
