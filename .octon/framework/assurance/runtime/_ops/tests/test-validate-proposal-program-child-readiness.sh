#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"

VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh"
STANDARD_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-program-readiness.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/lib"
  cp "$REPO_ROOT/$VALIDATE_SCRIPT" "$fixture_root/$VALIDATE_SCRIPT"
  cp "$REPO_ROOT/$STANDARD_SCRIPT" "$fixture_root/$STANDARD_SCRIPT"
  cp "$REPO_ROOT/$READINESS_SCRIPT" "$fixture_root/$READINESS_SCRIPT"
  cp "$REPO_ROOT/$REVIEW_GATE_SCRIPT" "$fixture_root/$REVIEW_GATE_SCRIPT"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validator-recovery-diagnostics.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validator-recovery-diagnostics.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/lib/validation-receipts.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/lib/validation-receipts.sh"
  chmod +x "$fixture_root/$VALIDATE_SCRIPT" "$fixture_root/$STANDARD_SCRIPT" "$fixture_root/$READINESS_SCRIPT" "$fixture_root/$REVIEW_GATE_SCRIPT" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
  printf '%s\n' "$fixture_root"
}

program_path() {
  printf '.octon/inputs/exploratory/proposals/architecture/program-fixture\n'
}

child_path() {
  local child_id="$1"
  printf '.octon/inputs/exploratory/proposals/architecture/%s\n' "$child_id"
}

packet_dir() {
  local root="$1" child_id="$2"
  printf '%s/%s\n' "$root" "$(child_path "$child_id")"
}

archive_packet_dir() {
  local root="$1" child_id="$2"
  printf '%s/.octon/inputs/exploratory/proposals/.archive/architecture/%s\n' "$root" "$child_id"
}

write_parent() {
  local root="$1"
  local dir="$root/$(program_path)"
  mkdir -p "$dir/resources" "$dir/architecture"
  cat >"$dir/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "program-fixture"
title: "Program Fixture"
summary: "Program child-readiness fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/program-fixture.md"
status: "accepted"
lifecycle:
  temporary: true
  exit_expectation: "Generate implementation prompt."
related_proposals: []
EOF
  cat >"$dir/resources/source.md" <<'EOF'
# Source
EOF
  cat >"$dir/architecture/child-packet-contract.md" <<'EOF'
# Child Packet Contract
EOF
}

write_registry() {
  local root="$1" body="$2"
  cat >"$root/$(program_path)/resources/child-packet-index.yml" <<EOF
schema_version: "octon-proposal-program-child-registry-v2"
execution_mode: "sequential"
default_child_lifecycle_id: "proposal-packet"
children:
$body
EOF
}

write_child() {
  local root="$1" child_id="$2" status="${3:-accepted}" profile="${4:-atomic}" readiness_text="${5:-task-specific harness envelope}"
  local dir
  dir="$(packet_dir "$root" "$child_id")"
  mkdir -p "$dir/navigation" "$dir/architecture" "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "$child_id"
title: "$child_id"
summary: "Child fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/$child_id.md"
status: "$status"
change_profile: "$profile"
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
  cat >"$dir/README.md" <<EOF
# $child_id
EOF
  cat >"$dir/navigation/source-of-truth-map.md" <<'EOF'
# Source Of Truth
EOF
  cat >"$dir/architecture/target-architecture.md" <<EOF
# Target Architecture

$readiness_text
EOF
  cat >"$dir/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan
EOF
  cat >"$dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria
EOF
  cat >"$dir/support/implementation-grade-completeness-review.md" <<EOF
# Implementation-Grade Completeness Review

verdict: pass
unresolved_questions_count: 0
clarification_required: no

## Blockers

None.

## Assumptions

None.

## Promotion Target Coverage

.octon/framework/$child_id.md is covered.

## Affected Artifact Coverage

$readiness_text

## Validator Coverage

Complete.

## Implementation Prompt Readiness

Ready.

## Exclusions

None.

## Final Route Recommendation

Generate implementation prompt.
EOF
  cat >"$dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `support/implementation-grade-completeness-review.md`
EOF
}

remove_child_change_profile() {
  local root="$1" child_id="$2"
  yq -i 'del(.change_profile)' "$(packet_dir "$root" "$child_id")/proposal.yml"
}

