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
    bronze.deleted_at is not null as is_deleted
from bronze
left join customers
    on bronze.customer_id = customers.customer_source_id
left join campaigns
    on bronze.campaign_id = campaigns.campaign_source_id
