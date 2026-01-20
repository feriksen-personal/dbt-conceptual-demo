{{
    config(
        alias='dim_customer'
    )
}}

with source as (
    select * from {{ ref('dim_customer_erp') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    customer_tk as customer_sk,
    customer_source_id,
    email,
    first_name,
    last_name,
    full_name,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
