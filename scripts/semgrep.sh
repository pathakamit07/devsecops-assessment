#!/usr/bin/env bash
set -euo pipefail
if ! command -v semgrep >/dev/null 2>&1; then
  echo 'semgrep not found. Install: pip3 install semgrep'
  exit 2
fi
echo 'Running semgrep with .semgrep/default.yml ...'
semgrep --config .semgrep/default.yml .

