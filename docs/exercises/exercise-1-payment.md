# Exercise 1: Complete the DRAFT concept (payment)

## Problem

The `payment` concept is defined in `conceptual.yml` but has no model implementation. This represents **top-down modeling**: the business concept exists, implementation follows.

## Current State

```bash
dbt-conceptual status
```

Output shows:
```
DRAFT:  payment (concept defined, no model)
```

## Solution

### Step 1: Create the model

Create `models/gold/fact_payments.sql`:

```sql
{{
    config(
        alias='fact_payments',
        materialized='incremental',
        unique_key='payment_sk'
    )
}}

with source as (
    select * from {{ ref('fact_payments_erp') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

dim_date as (
    select * from {{ ref('dim_date') }}
)

select
    source.payment_tk as payment_sk,
    source.order_tk as order_sk,
    dim_date.date_sk as payment_date_sk,
    source.payment_source_id,
    source.payment_method,
    source.amount,
    source.created_at,
    source.updated_at,
    source.deleted_at,
    source.is_deleted
from source
left join dim_date on cast(source.created_at as date) = dim_date.date_day
```

### Step 2: Add schema definition

Add to `models/gold/gold.schema.yml`:

```yaml
  - name: fact_payments
    description: "L2 Integrated payments fact"
    meta:
      concept: payment
    columns:
      - name: payment_sk
        description: "Surrogate key"
        tests:
          - not_null
          - unique
      - name: order_sk
        description: "FK to fact_orders"
        tests:
          - relationships:
              to: ref('fact_orders')
              field: order_sk
      - name: payment_date_sk
        description: "FK to dim_date"
        tests:
          - relationships:
              to: ref('dim_date')
              field: date_sk
```

### Step 3: Build and validate

```bash
dbt build --select fact_payments
dbt-conceptual sync
dbt-conceptual status
```

The `payment` concept should now show as complete.
