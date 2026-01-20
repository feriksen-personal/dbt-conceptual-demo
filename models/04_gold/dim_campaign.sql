with source as (
    select * from {{ ref('dim_campaign_crm') }}
)

select
    campaign_hk as campaign_sk,
    campaign_source_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    campaign_status,
    is_deleted,
    valid_from
from source
