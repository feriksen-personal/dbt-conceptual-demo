with source as (
    select * from {{ ref('dim_customer_erp') }}
)

select
    customer_hk as customer_sk,
    customer_source_id,
    email,
    first_name,
    last_name,
    full_name,
    is_deleted,
    valid_from
from source
