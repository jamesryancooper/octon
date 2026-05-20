#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_validator_common.sh"
release_id="$(resolve_validator_release_id "${1:-}")"
bash "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh"
bash "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh"
write_validator_report "$release_id" "authority-classification-report.yml" "V-SOT-001" "pass" "Authored authority remains confined to framework and instance surfaces, with raw inputs and generated outputs kept non-authoritative."
