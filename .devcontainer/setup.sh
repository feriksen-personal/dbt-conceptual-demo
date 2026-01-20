#!/bin/bash
set -e

echo "Setting up dbt-conceptual demo environment..."

# Create data directory and clean existing databases for fresh start
mkdir -p data
rm -f data/*.duckdb

# Install dbt packages
echo "Installing dbt packages..."
dbt deps

# Load source data (fresh database, so use origin_load_baseline)
echo "Loading source data..."
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Build all dbt models (allow test failures - known issues with source data)
echo "Building dbt models..."
dbt build || echo "Note: Some tests failed. This is expected due to known source data issues."

echo ""
echo "Setup complete!"
echo ""
echo "Try these commands:"
echo "  dbt-conceptual status          # View coverage"
echo "  dbt-conceptual validate        # Validate conceptual model"
echo "  dbt-conceptual serve           # Launch UI at http://localhost:5000"
echo ""
