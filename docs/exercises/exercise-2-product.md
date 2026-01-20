# Exercise 2: Enrich the STUB concept (product)

## Problem

The `product` models exist (`dim_product_erp`, `dim_product`) but the concept definitions are missing from `conceptual.yml`. This represents **bottom-up modeling**: implementation exists, concept documentation follows.

## Current State

```bash
dbt-conceptual sync --create-stubs
dbt-conceptual status
```

Output shows:
```
STUB:   product_erp (discovered from dim_product_erp, needs definition)
STUB:   product (discovered from dim_product, needs definition)
```

## Solution

### Step 1: Review discovered stubs

After running sync, check `conceptual.yml` for auto-generated stubs:

```yaml
product_erp:
  name: "Product Erp"
  domain: null          # Required - must be filled
  owner: null           # Required - must be filled
  definition: null      # Required - must be filled
  status: stub
  discovered_from: dim_product_erp

product:
  name: "Product"
  domain: null
  owner: null
  definition: null
  status: stub
  discovered_from: dim_product
```

### Step 2: Enrich the concepts

Update `models/conceptual/conceptual.yml`. Find the stub entries and replace with:

```yaml
  # In the L1 ERP Concepts section:
  product_erp:
    name: "Product (ERP)"
    domain: product
    owner: erp_team
    definition: "Product catalog from ERP system"

  # In the L2 Integrated Concepts section:
  product:
    name: "Product"
    domain: product
    owner: enterprise_data
    definition: "Conformed product dimension"
```

### Step 3: Validate

```bash
dbt-conceptual validate
dbt-conceptual status
```

Both `product_erp` and `product` should now show as complete.

## Bonus: Add meta.concept to schema

For full alignment, also add `meta.concept` to `gold.schema.yml`:

```yaml
  - name: dim_product
    description: "L2 Conformed product dimension"
    meta:
      concept: product    # Add this line
    columns:
      # ...
```
