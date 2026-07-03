#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" && -e "$path" ]] && rm -rf -- "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

write_architecture_packet() {
  local root="$1"
  local id="$2"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/$id"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture" "$proposal_dir/support"

  write_file "$proposal_dir/proposal.yml" \
    'schema_version: proposal-v1' \
    "proposal_id: $id" \
    "title: ${id}" \
    "summary: ${id} fixture." \
    'proposal_kind: architecture' \
    'promotion_scope: octon-internal' \
    'release_state: pre-1.0' \
    'change_profile: atomic' \
    'promotion_targets:' \
    '  - ".octon/framework/assurance/runtime/_ops/scripts/"' \
    'status: accepted' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Fixture lifecycle.' \
    'related_proposals: []' \
    'owner:' \
    '  role: Octon test fixture' \
    'created_date: "2026-07-02"'

  write_file "$proposal_dir/architecture-proposal.yml" \
    'schema_version: architecture-proposal-v1' \
    "proposal_id: $id" \
    "title: ${id}" \
    'architecture_scope: repo-architecture' \
    'decision_type: boundary-change' \
    'status: accepted'
  write_file "$proposal_dir/README.md" "# $id"
  write_file "$proposal_dir/navigation/source-of-truth-map.md" '# Source Map'
  write_file "$proposal_dir/navigation/artifact-catalog.md" '# Artifact Catalog'
  write_file "$proposal_dir/architecture/target-architecture.md" '# Target'
  write_file "$proposal_dir/architecture/implementation-plan.md" '# Plan'
  write_file "$proposal_dir/architecture/acceptance-criteria.md" '# Acceptance'
  write_file "$proposal_dir/support/proposal-review.md" \
    '# Proposal Review' \
    'verdict: accepted' \
    'implementation_prompt_authorized: yes' \
    'open_blocking_findings_count: 0'
  write_file "$proposal_dir/support/implementation-grade-completeness-review.md" \
    '# Implementation-Grade Completeness Review' \
    'verdict: pass' \
    'unresolved_questions_count: 0' \
    'clarification_required: no'
}

snapshot_file_metadata() {
  local path="$1"
  python3 - "$path" <<'PY'
import os
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
for path in sorted(p for p in root.rglob("*") if p.is_file()):
    stat = path.stat()
    print(f"{path.relative_to(root)}\t{stat.st_mtime_ns}\t{stat.st_size}")
PY
}

case_noop_artifact_generation_preserves_existing_bytes() {
  local fixture_root proposal output_dir before after
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-proposal-artifact-compaction.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  write_architecture_packet "$fixture_root" "artifact-noop"
  proposal=".octon/inputs/exploratory/proposals/architecture/artifact-noop"
  output_dir="$fixture_root/.octon/generated/proposals/artifacts/architecture/artifact-noop"

  bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal" --write >/dev/null
  before="$(snapshot_file_metadata "$output_dir")"
  sleep 1
  bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal" --write >/dev/null
  after="$(snapshot_file_metadata "$output_dir")"

  [[ "$after" == "$before" ]]
}

case_changed_packet_generation_does_not_rewrite_unrelated_packet_artifacts() {
  local fixture_root proposal_a proposal_b output_a output_b before_a before_b after_a after_b
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-proposal-artifact-compaction.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  write_architecture_packet "$fixture_root" "artifact-a"
  write_architecture_packet "$fixture_root" "artifact-b"
  proposal_a=".octon/inputs/exploratory/proposals/architecture/artifact-a"
  proposal_b=".octon/inputs/exploratory/proposals/architecture/artifact-b"
  output_a="$fixture_root/.octon/generated/proposals/artifacts/architecture/artifact-a"
  output_b="$fixture_root/.octon/generated/proposals/artifacts/architecture/artifact-b"

  bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal_a" --write >/dev/null
  bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal_b" --write >/dev/null
  before_a="$(snapshot_file_metadata "$output_a")"
  before_b="$(snapshot_file_metadata "$output_b")"
  sleep 1
  printf '\nchanged\n' >>"$fixture_root/$proposal_a/README.md"
  bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal_a" --write >/dev/null
  after_a="$(snapshot_file_metadata "$output_a")"
  after_b="$(snapshot_file_metadata "$output_b")"

  [[ "$after_a" != "$before_a" ]]
  [[ "$after_b" == "$before_b" ]]
}

assert_success \
  "noop artifact generation preserves existing bytes" \
  case_noop_artifact_generation_preserves_existing_bytes
assert_success \
  "changed packet generation does not rewrite unrelated packet artifacts" \
  case_changed_packet_generation_does_not_rewrite_unrelated_packet_artifacts

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
