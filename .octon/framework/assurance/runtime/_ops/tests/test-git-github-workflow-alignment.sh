#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh"
echo "PASS: Git/GitHub route mirrors are SI-00-contained"
