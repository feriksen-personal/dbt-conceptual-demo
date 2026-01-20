{{
    config(
        alias='fact_customer_engagement'
    )
}}

with web_sessions as (
    select
        web_session_tk as engagement_tk,
        customer_tk,
        null as campaign_tk,
        cast(session_start as date) as engagement_date,
        'web_session' as engagement_type,
        page_views as engagement_value,
        session_duration_minutes,
        null as opened,
        null as clicked,
        created_at,
        updated_at
    from {{ ref('fact_web_sessions_crm') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

email_engagement as (
    select
        email_activity_tk as engagement_tk,
        customer_tk,
        campaign_tk,
        cast(sent_date as date) as engagement_date,
        'email' as engagement_type,
        case
            when clicked then 3
            when opened then 2
            else 1
        end as engagement_value,
        null as session_duration_minutes,
        opened,
        clicked,
        created_at,
        updated_at
    from {{ ref('fact_email_engagement_crm') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
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
    combined.engagement_tk as engagement_sk,
    combined.customer_tk as customer_sk,
    combined.campaign_tk as campaign_sk,
    dim_date.date_sk as engagement_date_sk,
    combined.engagement_date,
    combined.engagement_type,
    combined.engagement_value,
    combined.session_duration_minutes,
    combined.opened,
    combined.clicked,
    combined.created_at,
    combined.updated_at
from combined
left join dim_date
    on combined.engagement_date = dim_date.date_day
