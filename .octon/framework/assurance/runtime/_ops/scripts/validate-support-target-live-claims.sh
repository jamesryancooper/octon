#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/harness-card.yml"
CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
COVERAGE_LEDGER="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/support-universe-coverage.yml"
PACK_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Support-Target Claim Validation =="

  require_yq '[.compatibility_matrix[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "live matrix contains only supported entries"
  require_yq '[.compatibility_matrix[] | select(.default_route != "allow")] | length == 0' "$SUPPORT_TARGETS" "live matrix routes supported tuples through allow"
  require_yq '[.host_adapters[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "no host adapter remains liminal"
  require_yq '[.model_adapters[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "no model adapter remains liminal"
  require_yq '.retired_surfaces[] | select(. == "MT-C")' "$SUPPORT_TARGETS" "retired model placeholder is recorded"
  require_yq '.retired_surfaces[] | select(. == "WT-4")' "$SUPPORT_TARGETS" "rebound deny-only tier is recorded"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "admitted")' "$PACK_REGISTRY" "browser pack is admitted in runtime registry"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "admitted")' "$PACK_REGISTRY" "api pack is admitted in runtime registry"

  require_yq '.claim_summary == load("'"$CLOSURE_MANIFEST"'").permitted_release_wording' "$AUTHORED_CARD" "authored HarnessCard wording matches closure manifest"
  require_yq '.claim_summary == load("'"$AUTHORED_CARD"'").claim_summary' "$RELEASE_CARD" "release HarnessCard wording matches authored disclosure"
  require_yq '.known_limits | length == 0' "$AUTHORED_CARD" "authored HarnessCard has no bounded-envelope caveat"
  require_yq '.known_limits | length == 0' "$RELEASE_CARD" "release HarnessCard has no bounded-envelope caveat"
  require_yq '.surfaces | length >= 14' "$COVERAGE_LEDGER" "coverage ledger spans the retained support universe"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
