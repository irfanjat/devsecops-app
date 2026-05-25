# DevSecOps CI/CD Pipeline

> End-to-end DevSecOps pipeline integrating security scanning at every stage of CI/CD — container vuln scanning, code security audit, K8s policy enforcement, and GitOps deployment on Kubernetes.

## Architecture

```
┌─────────────┐    ┌─────────┐    ┌────────────┐    ┌────────────────┐    ┌─────────────┐    ┌──────────┐
│  Stage 1    │    │ Stage 2 │    │  Stage 3   │    │   Stage 4     │    │  Stage 5    │    │ Stage 6  │
│  Lint       │ →  │ Test    │ →  │ Code Scan  │ →  │ Build & Scan  │ →  │ Config Scan │ →  │ Deploy   │
│  hadolint   │    │ pytest  │    │ Bandit     │    │ Trivy + Push  │    │ OPA/Conftest│    │ GitOps   │
│  yamllint   │    │         │    │            │    │               │    │             │    │ ArgoCD   │
└─────────────┘    └─────────┘    └────────────┘    └────────────────┘    └─────────────┘    └──────────┘
```

## Pipeline Stages

### Stage 1 — Lint
- **hadolint**: Dockerfile best-practices check (multi-stage, no-root, pinned versions)
- **yamllint**: YAML syntax validation

### Stage 2 — Test
- **pytest**: Unit tests with security endpoint coverage (auth, input validation)

### Stage 3 — Code Security Scan
- **Bandit**: SAST (Static Application Security Testing) for Python — finds hardcoded secrets, injection flaws, insecure imports

### Stage 4 — Build & Container Scan
- **Trivy**: Scans Docker image for CVEs (Critical & High severity) with SARIF output
- Results uploaded to **GitHub Security** tab
- Image pushed to GHCR only if scan passes

### Stage 5 — Config Policy Check
- **OPA/Conftest**: Rego policies enforce K8s security posture:
  - `must not run as root`
  - `must have CPU/memory limits`
  - `must have readiness + liveness probes`
  - `must not use :latest tag`
  - `must use trusted registry (ghcr.io)`
  - `must have securityContext with dropped capabilities`

### Stage 6 — Deploy (GitOps)
- Updates config repo `k8s/deployment.yaml` with new SHA-based image tag
- ArgoCD detects drift and syncs to cluster

## Repositories

| Repo | Purpose |
|---|---|
| `irfanjat/devsecops-app` | Application code + CI pipeline |
| `irfanjat/devsecops-config` | K8s manifests consumed by ArgoCD |

## Tech Stack

| Category | Tools |
|---|---|
| CI/CD | GitHub Actions |
| Container | Docker, Trivy, hadolint |
| K8s | Kubernetes, kind |
| GitOps | ArgoCD |
| Policy | OPA, Conftest, Rego |
| SAST | Bandit |
| Monitoring | Prometheus, Grafana (external) |

## Local Test

```bash
chmod +x scripts/local-test.sh
./scripts/local-test.sh
```

## Setup

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Requires: Docker, kind, kubectl, gh CLI with auth.

## Key Outcomes

- **Zero CVEs in production** — Trivy blocks vulnerable images at build time
- **Policy-as-code** — K8s manifests validated before deployment reaches cluster
- **Immutable tags** — Every deploy uses unique Git SHA tag; no `:latest` in prod
- **Audit trail** — SARIF reports in GitHub Security tab
- **MTTR reduction** — Security issues caught in CI, not in production
