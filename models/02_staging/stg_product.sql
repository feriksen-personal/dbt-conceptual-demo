with bronze as (
    select * from {{ ref('products') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'erp'", 'product_id']) }} as product_tk,
    product_id as product_source_id,
    name as product_name,
    category,
    price,
    created_at,
    updated_at,
    deleted_at,
    deleted_at is not null as is_deleted,
    md5(coalesce(name, '') || '|' || coalesce(category, '') || '|' || coalesce(cast(price as varchar), '')) as product_hd,
    -- metadata
    _loaded_at as load_ts,
    'erp.jaffle_shop.' || _pipeline_run_id as record_source
from bronze
