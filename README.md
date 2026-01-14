# dbt-conceptual Demo

> **Try [dbt-conceptual](https://github.com/feriksen-personal/dbt-conceptual) with a live demo using the jaffle-shop project**

This repository demonstrates dbt-conceptual with dbt-labs' jaffle-shop example project, pre-configured with a conceptual model.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/feriksen-personal/dbt-conceptual-demo?quickstart=1)

## What's This?

**dbt-conceptual** bridges the gap between your conceptual data model and your dbt implementation. This demo shows:

- ✅ Conceptual model defined in YAML
- ✅ dbt models tagged with `meta.concept` and `meta.realizes`
- ✅ Interactive web UI for editing
- ✅ Coverage reports showing implementation status
- ✅ Bus matrix showing which facts realize relationships
- ✅ CI validation

## Quick Start

### Option 1: GitHub Codespaces (Recommended)

Click the badge above to launch in Codespaces. Everything is pre-configured!

Once the container starts:

```bash
# View coverage
dbt-conceptual status

# Launch interactive UI
dbt-conceptual serve
# Opens automatically on port 5000

# Validate
dbt-conceptual validate

# Export diagrams
dbt-conceptual export --format excalidraw -o diagram.excalidraw
dbt-conceptual export --format coverage -o coverage.html
dbt-conceptual export --format bus-matrix -o bus-matrix.html
```

### Option 2: Local Setup

```bash
# Clone
git clone https://github.com/feriksen-personal/dbt-conceptual-demo.git
cd dbt-conceptual-demo

# Install
pip install -r requirements-demo.txt

# Setup dbt profile (DuckDB)
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: jaffle_shop.duckdb
      threads: 4
EOF

# Build dbt models
dbt deps
dbt build

# Try dbt-conceptual
dbt-conceptual status
dbt-conceptual serve
```

## What's Included

### Conceptual Model

The conceptual model is defined in [`models/conceptual/conceptual.yml`](models/conceptual/conceptual.yml):

- **Domains**: `party`, `transaction`
- **Concepts**: `customer`, `order`, `payment`
- **Relationships**: `customer:places:order`, `customer:pays_for:payment`, `payment:payment_for:order`

### dbt Models Tagged

The dbt models are tagged to link them to concepts:

```yaml
# models/marts/customers.yml
models:
  - name: customers
    meta:
      concept: customer

# models/marts/orders.yml
models:
  - name: orders
    meta:
      realizes:
        - customer:places:order
```

### Interactive UI

Launch with `dbt-conceptual serve` to get:

- **Graph Editor** - Visual drag-and-drop editor with D3.js force-directed layout
- **Coverage Report** - See which concepts are implemented
- **Bus Matrix** - See which fact tables realize relationships
- Direct editing and saving to `conceptual.yml`

## Project Structure

```
dbt-conceptual-demo/
├── .devcontainer/          # GitHub Codespaces config
├── .github/workflows/      # CI validation
├── models/
│   ├── conceptual/
│   │   └── conceptual.yml  # ⭐ Your conceptual model
│   ├── marts/
│   │   ├── customers.yml   # Tagged with meta.concept
│   │   ├── orders.yml      # Tagged with meta.realizes
│   │   └── ...
│   └── ...
├── dbt_project.yml
└── requirements-demo.txt
```

## Learn More

- **dbt-conceptual**: https://github.com/feriksen-personal/dbt-conceptual
- **Documentation**: See main repo README
- **jaffle-shop**: https://github.com/dbt-labs/jaffle-shop

## License

This demo is MIT licensed. The jaffle-shop project is from dbt-labs.
