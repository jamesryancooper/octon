#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-review-gate.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/$VALIDATE_SCRIPT" "$fixture_root/$VALIDATE_SCRIPT"
  printf '%s\n' "$fixture_root"
}

write_packet() {
  local root="$1" status="${2:-draft}"
  local dir="$root/.octon/inputs/exploratory/proposals/architecture/review-fixture"
  mkdir -p "$dir/navigation" "$dir/architecture" "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "review-fixture"
title: "Review Fixture"
summary: "Review gate fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "$status"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$dir/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF
  cat >"$dir/README.md" <<'EOF'
# Review Fixture
EOF
  cat >"$dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog
EOF
  cat >"$dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth
EOF
  cat >"$dir/architecture/target-architecture.md" <<'EOF'
# Target Architecture
EOF
  cat >"$dir/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan
EOF
  cat >"$dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria
EOF
  cat >"$dir/support/implementation-grade-completeness-review.md" <<'EOF'
# Implementation-Grade Completeness Review

verdict: pass
unresolved_questions_count: 0
clarification_required: no
EOF
}

packet_path() {
  printf '.octon/inputs/exploratory/proposals/architecture/review-fixture\n'
}

packet_dir() {
  local root="$1"
  printf '%s/%s\n' "$root" "$(packet_path)"
}

packet_digest() {
  local root="$1"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$(packet_path)" --print-digest
  )
}

write_review() {
  local root="$1" verdict="$2" auth="$3" blockers="$4" digest
  digest="$(packet_digest "$root")"
  cat >"$(packet_dir "$root")/support/proposal-review.md" <<EOF
# Proposal Review

review_id: review-fixture-001
reviewed_at: 2026-05-06
reviewer: fixture-reviewer
verdict: $verdict
implementation_prompt_authorized: $auth
reviewed_packet_digest: $digest
open_blocking_findings_count: $blockers

## Approved Promotion Targets

- .octon/framework/example.md

## Exclusions

None.

## Blocking Findings

Open blocker count: $blockers.

## Nonblocking Findings

None.

## Final Route Recommendation

Proceed according to the recorded verdict.
EOF
}

run_validator() {
  local root="$1"
  shift
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$(packet_path)" "$@"
  )
}

case_draft_missing_review_passes() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" draft
  run_validator "$root"
}

case_in_review_missing_review_passes() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" in-review
  run_validator "$root"
}

case_in_review_missing_review_fails_strict() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" in-review
  run_validator "$root" --require-implementation-authorization
}

case_accepted_fresh_review_passes() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" accepted
  write_review "$root" accepted yes 0
  run_validator "$root" --require-implementation-authorization
}

case_accepted_stale_review_fails() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" accepted
  write_review "$root" accepted yes 0
  printf '\nChanged after review.\n' >>"$(packet_dir "$root")/README.md"
  run_validator "$root" --require-implementation-authorization
}

case_accepted_review_survives_post_review_receipts() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" accepted
  write_review "$root" accepted yes 0
  cat >"$(packet_dir "$root")/support/proposal-creation.md" <<'EOF'
creation_id: creation-1
created_at: 2026-05-07T00:00:00Z
creator: test
source_context_bound: yes
packet_path: packet
verdict: pass
EOF
  cat >"$(packet_dir "$root")/support/implementation-run.md" <<'EOF'
verdict: pass
implemented_at: 2026-05-07T00:00:00Z
promotion_evidence_count: 1
EOF
  cat >"$(packet_dir "$root")/support/implementation-conformance-review.md" <<'EOF'
verdict: pass
unresolved_items_count: 0
EOF
  cat >"$(packet_dir "$root")/support/post-implementation-drift-churn-review.md" <<'EOF'
verdict: pass
unresolved_items_count: 0
EOF
  cat >"$(packet_dir "$root")/support/proposal-closeout.md" <<'EOF'
verdict: pass
closed_at: 2026-05-07T00:00:00Z
archive_authorized: yes
EOF
  run_validator "$root" --require-implementation-authorization
}

case_revision_required_blocks_implementation() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" in-review
  write_review "$root" revision-required no 2
  run_validator "$root" --require-implementation-authorization
}

case_rejected_requires_rejected_review() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" rejected
  run_validator "$root"
}

case_rejected_with_rejected_review_passes() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" rejected
  write_review "$root" rejected no 0
  run_validator "$root"
}

case_pre_gate_accepted_passes_baseline() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" accepted
  run_validator "$root"
}

case_pre_gate_accepted_fails_strict() {
  local root
  root="$(create_fixture_repo)"
  write_packet "$root" accepted
  run_validator "$root" --require-implementation-authorization
}

main() {
  assert_success \
    "draft packets may omit proposal review receipts" \
    case_draft_missing_review_passes
  assert_success \
    "in-review packets may await proposal review receipts" \
    case_in_review_missing_review_passes
  assert_failure_contains \
    "strict implementation authorization requires a review receipt" \
    "proposal review receipt authorizes implementation" \
    case_in_review_missing_review_fails_strict
  assert_success \
    "accepted packets pass strict review gate with a fresh accepted receipt" \
    case_accepted_fresh_review_passes
  assert_failure_contains \
    "accepted packets fail when review digest is stale" \
    "reviewed packet digest is fresh" \
    case_accepted_stale_review_fails
  assert_success \
    "accepted review remains fresh after post-review operational receipts" \
    case_accepted_review_survives_post_review_receipts
  assert_failure_contains \
    "revision-required review blocks implementation authorization" \
    "proposal status is accepted for implementation authorization" \
    case_revision_required_blocks_implementation
  assert_failure_contains \
    "rejected packets require rejected review receipts" \
    "rejected proposal has rejected proposal review receipt" \
    case_rejected_requires_rejected_review
  assert_success \
    "rejected packets pass with rejected review receipts" \
    case_rejected_with_rejected_review_passes
  assert_success \
    "pre-gate accepted packets remain structurally valid" \
    case_pre_gate_accepted_passes_baseline
  assert_failure_contains \
    "pre-gate accepted packets fail strict implementation authorization" \
    "proposal review receipt authorizes implementation" \
    case_pre_gate_accepted_fails_strict

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
