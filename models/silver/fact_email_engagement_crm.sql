{{
    config(
        alias='fact_email_engagement',
        materialized='incremental',
        unique_key='email_activity_tk'
    )
}}

with source as (
    select * from {{ ref('stg_email_activity') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    email_activity_tk,
    customer_tk,
    campaign_tk,
    activity_source_id,
    sent_date,
    opened,
    clicked,
    case
        when clicked then 'clicked'
        when opened then 'opened'
        else 'sent'
    end as engagement_level,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
