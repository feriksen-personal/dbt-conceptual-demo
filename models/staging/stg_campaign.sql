with source as (
    select * from {{ source('jaffle_crm', 'campaigns') }}
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
    deleted_at is not null as is_deleted
from source
