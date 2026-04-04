#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

DISCLOSURE_FAMILY="$OCTON_DIR/framework/constitution/contracts/disclosure/family.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/harness-card.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Disclosure Live-Root Validation =="

  require_yq '.run_card.evidence_root == ".octon/state/evidence/disclosure/runs"' "$DISCLOSURE_FAMILY" "run disclosure root remains canonical"
  require_yq '.harness_card.evidence_root == ".octon/state/evidence/disclosure/releases"' "$DISCLOSURE_FAMILY" "release disclosure root remains canonical"
  require_yq '.support_target_ref == ".octon/instance/governance/support-targets.yml"' "$AUTHORED_CARD" "authored HarnessCard cites support-target declaration"
  require_yq '.governance_exclusions_ref == ".octon/instance/governance/exclusions/action-classes.yml"' "$AUTHORED_CARD" "authored HarnessCard cites governance exclusions"
  require_yq '.claim_summary == load("'"$AUTHORED_CARD"'").claim_summary' "$RELEASE_CARD" "release HarnessCard matches authored disclosure"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
