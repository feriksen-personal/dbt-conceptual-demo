#!/bin/bash
set -e

echo "Setting up dbt-conceptual demo environment..."

# Setup dbt profile
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
default:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: jaffle_shop.duckdb
      threads: 4
EOF

# Run dbt to build the models
echo "Installing dbt packages..."
dbt deps

echo "Loading source data..."
dbt run-operation load_baseline

echo "Building dbt models..."
dbt build

echo ""
echo "Setup complete!"
echo ""
echo "Try these commands:"
echo "  dbt-conceptual status          # View coverage"
echo "  dbt-conceptual validate        # Validate conceptual model"
echo "  dbt-conceptual serve           # Launch UI at http://localhost:5000"
echo ""
