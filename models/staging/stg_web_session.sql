with source as (
    select * from {{ source('jaffle_crm', 'web_sessions') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'crm'", 'source.session_id']) }} as web_session_tk,
    customers.customer_tk,
    source.session_id as session_source_id,
    source.customer_id as customer_source_id,
    source.session_start,
    source.session_end,
    source.page_views,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.deleted_at is not null as is_deleted
from source
left join customers
    on source.customer_id = customers.customer_source_id
