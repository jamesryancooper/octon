#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
VALIDATE_SCRIPT="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh"
REGISTRY_SCHEMA="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-child-registry.schema.json"

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

registry_projection_digest() {
  local registry="$1"
  yq -o=json '.children' "$registry" \
    | jq -c '[.[] | {child_id: .child_id, dependencies: ((.dependencies // []) | sort), write_scopes: ((.write_scopes // []) | sort)}] | sort_by(.child_id)' \
    | shasum -a 256 \
    | awk '{print "sha256:" $1}'
}

append_single_collision_ledger() {
  local program="$1" left_child="$2" left_scope="$3" right_child="$4" right_scope="$5"
  local kind="$6" mechanism="$7" before="$8" after="$9" registry digest child_count scope_entries unique_paths
  registry="$program/resources/child-packet-index.yml"
  digest="$(registry_projection_digest "$registry")"
  child_count="$(yq -r '.children | length' "$registry")"
  scope_entries="$(yq -r '[.children[].write_scopes[]?] | length' "$registry")"
  unique_paths="$(yq -r '[.children[].write_scopes[]?] | unique | length' "$registry")"
  cat >>"$registry" <<EOF
write_scope_collision_ledger:
  schema_version: "octon-program-write-scope-collision-ledger-v1"
  registry_write_scopes_digest: "$digest"
  derived_counts:
    child_count: $child_count
    scope_entries: $scope_entries
    unique_paths: $unique_paths
    exact_records: $([[ "$kind" == exact ]] && printf '1' || printf '0')
    directory_prefix_records: $([[ "$kind" == directory-prefix ]] && printf '1' || printf '0')
    total_records: 1
  records:
    - collision_id: "WSC-001"
      participants:
        - child_id: "$left_child"
          write_scope: "$left_scope"
          contribution: "$left_child bounded contribution"
        - child_id: "$right_child"
          write_scope: "$right_scope"
          contribution: "$right_child bounded contribution"
      collision_kind: "$kind"
      integration_owner_child_id: "$left_child"
      serialization:
        mechanism: "$mechanism"
EOF
  if [[ "$mechanism" == "exclusive-integration-lock" ]]; then
    cat >>"$registry" <<'EOF'
        lock_id: "fixture-integration-lock"
EOF
  fi
  cat >>"$registry" <<EOF
        ordered_child_ids:
          - "$before"
          - "$after"
EOF
}

append_empty_collision_ledger() {
  local program="$1" registry digest child_count scope_entries unique_paths
  registry="$program/resources/child-packet-index.yml"
  digest="$(registry_projection_digest "$registry")"
  child_count="$(yq -r '.children | length' "$registry")"
  scope_entries="$(yq -r '[.children[].write_scopes[]?] | length' "$registry")"
  unique_paths="$(yq -r '[.children[].write_scopes[]?] | unique | length' "$registry")"
  cat >>"$registry" <<EOF
write_scope_collision_ledger:
  schema_version: "octon-program-write-scope-collision-ledger-v1"
  registry_write_scopes_digest: "$digest"
  derived_counts:
    child_count: $child_count
    scope_entries: $scope_entries
    unique_paths: $unique_paths
    exact_records: 0
    directory_prefix_records: 0
    total_records: 0
  records: []
EOF
}

add_child_c() {
  local program="$1" registry="$1/resources/child-packet-index.yml"
  yq -i '.related_proposals += ["child-c"]' "$program/proposal.yml"
  yq -i '.children += [{"child_id": "child-c", "path": ".octon/inputs/exploratory/proposals/architecture/child-c", "required": true, "deferred": false}]' "$registry"
  cat >>"$program/resources/child-packet-index.md" <<'EOF'
- `child-c`
EOF
  cat >>"$program/architecture/packet-sequence.md" <<'EOF'
3. `child-c`
EOF
}

