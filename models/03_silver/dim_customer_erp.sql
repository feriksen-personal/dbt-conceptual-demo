{{
    config(
        alias='dim_customer'
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
    is_deleted,
    customer_hd,
    md5(customer_tk || '|' || coalesce(cast(deleted_at as varchar), cast(updated_at as varchar), '')) as customer_hk,
    cast(coalesce(deleted_at, updated_at, created_at) as date) as valid_from,
    -- metadata
    load_ts,
    record_source
from source
{% if is_incremental() %}
where source.customer_hd != (
    select existing.customer_hd
    from {{ this }} existing
    where existing.customer_tk = source.customer_tk
    order by existing.valid_from desc
    limit 1
)
or not exists (
    select 1 from {{ this }} existing
    where existing.customer_tk = source.customer_tk
)
{% endif %}
