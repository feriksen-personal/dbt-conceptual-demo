{{
    config(
        alias='fact_web_sessions'
    )
}}

with sessions as (
    select * from {{ ref('stg_web_session') }}
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
)

select
    -- dimension keys (customer)
    sessions.customer_tk,
    cte_customer.customer_hk,
    -- fact timeline
    cast(sessions.session_start as date) as session_date,
    -- measures
    sessions.session_start,
    sessions.session_end,
    sessions.page_views,
    case
        when sessions.session_end is not null
        then extract(epoch from (sessions.session_end - sessions.session_start)) / 60.0
        else null
    end as session_duration_minutes,
    -- metadata
    sessions.load_ts,
    sessions.record_source
from sessions
left join cte_customer
    on sessions.customer_tk = cte_customer.customer_tk
    and cast(sessions.session_start as date) between cte_customer.valid_from and cte_customer.valid_to
