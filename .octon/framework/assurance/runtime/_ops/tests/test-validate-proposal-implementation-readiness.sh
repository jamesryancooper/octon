#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh"
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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-readiness.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/$VALIDATE_SCRIPT" "$fixture_root/$VALIDATE_SCRIPT"
  cp "$REPO_ROOT/$REVIEW_GATE_SCRIPT" "$fixture_root/$REVIEW_GATE_SCRIPT"
  printf '%s\n' "$fixture_root"
}

write_policy_packet() {
  local root="$1" status="${2:-draft}"
  local dir="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy"
  mkdir -p "$dir/policy" "$dir/navigation" "$dir/implementation" "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "readiness-policy"
title: "Readiness Policy"
summary: "Fixture."
proposal_kind: "policy"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "$status"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$dir/policy-proposal.yml" <<'EOF'
schema_version: "policy-proposal-v1"
policy_area: "readiness"
change_type: "new-policy"
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
  cat >"$dir/implementation/implementation-map.md" <<'EOF'
# Implementation Map

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/example.md` | Missing. | Create. | owns policy | P0. |
EOF
  cat >"$dir/README.md" <<'EOF'
# Readiness Policy
EOF
  cat >"$dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog
EOF
  cat >"$dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth
EOF
}

write_passing_review() {
  local root="$1"
  local review="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/implementation-grade-completeness-review.md"
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

Generate implementation prompt.
EOF
}

packet_digest() {
  local root="$1"
  (
    cd "$root"
    bash "$REVIEW_GATE_SCRIPT" --package ".octon/inputs/exploratory/proposals/policy/readiness-policy" --print-digest
  )
}

write_passing_proposal_review() {
  local root="$1" digest
  digest="$(packet_digest "$root")"
  cat >"$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/proposal-review.md" <<EOF
# Proposal Review

review_id: readiness-review-001
reviewed_at: 2026-05-06
reviewer: fixture-reviewer
verdict: accepted
implementation_prompt_authorized: yes
reviewed_packet_digest: $digest
open_blocking_findings_count: 0

## Approved Promotion Targets

- .octon/framework/example.md

## Exclusions

None.

## Blocking Findings

None.

## Nonblocking Findings

None.

## Final Route Recommendation

Generate implementation prompt.
EOF
}

run_validator() {
  local root="$1"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package ".octon/inputs/exploratory/proposals/policy/readiness-policy"
  )
}

run_validator_for_path() {
  local root="$1" path="$2"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$path"
  )
}

case_draft_without_review_warns_but_passes() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" draft
  run_validator "$root"
}

case_accepted_without_review_fails() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  run_validator "$root"
}

case_accepted_with_passing_review_passes() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  run_validator "$root"
}

case_executable_prompt_requires_passing_review() {
  local root prompt
  root="$(create_fixture_repo)"
  write_policy_packet "$root" draft
  prompt="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/executable-implementation-prompt.md"
  printf '# Prompt\n' >"$prompt"
  run_validator "$root"
}

case_executable_prompt_requires_prompt_contract() {
  local root prompt
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  write_passing_proposal_review "$root"
  prompt="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/executable-implementation-prompt.md"
  cat >"$prompt" <<'EOF'
# Executable Implementation Prompt

Implement `.octon/framework/example.md`.
EOF
  run_validator "$root"
}

case_valid_executable_prompt_passes() {
  local root prompt
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  write_passing_proposal_review "$root"
  prompt="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/executable-implementation-prompt.md"
  cat >"$prompt" <<'EOF'
# Executable Implementation Prompt

Implement the promotion target `.octon/framework/example.md`.

Run validation with validate-proposal-implementation-readiness.sh and
validate-proposal-implementation-conformance.sh.

Retain evidence for the implemented result and record rollback instructions.

After implementation, produce `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md`.

Refuse closeout/archive claims until both post-implementation receipts pass.
EOF
  run_validator "$root"
}

case_implemented_executable_prompt_preserves_authorization() {
  local root prompt manifest
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  write_passing_proposal_review "$root"
  prompt="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/executable-implementation-prompt.md"
  cat >"$prompt" <<'EOF'
# Executable Implementation Prompt

Implement the promotion target `.octon/framework/example.md`.

Run validation with validate-proposal-implementation-readiness.sh and
validate-proposal-implementation-conformance.sh.

Retain evidence for the implemented result and record rollback instructions.

After implementation, produce `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md`.

Refuse closeout/archive claims until both post-implementation receipts pass.
EOF
  manifest="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/proposal.yml"
  perl -0pi -e 's/status: "accepted"/status: "implemented"/' "$manifest"
  run_validator "$root"
}

case_executable_prompt_requires_accepted_review() {
  local root prompt
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  prompt="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/support/executable-implementation-prompt.md"
  cat >"$prompt" <<'EOF'
# Executable Implementation Prompt

Implement the promotion target `.octon/framework/example.md`.

Run validation with validate-proposal-implementation-readiness.sh and
validate-proposal-implementation-conformance.sh.

Retain evidence for the implemented result and record rollback instructions.

After implementation, produce `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md`.

Refuse closeout/archive claims until both post-implementation receipts pass.
EOF
  run_validator "$root"
}

case_legacy_archived_implemented_without_review_warns_but_passes() {
  local root manifest
  root="$(create_fixture_repo)"
  write_policy_packet "$root" archived
  manifest="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/proposal.yml"
  cat >>"$manifest" <<'EOF'
archive:
  disposition: implemented
EOF
  run_validator "$root"
}

case_legacy_archived_mixed_targets_warn_but_pass() {
  local root manifest
  root="$(create_fixture_repo)"
  write_policy_packet "$root" archived
  manifest="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/proposal.yml"
  cat >"$manifest" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "readiness-policy"
title: "Readiness Policy"
summary: "Fixture."
proposal_kind: "policy"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
  - ".github/workflows/example.yml"
status: "archived"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
archive:
  disposition: implemented
EOF
  run_validator "$root"
}

case_legacy_archive_path_with_implemented_status_warns_but_passes() {
  local root active archived
  root="$(create_fixture_repo)"
  write_policy_packet "$root" implemented
  active="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy"
  archived="$root/.octon/inputs/exploratory/proposals/.archive/policy/readiness-policy"
  mkdir -p "$(dirname "$archived")"
  mv "$active" "$archived"
  run_validator_for_path "$root" ".octon/inputs/exploratory/proposals/.archive/policy/readiness-policy"
}

case_legacy_archive_executable_prompt_without_review_warns_but_passes() {
  local root active archived prompt
  root="$(create_fixture_repo)"
  write_policy_packet "$root" archived
  active="$root/.octon/inputs/exploratory/proposals/policy/readiness-policy"
  archived="$root/.octon/inputs/exploratory/proposals/.archive/policy/readiness-policy"
  prompt="$archived/support/executable-implementation-prompt.md"
  mkdir -p "$(dirname "$archived")"
  mv "$active" "$archived"
  printf '# Historical Prompt\n' >"$prompt"
  run_validator_for_path "$root" ".octon/inputs/exploratory/proposals/.archive/policy/readiness-policy"
}

case_placeholder_blocks_review_status() {
  local root
  root="$(create_fixture_repo)"
  write_policy_packet "$root" accepted
  write_passing_review "$root"
  printf '\nTODO: fill later\n' >>"$root/.octon/inputs/exploratory/proposals/policy/readiness-policy/policy/decision.md"
  run_validator "$root"
}

main() {
  assert_success \
    "draft packets may be structurally valid before readiness review" \
    case_draft_without_review_warns_but_passes
  assert_failure_contains \
    "accepted packets require completeness review" \
    "implementation-grade completeness review exists" \
    case_accepted_without_review_fails
  assert_success \
    "accepted packets pass with clean completeness review" \
    case_accepted_with_passing_review_passes
  assert_failure_contains \
    "implementation prompt requires passing review" \
    "implementation-grade completeness review exists" \
    case_executable_prompt_requires_passing_review
  assert_failure_contains \
    "implementation prompt requires prompt contract coverage" \
    "executable implementation prompt requires conformance receipt" \
    case_executable_prompt_requires_prompt_contract
  assert_success \
    "valid executable implementation prompt passes prompt lint" \
    case_valid_executable_prompt_passes
  assert_success \
    "implemented executable prompt preserves prior implementation authorization" \
    case_implemented_executable_prompt_preserves_authorization
  assert_failure_contains \
    "implementation prompt requires accepted proposal review" \
    "proposal review authorizes executable implementation prompt" \
    case_executable_prompt_requires_accepted_review
  assert_success \
    "legacy implemented archives without receipts remain inventory-compatible" \
    case_legacy_archived_implemented_without_review_warns_but_passes
  assert_success \
    "legacy implemented archives may retain historical mixed targets" \
    case_legacy_archived_mixed_targets_warn_but_pass
  assert_success \
    "legacy archive paths with implemented status remain inventory-compatible" \
    case_legacy_archive_path_with_implemented_status_warns_but_passes
  assert_success \
    "legacy archive executable prompts do not require new receipts" \
    case_legacy_archive_executable_prompt_without_review_warns_but_passes
  assert_failure_contains \
    "placeholders block implementation-grade packets" \
    "contains no scaffold placeholders" \
    case_placeholder_blocks_review_status

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
