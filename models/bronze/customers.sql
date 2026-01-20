{{
    config(
        materialized='incremental',
        unique_key='customer_id'
    )
}}

select
    customer_id,
    first_name,
    last_name,
    email,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_shop', 'customers') }}
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
