# Setup Guide for dbt-conceptual-demo

This guide shows how to set up this demo repository on GitHub.

## Step 1: Create the Repository on GitHub

```bash
# On GitHub, create a new repository: dbt-conceptual-demo
# Make it public so Codespaces work
# Don't initialize with README (we have one)
```

## Step 2: Push Initial Code

```bash
cd /tmp/dbt-conceptual-demo

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: dbt-conceptual demo with jaffle-shop

- Pre-configured devcontainer for Codespaces
- Conceptual model with Party and Transaction domains
- dbt models tagged with meta.concept and meta.realizes
- CI workflow for validation
- Complete setup script
"

# Add remote and push
git remote add origin https://github.com/feriksen-personal/dbt-conceptual-demo.git
git branch -M main
git push -u origin main
```

## Step 3: Enable GitHub Actions

1. Go to repository Settings → Actions → General
2. Enable "Allow all actions and reusable workflows"
3. Save

## Step 4: Test Codespaces

1. Go to your repository on GitHub
2. Click the green "Code" button
3. Click "Codespaces" tab
4. Click "Create codespace on main"
5. Wait for setup to complete (runs `.devcontainer/setup.sh`)
6. Try: `dbt-conceptual serve`

## Step 5: Update Main dbt-conceptual README

Add a link to the demo in your main repo README:

```markdown
## Try It Live

Try dbt-conceptual with a live demo:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/feriksen-personal/dbt-conceptual-demo?quickstart=1)

See [dbt-conceptual-demo](https://github.com/feriksen-personal/dbt-conceptual-demo) for details.
```

## Maintenance

To update the demo with new dbt-conceptual features:

```bash
# In the demo repo
pip install --upgrade dbt-conceptual[serve]

# Test new features
dbt-conceptual status
dbt-conceptual serve

# Update README if needed
# Commit and push
```
