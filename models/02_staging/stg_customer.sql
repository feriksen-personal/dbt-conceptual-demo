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
    deleted_at is not null as is_deleted,
    md5(coalesce(first_name, '') || '|' || coalesce(last_name, '')) as customer_hd,
    -- metadata
    _loaded_at as load_ts,
    'erp.jaffle_shop.' || _pipeline_run_id as record_source
from bronze
