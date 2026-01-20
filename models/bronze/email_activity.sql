{{
    config(
        materialized='incremental',
        unique_key='activity_id'
    )
}}

select
    activity_id,
    customer_id,
    campaign_id,
    sent_date,
    opened,
    clicked,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_crm', 'email_activity') }}
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
