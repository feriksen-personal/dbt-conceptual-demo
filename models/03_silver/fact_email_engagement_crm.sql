{{
    config(
        alias='fact_email_engagement'
    )
}}

with source as (
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
    source.email_activity_tk,
    source.customer_tk,
    cte_customer.customer_hk,
    source.campaign_tk,
    cte_campaign.campaign_hk,
    source.activity_source_id,
    source.sent_date,
    source.opened,
    source.clicked,
    case
        when source.clicked then 'clicked'
        when source.opened then 'opened'
        else 'sent'
    end as engagement_level,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.is_deleted,
    source.email_activity_hd,
    -- metadata
    source.load_ts,
    source.record_source
from source
left join cte_customer
    on source.customer_tk = cte_customer.customer_tk
    and source.sent_date between cte_customer.valid_from and cte_customer.valid_to
left join cte_campaign
    on source.campaign_tk = cte_campaign.campaign_tk
    and source.sent_date between cte_campaign.valid_from and cte_campaign.valid_to
