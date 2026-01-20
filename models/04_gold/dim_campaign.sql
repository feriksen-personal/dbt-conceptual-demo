{{
    config(
        alias='dim_campaign',
        materialized='incremental',
        unique_key='campaign_sk'
    )
}}

with source as (
    select * from {{ ref('dim_campaign_crm') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    campaign_tk as campaign_sk,
    campaign_source_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    campaign_status,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
