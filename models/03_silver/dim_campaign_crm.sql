{{
    config(
        alias='dim_campaign',
        materialized='incremental',
        unique_key='campaign_tk'
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
    is_deleted
from source
