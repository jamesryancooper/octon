#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Projection Shell Boundary Validation =="
POLICY="$OCTON_DIR/instance/governance/contracts/projection-shell-boundary-policy.yml"
[[ -f "$POLICY" ]] && pass "projection shell boundary policy exists" || fail "missing projection shell boundary policy"

check_anchor() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if /usr/bin/grep -Fq "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_anchor "$ROOT_DIR/.github/workflows/ai-review-gate.yml" "run-evaluator-adapter.sh" "ai-review-gate routes provider evaluation through repo-local script"
check_anchor "$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml" "evaluate-pr-autonomy-policy.sh" "pr-autonomy-policy routes decisions through repo-local script"
check_anchor "$ROOT_DIR/.github/workflows/architecture-conformance.yml" "validate-version-parity.sh" "architecture-conformance runs repo-local validators"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
