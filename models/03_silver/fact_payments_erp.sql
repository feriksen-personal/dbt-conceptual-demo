{{
    config(
        alias='fact_payments'
    )
}}

with source as (
    select * from {{ ref('stg_payment') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
)

select
    payment_tk,
    order_tk,
    payment_source_id,
    payment_method,
    amount,
    created_at,
    updated_at,
    deleted_at,
    is_deleted,
    payment_hd,
    -- metadata
    load_ts,
    record_source
from source
