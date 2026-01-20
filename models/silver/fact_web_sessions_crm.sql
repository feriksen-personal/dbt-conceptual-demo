{{
    config(
        alias='fact_web_sessions',
        materialized='incremental',
        unique_key='web_session_tk'
    )
}}

with source as (
    select * from {{ ref('stg_web_session') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    web_session_tk,
    customer_tk,
    session_source_id,
    session_start,
    session_end,
    page_views,
    case
        when session_end is not null
        then extract(epoch from (session_end - session_start)) / 60.0
        else null
    end as session_duration_minutes,
    created_at,
    updated_at,
    deleted_at,
    is_deleted
from source
