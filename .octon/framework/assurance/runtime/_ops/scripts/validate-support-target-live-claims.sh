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
RESIDUAL_LEDGER="$ROOT_DIR/$(yq -r '.proof_bundle_refs[] | select(test("residual-ledger.yml$"))' "$RELEASE_CARD" | head -n1)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
require_equal_rendered() {
  local expr="$1"
  local file_a="$2"
  local file_b="$3"
  local label="$4"
  local value_a value_b
  value_a="$(yq -P "$expr" "$file_a" 2>/dev/null || true)"
  value_b="$(yq -P "$expr" "$file_b" 2>/dev/null || true)"
  if [[ "$value_a" == "$value_b" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Support-Target Live Claim Validation =="

  require_yq '.support_claim_mode == "bounded-admitted-finite"' "$SUPPORT_TARGETS" "support-target declaration uses bounded admitted-finite claim mode"
  require_yq '(.tuple_admissions | length) == 3' "$SUPPORT_TARGETS" "live support tuple inventory is narrowed to the three admitted tuples"
  require_yq '.live_support_universe.host_adapters[] | select(. == "repo-shell")' "$SUPPORT_TARGETS" "repo-shell host adapter is live supported"
  require_yq '.live_support_universe.host_adapters[] | select(. == "ci-control-plane")' "$SUPPORT_TARGETS" "ci host adapter is live supported"
  require_yq '.resolved_non_live_surfaces.host_adapters[] | select(. == "github-control-plane")' "$SUPPORT_TARGETS" "github host adapter is explicitly non-live"
  require_yq '.resolved_non_live_surfaces.host_adapters[] | select(. == "studio-control-plane")' "$SUPPORT_TARGETS" "studio host adapter is explicitly non-live"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "unadmitted")' "$PACK_REGISTRY" "browser pack is unadmitted"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "unadmitted")' "$PACK_REGISTRY" "api pack is unadmitted"

  require_yq '.claim_summary == load("'"$AUTHORED_CARD"'").claim_summary' "$RELEASE_CARD" "active release HarnessCard wording matches authored disclosure"
  require_equal_rendered '.known_limits' "$AUTHORED_CARD" "$RESIDUAL_LEDGER" "authored HarnessCard known limits match the residual ledger"
  require_equal_rendered '.known_limits' "$RELEASE_CARD" "$RESIDUAL_LEDGER" "active release HarnessCard known limits match the residual ledger"
  require_yq '(.excluded_surfaces | length) >= 1' "$COVERAGE_LEDGER" "coverage ledger records explicit non-live surfaces"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
