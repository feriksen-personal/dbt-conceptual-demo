{{
    config(
        materialized='incremental',
        unique_key='session_id'
    )
}}

select
    session_id,
    customer_id,
    session_start,
    session_end,
    page_views,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_crm', 'web_sessions') }}
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
