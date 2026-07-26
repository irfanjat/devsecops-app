#!/usr/bin/env bash
set -euo pipefail

echo "=== Local DevSecOps Pipeline Test ==="

# Stage 1: Lint
echo "--- Stage 1: Lint ---"
docker run --rm -v "$PWD":/workspace ghcr.io/hadolint/hadolint hadolint Dockerfile

# Stage 2: Test
echo "--- Stage 2: Test ---"
pip install -q -r app/requirements.txt -r app/requirements-dev.txt
python -m pytest app/test_app.py -v

# Stage 3: Code Scan
echo "--- Stage 3: Code Security Scan ---"
bandit -r app/ -s B101 -f json

# Stage 4: Build & Container Scan
echo "--- Stage 4: Build & Container Scan ---"
docker build -t devsecops-app:test .
docker run --rm \
  aquasec/trivy:latest image --severity CRITICAL,HIGH --exit-code 1 devsecops-app:test

# Stage 5: Config Policy Check
echo "--- Stage 5: Config Policy Check ---"
if command -v conftest &>/dev/null; then
  conftest test k8s/deployment.yaml k8s/service.yaml k8s/namespace.yaml -p policies/
else
  docker run --rm -v "$PWD":/project openpolicyagent/conftest test k8s/deployment.yaml k8s/service.yaml k8s/namespace.yaml -p policies/
fi

echo "=== All stages passed ==="
