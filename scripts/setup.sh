#!/usr/bin/env bash
set -euo pipefail

echo "=== DevSecOps Pipeline Setup ==="

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required"; exit 1; }
command -v kubectl >/dev/null 2>&1 || echo "Warning: kubectl not found"
command -v kind  >/dev/null 2>&1 || echo "Warning: kind not found"

if ! gh auth status 2>/dev/null; then
  echo "Please authenticate with GitHub CLI: gh auth login"
  exit 1
fi

# Create app repo
echo "Creating devsecops-app repository..."
gh repo create irfanjat/devsecops-app --public --source=. --push --remote=origin

# Create config repo
echo "Creating devsecops-config repository..."
TEMP_DIR=$(mktemp -d)
cp -r k8s "$TEMP_DIR/"
cp argocd-app.yaml "$TEMP_DIR/"
cd "$TEMP_DIR"
git init
git add .
git commit -m "init: K8s manifests and ArgoCD app"
gh repo create irfanjat/devsecops-config --public --source=. --push
cd - && rm -rf "$TEMP_DIR"

# Setup GitHub secrets
echo "Setting up GitHub secrets..."
gh secret set CONFIG_REPO_PAT -b"<your-github-pat>" --repo irfanjat/devsecops-app

# Deploy to kind cluster
if command -v kind >/dev/null 2>&1; then
  echo "Setting up kind cluster..."
  kind create cluster --name devsecops --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
EOF
fi

echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Push code to trigger the pipeline: git push origin main"
echo "  2. Monitor pipeline: https://github.com/irfanjat/devsecops-app/actions"
echo "  3. ArgoCD will sync the config repo automatically"
