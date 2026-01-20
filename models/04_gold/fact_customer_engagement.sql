with web_sessions as (
    select
        customer_hk,
        null as campaign_hk,
        session_date as engagement_date,
        'web_session' as engagement_type,
        page_views as engagement_value,
        session_duration_minutes,
        null as opened,
        null as clicked
    from {{ ref('fact_web_sessions_crm') }}
),

email_engagement as (
    select
        customer_hk,
        campaign_hk,
        sent_date as engagement_date,
        'email' as engagement_type,
        case
            when clicked then 3
            when opened then 2
            else 1
        end as engagement_value,
        null as session_duration_minutes,
        opened,
        clicked
    from {{ ref('fact_email_engagement_crm') }}
),

combined as (
    select * from web_sessions
    union all
    select * from email_engagement
),

dim_date as (
    select * from {{ ref('dim_date') }}
)

select
    -- dimension keys (customer -> campaign -> date)
    combined.customer_hk as customer_sk,
    combined.campaign_hk as campaign_sk,
    dim_date.date_sk as engagement_date_sk,
    -- fact timeline
    combined.engagement_date,
    -- measures
    combined.engagement_type,
    combined.engagement_value,
    combined.session_duration_minutes,
    combined.opened,
    combined.clicked
from combined
left join dim_date
    on combined.engagement_date = dim_date.date_day
