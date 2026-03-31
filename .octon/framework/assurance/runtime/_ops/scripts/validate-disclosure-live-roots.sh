#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

DISCLOSURE_FAMILY="$OCTON_DIR/framework/constitution/contracts/disclosure/family.yml"
GOVERNANCE_DISCLOSURE_README="$OCTON_DIR/instance/governance/disclosure/README.md"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
ATOMIC_RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml"
CLOSURE_RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-closure/harness-card.yml"
HISTORICAL_MIRROR_NOTE="Historical lab-local HarnessCard files remain retained as non-live mirrors under state/evidence/lab/harness-cards."

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

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if rg -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
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
  echo "== Disclosure Live-Root Validation =="

  require_file "$DISCLOSURE_FAMILY"
  require_file "$GOVERNANCE_DISCLOSURE_README"
  require_file "$AUTHORED_CARD"
  require_file "$ATOMIC_RELEASE_CARD"
  require_file "$CLOSURE_RELEASE_CARD"

  require_yq '.change_profile == "atomic"' "$DISCLOSURE_FAMILY" "disclosure family remains atomic"
  require_yq '.profile_selection_receipt_ref == ".octon/instance/cognition/context/shared/migrations/2026-03-30-unified-execution-constitution-atomic-cutover/plan.md"' "$DISCLOSURE_FAMILY" "disclosure family uses the March 30 live selector"
  require_yq '.harness_card.authored_source_ref == ".octon/instance/governance/disclosure/harness-card.yml"' "$DISCLOSURE_FAMILY" "disclosure family keeps governance as the authored HarnessCard source"
  require_yq '.harness_card.evidence_root == ".octon/state/evidence/disclosure/releases"' "$DISCLOSURE_FAMILY" "disclosure family keeps retained release disclosure as the live evidence root"
  require_yq '.harness_card.historical_mirror_root == ".octon/state/evidence/lab/harness-cards"' "$DISCLOSURE_FAMILY" "disclosure family keeps lab HarnessCards historical only"
  require_yq '.run_card.evidence_root == ".octon/state/evidence/disclosure/runs"' "$DISCLOSURE_FAMILY" "disclosure family keeps run disclosure under retained run evidence roots"

  require_text "authored source of truth" "$GOVERNANCE_DISCLOSURE_README" "governance disclosure README keeps authored source semantics"
  require_text "canonical release disclosure roots" "$GOVERNANCE_DISCLOSURE_README" "governance disclosure README keeps release disclosure roots canonical"
  require_text "historical mirrors" "$GOVERNANCE_DISCLOSURE_README" "governance disclosure README keeps lab mirrors historical"

  require_text "$HISTORICAL_MIRROR_NOTE" "$AUTHORED_CARD" "authored HarnessCard keeps the historical mirror note"
  require_text "$HISTORICAL_MIRROR_NOTE" "$ATOMIC_RELEASE_CARD" "atomic release HarnessCard keeps the historical mirror note"
  require_text "$HISTORICAL_MIRROR_NOTE" "$CLOSURE_RELEASE_CARD" "closure release HarnessCard keeps the historical mirror note"

  if rg -Fq -- ".octon/state/evidence/lab/harness-cards" "$ATOMIC_RELEASE_CARD" && ! rg -Fq -- "$HISTORICAL_MIRROR_NOTE" "$ATOMIC_RELEASE_CARD"; then
    fail "atomic release HarnessCard does not treat lab HarnessCards as historical only"
  else
    pass "atomic release HarnessCard does not promote lab HarnessCards into live roots"
  fi
  if rg -Fq -- ".octon/state/evidence/lab/harness-cards" "$CLOSURE_RELEASE_CARD" && ! rg -Fq -- "$HISTORICAL_MIRROR_NOTE" "$CLOSURE_RELEASE_CARD"; then
    fail "closure release HarnessCard does not treat lab HarnessCards as historical only"
  else
    pass "closure release HarnessCard does not promote lab HarnessCards into live roots"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
