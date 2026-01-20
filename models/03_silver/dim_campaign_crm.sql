{{
    config(
        alias='dim_campaign'
    )
}}

with source as (
    select * from {{ ref('stg_campaign') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    campaign_tk,
    campaign_source_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    case
        when end_date < current_date then 'completed'
        when start_date > current_date then 'planned'
        else 'active'
    end as campaign_status,
    created_at,
    updated_at,
    deleted_at,
    is_deleted,
    campaign_hd,
    md5(campaign_tk || '|' || coalesce(cast(deleted_at as varchar), cast(updated_at as varchar), '')) as campaign_hk,
    cast(coalesce(deleted_at, updated_at, created_at) as date) as valid_from,
    -- metadata
    load_ts,
    record_source
from source
{% if is_incremental() %}
where source.campaign_hd != (
    select existing.campaign_hd
    from {{ this }} existing
    where existing.campaign_tk = source.campaign_tk
    order by existing.valid_from desc
    limit 1
)
or not exists (
    select 1 from {{ this }} existing
    where existing.campaign_tk = source.campaign_tk
)
{% endif %}
