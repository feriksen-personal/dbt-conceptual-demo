# dbt-conceptual-demo

Demonstrates [dbt-conceptual](https://github.com/feriksen-personal/dbt-conceptual) with realistic source data.

<p align="center">
  <img src="docs/assets/dbt-conceptual-icon.svg" width="80" alt="dbt-conceptual" />
</p>

**Source data powered by [dbt-source-simulator](https://github.com/feriksen-personal/dbt-source-simulator)**

---

## Quick Start (5 min)

```bash
# Clone and setup
git clone https://github.com/feriksen-personal/dbt-conceptual-demo.git
cd dbt-conceptual-demo
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Install dbt packages
dbt deps

# Load source data
dbt run-operation load_baseline

# Build dbt models
dbt build

# Sync conceptual model
dbt-conceptual sync

# See coverage status
dbt-conceptual status
```

**Expected output:**
```
DRAFT:  payment (concept defined, no model)
STUB:   product (discovered, needs definition)
✓       customer, orders, campaign, ...

Coverage: 11/13 concepts complete (85%)
```

**Optionally**, explore visually:
```bash
dbt-conceptual serve
```

PLACEHOLDER:SCREENSHOT_UI_STATUS

---

## Conceptual Model

<p align="center">
  <img src="docs/assets/conceptual-model.svg" alt="Conceptual Model" />
</p>

---

## Explore More

### Exercise 1: Complete the DRAFT concept (payment)

The `payment` concept is defined in `conceptual.yml` but has no model implementation. This represents **top-down modeling**: the business concept exists, implementation follows.

**Option A: Use the UI**
```bash
dbt-conceptual serve
```
Navigate to Concepts → payment → Add Implementation

PLACEHOLDER:SCREENSHOT_UI_PAYMENT

**Option B: Edit YAML directly**

Create `models/gold/fact_payments.sql` and add the concept reference to `gold.schema.yml`.

<details>
<summary>Show complete solution</summary>

See `docs/exercises/exercise-1-payment.md`

</details>

---

### Exercise 2: Enrich the STUB concept (product)

The `product` models exist (`dim_product_erp`, `dim_product`) but the concept definitions are missing from `conceptual.yml`. This represents **bottom-up modeling**: implementation exists, concept documentation follows.

Run sync to see the stub:
```bash
dbt-conceptual sync --create-stubs
dbt-conceptual status
```

**Option A: Use the UI**
```bash
dbt-conceptual serve
```
Navigate to Concepts → product (stub) → Enrich

PLACEHOLDER:SCREENSHOT_UI_PRODUCT_STUB

**Option B: Edit YAML directly**

Add `product_erp` and `product` concepts to `models/conceptual/conceptual.yml`.

<details>
<summary>Show complete solution</summary>

See `docs/exercises/exercise-2-product.md`

</details>

---

### Reports

**Coverage Report:**
```bash
dbt-conceptual export --format coverage
```

PLACEHOLDER:SCREENSHOT_COVERAGE_REPORT

**Bus Matrix:**
```bash
dbt-conceptual export --format bus-matrix
```

PLACEHOLDER:SCREENSHOT_BUS_MATRIX

---

### CI/CD Integration

This project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:

1. Builds all dbt models
2. Validates the conceptual model
3. Posts coverage summary to the PR

PLACEHOLDER:SCREENSHOT_GITHUB_ACTION

---

## Want to test SCD2 handling?

The source data evolves over time. Run the delta operations to see dimension changes:

```bash
dbt run-operation apply_delta --args '{day: 1}'
dbt run-operation apply_delta --args '{day: 2}'
dbt run-operation apply_delta --args '{day: 3}'
dbt build --select dim_customer_erp+
```

Watch `dim_customer_erp` handle late-arriving changes, updates, and soft deletes.

---

## Project Structure

```
models/
├── bronze/           # Source definitions
├── staging/          # Views with technical keys
├── silver/           # L1 dimensional models (per source system)
├── gold/             # L2 integrated star schema
└── conceptual/       # dbt-conceptual definitions
```

---

## License

MIT
