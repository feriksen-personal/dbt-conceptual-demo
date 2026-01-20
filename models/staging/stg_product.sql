with source as (
    select * from {{ source('jaffle_shop', 'products') }}
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
    deleted_at is not null as is_deleted
from source
