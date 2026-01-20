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
where coalesce(created_at, updated_at) > (select max(coalesce(created_at, updated_at)) from {{ this }})
{% endif %}
