#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-repo-authority-write-scope-index.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-authority-write-scope-index.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

write_common_sources() {
  local root="$1"

  write_file "$root/.octon/framework/cognition/_meta/architecture/contract-registry.yml" \
    'schema_version: architecture-contract-registry-v2' \
    'class_roots:' \
    '  framework:' \
    '    root: .octon/framework/' \
    '    authority_class: portable-authored-authority' \
    '    authored_authority: true' \
    '  instance:' \
    '    root: .octon/instance/' \
    '    authority_class: repo-specific-authored-authority' \
    '    authored_authority: true' \
    'steady_state_surface_classes:' \
    '  authored-authority:' \
    '    canonical_roots: [.octon/framework/**, .octon/instance/**]' \
    '    authority_posture: durable-authored-authority'

  write_file "$root/.octon/framework/engine/runtime/spec/repo-authority-write-scope-index-v1.md" '# Spec'
  write_file "$root/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md" '# Context Pack Builder'
  write_file "$root/.octon/framework/engine/runtime/spec/repo-authority-graph-v1.schema.json" '{}'
  write_file "$root/.octon/framework/engine/runtime/spec/promotion-target-index-v1.schema.json" '{}'
  write_file "$root/.octon/framework/engine/runtime/spec/write-scope-index-v1.schema.json" '{}'
  write_file "$root/.octon/framework/constitution/precedence/normative.yml" 'schema_version: fixture'
  write_file "$root/.octon/framework/constitution/precedence/epistemic.yml" 'schema_version: fixture'
  write_file "$root/.octon/framework/constitution/obligations/fail-closed.yml" 'schema_version: fixture'
  write_file "$root/.octon/framework/constitution/obligations/evidence.yml" 'schema_version: fixture'
}

write_fixture_proposals() {
  local root="$1"
  local proposal_root=".octon/inputs/exploratory/proposals/architecture"
  local target_child_id="token-efficiency-repo-authority-write-scope-index"
  local parent="$root/$proposal_root/token-efficient-proposal-program-controller"
  local child="$root/$proposal_root/$target_child_id"
  local generated="$root/$proposal_root/generated-target-fixture"
  local child_path="$proposal_root/$target_child_id"

  write_file "$parent/resources/child-packet-index.yml" \
    'schema_version: octon-proposal-program-child-registry-v2' \
    'program_id: token-efficient-proposal-program-controller' \
    'children:' \
    "  - child_id: $target_child_id" \
    "    path: $child_path" \
    '    dependencies: []' \
    '    phase_id: phase-5' \
    '    group_id: repo-graph' \
    '    write_scopes:' \
    '      - .octon/framework/cognition/_meta/architecture/' \
    '      - .octon/framework/engine/runtime/spec/' \
    '      - .octon/framework/assurance/runtime/_ops/scripts/' \
    '      - .octon/framework/assurance/runtime/_ops/tests/' \
    '    model_route_default: deterministic graph generation' \
    '    token_ceiling: 6k'

  write_file "$child/proposal.yml" \
    'schema_version: proposal-v1' \
    'proposal_id: token-efficiency-repo-authority-write-scope-index' \
    'title: Repo Authority Graph And Write Scope Index' \
    'summary: Fixture.' \
    'proposal_kind: architecture' \
    'promotion_scope: octon-internal' \
    'status: accepted' \
    'promotion_targets:' \
    '  - .octon/framework/cognition/_meta/architecture/' \
    '  - .octon/framework/engine/runtime/spec/' \
    '  - .octon/framework/assurance/runtime/_ops/scripts/' \
    '  - .octon/framework/assurance/runtime/_ops/tests/' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Durable outputs stand without proposal authority.'

  write_file "$generated/proposal.yml" \
    'schema_version: proposal-v1' \
    'proposal_id: generated-target-fixture' \
    'title: Generated Target Fixture' \
    'summary: Fixture.' \
    'proposal_kind: architecture' \
    'promotion_scope: octon-internal' \
    'status: accepted' \
    'promotion_targets:' \
    '  - .octon/generated/effective/extensions/' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Generated output remains derived-only.'
}

make_fixture() {
  local root="$1"
  write_common_sources "$root"
  write_fixture_proposals "$root"
}

case_valid_bundle_passes() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" RETURN
  make_fixture "$tmp"
  bash "$GENERATOR" --root "$tmp" --write
  bash "$VALIDATOR" --root "$tmp"
  bash "$GENERATOR" --root "$tmp" --check
}

case_source_digest_mismatch_fails() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" RETURN
  make_fixture "$tmp"
  bash "$GENERATOR" --root "$tmp" --write >/dev/null
  printf '%s\n' 'drift' >>"$tmp/.octon/framework/cognition/_meta/architecture/contract-registry.yml"
  bash "$VALIDATOR" --root "$tmp"
}

case_generated_target_authority_misclassification_fails() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" RETURN
  make_fixture "$tmp"
  bash "$GENERATOR" --root "$tmp" --write >/dev/null
  python3 - "$tmp/.octon/generated/proposals/repo-authority/promotion-target-index.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
for proposal in data["proposals"]:
    if proposal["proposal_id"] == "generated-target-fixture":
        proposal["targets"][0]["authored_authority"] = True
        proposal["targets"][0]["authority_posture"] = "portable-authored-authority"
        proposal["targets"][0]["risk_flags"] = []
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  bash "$VALIDATOR" --root "$tmp"
}

case_missing_target_child_fails() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" RETURN
  make_fixture "$tmp"
  bash "$GENERATOR" --root "$tmp" --write >/dev/null
  python3 - "$tmp/.octon/generated/proposals/repo-authority/write-scope-index.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["children"] = []
data["child_count"] = 0
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  bash "$VALIDATOR" --root "$tmp"
}

main() {
  assert_success "valid repo authority/write-scope bundle passes" case_valid_bundle_passes
  assert_failure "source digest mismatch fails closed" case_source_digest_mismatch_fails
  assert_failure "generated target authority misclassification fails" case_generated_target_authority_misclassification_fails
  assert_failure "missing target child write-scope entry fails" case_missing_target_child_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
