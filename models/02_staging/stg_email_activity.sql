with bronze as (
    select * from {{ ref('email_activity') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
),

campaigns as (
    select * from {{ ref('stg_campaign') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'crm'", 'bronze.activity_id']) }} as email_activity_tk,
    customers.customer_tk,
    campaigns.campaign_tk,
    bronze.activity_id as activity_source_id,
    bronze.customer_id as customer_source_id,
    bronze.campaign_id as campaign_source_id,
    bronze.sent_date,
    bronze.opened,
    bronze.clicked,
    bronze.created_at,
    bronze.updated_at,
    bronze.deleted_at,
    bronze.deleted_at is not null as is_deleted,
    md5(coalesce(cast(bronze.customer_id as varchar), '') || '|' || coalesce(cast(bronze.campaign_id as varchar), '') || '|' || coalesce(cast(bronze.sent_date as varchar), '') || '|' || coalesce(cast(bronze.opened as varchar), '') || '|' || coalesce(cast(bronze.clicked as varchar), '')) as email_activity_hd,
    -- metadata
    bronze._loaded_at as load_ts,
    'crm.jaffle_crm.' || bronze._pipeline_run_id as record_source
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
left join campaigns
    on bronze.campaign_id = campaigns.campaign_source_id
