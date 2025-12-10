#!/usr/bin/env bash
set -euo pipefail
IMAGE_NAME=\
if ! command -v trivy >/dev/null 2>&1; then
  echo 'trivy not found. Follow https://aquasecurity.github.io/trivy/v0.50.1/getting-started/installation/'
  exit 2
fi
echo \"Scanning image: \ (severity HIGH,CRITICAL) ...\"
trivy image --exit-code 1 --severity HIGH,CRITICAL \ || { echo 'High/Critical findings found'; exit 1; }
echo 'No HIGH/CRITICAL vulnerabilities found by trivy.'

