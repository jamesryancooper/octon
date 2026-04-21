#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

bash "$ROOT/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh"
bash "$ROOT/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-completeness.sh"
