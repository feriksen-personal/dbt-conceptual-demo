{{
    config(
        alias='dim_order'
    )
}}

with source as (
    select * from {{ ref('stg_order') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    order_tk,
    customer_tk,
    order_source_id,
    order_date,
    order_status,
    created_at,
    updated_at,
    deleted_at,
    is_deleted,
    order_hd,
    md5(order_tk || '|' || coalesce(cast(deleted_at as varchar), cast(updated_at as varchar), '')) as order_hk,
    cast(coalesce(deleted_at, updated_at, created_at) as date) as valid_from,
    -- metadata
    load_ts,
    record_source
from source
{% if is_incremental() %}
where source.order_hd != (
    select existing.order_hd
    from {{ this }} existing
    where existing.order_tk = source.order_tk
    order by existing.valid_from desc
    limit 1
)
or not exists (
    select 1 from {{ this }} existing
    where existing.order_tk = source.order_tk
)
{% endif %}
