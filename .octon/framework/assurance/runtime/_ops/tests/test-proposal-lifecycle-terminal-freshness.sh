#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    if [[ -f "$path" ]]; then
      rm -f -- "$path"
    elif [[ -d "$path" ]]; then
      rm -rf -- "$path"
    fi
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

assert_failure() {
  local label="$1"
  shift
  if "$@"; then fail "$label"; else pass "$label"; fi
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
  local parent_program="${3:-}"
  local related_id="${4:-}"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/$id"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture" "$proposal_dir/resources"

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
    '  - .octon/framework/assurance/runtime/_ops/scripts/' \
    'status: accepted' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Fixture lifecycle.' \
    'related_proposals: []' \
    'owner:' \
    '  role: Octon test fixture' \
    'created_date: "2026-06-12"'

  if [[ -n "$parent_program" ]]; then
    yq -i ".parent_program = \"$parent_program\"" "$proposal_dir/proposal.yml"
  fi
  if [[ -n "$related_id" ]]; then
    yq -i ".related_proposals = [\"$related_id\"]" "$proposal_dir/proposal.yml"
  fi

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
}

make_targeted_fixture() {
  local root="$1"
  local target_rel=".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child"
  write_architecture_packet "$root" "targeted-terminal-nested"
  write_architecture_packet "$root" "targeted-terminal-related" "" "targeted-terminal-nested"
  write_architecture_packet "$root" "targeted-terminal-program"
  write_architecture_packet "$root" "targeted-terminal-child" "targeted-terminal-program" "targeted-terminal-related"

  write_file "$root/.octon/inputs/exploratory/proposals/architecture/targeted-terminal-program/resources/child-packet-index.yml" \
    'schema_version: fixture-child-packet-index-v1' \
    'children:' \
    '  - child_id: targeted-terminal-child' \
    "    path: $target_rel"

  bash "$GENERATOR" --root "$root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-program" --write >/dev/null
  bash "$GENERATOR" --root "$root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-related" --write >/dev/null
  bash "$GENERATOR" --root "$root" --proposal "$target_rel" --write >/dev/null
}

case_targeted_terminal_freshness_validates_scoped_proposal_and_dependencies() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-targeted-freshness.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  make_targeted_fixture "$fixture_root"
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted
}

case_targeted_terminal_freshness_fails_on_stale_generated_artifact() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-targeted-freshness.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  make_targeted_fixture "$fixture_root"
  printf '%s\n' 'stale mutation' >>"$fixture_root/.octon/inputs/exploratory/proposals/architecture/targeted-terminal-child/README.md"
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted
}

case_targeted_terminal_freshness_rejects_parent_only_artifacts() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-targeted-freshness.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  make_targeted_fixture "$fixture_root"
  rm -rf "$fixture_root/.octon/generated/proposals/artifacts/architecture/targeted-terminal-child"
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted
}

case_targeted_terminal_freshness_rejects_generated_authority_widening() {
  local fixture_root artifact
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-targeted-freshness.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  make_targeted_fixture "$fixture_root"
  artifact="$fixture_root/.octon/generated/proposals/artifacts/architecture/targeted-terminal-child/proposal-artifact-index.yml"
  python3 - "$artifact" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["authority_boundary"]["generated_registry_replaces_manifest"] = True
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted
}

case_targeted_terminal_freshness_does_not_replace_full_registry_gate() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-targeted-freshness.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  make_targeted_fixture "$fixture_root"
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted >/dev/null
  "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/targeted-terminal-child" --targeted --run-registry-check
}

assert_success \
  "targeted_terminal_freshness_validates_scoped_proposal_and_dependencies" \
  case_targeted_terminal_freshness_validates_scoped_proposal_and_dependencies
assert_failure \
  "targeted_terminal_freshness_fails_on_stale_generated_artifact" \
  case_targeted_terminal_freshness_fails_on_stale_generated_artifact
assert_failure \
  "targeted_terminal_freshness_parent_summary_cannot_satisfy_child_evidence" \
  case_targeted_terminal_freshness_rejects_parent_only_artifacts
assert_failure \
  "targeted_terminal_freshness_generated_artifacts_remain_derived_only" \
  case_targeted_terminal_freshness_rejects_generated_authority_widening
assert_failure \
  "targeted_terminal_freshness_does_not_replace_full_registry_gate" \
  case_targeted_terminal_freshness_does_not_replace_full_registry_gate

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
