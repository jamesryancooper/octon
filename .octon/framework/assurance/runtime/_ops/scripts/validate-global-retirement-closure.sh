#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
GATE="$OCTON_DIR/instance/governance/retirement/claim-gate.yml"
REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
REVIEW_SET="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
LEDGER="$OCTON_DIR/instance/governance/closure/global-support-surface-ledger.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Retirement Closure Validation =="
  CURRENT_REVIEW="$(yq -r '.current_governance_review_ref' "$GATE")"
  require_yq '.nonblocking_statuses | length >= 3' "$GATE" "retirement claim gate publishes nonblocking statuses"
  require_yq '[.entries[] | select(.status != "retired" and .review_date == null)] | length == 0' "$REGISTRY" "no non-retired retirement entry is missing review_date"
  require_yq '.latest_review_packet | test("^\\.octon/state/evidence/validation/publication/build-to-delete/[0-9]{4}-[0-9]{2}-[0-9]{2}$")' "$REVIEW_SET" "closeout reviews point at a canonical build-to-delete packet"
  require_yq '.required_reviews[] | select(.review_id == "retirement-review")' "$REVIEW_SET" "closeout reviews require retirement review"
  require_yq '.claim_ready == true and .claim_blocking_count == 0' "$ROOT_DIR/$CURRENT_REVIEW" "governance retirement claim review reports no blockers"
  require_yq '.retired[] | select(. == "experimental-model-surface")' "$LEDGER" "surface ledger records retired model surface"
  require_yq '.rebound[] | select(.surface_id == "deny-only-external-irreversible-surface")' "$LEDGER" "surface ledger records rebound deny-only surface"
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
