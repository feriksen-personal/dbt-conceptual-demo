with bronze as (
    select * from {{ ref('customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['email']) }} as customer_tk,
    customer_id as customer_source_id,
    email,
    first_name,
    last_name,
    created_at,
    updated_at,
    deleted_at,
    deleted_at is not null as is_deleted
from bronze
