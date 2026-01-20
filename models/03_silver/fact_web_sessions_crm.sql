{{
    config(
        alias='fact_web_sessions'
    )
}}

with source as (
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
    source.web_session_tk,
    source.customer_tk,
    cte_customer.customer_hk,
    source.session_source_id,
    source.session_start,
    source.session_end,
    source.page_views,
    case
        when source.session_end is not null
        then extract(epoch from (source.session_end - source.session_start)) / 60.0
        else null
    end as session_duration_minutes,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.is_deleted,
    source.web_session_hd,
    -- metadata
    source.load_ts,
    source.record_source
from source
left join cte_customer
    on source.customer_tk = cte_customer.customer_tk
    and cast(source.session_start as date) between cte_customer.valid_from and cte_customer.valid_to
