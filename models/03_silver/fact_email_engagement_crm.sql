{{
    config(
        alias='fact_email_engagement'
    )
}}

with emails as (
    select * from {{ ref('stg_email_activity') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

-- SCD2 dimension lookup: customer
cte_customer as (
    select
        customer_tk,
        customer_hk,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by customer_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_customer_erp') }}
),

-- SCD2 dimension lookup: campaign
cte_campaign as (
    select
        campaign_tk,
        campaign_hk,
        valid_from,
        coalesce(
            lead(valid_from) over (partition by campaign_tk order by valid_from) - interval '1 day',
            cast('9999-12-31' as date)
        ) as valid_to
    from {{ ref('dim_campaign_crm') }}
)

select
    -- dimension keys (customer -> campaign)
    emails.customer_tk,
    cte_customer.customer_hk,
    emails.campaign_tk,
    cte_campaign.campaign_hk,
    -- fact timeline
    emails.sent_date,
    -- measures
    emails.opened,
    emails.clicked,
    case
        when emails.clicked then 'clicked'
        when emails.opened then 'opened'
        else 'sent'
    end as engagement_level,
    -- metadata
    emails.load_ts,
    emails.record_source
from emails
left join cte_customer
    on emails.customer_tk = cte_customer.customer_tk
    and emails.sent_date between cte_customer.valid_from and cte_customer.valid_to
left join cte_campaign
    on emails.campaign_tk = cte_campaign.campaign_tk
    and emails.sent_date between cte_campaign.valid_from and cte_campaign.valid_to
