{{
    config(
        alias='obt_customer_360',
        materialized='incremental',
        unique_key='customer_sk'
    )
}}

with customers as (
    select * from {{ ref('dim_customer') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

orders as (
    select * from {{ ref('fact_orders') }}
),

engagements as (
    select * from {{ ref('fact_customer_engagement') }}
),

order_metrics as (
    select
        customer_sk,
        count(*) as total_orders,
        sum(order_total) as lifetime_revenue,
        avg(order_total) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from orders
    where not is_deleted
    group by customer_sk
),

engagement_metrics as (
    select
        customer_sk,
        count(*) as total_engagements,
        count(case when engagement_type = 'web_session' then 1 end) as web_sessions,
        count(case when engagement_type = 'email' then 1 end) as emails_received,
        count(case when engagement_type = 'email' and opened then 1 end) as emails_opened,
        count(case when engagement_type = 'email' and clicked then 1 end) as emails_clicked
    from engagements
    group by customer_sk
)

select
    customers.customer_sk,
    customers.email,
    customers.full_name,
    customers.created_at as customer_since,
    -- Order metrics
    order_metrics.total_orders,
    order_metrics.lifetime_revenue,
    order_metrics.avg_order_value,
    order_metrics.first_order_date,
    order_metrics.last_order_date,
    -- Engagement metrics
    engagement_metrics.total_engagements,
    engagement_metrics.web_sessions,
    engagement_metrics.emails_received,
    engagement_metrics.emails_opened,
    engagement_metrics.emails_clicked,
    -- Derived
    case
        when order_metrics.total_orders is null or order_metrics.total_orders = 0 then 'prospect'
        when order_metrics.total_orders = 1 then 'new'
        when order_metrics.total_orders <= 3 then 'developing'
        else 'loyal'
    end as customer_segment,
    customers.is_deleted,
    customers.updated_at
from customers
left join order_metrics
    on customers.customer_sk = order_metrics.customer_sk
left join engagement_metrics
    on customers.customer_sk = engagement_metrics.customer_sk
