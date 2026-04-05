#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_LINEAGE="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
RELEASE_CARD="$ROOT_DIR/$(yq -r '.active_release.harness_card_ref' "$RELEASE_LINEAGE")"
COVERAGE_LEDGER="$ROOT_DIR/$(yq -r '.coverage_ledger_ref' "$AUTHORED_CARD")"
PACK_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Support-Target Live Claim Validation =="

  require_yq '.support_claim_mode == "bounded-admitted-finite"' "$SUPPORT_TARGETS" "support-target declaration uses bounded admitted claim mode"
  require_yq '[.tuple_admissions[] | select(.support_status == "supported")] | length == 2' "$SUPPORT_TARGETS" "exactly two tuples are live supported"
  require_yq '[.host_adapters[] | select(.support_status == "supported")] | length == 1' "$SUPPORT_TARGETS" "only one host adapter is live supported"
  require_yq '[.model_adapters[] | select(.support_status == "supported")] | length == 1' "$SUPPORT_TARGETS" "only one model adapter is live supported"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "stage_only")' "$PACK_REGISTRY" "browser pack is stage_only"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "stage_only")' "$PACK_REGISTRY" "api pack is stage_only"

  require_yq '.claim_summary == load("'"$AUTHORED_CARD"'").claim_summary' "$RELEASE_CARD" "active release HarnessCard wording matches authored disclosure"
  require_yq '.known_limits | length >= 1' "$AUTHORED_CARD" "authored HarnessCard discloses excluded stage-only surfaces"
  require_yq '.known_limits | length >= 1' "$RELEASE_CARD" "active release HarnessCard discloses excluded stage-only surfaces"
  require_yq '[.excluded_surfaces[] | select(. == "browser" or . == "api" or . == "github-control-plane")] | length == 3' "$COVERAGE_LEDGER" "coverage ledger excludes stage-only browser/api/github surfaces from the live claim"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