write_implementation_receipts() {
  local root="$1" child_id="$2"
  local dir
  dir="$(packet_dir "$root" "$child_id")/support"
  cat >"$dir/implementation-run.md" <<'EOF'
verdict: pass
EOF
  cat >"$dir/implementation-conformance-review.md" <<'EOF'
verdict: pass
EOF
  cat >"$dir/post-implementation-drift-churn-review.md" <<'EOF'
verdict: pass
EOF
}

packet_digest() {
  local root="$1" child_id="$2"
  (
    cd "$root"
    bash "$REVIEW_GATE_SCRIPT" --package "$(child_path "$child_id")" --print-digest
  )
}

write_review() {
  local root="$1" child_id="$2" digest
  digest="$(packet_digest "$root" "$child_id")"
  cat >"$(packet_dir "$root" "$child_id")/support/proposal-review.md" <<EOF
# Proposal Review

review_id: $child_id-review-001
reviewed_at: 2026-05-12
reviewer: fixture-reviewer
verdict: accepted
implementation_prompt_authorized: yes
reviewed_packet_digest: $digest
open_blocking_findings_count: 0

## Approved Promotion Targets

- .octon/framework/$child_id.md

## Exclusions

None.

## Blocking Findings

None.

## Nonblocking Findings

None.

## Final Route Recommendation

Generate implementation prompt.
EOF
  cat >"$(packet_dir "$root" "$child_id")/support/pre-integration-architecture-review.yml" <<EOF
schema_version: "architectural-review-support-receipt-v1"
receipt_id: "$child_id-pre-integration-architecture-review"
proposal_path: "$(child_path "$child_id")"
packet_digest: "$digest"
review_mode: "pre-integration-architecture-review"
verdict: "pass"
unresolved_count: 0
non_authority_classification: "retained-evidence-only"
recorded_at: "2026-07-16T14:24:00Z"
evidence_refs:
  - "$(child_path "$child_id")/architecture/target-architecture.md"
  - "$(child_path "$child_id")/architecture/acceptance-criteria.md"
validator_refs:
  - ".octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
blockers: []
mode_specific_coverage:
  fixture: "covered"
  external_tool_integrity: "covered: external tools remain unmodified and Octon owns all required solution changes"
EOF
}

write_valid_fixture() {
  local root="$1"
  write_parent "$root"
  write_child "$root" "base-child" accepted atomic "task-specific harness envelope"
  write_child "$root" "cutover-child" accepted atomic "compatibility retirement and canonical runtime support constraints"
  write_review "$root" "base-child"
  write_review "$root" "cutover-child"
  write_registry "$root" '  - child_id: "base-child"
    path: ".octon/inputs/exploratory/proposals/architecture/base-child"
    required: true
    deferred: false
    required_metadata:
      - "change_profile"
    source_lineage_refs:
      - ".octon/inputs/exploratory/proposals/architecture/program-fixture/resources/source.md"
    parent_contract_refs:
      - ".octon/inputs/exploratory/proposals/architecture/program-fixture/architecture/child-packet-contract.md"
    readiness_requirements:
      - requirement_id: "harness-envelope-completeness"
        summary: "Harness envelope must be complete."
        review_must_mention:
          - "task-specific harness envelope"
  - child_id: "cutover-child"
    path: ".octon/inputs/exploratory/proposals/architecture/cutover-child"
    required: true
    deferred: false
    dependencies:
      - "base-child"
    required_metadata:
      - "change_profile"
    readiness_requirements:
      - requirement_id: "cutover-readiness"
        summary: "Cutover constraints must remain explicit."
        review_must_mention:
          - "compatibility retirement"
          - "canonical runtime support"
    predecessor_constraints:
      - predecessor_child_id: "base-child"
        constraint: "Base child readiness is required before cutover prompt generation."
    cutover_constraints:
      compatibility_retirement_requires_predecessor_evidence: true
      canonical_runtime_support_requires_predecessor_evidence: true
      required_predecessor_child_ids:
        - "base-child"
      forbidden_claims_until_ready:
        - "compatibility-retired"
        - "canonical-runtime-support"'
}

