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
    bronze.deleted_at is not null as is_deleted,
    md5(coalesce(cast(bronze.customer_id as varchar), '') || '|' || coalesce(cast(bronze.session_start as varchar), '') || '|' || coalesce(cast(bronze.session_end as varchar), '') || '|' || coalesce(cast(bronze.page_views as varchar), '')) as web_session_hd,
    -- metadata
    bronze._loaded_at as load_ts,
    'crm.jaffle_crm.' || bronze._pipeline_run_id as record_source
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
