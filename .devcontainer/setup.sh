#!/bin/bash
set -e

echo "🚀 Setting up dbt-conceptual demo environment..."

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Setup dbt profile
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

# Run dbt to build the models
echo "📊 Building dbt models..."
dbt deps
dbt build

# Initialize git if not already done
if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "Initial commit"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Try these commands:"
echo "  dbt-conceptual status          # View coverage"
echo "  dbt-conceptual serve           # Launch UI (opens on port 5000)"
echo "  dbt-conceptual validate        # Validate conceptual model"
echo "  dbt-conceptual export --format excalidraw -o diagram.excalidraw"
echo ""
