#!/bin/bash
set -e

echo "Setting up dbt-conceptual demo environment..."

# Create data directory
mkdir -p data

# Run dbt to build the models
echo "Installing dbt packages..."
dbt deps

echo "Loading source data..."
# Use origin_load_baseline for initial setup (creates tables and loads data)
# For subsequent runs, use: dbt run-operation origin_reset --profile ingestion_simulator
dbt run-operation origin_load_baseline --profile ingestion_simulator

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
