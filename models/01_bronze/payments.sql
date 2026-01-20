select
    payment_id,
    order_id,
    payment_method,
    amount,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_shop', 'payments') }}
{% if is_incremental() %}
where coalesce(created_at, updated_at) > (select max(coalesce(created_at, updated_at)) from {{ this }})
{% endif %}
