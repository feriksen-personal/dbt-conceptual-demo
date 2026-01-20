with bronze as (
    select * from {{ ref('campaigns') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'crm'", 'campaign_id']) }} as campaign_tk,
    campaign_id as campaign_source_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    created_at,
    updated_at,
    deleted_at,
    deleted_at is not null as is_deleted,
    md5(coalesce(campaign_name, '') || '|' || coalesce(cast(start_date as varchar), '') || '|' || coalesce(cast(end_date as varchar), '') || '|' || coalesce(cast(budget as varchar), '')) as campaign_hd,
    -- metadata
    _loaded_at as load_ts,
    'crm.jaffle_crm.' || _pipeline_run_id as record_source
from bronze
