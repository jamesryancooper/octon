#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh"
CONFORMANCE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh"
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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-drift.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/$VALIDATE_SCRIPT" "$fixture_root/$VALIDATE_SCRIPT"
  cp "$REPO_ROOT/$CONFORMANCE_SCRIPT" "$fixture_root/$CONFORMANCE_SCRIPT"
  cp "$REPO_ROOT/$READINESS_SCRIPT" "$fixture_root/$READINESS_SCRIPT"
  cp "$REPO_ROOT/$REVIEW_GATE_SCRIPT" "$fixture_root/$REVIEW_GATE_SCRIPT"
  printf '%s\n' "$fixture_root"
}

write_policy_packet() {
  local root="$1" status="${2:-implemented}" target="${3:-.octon/framework/example.md}"
  local dir="$root/.octon/inputs/exploratory/proposals/policy/drift-policy"
  mkdir -p "$dir/policy" "$dir/navigation" "$dir/implementation" "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "drift-policy"
title: "Drift Policy"
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

write_target() {
  local root="$1" body="${2:-# Example}"
  mkdir -p "$root/.octon/framework"
  printf '%s\n' "$body" >"$root/.octon/framework/example.md"
}

write_registry() {
  local root="$1" bucket="${2:-active}" path="${3:-.octon/inputs/exploratory/proposals/policy/drift-policy}" status="${4:-implemented}"
  mkdir -p "$root/.octon/generated/proposals"
  if [[ "$bucket" == "active" ]]; then
    cat >"$root/.octon/generated/proposals/registry.yml" <<EOF
schema_version: "proposal-registry-v1"
active:
  - id: "drift-policy"
    kind: "policy"
    scope: "octon-internal"
    path: "$path"
    title: "Drift Policy"
    status: "$status"
    promotion_targets:
      - ".octon/framework/example.md"
archived: []
EOF
  else
    cat >"$root/.octon/generated/proposals/registry.yml" <<EOF
schema_version: "proposal-registry-v1"
active: []
archived:
  - id: "drift-policy"
    kind: "policy"
    scope: "octon-internal"
    path: "$path"
    title: "Drift Policy"
    status: "archived"
    promotion_targets:
      - ".octon/framework/example.md"
EOF
  fi
}

write_passing_review() {
  local root="$1"
  local review="$root/.octon/inputs/exploratory/proposals/policy/drift-policy/support/post-implementation-drift-churn-review.md"
  cat >"$review" <<'EOF'
# Post-Implementation Drift/Churn Review

verdict: pass
unresolved_items_count: 0

## Blockers

None.

## Checked Evidence

- `.octon/framework/example.md`

## Backreference Scan

- No active proposal backreferences.

## Naming Drift

- No stale Work Package/Change naming conflicts.

## Generated Projection Freshness

- `.octon/generated/proposals/registry.yml` checked with generate-proposal-registry.sh --check.

## Manifest And Schema Validity

- Manifests parse.

## Repo-Local Projection Boundaries

- No repo-local projections are included in this octon-internal proposal.

## Target Family Boundaries

- Promotion targets stay in one target family.

## Churn Review

- Churn is limited to declared targets.

## Validators Run

- validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/policy/drift-policy

## Exclusions

None.

## Final Closeout Recommendation

Close out.
EOF
}

write_passing_completeness_review() {
  local root="$1"
  local review="$root/.octon/inputs/exploratory/proposals/policy/drift-policy/support/implementation-grade-completeness-review.md"
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

write_passing_conformance_review() {
  local root="$1"
  local review="$root/.octon/inputs/exploratory/proposals/policy/drift-policy/support/implementation-conformance-review.md"
  cat >"$review" <<'EOF'
# Implementation Conformance Review

verdict: pass
unresolved_items_count: 0

## Blockers

None.

## Checked Evidence

- `.octon/framework/example.md`

## Promotion Target Coverage

- `.octon/framework/example.md`: implemented.

## Implementation Map Coverage

- `.octon/framework/example.md`: covered by the implementation map.

## Validator Coverage

- validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/drift-policy

## Generated Output Coverage

- Generated proposal registry checked.

## Rollback Coverage

- Rollback is to revert `.octon/framework/example.md`.

## Downstream Reference Coverage

- Downstream references are aligned.

## Exclusions

None.

## Final Closeout Recommendation

Run post-implementation drift/churn.
EOF
}

run_validator() {
  local root="$1"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package ".octon/inputs/exploratory/proposals/policy/drift-policy"
  )
}

run_validator_for_path() {
  local root="$1" path="$2"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$path"
  )
}

case_implemented_without_drift_receipt_fails() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_conformance_review "$root"
  run_validator "$root"
}

case_implemented_with_passing_drift_receipt_passes() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_conformance_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_implemented_drift_requires_conformance_gate() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root"
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_active_proposal_backreference_fails_drift() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root" "See .octon/inputs/exploratory/proposals/policy/drift-policy for runtime details."
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_conformance_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_unrelated_proposal_path_literal_passes_drift() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root" "Fixture validator pattern: .octon/inputs/exploratory/proposals/policy/other-policy."
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_conformance_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_stale_work_package_conflict_fails_drift() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  write_target "$root" "Work Package is the current runtime unit."
  write_registry "$root"
  write_passing_completeness_review "$root"
  write_passing_conformance_review "$root"
  write_passing_review "$root"
  run_validator "$root"
}

case_legacy_archived_implemented_without_drift_receipt_warns_but_passes() {
  local root active archived manifest
  root="$(create_fixture_repo)"
  write_policy_packet "$root" archived
  write_target "$root"
  manifest="$root/.octon/inputs/exploratory/proposals/policy/drift-policy/proposal.yml"
  cat >>"$manifest" <<'EOF'
archive:
  archived_at: "2026-05-01T00:00:00Z"
  archived_from_status: "implemented"
  disposition: "implemented"
  original_path: ".octon/inputs/exploratory/proposals/policy/drift-policy"
  promotion_evidence:
    - ".octon/framework/example.md"
EOF
  active="$root/.octon/inputs/exploratory/proposals/policy/drift-policy"
  archived="$root/.octon/inputs/exploratory/proposals/.archive/policy/drift-policy"
  mkdir -p "$(dirname "$archived")"
  mv "$active" "$archived"
  write_registry "$root" archived ".octon/inputs/exploratory/proposals/.archive/policy/drift-policy" archived
  run_validator_for_path "$root" ".octon/inputs/exploratory/proposals/.archive/policy/drift-policy"
}

main() {
  assert_failure_contains \
    "implemented packets require drift/churn receipt" \
    "post-implementation drift/churn review exists" \
    case_implemented_without_drift_receipt_fails
  assert_success \
    "implemented packets pass with clean drift/churn receipt" \
    case_implemented_with_passing_drift_receipt_passes
  assert_failure_contains \
    "drift/churn gate requires passing conformance gate" \
    "implementation conformance gate passes before drift/churn" \
    case_implemented_drift_requires_conformance_gate
  assert_failure_contains \
    "active proposal backreferences fail drift/churn" \
    "promotion target has no active proposal backreferences" \
    case_active_proposal_backreference_fails_drift
  assert_success \
    "unrelated proposal path literals do not fail drift/churn" \
    case_unrelated_proposal_path_literal_passes_drift
  assert_failure_contains \
    "stale Work Package naming conflicts fail drift/churn" \
    "no stale Work Package/Change naming conflict" \
    case_stale_work_package_conflict_fails_drift
  assert_success \
    "legacy implemented archives without drift/churn receipts remain inventory-compatible" \
    case_legacy_archived_implemented_without_drift_receipt_warns_but_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
