#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
EVALUATOR="$REPO_ROOT/.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh"
STANDARDS="$REPO_ROOT/.octon/framework/execution-roles/practices/standards/commit-pr-standards.json"
TEMPLATE="$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

fixture_dir() {
  local dir
  dir="$(mktemp -d)"
  CLEANUP_DIRS+=("$dir")
  printf '%s\n' "$dir"
}

write_body() {
  local path="$1"
  local autonomy_line="$2"
  cat >"$path" <<EOF
Policy reference: \`.octon/framework/execution-roles/practices/pull-request-standards.md\`
Reminder: Run \`@codex review\`.

## What

Clarifies high-impact PR autonomy policy.

## Why

No-Issue: autonomy policy regression fixture.

## How

Adds fixture coverage.

## Profile Selection Receipt

- Semantic version source(s): fixture
- Release state (\`pre-1.0\` or \`stable\`): \`pre-1.0\`
- \`change_profile\` (\`atomic\` or \`transitional\`): \`atomic\`
- Hard-gate facts (downtime, coordination, migration/backfill, rollback, blast radius, compliance): none
- Tie-break status: n/a
- \`transitional_exception_note\` (required when \`pre-1.0\` + \`transitional\`): n/a

## Implementation Plan

- Workstreams and scope: fixture
- Public interfaces/types/contracts affected: fixture
- Test scenarios: fixture
- Assumptions/defaults: fixture

## Impact Map (code, tests, docs, contracts)

Fixture only.

## Compliance Receipt

- [x] Selected exactly one execution profile before planning/implementation.
- [x] Applied release-maturity gate from semantic version.
- [x] Enforced pre-1.0 default (\`atomic\`) unless hard gates required \`transitional\`.
- [x] Included \`transitional_exception_note\` when required.
- [x] Included tie-break escalation when applicable.
- [x] Updated impacted contracts/docs/tests.
- [x] Honored charter change-control constraint (no direct principles charter edits without override evidence).

## Exceptions/Escalations

none

## Tradeoffs

none

## Testing

fixture

## Rollout

n/a

## Convivial Purpose Check

- [x] Feature expands genuine user capability (not synthetic engagement).
- [x] Attention and interruption behavior are justified and user-controllable.
- [x] No manipulative patterns or dark-pattern mechanics are introduced.
- [x] Data collection/extraction risk is minimal and explicitly justified.

## Risk Rubric

- Risk class: [ ] Trivial [ ] Low [ ] Medium [x] High
- Rollback plan: revert fixture commit
- Rollback handle: fixture
- Flags changed (name, owner, expiry, rollout): none
- Autonomy eligibility: ${autonomy_line}

## Contracts and Threat Model

- OpenAPI/JSON-Schema changes: none
- Threat model update/link: n/a

## Observability and Performance

- Traces/logs/metrics for changed flows: n/a
- Representative traces for high risk changes: n/a
- Performance or bundle impact: none

## License and Provenance

- New dependencies and licenses: none
- Generated code/templates provenance notes: none

## Checklist

- [x] Requirements met; edge cases handled
EOF
}

write_pr_json() {
  local path="$1"
  local body_file="$2"
  jq -n \
    --rawfile body "$body_file" \
    '{
      title: "docs(pr): clarify policy",
      body: $body,
      head: { ref: "chore/high-impact-autonomy" },
      base: { ref: "main" },
      user: { login: "octon-agent" },
      number: 17
    }' >"$path"
}

run_policy() {
  local fixture="$1"
  local autonomy_line="$2"
  local result="$fixture/result.json"
  write_body "$fixture/body.md" "$autonomy_line"
  write_pr_json "$fixture/pr.json" "$fixture/body.md"
  printf '%s\n' '[".github/workflows/pr-triage.yml"]' >"$fixture/files.json"
  bash "$EVALUATOR" \
    --pr-json "$fixture/pr.json" \
    --changed-files-json "$fixture/files.json" \
    --standards-json "$STANDARDS" \
    --pr-template "$TEMPLATE" \
    --output-json "$result"
  printf '%s\n' "$result"
}

case_high_impact_is_elevated_autonomy() {
  local fixture result
  fixture="$(fixture_dir)"
  result="$(run_policy "$fixture" "[x] autonomy:auto-merge [ ] autonomy:no-automerge")"
  jq -e '
    .status == "granted"
    and .reason_code == "PR_AUTONOMY_HIGH_IMPACT_ELEVATED"
    and .is_high_impact == true
    and .high_impact_elevated == true
    and .requires_human_review == false
  ' "$result" >/dev/null
}

case_manual_request_still_stages() {
  local fixture result
  fixture="$(fixture_dir)"
  result="$(run_policy "$fixture" "[ ] autonomy:auto-merge [x] autonomy:no-automerge")"
  jq -e '
    .status == "staged"
    and .reason_code == "PR_AUTONOMY_MANUAL_LANE_REQUESTED"
    and .is_high_impact == true
    and .high_impact_elevated == true
    and .requires_human_review == true
  ' "$result" >/dev/null
}

main() {
  assert_success "high-impact PR remains autonomous under elevated evidence policy" case_high_impact_is_elevated_autonomy
  assert_success "explicit manual request still stages autonomy" case_manual_request_still_stages

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