run_validator() {
  local root="$1"
  (
    cd "$root"
    bash "$VALIDATE_SCRIPT" --package "$(program_path)"
  )
}

case_valid_program_passes() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  run_validator "$root"
}

case_missing_change_profile_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  remove_child_change_profile "$root" "base-child"
  run_validator "$root"
}

case_missing_completeness_review_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  rm "$(packet_dir "$root" "base-child")/support/implementation-grade-completeness-review.md"
  run_validator "$root"
}

case_absent_proposal_review_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  rm "$(packet_dir "$root" "base-child")/support/proposal-review.md"
  run_validator "$root"
}

case_stale_proposal_review_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  printf '\nChanged after review.\n' >>"$(packet_dir "$root" "base-child")/README.md"
  run_validator "$root"
}

case_implemented_child_with_receipts_passes() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.status = "implemented"' "$(packet_dir "$root" "base-child")/proposal.yml"
  remove_child_change_profile "$root" "base-child"
  printf '\nChanged by promotion after review.\n' >>"$(packet_dir "$root" "base-child")/README.md"
  write_implementation_receipts "$root" "base-child"
  run_validator "$root"
}

case_archived_implemented_child_with_receipts_passes() {
  local root active archive
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.status = "implemented"' "$(packet_dir "$root" "base-child")/proposal.yml"
  write_implementation_receipts "$root" "base-child"
  cat >"$(packet_dir "$root" "base-child")/support/proposal-closeout.md" <<'EOF'
verdict: pass
archive_authorized: yes
EOF
  active="$(packet_dir "$root" "base-child")"
  archive="$(archive_packet_dir "$root" "base-child")"
  mkdir -p "$(dirname "$archive")"
  mv "$active" "$archive"
  yq -i '.status = "archived" | .archive.archived_at = "2026-05-12" | .archive.archived_from_status = "implemented" | .archive.disposition = "implemented" | .archive.original_path = ".octon/inputs/exploratory/proposals/architecture/base-child" | .archive.promotion_evidence = [".octon/framework/base-child.md"]' "$archive/proposal.yml"
  cat >"$archive/support/proposal-terminal-closeout.yml" <<'EOF'
terminal_verdict: archive-ready
archive_ready: yes
EOF
  cat >"$archive/support/validation.md" <<'EOF'
verdict: pass
EOF
  run_validator "$root"
}

case_archived_implemented_child_with_legacy_validation_receipt_passes() {
  local root active archive
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.status = "implemented"' "$(packet_dir "$root" "base-child")/proposal.yml"
  write_implementation_receipts "$root" "base-child"
  cat >"$(packet_dir "$root" "base-child")/support/proposal-closeout.md" <<'EOF'
verdict: pass
archive_authorized: yes
EOF
  active="$(packet_dir "$root" "base-child")"
  archive="$(archive_packet_dir "$root" "base-child")"
  mkdir -p "$(dirname "$archive")"
  mv "$active" "$archive"
  yq -i '.status = "archived" | .archive.archived_at = "2026-05-12" | .archive.archived_from_status = "implemented" | .archive.disposition = "implemented" | .archive.original_path = ".octon/inputs/exploratory/proposals/architecture/base-child" | .archive.promotion_evidence = [".octon/framework/base-child.md"]' "$archive/proposal.yml"
  cat >"$archive/support/proposal-terminal-closeout.yml" <<'EOF'
terminal_verdict: archive-ready
archive_ready: yes
EOF
  cat >"$archive/support/validation.md" <<'EOF'
# Validation Evidence

## Commands

- `bash validate.sh`

## Result

All listed commands exited successfully.
EOF
  run_validator "$root"
}

