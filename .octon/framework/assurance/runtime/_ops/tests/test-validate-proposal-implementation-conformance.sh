#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh"
READINESS_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh"
REVIEW_GATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then pass "$name"; else fail "$name"; fi
}

assert_failure_contains() {
  local name="$1" needle="$2"
  shift 2
  local output="" rc=0
  output="$("$@" 2>&1)" || rc=$?
  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi
  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-conformance.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/$VALIDATE_SCRIPT" "$fixture_root/$VALIDATE_SCRIPT"
  cp "$REPO_ROOT/$READINESS_SCRIPT" "$fixture_root/$READINESS_SCRIPT"
  cp "$REPO_ROOT/$REVIEW_GATE_SCRIPT" "$fixture_root/$REVIEW_GATE_SCRIPT"
  printf '%s\n' "$fixture_root"
}

write_policy_packet() {
  local root="$1" status="${2:-implemented}" target="${3:-.octon/framework/example.md}"
  local dir="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy"
  mkdir -p "$dir/policy" "$dir/navigation" "$dir/implementation" "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "conformance-policy"
title: "Conformance Policy"
summary: "Fixture."
proposal_kind: "policy"
promotion_scope: "octon-internal"
promotion_targets:
  - "$target"
status: "$status"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$dir/policy-proposal.yml" <<'EOF'
schema_version: "policy-proposal-v1"
policy_area: "proposal-governance"
change_type: "policy-update"
EOF
  cat >"$dir/policy/decision.md" <<'EOF'
# Policy Decision

## Context

Context is known.

## Decision

Decision is explicit.

## Consequences

Consequences are recorded.
EOF
  cat >"$dir/policy/policy-delta.md" <<'EOF'
# Policy Delta

## Durable Authority

The durable authority is named.

## Downstream References

Downstream references are named.
EOF
  cat >"$dir/policy/enforcement-plan.md" <<'EOF'
# Enforcement Plan

## Validators

Validator coverage is named.
EOF
  cat >"$dir/implementation/implementation-map.md" <<EOF
# Implementation Map

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| \`$target\` | Missing. | Create. | owns policy | P0: required target. |
EOF
}

write_passing_completeness_review() {
  local root="$1"
  local review="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy/support/implementation-grade-completeness-review.md"
  cat >"$review" <<'EOF'
# Implementation-Grade Completeness Review

verdict: pass
unresolved_questions_count: 0
clarification_required: no

## Blockers

None.

## Assumptions Made

None.

## Promotion Target Coverage

Complete.

## Affected Artifact Coverage

Complete.

## Validator Coverage

Complete.

## Implementation Prompt Readiness

Ready.

## Exclusions

None.

## Final Route Recommendation

Run implementation conformance.
EOF
}

write_target() {
  local root="$1" target="${2:-.octon/framework/example.md}"
  mkdir -p "$(dirname "$root/$target")"
  printf '# Example\n' >"$root/$target"
}

write_passing_review() {
  local root="$1" target="${2:-.octon/framework/example.md}"
  local review="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy/support/implementation-conformance-review.md"
  cat >"$review" <<EOF
# Implementation Conformance Review

verdict: pass
unresolved_items_count: 0

## Blockers

None.

## Checked Evidence

- \`$target\`

## Promotion Target Coverage

- \`$target\`: implemented.

## Implementation Map Coverage

- \`$target\`: covered by the implementation map.

## Validator Coverage

- validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/policy/conformance-policy
- validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/conformance-policy

## Generated Output Coverage

- Generated proposal registry checked.

## Rollback Coverage

- Rollback is to revert \`$target\`.

## Downstream Reference Coverage

- Downstream references are aligned.

## Exclusions

None.

## Final Closeout Recommendation

Close out after drift/churn passes.
EOF
}

run_validator() {
  local root="$1"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package ".octon/inputs/exploratory/proposals/policy/conformance-policy"
  )
}

run_validator_for_path() {
  local root="$1" path="$2"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$path"
  )
}

case_accepted_without_conformance_receipt_passes() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  run_validator "$root"
}

case_implemented_without_conformance_receipt_fails() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_passing_completeness_review "$root"
  run_validator "$root"
}

case_implemented_with_passing_conformance_passes() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_passing_completeness_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_implemented_conformance_requires_completeness_gate() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_missing_promotion_target_fails_conformance() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_passing_completeness_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_incomplete_implementation_map_fails_conformance() {
  local root map
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_passing_completeness_review "$root"
  write_passing_review "$root"
  map="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy/implementation/implementation-map.md"
  cat >"$map" <<'EOF'
# Implementation Map

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/other.md` | Missing. | Create. | owns policy | P0. |
EOF
  run_validator "$root"
}

case_legacy_archived_implemented_without_conformance_receipt_warns_but_passes() {
  local root active archived manifest
  root="$(create_fixture_repo)"
  write_policy_packet "$root" archived
  write_target "$root"
  manifest="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy/proposal.yml"
  cat >>"$manifest" <<'EOF'
archive:
  archived_at: "2026-05-01T00:00:00Z"
  archived_from_status: "implemented"
  disposition: "implemented"
  original_path: ".octon/inputs/exploratory/proposals/policy/conformance-policy"
  promotion_evidence:
    - ".octon/framework/example.md"
EOF
  active="$root/.octon/inputs/exploratory/proposals/policy/conformance-policy"
  archived="$root/.octon/inputs/exploratory/proposals/.archive/policy/conformance-policy"
  mkdir -p "$(dirname "$archived")"
  mv "$active" "$archived"
  run_validator_for_path "$root" ".octon/inputs/exploratory/proposals/.archive/policy/conformance-policy"
}

main() {
  assert_success \
    "accepted packets do not require post-implementation conformance receipts" \
    case_accepted_without_conformance_receipt_passes
  assert_failure_contains \
    "implemented packets require conformance receipt" \
    "implementation conformance review exists" \
    case_implemented_without_conformance_receipt_fails
  assert_success \
    "implemented packets pass with complete conformance receipt" \
    case_implemented_with_passing_conformance_passes
  assert_failure_contains \
    "conformance gate requires passing completeness gate" \
    "implementation-grade completeness gate passes before conformance" \
    case_implemented_conformance_requires_completeness_gate
  assert_failure_contains \
    "missing promotion target fails conformance" \
    "promotion target exists" \
    case_missing_promotion_target_fails_conformance
  assert_failure_contains \
    "incomplete promotion-target coverage fails conformance" \
    "implementation map covers promotion target" \
    case_incomplete_implementation_map_fails_conformance
  assert_success \
    "legacy implemented archives without conformance receipts remain inventory-compatible" \
    case_legacy_archived_implemented_without_conformance_receipt_warns_but_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
