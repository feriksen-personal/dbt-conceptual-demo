with source as (
    select * from {{ source('jaffle_shop', 'orders') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'source.order_id']) }} as order_tk,
    customers.customer_tk,
    source.order_id as order_source_id,
    source.customer_id as customer_source_id,
    source.order_date,
    source.status as order_status,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.deleted_at is not null as is_deleted
from source
left join customers
    on source.customer_id = customers.customer_source_id
