with source as (
    select * from {{ ref('dim_product_erp') }}
)

select
    product_hk as product_sk,
    product_source_id,
    product_name,
    category,
    price,
    is_deleted,
    valid_from
from source
