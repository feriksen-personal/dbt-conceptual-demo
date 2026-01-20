{{
    config(
        alias='dim_customer',
        materialized='incremental',
        unique_key='customer_tk'
    )
}}

with source as (
    select * from {{ ref('stg_customer') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    customer_tk,
    customer_source_id,
    email,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
