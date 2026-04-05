#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

TRUTH_CONDITIONS="$OCTON_DIR/framework/constitution/claim-truth-conditions.yml"
CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
STATUS_MATRIX="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-status.yml"
PRECLAIM_BLOCKERS="$OCTON_DIR/instance/governance/closure/preclaim-blockers.yml"
GATE_STATUS="$OCTON_DIR/instance/governance/closure/gate-status.yml"
CLOSURE_SUMMARY="$OCTON_DIR/instance/governance/closure/closure-summary.yml"
RETIREMENT_REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
AUTHORED_HARNESS_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_LINEAGE="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
COVERAGE_LEDGER="$ROOT_DIR/$(yq -r '.coverage_ledger_ref' "$AUTHORED_HARNESS_CARD")"
PROOF_COVERAGE="$ROOT_DIR/$(yq -r '.proof_bundle_refs[] | select(test("proof-plane-coverage.yml$"))' "$AUTHORED_HARNESS_CARD" | head -n1)"
CLOSURE_CERTIFICATE="$ROOT_DIR/$(yq -r '.proof_bundle_refs[] | select(test("closure-certificate.yml$"))' "$AUTHORED_HARNESS_CARD" | head -n1)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Closure Assertion =="

  require_yq '.claim_status == "complete"' "$CLOSURE_MANIFEST" "closure manifest is complete"
  require_yq '.status_summary.final_verdict == "claim_complete"' "$STATUS_MATRIX" "status matrix is complete"
  require_yq '.summary.open_count == 0 and .summary.closure_ready == true' "$PRECLAIM_BLOCKERS" "preclaim blockers are closed"
  require_yq '[.gates[] | select(.status != "green")] | length == 0' "$GATE_STATUS" "all closure gates are green"
  require_yq '.claim_status == "complete" and .preclaim_blockers_open == 0' "$CLOSURE_SUMMARY" "closure summary is complete"
  require_yq '.status == "closed"' "$RETIREMENT_REGISTRY" "retirement registry is closed"
  require_yq '.claim_summary == load("'"$CLOSURE_MANIFEST"'").permitted_release_wording' "$AUTHORED_HARNESS_CARD" "HarnessCard wording matches closure manifest"
  require_yq '.active_release.release_id == "2026-04-05-uec-proposal-packet-completion"' "$RELEASE_LINEAGE" "release lineage marks the bounded proposal-packet release active"
  require_yq '.historical_releases[] | select(.release_id == "2026-04-04-uec-global-completion" and .status == "superseded")' "$RELEASE_LINEAGE" "release lineage supersedes the prior global-completion release"
  require_yq '.surfaces | length >= 8' "$COVERAGE_LEDGER" "coverage ledger spans admitted support surfaces"
  require_yq '[.compatibility_matrix[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "compatibility matrix contains no liminal live entry"
  require_yq '[.tuple_admissions[] | select(.support_status == "supported")] | length == 2' "$SUPPORT_TARGETS" "exactly two tuples are live supported"
  require_yq '.schema_version == "support-universe-coverage-v2"' "$COVERAGE_LEDGER" "coverage ledger uses v2 schema"
  require_yq '.schema_version == "closure-certificate-v2"' "$CLOSURE_CERTIFICATE" "closure certificate uses v2 schema"
  require_yq '.schema_version == "proof-plane-coverage-v1"' "$PROOF_COVERAGE" "proof-plane coverage artifact exists"
  require_yq '.conditions | length == 10' "$TRUTH_CONDITIONS" "truth-conditions artifact enumerates all ten conditions"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    [[ -e "$ROOT_DIR/$ref" ]] && pass "closure proof ref resolves: $ref" || fail "closure proof ref missing: $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$AUTHORED_HARNESS_CARD")
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    [[ -e "$ROOT_DIR/$ref" ]] && pass "certificate proof ref resolves: $ref" || fail "certificate proof ref missing: $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$CLOSURE_CERTIFICATE")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
