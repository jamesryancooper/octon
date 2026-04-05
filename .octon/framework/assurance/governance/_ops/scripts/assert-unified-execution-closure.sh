#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
STATUS_MATRIX="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-status.yml"
PACKET_ISSUES="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-packet-issues.yml"
AUTHORED_HARNESS_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
RETIREMENT_REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
COVERAGE_LEDGER="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/support-universe-coverage.yml"
CLOSURE_CERTIFICATE="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/closure-certificate.yml"
PROOF_COVERAGE="$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/proof-plane-coverage.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Closure Assertion =="

  require_yq '.claim_status == "complete"' "$CLOSURE_MANIFEST" "closure manifest is complete"
  require_yq '.status_summary.final_verdict == "claim_complete"' "$STATUS_MATRIX" "status matrix is complete"
  require_yq '.summary.open_count == 0 and .summary.closure_ready == true' "$PACKET_ISSUES" "packet issues are closed"
  require_yq '.status == "closed"' "$RETIREMENT_REGISTRY" "retirement registry is closed"
  require_yq '[.entries[] | select(.status == "registered" or .status == "active")] | length == 0' "$RETIREMENT_REGISTRY" "retirement registry has no active architecture-critical entry"
  require_yq '.claim_summary == load("'"$CLOSURE_MANIFEST"'").permitted_release_wording' "$AUTHORED_HARNESS_CARD" "HarnessCard wording matches closure manifest"
  require_yq '.surfaces | length >= 14' "$COVERAGE_LEDGER" "coverage ledger spans retained support surfaces"
  require_yq '[.compatibility_matrix[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "support-target declaration contains no liminal live entry"
  require_yq '.schema_version == "support-universe-coverage-v2"' "$COVERAGE_LEDGER" "coverage ledger uses v2 schema"
  require_yq '.schema_version == "closure-certificate-v2"' "$CLOSURE_CERTIFICATE" "closure certificate uses v2 schema"
  require_yq '.schema_version == "proof-plane-coverage-v1"' "$PROOF_COVERAGE" "proof-plane coverage artifact exists"
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    [[ -e "$DEFAULT_OCTON_DIR/../$ref" ]] && pass "closure proof ref resolves: $ref" || fail "closure proof ref missing: $ref"
  done < <(yq -r '.proof_bundle_refs.*' "$CLOSURE_CERTIFICATE")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
