#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

bash "$ROOT/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh"
bash "$ROOT/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh"
