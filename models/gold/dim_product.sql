{{
    config(
        alias='dim_product',
        materialized='incremental',
        unique_key='product_sk'
    )
}}

with source as (
    select * from {{ ref('dim_product_erp') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    product_tk as product_sk,
    product_source_id,
    product_name,
    category,
    price,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
