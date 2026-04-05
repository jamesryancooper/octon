#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

DISCLOSURE_FAMILY="$OCTON_DIR/framework/constitution/contracts/disclosure/family.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_LINEAGE="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
ACTIVE_RELEASE_CARD="$ROOT_DIR/$(yq -r '.active_release.harness_card_ref' "$RELEASE_LINEAGE")"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Disclosure Live-Root Validation =="

  require_yq '.run_card.evidence_root == ".octon/state/evidence/disclosure/runs"' "$DISCLOSURE_FAMILY" "run disclosure root remains canonical"
  require_yq '.harness_card.evidence_root == ".octon/state/evidence/disclosure/releases"' "$DISCLOSURE_FAMILY" "release disclosure root remains canonical"
  require_yq '.harness_card.release_lineage_ref == ".octon/instance/governance/disclosure/release-lineage.yml"' "$DISCLOSURE_FAMILY" "disclosure family points to release-lineage registry"
  require_yq '.support_target_ref == ".octon/instance/governance/support-targets.yml"' "$AUTHORED_CARD" "authored HarnessCard cites support-target declaration"
  require_yq '.governance_exclusions_ref == ".octon/instance/governance/exclusions/action-classes.yml"' "$AUTHORED_CARD" "authored HarnessCard cites governance exclusions"
  require_yq '.claim_summary == load("'"$AUTHORED_CARD"'").claim_summary' "$ACTIVE_RELEASE_CARD" "active release HarnessCard matches authored disclosure"
  require_yq '.active_release.release_id == "2026-04-05-uec-proposal-packet-completion"' "$RELEASE_LINEAGE" "release-lineage marks the bounded release active"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
