with source as (
    select * from {{ source('jaffle_crm', 'email_activity') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
),

campaigns as (
    select * from {{ ref('stg_campaign') }}
)

select
    {{ dbt_utils.generate_surrogate_key(["'crm'", 'source.activity_id']) }} as email_activity_tk,
    customers.customer_tk,
    campaigns.campaign_tk,
    source.activity_id as activity_source_id,
    source.customer_id as customer_source_id,
    source.campaign_id as campaign_source_id,
    source.sent_date,
    source.opened,
    source.clicked,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.deleted_at is not null as is_deleted
from source
left join customers
    on source.customer_id = customers.customer_source_id
left join campaigns
    on source.campaign_id = campaigns.campaign_source_id
