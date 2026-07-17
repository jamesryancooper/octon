#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
MACHINE="$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml"

bash "$VALIDATOR"
yq -e '.phases[] | select(.phase_id == "effect-denial")' "$MACHINE" >/dev/null
yq -e '.forbidden_actions[] | select(. == "select direct-main")' "$MACHINE" >/dev/null
! yq -e '.lifecycle_outcomes[] | select(. == "cleaned")' "$MACHINE" >/dev/null 2>&1
echo "PASS: state machine is preservation and denial only"