set_exact_collision() {
  local program="$1" registry="$1/resources/child-packet-index.yml"
  yq -i '.children[0].write_scopes = ["framework/shared.md"] | .children[1].write_scopes = ["framework/shared.md"]' "$registry"
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

case_zero_collision_empty_ledger_passes() {
  local program
  program="$(create_fixture)"
  append_empty_collision_ledger "$program"
  run_validator "$program"
}

case_exact_collision_passes() {
  local program
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  run_validator "$program"
}

case_directory_prefix_collision_passes() {
  local program registry
  program="$(create_fixture)"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[0].write_scopes = ["framework/host/"] | .children[1].write_scopes = ["framework/host/file.yml"]' "$registry"
  append_single_collision_ledger "$program" child-a framework/host/ child-b framework/host/file.yml directory-prefix dependency-order child-a child-b
  run_validator "$program"
}

case_similar_prefix_is_not_collision() {
  local program registry
  program="$(create_fixture)"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[0].write_scopes = ["framework/host/"] | .children[1].write_scopes = ["framework/hosted.yml"]' "$registry"
  run_validator "$program"
}

case_transitive_dependency_collision_passes() {
  local program registry
  program="$(create_fixture)"
  add_child_c "$program"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[0].write_scopes = ["framework/shared.md"] | .children[1].write_scopes = [] | .children[2].dependencies = ["child-b"] | .children[2].write_scopes = ["framework/shared.md"]' "$registry"
  append_single_collision_ledger "$program" child-a framework/shared.md child-c framework/shared.md exact dependency-order child-a child-c
  run_validator "$program"
}

case_peer_lock_collision_passes() {
  local program registry
  program="$(create_fixture)"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[1].dependencies = []' "$registry"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact exclusive-integration-lock child-b child-a
  run_validator "$program"
}

case_missing_collision_ledger_fails() {
  local program
  program="$(create_fixture)"
  set_exact_collision "$program"
  run_validator "$program"
}

case_duplicate_collision_record_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records += [(.write_scope_collision_ledger.records[0] | .collision_id = "WSC-002" | .participants |= reverse)]' "$registry"
  run_validator "$program"
}

case_extra_noncollision_fails() {
  local program registry digest
  program="$(create_fixture)"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[0].write_scopes = ["framework/a.md"] | .children[1].write_scopes = ["framework/b.md"]' "$registry"
  append_empty_collision_ledger "$program"
  yq -i '.write_scope_collision_ledger.records = [{"collision_id": "WSC-001", "participants": [{"child_id": "child-a", "write_scope": "framework/a.md", "contribution": "a"}, {"child_id": "child-b", "write_scope": "framework/b.md", "contribution": "b"}], "collision_kind": "exact", "integration_owner_child_id": "child-a", "serialization": {"mechanism": "dependency-order", "ordered_child_ids": ["child-a", "child-b"]}}]' "$registry"
  run_validator "$program"
}

case_unknown_participant_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records[0].participants[1].child_id = "child-c"' "$registry"
  run_validator "$program"
}

case_wrong_relation_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records[0].collision_kind = "directory-prefix"' "$registry"
  run_validator "$program"
}

case_same_child_participants_fail() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records[0].participants[1].child_id = "child-a"' "$registry"
  run_validator "$program"
}

case_stale_collision_digest_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.registry_write_scopes_digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"' "$registry"
  run_validator "$program"
}

case_missing_owner_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i 'del(.write_scope_collision_ledger.records[0].integration_owner_child_id)' "$registry"
  run_validator "$program"
}

case_empty_contribution_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records[0].participants[0].contribution = ""' "$registry"
  run_validator "$program"
}

case_duplicate_order_fails() {
  local program registry
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  yq -i '.write_scope_collision_ledger.records[0].serialization.ordered_child_ids = ["child-a", "child-a"]' "$registry"
  run_validator "$program"
}

case_dependency_order_mismatch_fails() {
  local program
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-b child-a
  run_validator "$program"
}

