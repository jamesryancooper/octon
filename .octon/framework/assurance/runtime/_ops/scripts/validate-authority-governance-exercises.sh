#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_yq() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Authority Governance Exercise Validation =="

  local approval_run="uec-safe-stage-approval-exercise-20260402"
  local lease_run="uec-safe-stage-lease-revocation-exercise-20260402"

  require_file "$OCTON_DIR/state/control/execution/approvals/requests/${approval_run}.yml"
  require_file "$OCTON_DIR/state/control/execution/approvals/grants/grant-${approval_run}.yml"
  require_file "$OCTON_DIR/state/evidence/disclosure/runs/${approval_run}/run-card.yml"
  require_file "$OCTON_DIR/state/evidence/control/execution/authority-decision-${approval_run}.yml"

  require_yq '.workflow_mode == "role-mediated"' "$OCTON_DIR/state/control/execution/approvals/requests/${approval_run}.yml" "approval exercise uses role-mediated request"
  require_yq '.state == "active"' "$OCTON_DIR/state/control/execution/approvals/grants/grant-${approval_run}.yml" "approval exercise grant is active"
  require_yq '.decision == "ALLOW"' "$OCTON_DIR/state/evidence/control/execution/authority-decision-${approval_run}.yml" "approval exercise decision is ALLOW"

  require_file "$OCTON_DIR/state/control/execution/approvals/requests/${lease_run}.yml"
  require_file "$OCTON_DIR/state/control/execution/approvals/grants/grant-${lease_run}.yml"
  require_file "$OCTON_DIR/state/control/execution/exceptions/leases/lease-uec-safe-stage-lease-revocation-exercise-20260402.yml"
  require_file "$OCTON_DIR/state/control/execution/revocations/revoke-uec-safe-stage-lease-revocation-exercise-20260402.yml"
  require_file "$OCTON_DIR/state/evidence/disclosure/runs/${lease_run}/run-card.yml"
  require_file "$OCTON_DIR/state/evidence/control/execution/authority-decision-${lease_run}.yml"

  require_yq '.lease_id == "lease-uec-safe-stage-lease-revocation-exercise-20260402" and .run_id == "uec-safe-stage-lease-revocation-exercise-20260402"' "$OCTON_DIR/state/control/execution/exceptions/leases/lease-uec-safe-stage-lease-revocation-exercise-20260402.yml" "lease exercise retains bounded exception lease"
  require_yq '.revocation_id == "revoke-uec-safe-stage-lease-revocation-exercise-20260402" and .state == "active"' "$OCTON_DIR/state/control/execution/revocations/revoke-uec-safe-stage-lease-revocation-exercise-20260402.yml" "revocation exercise retains active revocation"
  require_yq '.decision == "DENY"' "$OCTON_DIR/state/evidence/control/execution/authority-decision-${lease_run}.yml" "revocation exercise decision is DENY"
  require_yq '.exception_refs | length > 0 and .revocation_refs | length > 0' "$OCTON_DIR/state/evidence/control/execution/authority-decision-${lease_run}.yml" "revocation exercise decision records lease and revocation refs"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
