{{
    config(
        alias='dim_product'
    )
}}

with source as (
    select * from {{ ref('stg_product') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    product_tk,
    product_source_id,
    product_name,
    category,
    price,
    created_at,
    updated_at,
    deleted_at,
    is_deleted,
    product_hd,
    md5(product_tk || '|' || coalesce(cast(deleted_at as varchar), cast(updated_at as varchar), '')) as product_hk,
    cast(coalesce(deleted_at, updated_at, created_at) as date) as valid_from,
    -- metadata
    load_ts,
    record_source
from source
