select
    product_id,
    name,
    category,
    price,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_shop', 'products') }}
{% if is_incremental() %}
where coalesce(created_at, updated_at) > (select max(coalesce(created_at, updated_at)) from {{ this }})
{% endif %}
