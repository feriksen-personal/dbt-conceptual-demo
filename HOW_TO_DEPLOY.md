# How to Deploy dbt-conceptual-demo

## Quick Deploy Steps

### 1. Create GitHub Repository

```bash
# On GitHub.com
# Click "+" → "New repository"
# Name: dbt-conceptual-demo
# Description: Live demo of dbt-conceptual with jaffle-shop
# Public: ✓ (required for Codespaces)
# Do NOT initialize with README
# Click "Create repository"
```

### 2. Push Code

```bash
# Extract the demo repo
cd /tmp
tar xzf dbt-conceptual-demo.tar.gz
cd dbt-conceptual-demo

# Commit everything
git commit -m "Initial commit: dbt-conceptual demo with jaffle-shop

Features:
- Devcontainer for GitHub Codespaces
- Pre-configured conceptual model (Party & Transaction domains)
- dbt models tagged with meta.concept and meta.realizes
- CI workflow validates on every push
- One-click demo experience
"

# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/dbt-conceptual-demo.git
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Actions

1. Go to https://github.com/YOUR_USERNAME/dbt-conceptual-demo/settings/actions
2. Under "Actions permissions" select "Allow all actions and reusable workflows"
3. Click "Save"

### 4. Test It

**Test Codespaces:**
1. Go to https://github.com/YOUR_USERNAME/dbt-conceptual-demo
2. Click green "Code" button → "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for setup (~2-3 minutes)
5. Once ready, run: `dbt-conceptual serve`
6. UI opens automatically on port 5000

**Test Locally:**
```bash
git clone https://github.com/YOUR_USERNAME/dbt-conceptual-demo.git
cd dbt-conceptual-demo
pip install -r requirements.txt
bash .devcontainer/setup.sh
dbt-conceptual serve
```

## What's Included

### Files Created

```
dbt-conceptual-demo/
├── .devcontainer/
│   ├── devcontainer.json        # Codespaces config
│   └── setup.sh                 # Auto-setup script
├── .github/workflows/
│   └── validate.yml             # CI validation
├── models/
│   ├── conceptual/
│   │   └── conceptual.yml       # ⭐ Conceptual model
│   ├── marts/
│   │   ├── customers.yml        # Tagged with meta.concept
│   │   ├── orders.yml           # Tagged with meta.realizes
│   │   └── ...
│   └── ...
├── README.md                    # User-facing docs
├── SETUP.md                     # This guide
├── requirements.txt             # Python deps
└── ... (jaffle-shop files)
```

### Conceptual Model

Defines 3 concepts in 2 domains:

**Party Domain:**
- Customer

**Transaction Domain:**
- Order
- Payment

**Relationships:**
- customer:places:order (1:N)
- customer:pays_for:payment (1:N)
- payment:payment_for:order (N:1)

### Tagged Models

- `customers` → tagged with `concept: customer`
- `orders` → tagged with `realizes: [customer:places:order]`

## Update Main README

Add this to your main dbt-conceptual README:

```markdown
## 🚀 Try It Live

Experience dbt-conceptual with a fully configured demo:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/YOUR_USERNAME/dbt-conceptual-demo?quickstart=1)

The demo includes:
- Pre-configured conceptual model with Party and Transaction domains
- dbt models tagged with meta tags
- Interactive web UI for editing
- One-click launch in GitHub Codespaces

See [dbt-conceptual-demo](https://github.com/YOUR_USERNAME/dbt-conceptual-demo) for details.
```

## Maintenance

### Update dbt-conceptual Version

```bash
# In requirements.txt, update version
dbt-conceptual[serve]>=0.2.0

# Test
pip install -r requirements.txt --upgrade
dbt-conceptual serve

# Commit and push
git add requirements.txt
git commit -m "Update dbt-conceptual to v0.2.0"
git push
```

### Update Conceptual Model

Just edit `models/conceptual/conceptual.yml` and push. The CI will validate it.

## Troubleshooting

**Codespaces not opening?**
- Make sure repo is public
- Check GitHub Actions are enabled

**Setup script failing?**
- Check Python version (needs 3.11+)
- Check dbt-duckdb is compatible

**UI not loading?**
- Run `dbt build` first
- Check port 5000 is forwarded
- Try `dbt-conceptual status` to verify setup
