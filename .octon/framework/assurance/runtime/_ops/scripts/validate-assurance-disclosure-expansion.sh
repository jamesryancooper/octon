#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

DISCLOSURE_FAMILY="$OCTON_DIR/framework/constitution/contracts/disclosure/family.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
COVERAGE_LEDGER="$ROOT_DIR/$(yq -r '.coverage_ledger_ref' "$AUTHORED_CARD")"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Assurance And Disclosure Expansion Validation =="

  require_file "$OCTON_DIR/framework/constitution/contracts/disclosure/run-card-v2.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/disclosure/harness-card-v2.schema.json"
  require_file "$OCTON_DIR/framework/assurance/evaluators/conformance/global-support-universe.yml"

  require_yq '.run_card.schema_ref == ".octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json"' "$DISCLOSURE_FAMILY" "disclosure family points to RunCard v2"
  require_yq '.harness_card.schema_ref == ".octon/framework/constitution/contracts/disclosure/harness-card-v2.schema.json"' "$DISCLOSURE_FAMILY" "disclosure family points to HarnessCard v2"
  require_yq '.coverage_ledger_ref == ".octon/state/evidence/disclosure/releases/2026-04-05-uec-proposal-packet-completion/closure/support-universe-coverage.yml"' "$AUTHORED_CARD" "HarnessCard points to bounded support-universe coverage ledger"
  require_yq '.surfaces[] | select(.surface_id == "repo-local-governed")' "$COVERAGE_LEDGER" "coverage ledger includes live supported model"
  require_yq '.surfaces[] | select(.surface_id == "repo-shell")' "$COVERAGE_LEDGER" "coverage ledger includes live supported host adapter"
  require_yq '.excluded_surfaces[] | select(. == "browser")' "$COVERAGE_LEDGER" "coverage ledger excludes browser from the live claim"
  require_yq '.excluded_surfaces[] | select(. == "api")' "$COVERAGE_LEDGER" "coverage ledger excludes api from the live claim"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
