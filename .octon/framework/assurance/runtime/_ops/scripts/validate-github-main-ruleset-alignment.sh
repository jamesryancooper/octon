#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"
EXPECTATION="si00-pr-required-bootstrap"
RULESET_JSON=""
SNAPSHOT_JSON=""
BASE_SHA=""
STRICT_LIVE=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-github-main-ruleset-alignment.sh [--expect si00-pr-required-bootstrap] [--ruleset-json <path>] [--snapshot-json <path>] [--base-sha <sha>] [--strict-live]

Validates the SI-00 PR-required two-check bootstrap topology. This validator
is read-only. --strict-live requires a retained snapshot; it never queries or
mutates GitHub directly.
USAGE
}

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --expect) shift; EXPECTATION="${1:-}" ;;
    --ruleset-json) shift; RULESET_JSON="${1:-}" ;;
    --snapshot-json) shift; SNAPSHOT_JSON="${1:-}" ;;
    --base-sha) shift; BASE_SHA="${1:-}" ;;
    --strict-live) STRICT_LIVE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

[[ "$EXPECTATION" == "si00-pr-required-bootstrap" ]] || fail "only si00-pr-required-bootstrap is a current expectation"
[[ -f "$CONTRACT" ]] && pass "GitHub control-plane contract exists" || fail "GitHub control-plane contract missing"
jq -e . "$CONTRACT" >/dev/null 2>&1 && pass "GitHub control-plane contract parses" || fail "GitHub control-plane contract must parse"

jq -e '
  .si00_containment.current_effect_routes == [] and
  (.si00_containment.denied_routes | index("direct-main") != null) and
  (.si00_containment.denied_routes | index("hosted-branch-no-pr-landing") != null) and
  .si00_containment.provider_mutation_requires_separate_authorization == true and
  .si00_containment.repo_local_projection_performs_provider_mutation == false
' "$CONTRACT" >/dev/null 2>&1 \
  && pass "SI-00 provider effects are denied locally" \
  || fail "SI-00 provider-effect denial is incomplete"

jq -e '
  .rulesets.si00_bootstrap_main.expectation == "pr-required-two-check-bootstrap" and
  .rulesets.si00_bootstrap_main.required_checks == ["PR Quality Standards", "Validate branch naming"] and
  .rulesets.si00_bootstrap_main.strict_required_status_checks_policy == true and
  .rulesets.si00_bootstrap_main.bypass_actors == [] and
  .rulesets.si00_bootstrap_main.exact_base_binding_required == true and
  .rulesets.si00_bootstrap_main.exact_head_conditional_merge_required == true and
  .rulesets.si00_bootstrap_main.hosted_no_pr_required == false and
  .rulesets.si00_bootstrap_main.live_mutation_performed_by_this_projection == false
' "$CONTRACT" >/dev/null 2>&1 \
  && pass "contract defines the exact SI-00 bootstrap ruleset" \
  || fail "contract SI-00 bootstrap ruleset is incomplete"

if rg -n -- '--method[[:space:]]+(PATCH|POST|PUT|DELETE)|-X[[:space:]]+(PATCH|POST|PUT|DELETE)|gh[[:space:]]+api.*--method' "$0" >/dev/null 2>&1; then
  fail "validator contains a provider mutation command"
else
  pass "validator contains no provider mutation command"
fi

if [[ -n "$RULESET_JSON" ]]; then
  [[ -f "$RULESET_JSON" ]] || fail "ruleset JSON missing: $RULESET_JSON"
  if [[ -f "$RULESET_JSON" ]] && jq -e . "$RULESET_JSON" >/dev/null 2>&1; then
    pass "ruleset JSON parses"
    jq -e '[.. | objects | select(.type? == "pull_request")] | length == 1' "$RULESET_JSON" >/dev/null 2>&1 \
      && pass "ruleset requires PR exactly once" || fail "ruleset must require PR exactly once"
    jq -e '[.. | objects | select(.type? == "required_status_checks")] | length == 1' "$RULESET_JSON" >/dev/null 2>&1 \
      && pass "ruleset has one required-status-check rule" || fail "ruleset must have one required-status-check rule"
    jq -e '
      [.. | objects | select(.type? == "required_status_checks") | .parameters.required_status_checks[]?.context] | unique | sort
      == ["PR Quality Standards", "Validate branch naming"]
    ' "$RULESET_JSON" >/dev/null 2>&1 \
      && pass "ruleset requires exactly the two bootstrap-safe checks" || fail "ruleset check topology must be exact"
    jq -e '[.. | objects | select(.type? == "required_status_checks") | .parameters.strict_required_status_checks_policy] == [true]' "$RULESET_JSON" >/dev/null 2>&1 \
      && pass "ruleset requires strict latest-base checks" || fail "ruleset must require strict latest-base checks"
    for rule_type in deletion non_fast_forward required_linear_history; do
      jq -e --arg rule_type "$rule_type" '[.. | objects | select(.type? == $rule_type)] | length == 1' "$RULESET_JSON" >/dev/null 2>&1 \
        && pass "ruleset retains $rule_type" || fail "ruleset must retain $rule_type"
    done
    jq -e '[(.. | objects | .bypass_actors? // empty)[]?] | length == 0' "$RULESET_JSON" >/dev/null 2>&1 \
      && pass "ruleset has no bypass actors" || fail "ruleset must have no bypass actors"
  else
    fail "ruleset JSON must parse"
  fi
fi

if [[ -n "$SNAPSHOT_JSON" ]]; then
  [[ -f "$SNAPSHOT_JSON" ]] || fail "snapshot JSON missing: $SNAPSHOT_JSON"
  if [[ -f "$SNAPSHOT_JSON" ]] && jq -e '.schema_version == "github-control-plane-snapshot-v2" and .capture_complete == true' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
    pass "snapshot is complete and current"
    snapshot_base="$(jq -r '.binding.base_sha // ""' "$SNAPSHOT_JSON")"
    if [[ -n "$BASE_SHA" && "$snapshot_base" != "$BASE_SHA" ]]; then
      fail "snapshot base SHA does not match --base-sha"
    elif [[ "$snapshot_base" =~ ^[0-9a-f]{40}$ ]]; then
      pass "snapshot binds an exact base SHA"
    else
      fail "snapshot base SHA is not exact"
    fi
    jq -e '
      [.derived.check_run_producers.base[]? | select(.conclusion == "success") | .name] | unique | sort
      | index("PR Quality Standards") != null and index("Validate branch naming") != null
    ' "$SNAPSHOT_JSON" >/dev/null 2>&1 \
      && pass "snapshot proves both safe producers at the base" \
      || fail "snapshot lacks both safe producer proofs at the base"
  else
    fail "snapshot must be complete github-control-plane-snapshot-v2"
  fi
fi

if [[ "$STRICT_LIVE" -eq 1 && -z "$SNAPSHOT_JSON" ]]; then
  fail "strict-live requires --snapshot-json; direct live queries are not an authority path"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
