{{
    config(
        alias='dim_date',
        materialized='table'
    )
}}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast(current_date - interval '30 day' as date)",
        end_date="cast(current_date + interval '365 day' as date)"
    ) }}
)

select
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_sk,
    cast(date_day as date) as date_day,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(week from date_day) as week_of_year,
    extract(day from date_day) as day_of_month,
    extract(dayofweek from date_day) as day_of_week,
    case extract(dayofweek from date_day)
        when 0 then 'Sunday'
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
    end as day_name,
    case when extract(dayofweek from date_day) in (0, 6) then true else false end as is_weekend
from date_spine
