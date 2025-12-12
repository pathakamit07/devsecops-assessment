# DevSecOps Assessment — End-to-End Implementation

> Author: Amit Pathak

---

## Overview

This repo demonstrates an end-to-end DevSecOps exercise: secure containerization, CI/CD, Terraform-based IaC (EKS simulation), Kubernetes hardening (local), observability, and a short security report. The goal is to show a production-minded design while running everything locally (no paid cloud required).

---

## Project structure (what should be present)

```
devsecops-assessment/
├── .github/workflows/ci.yml
├── Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── networkpolicy.yaml
│   ├── pdb.yaml
│   └── monitoring/
│       ├── 00-namespace.yaml
│       ├── 01-prometheus-setup.yaml
│       ├── 02-grafana-deployment.yaml
│       └── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── terraform.tfvars
├── scripts/
│   ├── semgrep.sh
│   └── trivy.sh
├── scans/
│   ├── semgrep-output.txt
│   ├── trivy-output.txt
│   └── checkov-output.txt
├── REPORT.md
└── README.md
```

---

## Prerequisites (local machine)

* Git
* Docker (for image build & running scanners)
* kind (or minikube) and kubectl for local k8s
* Terraform (for `terraform validate`) — optional if using Dockerized scanners
* PowerShell (you mentioned using Windows)

---

## Quick setup & useful commands

> **Run these from the project root (`devsecops-assessment`)**

### 1) Prepare files and folders

```powershell
mkdir .github\workflows scripts k8s k8s\monitoring terraform scans
```

### 2) CI (GitHub Actions)

* Workflow file: `.github/workflows/ci.yml` — contains steps for checkout, semgrep, build, trivy scan, and conditional push to GHCR only if scan passes.
* To re-run the pipeline after edits: commit & push (see Git commands section).

### 3) Local Docker image build & scan (manual)

```powershell
# build local image
docker build -t webapp:local .
# run trivy (fails only on CRITICAL if configured that way)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --exit-code 1 --severity CRITICAL webapp:local || true
```

### 4) Terraform (EKS simulation)

```powershell
# validate the terraform configuration
terraform -chdir=terraform init
terraform -chdir=terraform validate
# Run Checkov (dockerized) and save output
docker run --rm -v ${PWD}:/repo bridgecrew/checkov:latest -d /repo/terraform 2>&1 | Tee-Object scans/checkov-output.txt
# Or tfsec
docker run --rm -v ${PWD}\terraform:/src aquasec/tfsec:latest /src 2>&1 | Tee-Object scans/tfsec-output.txt
```

Notes: terraform init may fail when provider blocks are invalid for local/offline testing — it's OK for the simulation as long as `terraform validate` passes after fixing syntax.

### 5) Kubernetes hardening (kind)

```powershell
# create cluster (1-time):
kind create cluster --name devsecops --wait 90s
# apply manifests
kubectl apply -f k8s/ --dry-run=client
kubectl apply -f k8s/
# check pods & services
kubectl get pods,svc,ing -n devsecops
# when finished
kind delete cluster --name devsecops
```

Your YAMLs must include:

* `PodSecurityContext` set to non-root and `allowPrivilegeEscalation: false`
* `resources.requests` and `resources.limits` for CPU & memory
* A `NetworkPolicy` to isolate namespaces
* Optional `PodDisruptionBudget` or `HorizontalPodAutoscaler` manifests

### 6) Monitoring (Prometheus + Grafana)

Deploy Prometheus + Grafana manifests in `k8s/monitoring/`. After they are running:

```powershell
kubectl -n monitoring port-forward svc/prometheus 9090:9090
kubectl -n monitoring port-forward svc/grafana 3000:3000
# Grafana URL: http://localhost:3000
# Prometheus URL: http://localhost:9090
```

### 7) Git commands (safe push workflow)

```powershell
# ensure you have the latest remote changes
git fetch origin
git pull --rebase origin main
# add and commit
git add .
git commit -m "<your message>"
# push
git push origin main
```

If push is rejected, `git pull --rebase origin main` then resolve any conflicts, then `git push` again.

---

## Security gates & secrets (CI)

* For pushing to GHCR: you can use the automatic `GITHUB_TOKEN` for public repos — but if you prefer PAT provide `GHCR_TOKEN` as a repo secret.
* If using a PAT: create a **fine-grained token** with `Packages: Read & write` for the repo owner OR use classic token with `write:packages`. Add it to repo Settings → Secrets → Actions as `GHCR_TOKEN`.

**Important**: workflow should `push` only when security steps succeed (use `if: ${{ success() }}` or check job results). Trivy should be configured to fail only on CRITICAL if that's your chosen policy.

---

## Deliverables checklist (what to include in final ZIP or GitHub repo)

* `Dockerfile` and Trivy scan outputs (`scans/trivy-output.txt`)
* `.github/workflows/ci.yml` and pipeline logs/screenshots
* `terraform/` folder with `.tf` files and `scans/checkov-output.txt` (or `tfsec` output)
* `k8s/` folder with Deployment/Service/Ingress/NetworkPolicy/PDB/HPA YAMLs
* `k8s/monitoring/` manifests (Prometheus, Grafana provisioning)
* `REPORT.md` (short 1–2 page summary)

---

## Troubleshooting tips

* If `kind` command not found: install `kind` or use minikube
* If `kubectl` cannot connect: ensure cluster exists and kubeconfig context is set
* For large files in `terraform/.terraform/` (provider executables): do **not** commit `.terraform` or provider binaries. Add `.gitignore` entries:

```
terraform/.terraform/
*.tfstate
*.tfstate.backup
```

* If Git push fails due to large file: remove large files and rewrite history (or use git-lfs). Simpler path: remove `.terraform/providers/...` files and add `.gitignore`, then commit & push.

---

## Notes and best practices

* Keep secrets out of code. Use GitHub Secrets for tokens.
* Use multi-stage Dockerfile and non-root user.
* Make CI fail on high/critical per policy; we chose `CRITICAL` only for your request.
* Keep Terraform code modular and document mapping to real AWS resources in `terraform/README.md`.

---


