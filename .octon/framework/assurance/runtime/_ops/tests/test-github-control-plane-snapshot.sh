#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
CAPTURE="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/octon-github-snapshot-test.XXXXXX")"
trap 'rm -rf -- "$TEST_ROOT"' EXIT
BASE_SHA="1111111111111111111111111111111111111111"
CANDIDATE_SHA="2222222222222222222222222222222222222222"
passed=0
failed=0

pass() { echo "PASS: $1"; passed=$((passed + 1)); }
fail() { echo "FAIL: $1" >&2; failed=$((failed + 1)); }
assert_success() { local label="$1"; shift; if "$@"; then pass "$label"; else fail "$label"; fi; }

MOCK_GH="$TEST_ROOT/gh"
cat >"$MOCK_GH" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
endpoint="${!#}"
if [[ -n "${MOCK_GH_FAIL_PATTERN:-}" && "$endpoint" == *"$MOCK_GH_FAIL_PATTERN"* ]]; then
  exit 42
fi
if [[ -n "${MOCK_GH_MALFORMED_PATTERN:-}" && "$endpoint" == *"$MOCK_GH_MALFORMED_PATTERN"* ]]; then
  printf 'not-json\n'
  exit 0
fi
variant="${MOCK_GH_VARIANT:-baseline}"
case "$endpoint" in
  repos/example/octon)
    printf '{"id":1,"full_name":"example/octon","default_branch":"main","visibility":"public"}\n'
    ;;
  *'/rulesets?'*)
    printf '[[{"id":10,"name":"main","enforcement":"active","bypass_actors":[],"rules":[{"type":"pull_request"},{"type":"required_status_checks","parameters":{"strict_required_status_checks_policy":true,"required_status_checks":[{"context":"PR Quality Standards"},{"context":"Validate branch naming"}]}},{"type":"required_linear_history"},{"type":"non_fast_forward"},{"type":"deletion"}]}]]\n'
    ;;
  */branches/main/protection)
    printf '{"required_status_checks":{"strict":true,"contexts":["PR Quality Standards","Validate branch naming"],"checks":[]},"enforce_admins":{"enabled":true},"restrictions":null}\n'
    ;;
  */actions/permissions/workflow)
    printf '{"default_workflow_permissions":"read","can_approve_pull_request_reviews":false}\n'
    ;;
  */actions/permissions)
    printf '{"enabled":true,"allowed_actions":"selected"}\n'
    ;;
  *'/actions/workflows?'*)
    if [[ "$variant" == "changed" ]]; then state="active"; else state="disabled_manually"; fi
    printf '[{"workflows":[{"id":100,"name":"Change Route Projection","path":".github/workflows/change-route-projection.yml","state":"%s"},{"id":101,"name":"PR Quality Standards","path":".github/workflows/pr-quality.yml","state":"active"},{"id":102,"name":"Commit and Branch Standards","path":".github/workflows/commit-and-branch-standards.yml","state":"active"}]}]\n' "$state"
    ;;
  *'/actions/runs?'*)
    printf '[{"workflow_runs":[{"id":900,"workflow_id":100,"name":"Change Route Projection","event":"push","status":"queued","head_sha":"2222222222222222222222222222222222222222","head_branch":"candidate","run_attempt":1,"created_at":"2026-07-16T00:00:00Z","updated_at":"2026-07-16T00:00:00Z"},{"id":901,"workflow_id":101,"name":"PR Quality Standards","event":"pull_request","status":"completed","conclusion":"success","head_sha":"1111111111111111111111111111111111111111"}]}]\n'
    ;;
  *'/actions/variables?'*)
    if [[ "$variant" == "changed" ]]; then
      printf '[{"variables":[{"name":"AUTONOMY_POLICY_ENFORCE","value":"true"},{"name":"OCTON_RP00_OWNER_LANE_LEASE","value":"sealed-marker"}]}]\n'
    else
      printf '[{"variables":[{"name":"AUTONOMY_POLICY_ENFORCE","value":"true"}]}]\n'
    fi
    ;;
  *'/actions/secrets?'*)
    printf '[{"secrets":[{"name":"AUTONOMY_PAT","created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-02T00:00:00Z"}]}]\n'
    ;;
  *'/installations?'*)
    printf '[{"installations":[{"id":55,"app_id":5,"app_slug":"safe-check-app","target_id":1,"target_type":"User","permissions":{"checks":"read"},"events":["check_run"],"suspended_at":null}]}]\n'
    ;;
  *'/environments?'*)
    printf '[{"environments":[{"id":7,"name":"production"}]}]\n'
    ;;
  */environments/production)
    printf '{"id":7,"name":"production","protected_branches":true,"protection_rules":[{"id":70,"type":"branch_policy"}],"deployment_branch_policy":{"protected_branches":true,"custom_branch_policies":false}}\n'
    ;;
  *'/keys?'*)
    printf '[[{"id":77,"title":"read-only","read_only":true,"verified":true,"enabled":true,"created_at":"2026-01-01T00:00:00Z"}]]\n'
    ;;
  *'/collaborators?'*)
    printf '[[{"login":"jamesryancooper","id":800837,"type":"User","site_admin":false,"permissions":{"admin":true},"role_name":"admin"}]]\n'
    ;;
  *'/commits/1111111111111111111111111111111111111111/check-runs?'*)
    printf '[{"check_runs":[{"id":1,"name":"PR Quality Standards","head_sha":"1111111111111111111111111111111111111111","status":"completed","conclusion":"success","app":{"id":5,"slug":"github-actions"},"external_id":"a","details_url":"https://example.test/a"},{"id":2,"name":"Validate branch naming","head_sha":"1111111111111111111111111111111111111111","status":"completed","conclusion":"success","app":{"id":5,"slug":"github-actions"},"external_id":"b","details_url":"https://example.test/b"}]}]\n'
    ;;
  *'/commits/2222222222222222222222222222222222222222/check-runs?'*)
    printf '[{"check_runs":[{"id":3,"name":"PR Quality Standards","head_sha":"2222222222222222222222222222222222222222","status":"completed","conclusion":"success","app":{"id":5,"slug":"github-actions"},"external_id":"c","details_url":"https://example.test/c"}]}]\n'
    ;;
  *)
    echo "unexpected endpoint: $endpoint" >&2
    exit 44
    ;;
