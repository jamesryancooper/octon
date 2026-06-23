#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
VALIDATE_SCRIPT="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh"

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

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

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
  printf '  expected failure containing: %s\n%s\n' "$needle" "$output" >&2
  return 1
}

create_fixture() {
  local root program
  root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-program-structure.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  program="$root/parent"
  mkdir -p "$program/resources" "$program/architecture" "$program/support"
  cat >"$program/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "program-fixture"
title: "Program Fixture"
summary: "Program structure fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/program-fixture.md"
status: "accepted"
lifecycle:
  temporary: true
  exit_expectation: "Coordinate child packets."
related_proposals:
  - "child-a"
  - "child-b"
EOF
  cat >"$program/resources/child-packet-index.yml" <<'EOF'
schema_version: "octon-proposal-program-child-registry-v2"
execution_mode: "sequential"
default_child_lifecycle_id: "proposal-packet"
children:
  - child_id: "child-a"
    path: ".octon/inputs/exploratory/proposals/architecture/child-a"
    required: true
    deferred: false
  - child_id: "child-b"
    path: ".octon/inputs/exploratory/proposals/architecture/child-b"
    required: true
    deferred: false
    dependencies:
      - "child-a"
EOF
  cat >"$program/resources/child-packet-index.md" <<'EOF'
# Child Packet Index

- `child-a`
- `child-b`
EOF
  cat >"$program/architecture/packet-sequence.md" <<'EOF'
# Packet Sequence

1. `child-a`
2. `child-b`
EOF
  cat >"$program/architecture/child-packet-contract.md" <<'EOF'
# Child Packet Contract

Children remain sibling proposal packets.
EOF
  cat >"$program/architecture/program-closeout-plan.md" <<'EOF'
# Program Closeout Plan

Parent closeout summarizes child outcomes only.
EOF
  printf '%s\n' "$program"
}

run_validator() {
  local program="$1"
  bash "$VALIDATE_SCRIPT" --package "$program"
}

case_valid_structure_passes() {
  local program
  program="$(create_fixture)"
  run_validator "$program"
}

case_sequenced_gated_alias_passes() {
  local program
  program="$(create_fixture)"
  yq -i '.execution_mode = "sequenced-gated"' "$program/resources/child-packet-index.yml"
  run_validator "$program"
}

case_unknown_execution_mode_fails() {
  local program
  program="$(create_fixture)"
  yq -i '.execution_mode = "unknown-mode"' "$program/resources/child-packet-index.yml"
  run_validator "$program"
}

case_manifest_registry_execution_mode_disagreement_fails() {
  local program
  program="$(create_fixture)"
  yq -i '.program_execution_mode = "sequential"' "$program/proposal.yml"
  yq -i '.execution_mode = "gated-parallel"' "$program/resources/child-packet-index.yml"
  run_validator "$program"
}

case_mismatched_related_proposals_fails() {
  local program
  program="$(create_fixture)"
  yq -i '.related_proposals = ["child-a", "child-c"]' "$program/proposal.yml"
  run_validator "$program"
}

case_unsafe_child_path_fails() {
  local program
  program="$(create_fixture)"
  yq -i '.children[0].path = "../outside"' "$program/resources/child-packet-index.yml"
  run_validator "$program"
}

case_nested_child_path_fails() {
  local program
  program="$(create_fixture)"
  yq -i '.children[0].path = "parent/children/child-a"' "$program/resources/child-packet-index.yml"
  run_validator "$program"
}

case_missing_human_index_fails() {
  local program
  program="$(create_fixture)"
  rm "$program/resources/child-packet-index.md"
  run_validator "$program"
}

case_missing_sequence_fails() {
  local program
  program="$(create_fixture)"
  rm "$program/architecture/packet-sequence.md"
  run_validator "$program"
}

case_parent_child_authority_surface_fails() {
  local program
  program="$(create_fixture)"
  cat >>"$program/proposal.yml" <<'EOF'
child_validation_verdicts: []
child_archive_metadata: {}
EOF
  run_validator "$program"
}

assert_success "valid parent program structure passes" case_valid_structure_passes
assert_success "sequenced-gated alias passes" case_sequenced_gated_alias_passes
assert_failure_contains "unknown execution mode fails" "program registry execution_mode is supported: unknown-mode" case_unknown_execution_mode_fails
assert_failure_contains "unknown execution mode emits registry diagnostic" "resources/child-packet-index.yml#execution_mode" case_unknown_execution_mode_fails
assert_failure_contains "manifest and registry execution modes must agree" "parent program_execution_mode agrees with registry execution_mode after normalization" case_manifest_registry_execution_mode_disagreement_fails
assert_failure_contains "mismatched child ids fail" "related_proposals covers registry children" case_mismatched_related_proposals_fails
assert_failure_contains "unsafe child path fails" "child child-a path is repo-relative" case_unsafe_child_path_fails
assert_failure_contains "unsafe child path emits child registry diagnostic" '"recovery_class":"child_registry_error"' case_unsafe_child_path_fails
assert_failure_contains "nested child path fails" "child child-a path is not nested under parent program" case_nested_child_path_fails
assert_failure_contains "missing human child index fails" "human child index exists" case_missing_human_index_fails
assert_failure_contains "missing packet sequence fails" "packet sequence exists" case_missing_sequence_fails
assert_failure_contains "parent-owned child authority surface fails" "parent package contains child-owned authority surfaces" case_parent_child_authority_surface_fails
assert_failure_contains "parent-owned child authority emits hard blocker diagnostic" '"hard_blocker_reason":"parent package contains child-owned authority surfaces"' case_parent_child_authority_surface_fails

printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
