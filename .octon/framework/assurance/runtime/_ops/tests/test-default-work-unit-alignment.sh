#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh"
POLICY="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"

bash "$VALIDATOR"
! yq -e '.routes[].route_id | select(. == "direct-main")' "$POLICY" >/dev/null 2>&1
yq -e '.closeout_defaults.target_lifecycle_outcome.unspecified_closeout_request == "preserved"' "$POLICY" >/dev/null
yq -e '.hosted_provider_ruleset.branch_no_pr_hosted_landing.mechanism == "disabled"' "$POLICY" >/dev/null
echo "PASS: default work unit is SI-00-contained"
