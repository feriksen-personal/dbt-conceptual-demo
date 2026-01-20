{{
    config(
        materialized='incremental',
        unique_key='campaign_id'
    )
}}

select
    campaign_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_crm', 'campaigns') }}
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
