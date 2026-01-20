with source as (
    select * from {{ ref('dim_order_erp') }}
)

select
    order_hk as order_sk,
    order_source_id,
    customer_tk,
    order_date,
    order_status,
    is_deleted,
    valid_from
from source
