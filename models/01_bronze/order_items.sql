select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    created_at,
    updated_at,
    deleted_at,
    -- Ingestion metadata
    '{{ invocation_id }}' as _pipeline_run_id,
    current_timestamp as _loaded_at
from {{ source('jaffle_shop', 'order_items') }}
{% if is_incremental() %}
where coalesce(created_at, updated_at) > (select max(coalesce(created_at, updated_at)) from {{ this }})
{% endif %}
