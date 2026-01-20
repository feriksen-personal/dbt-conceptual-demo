with bronze as (
    select * from {{ ref('orders') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'bronze.order_id']) }} as order_tk,
    customers.customer_tk,
    bronze.order_id as order_source_id,
    bronze.customer_id as customer_source_id,
    bronze.order_date,
    bronze.status as order_status,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