case_archived_implemented_child_without_validation_pass_fails() {
  local root active archive
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.status = "implemented"' "$(packet_dir "$root" "base-child")/proposal.yml"
  write_implementation_receipts "$root" "base-child"
  cat >"$(packet_dir "$root" "base-child")/support/proposal-closeout.md" <<'EOF'
verdict: pass
archive_authorized: yes
EOF
  active="$(packet_dir "$root" "base-child")"
  archive="$(archive_packet_dir "$root" "base-child")"
  mkdir -p "$(dirname "$archive")"
  mv "$active" "$archive"
  yq -i '.status = "archived" | .archive.archived_at = "2026-05-12" | .archive.archived_from_status = "implemented" | .archive.disposition = "implemented" | .archive.original_path = ".octon/inputs/exploratory/proposals/architecture/base-child" | .archive.promotion_evidence = [".octon/framework/base-child.md"]' "$archive/proposal.yml"
  cat >"$archive/support/proposal-terminal-closeout.yml" <<'EOF'
terminal_verdict: archive-ready
archive_ready: yes
EOF
  cat >"$archive/support/validation.md" <<'EOF'
# Validation Evidence

## Commands

| Command | Result |
| --- | --- |
| `bash validate.sh` | blocked |
EOF
  run_validator "$root"
}

case_archived_implemented_child_with_failed_word_fails() {
  local root active archive
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.status = "implemented"' "$(packet_dir "$root" "base-child")/proposal.yml"
  write_implementation_receipts "$root" "base-child"
  cat >"$(packet_dir "$root" "base-child")/support/proposal-closeout.md" <<'EOF'
verdict: pass
archive_authorized: yes
EOF
  active="$(packet_dir "$root" "base-child")"
  archive="$(archive_packet_dir "$root" "base-child")"
  mkdir -p "$(dirname "$archive")"
  mv "$active" "$archive"
  yq -i '.status = "archived" | .archive.archived_at = "2026-05-12" | .archive.archived_from_status = "implemented" | .archive.disposition = "implemented" | .archive.original_path = ".octon/inputs/exploratory/proposals/architecture/base-child" | .archive.promotion_evidence = [".octon/framework/base-child.md"]' "$archive/proposal.yml"
  cat >"$archive/support/proposal-terminal-closeout.yml" <<'EOF'
terminal_verdict: archive-ready
archive_ready: yes
EOF
  cat >"$archive/support/validation.md" <<'EOF'
# Validation Evidence

| Command | Result |
| --- | --- |
| `bash validate.sh` | failed |
EOF
  run_validator "$root"
}

case_missing_packet_specific_requirement_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i '.children[0].readiness_requirements[0].review_must_mention = ["connector operation fields"]' "$root/$(program_path)/resources/child-packet-index.yml"
  run_validator "$root"
}

case_premature_cutover_fails() {
  local root
  root="$(create_fixture_repo)"
  write_valid_fixture "$root"
  yq -i 'del(.children[1].dependencies) | del(.children[1].cutover_constraints.required_predecessor_child_ids)' "$root/$(program_path)/resources/child-packet-index.yml"
  run_validator "$root"
}

assert_success "valid program child readiness passes" case_valid_program_passes
assert_failure_contains "missing child change_profile fails" "child base-child declares change_profile" case_missing_change_profile_fails
assert_failure_contains "missing implementation-grade completeness review fails" "implementation-grade completeness review exists" case_missing_completeness_review_fails
assert_failure_contains "absent accepted proposal-review digest fails" "proposal review receipt authorizes implementation" case_absent_proposal_review_fails
assert_failure_contains "stale accepted proposal-review digest fails" "reviewed packet digest is fresh" case_stale_proposal_review_fails
assert_failure_contains "stale child gate emits readiness gate diagnostic" '"recovery_class":"child_readiness_gate_failed"' case_stale_proposal_review_fails
assert_success "implemented child with receipts remains child-ready" case_implemented_child_with_receipts_passes
assert_success "archived implemented child with receipts remains child-ready" case_archived_implemented_child_with_receipts_passes
assert_success "archived implemented child with legacy validation receipt remains child-ready" case_archived_implemented_child_with_legacy_validation_receipt_passes
assert_failure_contains "archived implemented child without validation pass fails" "child base-child archived validation receipt passes" case_archived_implemented_child_without_validation_pass_fails
assert_failure_contains "archived implemented child with failed validation row fails" "child base-child archived validation receipt passes" case_archived_implemented_child_with_failed_word_fails
assert_failure_contains "missing packet-specific completeness requirement fails" "child base-child readiness evidence mentions: connector operation fields" case_missing_packet_specific_requirement_fails
assert_failure_contains "premature cutover retirement fails" "child cutover-child cutover constraints declare predecessor evidence" case_premature_cutover_fails

printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
