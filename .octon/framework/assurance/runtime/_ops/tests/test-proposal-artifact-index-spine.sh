#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh"

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

make_fixture() {
  local fixture_root="$1"
  local child="$fixture_root/.octon/inputs/exploratory/proposals/architecture/fixture-child"
  local parent="$fixture_root/.octon/inputs/exploratory/proposals/architecture/fixture-program"
  mkdir -p \
    "$child/navigation" \
    "$child/architecture" \
    "$child/resources" \
    "$child/support" \
    "$parent/architecture" \
    "$parent/navigation" \
    "$parent/resources"

  write_file "$parent/resources/child-packet-index.yml" \
    'schema_version: fixture-child-packet-index-v1' \
    'children:' \
    '  - child_id: fixture-child' \
    '    path: .octon/inputs/exploratory/proposals/architecture/fixture-child'

  write_file "$parent/proposal.yml" \
    'schema_version: proposal-v1' \
    'proposal_id: fixture-program' \
    'title: Fixture Program' \
    'summary: Fixture parent program.' \
    'proposal_kind: architecture' \
    'promotion_scope: octon-internal' \
    'release_state: pre-1.0' \
    'change_profile: atomic' \
    'promotion_targets:' \
    '  - .octon/framework/assurance/runtime/_ops/scripts/' \
    'status: accepted' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Parent fixture lifecycle.' \
    'related_proposals: []'

  write_file "$parent/architecture-proposal.yml" \
    'schema_version: architecture-proposal-v1' \
    'proposal_id: fixture-program' \
    'title: Fixture Program' \
    'architecture_scope: repo-architecture' \
    'decision_type: boundary-change' \
    'status: accepted'

  write_file "$parent/README.md" '# Fixture Program'
  write_file "$parent/navigation/source-of-truth-map.md" '# Source Map'
  write_file "$parent/navigation/artifact-catalog.md" '# Artifact Catalog'
  write_file "$parent/architecture/target-architecture.md" '# Target'
  write_file "$parent/architecture/implementation-plan.md" '# Plan'
  write_file "$parent/architecture/acceptance-criteria.md" '# Acceptance'

  write_file "$child/proposal.yml" \
    'schema_version: proposal-v1' \
    'proposal_id: fixture-child' \
    'title: Fixture Child' \
    'summary: Fixture proposal child.' \
    'proposal_kind: architecture' \
    'promotion_scope: octon-internal' \
    'release_state: pre-1.0' \
    'change_profile: atomic' \
    'promotion_targets:' \
    '  - .octon/framework/assurance/runtime/_ops/scripts/' \
    'status: accepted' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: Durable outputs stand without proposal authority.' \
    'related_proposals: []' \
    'parent_program: fixture-program' \
    'scope_statement: Fixture scope.' \
    'evidence_requirements:' \
    '  - implementation conformance receipt' \
    'validation_gates:' \
    '  - proposal artifact index schema validation'

  write_file "$child/architecture-proposal.yml" \
    'schema_version: architecture-proposal-v1' \
    'proposal_id: fixture-child' \
    'title: Fixture Child' \
    'architecture_scope: repo-architecture' \
    'decision_type: new-surface' \
    'status: accepted'

  write_file "$child/README.md" '# Fixture Child'
  write_file "$child/navigation/source-of-truth-map.md" '# Source Map'
  write_file "$child/navigation/artifact-catalog.md" '# Artifact Catalog'
  write_file "$child/architecture/target-architecture.md" '# Target'
  write_file "$child/architecture/implementation-plan.md" '# Plan'
  write_file "$child/architecture/acceptance-criteria.md" '# Acceptance'
  write_file "$child/architecture/rollback-posture.md" '# Rollback'
  write_file "$child/resources/repo-placement.yml" 'schema_version: fixture-placement-v1'
  write_file "$child/support/proposal-review.md" \
    '# Proposal Review Receipt' \
    'review_id: fixture-review' \
    'reviewed_at: 2026-06-03T00:00:00Z' \
    'reviewer: fixture' \
    'verdict: accepted' \
    'implementation_prompt_authorized: yes' \
    'reviewed_packet_digest: sha256:fixture' \
    'open_blocking_findings_count: 0'
  write_file "$child/support/implementation-grade-completeness-review.md" \
    '---' \
    'verdict: pass' \
    'unresolved_questions_count: 0' \
    'clarification_required: no' \
    'blockers: []' \
    '---' \
    '# Completeness'
  write_file "$child/support/executable-implementation-prompt.md" '# Executable Prompt'
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  local valid_root="$tmp/valid"
  make_fixture "$valid_root"
  assert_success "generator writes valid compact artifacts" \
    bash "$GENERATOR" --root "$valid_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --write
  local generated_spine="$valid_root/.octon/generated/proposals/artifacts/architecture/fixture-child/proposal-program-spine.yml"
  if python3 - "$generated_spine" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
boundary = json.loads(path.read_text()).get("authority_boundary") or {}
expected_false = [
    "authorizes_dispatch",
    "satisfies_child_gates",
    "authorizes_closeout",
    "authorizes_archive",
    "authorizes_correction",
    "authorizes_implementation",
    "authorizes_generated_publication",
    "replaces_source_evidence",
    "parent_summary_satisfies_child_receipts",
    "retained_evidence_authorizes_execution",
]
missing = [key for key in expected_false if boundary.get(key) is not False]
if boundary.get("diagnostic_only") is not True:
    missing.append("diagnostic_only")
if missing:
    print("missing generated spine boundary fields: " + ", ".join(missing), file=sys.stderr)
    sys.exit(1)
PY
  then
    pass "generated program spine declares diagnostic-only non-authority boundary"
  else
    fail "generated program spine declares diagnostic-only non-authority boundary"
  fi
  assert_success "validator accepts generated compact artifacts" \
    bash "$VALIDATOR" --root "$valid_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  assert_success "generator check accepts fresh generated artifacts" \
    bash "$GENERATOR" --root "$valid_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --check
  local receipt_output
  receipt_output="$(bash "$GENERATOR" --root "$valid_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --check)"
  if grep -Fq 'refresh_receipt:' <<<"$receipt_output" &&
    grep -Fq 'owning_generator: ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"' <<<"$receipt_output" &&
    grep -Fq 'generated_output_authority: "derived-only"' <<<"$receipt_output" &&
    grep -Fq 'source_refs:' <<<"$receipt_output" &&
    grep -Fq 'output_refs:' <<<"$receipt_output"; then
    pass "artifact generator emits digest-backed refresh receipt"
  else
    fail "artifact generator emits digest-backed refresh receipt"
  fi

  local digest_root="$tmp/digest-mismatch"
  make_fixture "$digest_root"
  bash "$GENERATOR" --root "$digest_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --write >/dev/null
  printf '%s\n' 'tampered source' >>"$digest_root/.octon/inputs/exploratory/proposals/architecture/fixture-child/README.md"
  assert_failure "source digest mismatch fails closed" \
    bash "$VALIDATOR" --root "$digest_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child"
  local stale_output stale_rc=0
  stale_output="$(bash "$GENERATOR" --root "$digest_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --check 2>&1)" || stale_rc=$?
  if (( stale_rc != 0 )) &&
    grep -Fq 'refresh_status: "stale-output"' <<<"$stale_output" &&
    grep -Fq 'next_owning_route: "generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/fixture-child --write"' <<<"$stale_output"; then
    pass "artifact generator stale check names next owning route"
  else
    fail "artifact generator stale check names next owning route"
  fi

  local authority_root="$tmp/authority-negative-control"
  make_fixture "$authority_root"
  bash "$GENERATOR" --root "$authority_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --write >/dev/null
  python3 - "$authority_root/.octon/generated/proposals/artifacts/architecture/fixture-child/proposal-program-spine.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["source_refs"].append(".octon/generated/proposals/registry.yml")
data["authority_boundary"]["generated_registry_replaces_manifest"] = True
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  assert_failure "generated registry cannot replace manifest" \
    bash "$VALIDATOR" --root "$authority_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child"

  local handoff_root="$tmp/missing-handoff"
  make_fixture "$handoff_root"
  bash "$GENERATOR" --root "$handoff_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child" --write >/dev/null
  rm "$handoff_root/.octon/generated/proposals/artifacts/architecture/fixture-child/child-handoff-capsule.yml"
  assert_failure "missing child handoff fails when parent program is present" \
    bash "$VALIDATOR" --root "$handoff_root" --proposal ".octon/inputs/exploratory/proposals/architecture/fixture-child"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