esac
MOCK
chmod +x "$MOCK_GH"

capture() {
  local out_dir="$1" basename="$2"
  shift 2
  OCTON_GH_BIN="$MOCK_GH" OCTON_FIXED_UTC="2026-07-16T12:00:00Z" \
    bash "$CAPTURE" --repo example/octon --base-sha "$BASE_SHA" --candidate-sha "$CANDIDATE_SHA" \
      --out-dir "$out_dir" --basename "$basename" "$@" >/dev/null
}

case_complete_capture() {
  local out="$TEST_ROOT/complete"
  capture "$out" snapshot || return 1
  jq -e --arg base "$BASE_SHA" --arg candidate "$CANDIDATE_SHA" '
    .schema_version == "github-control-plane-snapshot-v2" and
    .capture_complete == true and
    .binding.base_sha == $base and .binding.candidate_sha == $candidate and
    (.captures.workflows | length) == 3 and
    (.captures.active_runs | length) == 1 and
    (.captures.installations | length) == 1 and
    (.captures.environments | length) == 1 and
    .derived.advisory_marker.state == "expected-absent" and
    .redaction.secret_values_captured == false and
    (.captures.secret_names[0] | has("value") | not)
  ' "$out/snapshot.json" >/dev/null
}

case_deterministic_digest() {
  local first="$TEST_ROOT/deterministic-a" second="$TEST_ROOT/deterministic-b"
  capture "$first" one || return 1
  capture "$second" two || return 1
  [[ "$(jq -r '.canonical_sha256' "$first/one.json")" == "$(jq -r '.canonical_sha256' "$second/two.json")" ]]
}

case_comparison_detects_change() {
  local first="$TEST_ROOT/compare-a" second="$TEST_ROOT/compare-b"
  capture "$first" before || return 1
  MOCK_GH_VARIANT=changed capture "$second" after --compare-to "$first/before.json" || return 1
  jq -e '.comparison.changed_capture_families | index("variables") != null and index("workflows") != null' "$second/after.json" >/dev/null
}

case_endpoint_failure_denies() {
  local out="$TEST_ROOT/failure"
  ! MOCK_GH_FAIL_PATTERN="actions/workflows" capture "$out" snapshot
}

case_malformed_pagination_denies() {
  local out="$TEST_ROOT/malformed"
  ! MOCK_GH_MALFORMED_PATTERN="actions/runs" capture "$out" snapshot
}

case_non_exact_sha_denies() {
  local out="$TEST_ROOT/bad-sha"
  ! OCTON_GH_BIN="$MOCK_GH" bash "$CAPTURE" --repo example/octon --base-sha short --candidate-sha "$CANDIDATE_SHA" --out-dir "$out" >/dev/null 2>&1
}

case_raw_secret_absent() {
  local out="$TEST_ROOT/redaction"
  capture "$out" snapshot || return 1
  ! rg -n 'secret-value|Authorization:|github_pat_' "$out/snapshot.json" "$out/snapshot.md" >/dev/null
}

assert_success "complete paginated provider snapshot" case_complete_capture
assert_success "canonical digest is deterministic" case_deterministic_digest
assert_success "pre/post comparison detects changed families" case_comparison_detects_change
assert_success "endpoint failure denies partial capture" case_endpoint_failure_denies
assert_success "malformed paginated output denies capture" case_malformed_pagination_denies
assert_success "non-exact SHA binding is rejected" case_non_exact_sha_denies
assert_success "secret values and credential material are absent" case_raw_secret_absent

echo "Passed: $passed"
echo "Failed: $failed"
[[ "$failed" -eq 0 ]]
