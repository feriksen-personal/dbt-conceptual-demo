with bronze as (
    select * from {{ ref('web_sessions') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'crm'", 'bronze.session_id']) }} as web_session_tk,
    customers.customer_tk,
    bronze.session_id as session_source_id,
    bronze.customer_id as customer_source_id,
    bronze.session_start,
    bronze.session_end,
    bronze.page_views,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
