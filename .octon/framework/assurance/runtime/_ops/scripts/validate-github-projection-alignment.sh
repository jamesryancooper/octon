#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="$DEFAULT_ROOT"
errors=0

usage() {
  echo "usage: validate-github-projection-alignment.sh [--root <repo-root>]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) shift; ROOT_DIR="${1:-}" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

ROOT_DIR="$(cd -- "$ROOT_DIR" && pwd)"
OCTON_DIR="$ROOT_DIR/.octon"
CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"
RUNBOOK="$OCTON_DIR/framework/execution-roles/practices/github-autonomy-runbook.md"
CAPTURE="$OCTON_DIR/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh"
CAPTURE_TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-github-control-plane-snapshot.sh"
RULESET_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"
SAFE_BRANCH="$ROOT_DIR/.github/workflows/commit-and-branch-standards.yml"
SAFE_QUALITY="$ROOT_DIR/.github/workflows/pr-quality.yml"

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
require_file() { [[ -f "$1" ]] && pass "$2" || fail "$2 missing: $1"; }
require_text() { grep -Fq -- "$2" "$1" && pass "$3" || fail "$3 missing token: $2"; }

echo "== GitHub SI-00 Projection Alignment Validation =="
for pair in \
  "$CONTRACT|control-plane contract" \
  "$RUNBOOK|operator runbook" \
  "$CAPTURE|snapshot helper" \
  "$CAPTURE_TEST|mocked-provider snapshot test" \
  "$RULESET_VALIDATOR|ruleset validator" \
  "$SAFE_BRANCH|branch-name safe producer" \
  "$SAFE_QUALITY|PR-quality safe producer"; do
  require_file "${pair%%|*}" "${pair#*|}"
done

if [[ -f "$CONTRACT" ]] && jq -e '
  .schema_version == "github-control-plane-contract-v2" and
  .si00_containment.current_effect_routes == [] and
  .si00_containment.provider_mutation_requires_separate_authorization == true and
  .si00_containment.repo_local_projection_performs_provider_mutation == false and
  (.workflow_disposition.bootstrap_safe_producers | length) == 2
' "$CONTRACT" >/dev/null 2>&1; then
  pass "contract is containment-bound with exactly two safe producers"
else
  fail "contract containment or safe-producer topology is invalid"
fi

if [[ -f "$CONTRACT" ]] && jq -e '
  .rulesets.si00_bootstrap_main.required_checks == ["PR Quality Standards", "Validate branch naming"] and
  .rulesets.si00_bootstrap_main.hosted_no_pr_required == false and
  .rulesets.si00_bootstrap_main.bypass_actors == [] and
  .operation_construction.marker_is_provider_enforced_merge_predicate == false and
  .operation_construction.post_marker_failure_retry_authorized == false
' "$CONTRACT" >/dev/null 2>&1; then
  pass "bootstrap topology, advisory marker, and no-retry boundary align"
else
  fail "bootstrap topology or marker boundary is invalid"
fi

for unsafe_path in \
  .github/workflows/change-route-projection.yml \
  .github/workflows/main-change-route-guard.yml \
  .github/workflows/pr-auto-merge.yml \
  .github/workflows/pr-clean-state-enforcer.yml \
  .github/workflows/pr-autonomy-policy.yml; do
  jq -e --arg unsafe_path "$unsafe_path" '.workflow_disposition.unsafe_until_rp06 | index($unsafe_path) != null' "$CONTRACT" >/dev/null 2>&1 \
    && pass "contract classifies unsafe workflow: $unsafe_path" \
    || fail "contract omits unsafe workflow: $unsafe_path"
done

for safe_file in "$SAFE_BRANCH" "$SAFE_QUALITY"; do
  if [[ -f "$safe_file" ]]; then
    if rg -n 'actions/checkout|secrets\.' "$safe_file" >/dev/null 2>&1; then
      fail "bootstrap-safe producer checks out code or consumes a repository secret: ${safe_file#$ROOT_DIR/}"
    else
      pass "bootstrap-safe producer is no-checkout and secret-free: ${safe_file#$ROOT_DIR/}"
    fi
    require_text "$safe_file" 'baseSha' "bootstrap-safe producer binds the PR base: ${safe_file#$ROOT_DIR/}"
  fi
done

if [[ -f "$CAPTURE" ]]; then
  for token in '--base-sha' '--candidate-sha' '--paginate' 'capture_complete' 'canonical_sha256' 'active_runs'; do
    require_text "$CAPTURE" "$token" "snapshot helper covers $token"
  done
  if rg -n -- '--method[[:space:]]+(PATCH|POST|PUT|DELETE)|-X[[:space:]]+(PATCH|POST|PUT|DELETE)' "$CAPTURE" >/dev/null 2>&1; then
    fail "snapshot helper contains provider mutation syntax"
  else
    pass "snapshot helper remains provider-read-only"
  fi
fi

if [[ -f "$RUNBOOK" ]]; then
  for token in \
    '## SI-00 Owner-Lane Provider Containment' \
    'octon-owner-lane-credential-admission-authorization-v1' \
    'octon-owner-lane-credential-capture-metadata-v1' \
    'octon-owner-lane-credential-lifecycle-envelope-v1' \
    'octon-owner-lane-operation-manifest-v1' \
    'octon-owner-lane-operation-construction-receipt-v1' \
    'inherited file descriptor' \
    'RP00-CREDENTIAL-UNRESOLVED' \
    'same-token' \
    'no-resend'; do
    require_text "$RUNBOOK" "$token" "runbook documents $token"
  done
fi

if [[ -f "$RULESET_VALIDATOR" ]] && bash "$RULESET_VALIDATOR" >/dev/null; then
  pass "ruleset validator static contract passes"
else
  fail "ruleset validator static contract fails"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