case_aggregate_serialization_cycle_fails() {
  local program registry digest
  program="$(create_fixture)"
  add_child_c "$program"
  registry="$program/resources/child-packet-index.yml"
  yq -i '.children[].dependencies = [] | .children[].write_scopes = ["framework/shared.md"]' "$registry"
  digest="$(registry_projection_digest "$registry")"
  cat >>"$registry" <<EOF
write_scope_collision_ledger:
  schema_version: octon-program-write-scope-collision-ledger-v1
  registry_write_scopes_digest: "$digest"
  derived_counts: {child_count: 3, scope_entries: 3, unique_paths: 1, exact_records: 3, directory_prefix_records: 0, total_records: 3}
  records:
    - {collision_id: WSC-001, participants: [{child_id: child-a, write_scope: framework/shared.md, contribution: a}, {child_id: child-b, write_scope: framework/shared.md, contribution: b}], collision_kind: exact, integration_owner_child_id: child-a, serialization: {mechanism: exclusive-integration-lock, lock_id: fixture-lock, ordered_child_ids: [child-a, child-b]}}
    - {collision_id: WSC-002, participants: [{child_id: child-a, write_scope: framework/shared.md, contribution: a}, {child_id: child-c, write_scope: framework/shared.md, contribution: c}], collision_kind: exact, integration_owner_child_id: child-a, serialization: {mechanism: exclusive-integration-lock, lock_id: fixture-lock, ordered_child_ids: [child-c, child-a]}}
    - {collision_id: WSC-003, participants: [{child_id: child-b, write_scope: framework/shared.md, contribution: b}, {child_id: child-c, write_scope: framework/shared.md, contribution: c}], collision_kind: exact, integration_owner_child_id: child-b, serialization: {mechanism: exclusive-integration-lock, lock_id: fixture-lock, ordered_child_ids: [child-b, child-c]}}
EOF
  run_validator "$program"
}

case_schema_accepts_collision_ledger() {
  local program registry json
  program="$(create_fixture)"
  set_exact_collision "$program"
  append_single_collision_ledger "$program" child-a framework/shared.md child-b framework/shared.md exact dependency-order child-a child-b
  registry="$program/resources/child-packet-index.yml"
  json="$program/registry.json"
  yq -o=json '.' "$registry" >"$json"
  python3 - "$REGISTRY_SCHEMA" "$json" <<'PY'
import json, jsonschema, sys
with open(sys.argv[1], encoding="utf-8") as handle:
    schema = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    instance = json.load(handle)
jsonschema.Draft202012Validator(schema).validate(instance)
PY
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
assert_success "zero-collision registry accepts an empty ledger" case_zero_collision_empty_ledger_passes
assert_success "exact collision ledger passes" case_exact_collision_passes
assert_success "directory-prefix collision ledger passes" case_directory_prefix_collision_passes
assert_success "lexical sibling does not collide with trailing-slash directory" case_similar_prefix_is_not_collision
assert_success "transitive dependency serialization passes" case_transitive_dependency_collision_passes
assert_success "exclusive peer-lock serialization passes" case_peer_lock_collision_passes
assert_success "canonical schema admits a valid collision ledger" case_schema_accepts_collision_ledger
assert_failure_contains "missing collision ledger fails" "write_scope_collision_ledger is required" case_missing_collision_ledger_fails
assert_failure_contains "duplicate or reversed collision record fails" "duplicate or reversed collision record" case_duplicate_collision_record_fails
assert_failure_contains "extra non-collision fails" "extra non-collision" case_extra_noncollision_fails
assert_failure_contains "unknown collision participant fails" "names unknown child child-c" case_unknown_participant_fails
assert_failure_contains "wrong collision relation fails" "collision_kind mismatch" case_wrong_relation_fails
assert_failure_contains "same-child participants fail" "participants must name distinct children" case_same_child_participants_fail
assert_failure_contains "stale collision projection digest fails" "registry_write_scopes_digest is stale" case_stale_collision_digest_fails
assert_failure_contains "missing integration owner fails" "integration owner must name exactly one participant" case_missing_owner_fails
assert_failure_contains "empty contribution fails" "contribution must be nonempty" case_empty_contribution_fails
assert_failure_contains "duplicate participant order fails" "ordered_child_ids must list both participants exactly once" case_duplicate_order_fails
assert_failure_contains "dependency order mismatch fails" "does not agree with transitive reachability" case_dependency_order_mismatch_fails
assert_failure_contains "aggregate dependency and lock cycle fails" "dependency plus collision serialization graph is cyclic" case_aggregate_serialization_cycle_fails

printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
