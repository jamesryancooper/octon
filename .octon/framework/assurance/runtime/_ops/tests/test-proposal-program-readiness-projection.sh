#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh"
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

sha() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

review_digest() {
  local root="$1" packet="$2"
  OCTON_ROOT_DIR="$root" bash "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" \
    --package "$packet" --print-digest
}

make_repo() {
  local root="$1"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  cp "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validator-recovery-diagnostics.sh" "$root/.octon/framework/assurance/runtime/_ops/scripts/"
  chmod +x "$root"/.octon/framework/assurance/runtime/_ops/scripts/*.sh
}

write_parent() {
  local root="$1"
  local parent=".octon/inputs/exploratory/proposals/architecture/program-fixture"
  mkdir -p "$root/$parent/resources" "$root/$parent/support" "$root/$parent/navigation" "$root/$parent/architecture"
  write_file "$root/$parent/proposal.yml" \
    'schema_version: "proposal-v1"' \
    'proposal_id: "program-fixture"' \
    'title: "Program Fixture"' \
    'summary: "Program fixture."' \
    'proposal_kind: "architecture"' \
    'promotion_scope: "octon-internal"' \
    'promotion_targets:' \
    '  - ".octon/framework/program-fixture.md"' \
    'status: "accepted"' \
    'change_profile: "atomic"' \
    'readiness_projection:' \
    '  publication_freshness_refs:' \
    '    - ref: ".octon/state/evidence/validation/publication/freshness.yml"' \
    "      sha256: \"$(sha "$root/.octon/state/evidence/validation/publication/freshness.yml")\"" \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: "Program implementation orchestration."'
  write_file "$root/$parent/README.md" "# Program Fixture"
  write_file "$root/$parent/navigation/artifact-catalog.md" "# Artifact Catalog"
  write_file "$root/$parent/navigation/source-of-truth-map.md" "# Source Of Truth"
  write_file "$root/$parent/architecture/target-architecture.md" "# Target Architecture" "task-specific harness envelope"
  write_file "$root/$parent/architecture/implementation-plan.md" "# Implementation Plan"
  write_file "$root/$parent/architecture/acceptance-criteria.md" "# Acceptance Criteria"
  write_file "$root/$parent/architecture/child-packet-contract.md" "# Child Packet Contract" "task-specific harness envelope"
  write_file "$root/$parent/architecture/packet-sequence.md" "# Packet Sequence" "- child-one"
  write_file "$root/$parent/architecture/program-closeout-plan.md" "# Program Closeout Plan"
  write_file "$root/$parent/resources/child-packet-index.md" "# Child Packet Index" "- child-one"
}

write_parent_review() {
  local root="$1"
  local parent=".octon/inputs/exploratory/proposals/architecture/program-fixture"
  write_file "$root/$parent/support/proposal-review.md" \
    "# Proposal Review Receipt" \
    "review_id: program-review" \
    "reviewed_at: 2026-06-11T00:00:00Z" \
    "reviewer: test" \
    "verdict: accepted" \
    "implementation_prompt_authorized: yes" \
    "reviewed_packet_digest: $(review_digest "$root" "$parent")" \
    "open_blocking_findings_count: 0" \
    "## Approved Promotion Targets" \
    "- .octon/framework/program-fixture.md" \
    "## Exclusions" \
    "None." \
    "## Blocking Findings" \
    "None." \
    "## Nonblocking Findings" \
    "None." \
    "## Final Route Recommendation" \
    "Proceed."
}

write_child() {
  local root="$1" status="${2:-implemented}"
  local child=".octon/inputs/exploratory/proposals/architecture/child-one"
  mkdir -p "$root/$child/support" "$root/$child/navigation" "$root/$child/architecture"
  write_file "$root/$child/proposal.yml" \
    'schema_version: "proposal-v1"' \
    'proposal_id: "child-one"' \
    'title: "Child One"' \
    'summary: "Child fixture."' \
    'proposal_kind: "architecture"' \
    'promotion_scope: "octon-internal"' \
    'promotion_targets:' \
    '  - ".octon/framework/child-one.md"' \
    "status: \"$status\"" \
    'change_profile: "atomic"' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: "Promote and archive."'
  write_file "$root/$child/architecture-proposal.yml" \
    'schema_version: "architecture-proposal-v1"' \
    'architecture_scope: "fixture"' \
    'decision_type: "new-surface"'
  write_file "$root/$child/README.md" "# Child One"
  write_file "$root/$child/navigation/artifact-catalog.md" "# Artifact Catalog"
  write_file "$root/$child/navigation/source-of-truth-map.md" "# Source Of Truth"
  write_file "$root/$child/architecture/target-architecture.md" "# Target Architecture" "task-specific harness envelope"
  write_file "$root/$child/architecture/implementation-plan.md" "# Implementation Plan"
  write_file "$root/$child/architecture/acceptance-criteria.md" "# Acceptance Criteria"
  write_file "$root/$child/support/implementation-grade-completeness-review.md" \
    "# Implementation-Grade Completeness Review" \
    "verdict: pass" \
    "unresolved_questions_count: 0" \
    "clarification_required: no" \
    "## Blockers" \
    "None." \
    "## Assumptions" \
    "None." \
    "## Promotion Target Coverage" \
    ".octon/framework/child-one.md" \
    "## Affected Artifact Coverage" \
    "task-specific harness envelope" \
    "## Validator Coverage" \
    "Complete." \
    "## Implementation Prompt Readiness" \
    "Ready." \
    "## Exclusions" \
    "None." \
    "## Final Route Recommendation" \
    "Proceed."
  write_file "$root/$child/support/executable-implementation-prompt.md" \
    "# Executable Implementation Prompt" \
    "validation commands" \
    "retained evidence" \
    "rollback" \
    "executable implementation prompt requires conformance receipt" \
    "executable implementation prompt requires drift/churn receipt" \
    "executable implementation prompt includes closeout refusal criteria" \
    ".octon/framework/child-one.md"
  write_file "$root/$child/support/proposal-review.md" \
    "# Proposal Review Receipt" \
    "review_id: child-review" \
    "reviewed_at: 2026-06-11T00:00:00Z" \
    "reviewer: test" \
    "verdict: accepted" \
    "implementation_prompt_authorized: yes" \
    "reviewed_packet_digest: $(review_digest "$root" "$child")" \
    "open_blocking_findings_count: 0" \
    "## Approved Promotion Targets" \
    "- .octon/framework/child-one.md" \
    "## Exclusions" \
    "None." \
    "## Blocking Findings" \
    "None." \
    "## Nonblocking Findings" \
    "None." \
    "## Final Route Recommendation" \
    "Proceed."
  write_file "$root/$child/support/implementation-run.md" "verdict: pass"
  write_file "$root/$child/support/implementation-conformance-review.md" "verdict: pass"
  write_file "$root/$child/support/post-implementation-drift-churn-review.md" "verdict: pass"
  write_file "$root/$child/support/proposal-closeout.md" "verdict: pass"
}

write_registry() {
  local root="$1"
  local parent=".octon/inputs/exploratory/proposals/architecture/program-fixture"
  write_file "$root/$parent/resources/child-packet-index.yml" \
    'schema_version: "octon-proposal-program-child-registry-v2"' \
    'execution_mode: "sequential"' \
    'default_child_lifecycle_id: "proposal-packet"' \
    'children:' \
    '  - child_id: "child-one"' \
    '    path: ".octon/inputs/exploratory/proposals/architecture/child-one"' \
    '    dependency_gate: "terminal"' \
    '    recovery_profile: "default"' \
    '    rollback_posture: "compensating"' \
    '    required_metadata:' \
    '      - "change_profile"' \
    '    readiness_requirements:' \
    '      - requirement_id: "fixture"' \
    '        summary: "Fixture requirement."' \
    '        review_must_mention:' \
    '          - "task-specific harness envelope"' \
    '    evidence_index_refs:' \
    '      - ".octon/state/evidence/runs/test-run/retained-run-evidence-index.yml"'
}

write_evidence_index() {
  local root="$1"
  mkdir -p "$root/.octon/state/control/execution/runs/test-run" \
    "$root/.octon/state/evidence/runs/test-run/validation" \
    "$root/.octon/state/evidence/runs/test-run/rollback" \
    "$root/.octon/state/evidence/validation/publication"
  write_file "$root/.octon/state/control/execution/runs/test-run/runtime-state.yml" "status: completed"
  write_file "$root/.octon/state/evidence/runs/test-run/validation/result.yml" "validation: pass"
  write_file "$root/.octon/state/evidence/runs/test-run/rollback/rollback.md" "rollback: fixture"
  write_file "$root/.octon/state/evidence/validation/publication/freshness.yml" "freshness: pass"
  local runtime_ref=".octon/state/control/execution/runs/test-run/runtime-state.yml"
  local validation_ref=".octon/state/evidence/runs/test-run/validation/result.yml"
  local rollback_ref=".octon/state/evidence/runs/test-run/rollback/rollback.md"
  write_file "$root/.octon/state/evidence/runs/test-run/retained-run-evidence-index.yml" \
    'schema_version: "retained-run-evidence-index-v1"' \
    'subject:' \
    '  run_id: "test-run"' \
    '  lifecycle_kind: "proposal-packet"' \
    '  terminal_status: "archived"' \
    'producer: "test"' \
    'generated_at: "2026-06-11T00:00:00Z"' \
    'evidence_posture:' \
    '  purpose: "discovery-and-replay-aid"' \
    '  freshness_state: "digest-bound"' \
    '  direct_control_refs_present: true' \
    'control_refs:' \
    "  - ref: \"$runtime_ref\"" \
    '    role: "runtime-state"' \
    '    ref_class: "control"' \
    "    sha256: \"$(sha "$root/$runtime_ref")\"" \
    '    authority_use: "control-truth"' \
    'substitute_workflow_refs: []' \
    'terminal_evidence_refs:' \
    '  validation:' \
    "    - ref: \"$validation_ref\"" \
    '      role: "validation-result"' \
    '      ref_class: "retained-evidence"' \
    "      sha256: \"$(sha "$root/$validation_ref")\"" \
    '      authority_use: "evidence-only"' \
    '  rollback:' \
    "    - ref: \"$rollback_ref\"" \
    '      role: "rollback-posture"' \
    '      ref_class: "retained-evidence"' \
    "      sha256: \"$(sha "$root/$rollback_ref")\"" \
    '      authority_use: "evidence-only"' \
    'indexed_refs:' \
    "  - ref: \"$runtime_ref\"" \
    '    role: "runtime-state"' \
    '    ref_class: "control"' \
    "    sha256: \"$(sha "$root/$runtime_ref")\"" \
    '    authority_use: "control-truth"' \
    "  - ref: \"$validation_ref\"" \
    '    role: "validation-result"' \
    '    ref_class: "retained-evidence"' \
    "    sha256: \"$(sha "$root/$validation_ref")\"" \
    '    authority_use: "evidence-only"' \
    "  - ref: \"$rollback_ref\"" \
    '    role: "rollback-posture"' \
    '    ref_class: "retained-evidence"' \
    "    sha256: \"$(sha "$root/$rollback_ref")\"" \
    '    authority_use: "evidence-only"' \
    'freshness:' \
    '  mode: "digest-bound"' \
    '  source_digest_required: true' \
    '  stale_behavior: "fail-closed"' \
    'authority_boundary:' \
    '  replaces_source_evidence: false' \
    '  authorizes_execution: false' \
    '  satisfies_lifecycle_transition_authority: false' \
    '  satisfies_child_receipts: false' \
    '  proposal_input_authority: "non-authoritative"' \
    '  generated_output_authority: "derived-only"' \
    '  raw_evidence_retained: true' \
    'failure_behavior:' \
    '  - "fail-closed-on-source-missing"' \
    '  - "fail-closed-on-source-digest-mismatch"' \
    '  - "fail-closed-on-authority-boundary-conflict"'
}

write_projection() {
  local root="$1"
  write_file "$root/projection.yml" \
    'schema_version: "proposal-program-readiness-projection-v1"' \
    'authority_boundary:' \
    '  diagnostic_only: true' \
    '  authorizes_dispatch: false' \
    '  satisfies_child_gates: false' \
    '  authorizes_closeout: false' \
    '  authorizes_archive: false' \
    '  authorizes_correction: false' \
    '  authorizes_implementation: false' \
    '  authorizes_generated_publication: false' \
    '  replaces_source_evidence: false' \
    '  generated_output_authority: "derived-only"' \
    '  proposal_input_authority: "non-authoritative"'
}

make_fixture() {
  local root="$1"
  make_repo "$root"
  write_evidence_index "$root"
  write_parent "$root"
  write_child "$root" implemented
  write_registry "$root"
  write_parent_review "$root"
  write_projection "$root"
}

archive_fixture() {
  local root="$1"
  local active_parent=".octon/inputs/exploratory/proposals/architecture/program-fixture"
  local archived_parent=".octon/inputs/exploratory/proposals/.archive/architecture/program-fixture"
  local active_child=".octon/inputs/exploratory/proposals/architecture/child-one"
  local archived_child=".octon/inputs/exploratory/proposals/.archive/architecture/child-one"
  mkdir -p "$root/.octon/inputs/exploratory/proposals/.archive/architecture" "$root/.octon/framework"
  write_file "$root/.octon/framework/program-fixture.md" "program fixture target"
  write_file "$root/.octon/framework/child-one.md" "child fixture target"
  mv "$root/$active_child" "$root/$archived_child"
  yq -i '.status = "archived" | .archive = {"archived_at": "2026-06-11", "archived_from_status": "implemented", "disposition": "implemented", "original_path": ".octon/inputs/exploratory/proposals/architecture/child-one", "promotion_evidence": [".octon/framework/child-one.md"]}' "$root/$archived_child/proposal.yml"
  mv "$root/$active_parent" "$root/$archived_parent"
  yq -i '.status = "archived" | .archive = {"archived_at": "2026-06-11", "archived_from_status": "implemented", "disposition": "implemented", "original_path": ".octon/inputs/exploratory/proposals/architecture/program-fixture", "promotion_evidence": [".octon/framework/program-fixture.md"]}' "$root/$archived_parent/proposal.yml"
  yq -i 'del(.children[].evidence_index_refs)' "$root/$archived_parent/resources/child-packet-index.yml"
}

main() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/proposal-program-projection.XXXXXX")"
  trap "rm -rf '$tmp'" EXIT

  local ok_root="$tmp/ok"
  make_fixture "$ok_root"
  assert_success "all-clear readiness projection passes" \
    bash "$VALIDATOR" --root "$ok_root" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local archived_root="$tmp/archived"
  make_fixture "$archived_root"
  archive_fixture "$archived_root"
  assert_success "archived readiness projection resolves archived child paths" \
    bash "$VALIDATOR" --root "$archived_root" --package .octon/inputs/exploratory/proposals/.archive/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local stale_review="$tmp/stale-review"
  make_fixture "$stale_review"
  printf '\nstale: true\n' >>"$stale_review/.octon/inputs/exploratory/proposals/architecture/child-one/architecture/target-architecture.md"
  assert_failure "stale proposal review digest fails" \
    bash "$VALIDATOR" --root "$stale_review" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local missing_readiness="$tmp/missing-readiness"
  make_fixture "$missing_readiness"
  rm "$missing_readiness/.octon/inputs/exploratory/proposals/architecture/child-one/support/implementation-grade-completeness-review.md"
  assert_failure "missing implementation-readiness receipt fails" \
    bash "$VALIDATOR" --root "$missing_readiness" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local missing_archive="$tmp/missing-archive"
  make_fixture "$missing_archive"
  rm "$missing_archive/.octon/inputs/exploratory/proposals/architecture/child-one/support/proposal-closeout.md"
  assert_failure "missing closeout/archive readiness evidence fails" \
    bash "$VALIDATOR" --root "$missing_archive" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local publication_drift="$tmp/publication-drift"
  make_fixture "$publication_drift"
  printf 'drift: true\n' >>"$publication_drift/.octon/state/evidence/validation/publication/freshness.yml"
  assert_failure "generated/publication freshness drift fails" \
    bash "$VALIDATOR" --root "$publication_drift" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local missing_index="$tmp/missing-index"
  make_fixture "$missing_index"
  rm "$missing_index/.octon/state/evidence/runs/test-run/retained-run-evidence-index.yml"
  assert_failure "missing evidence-index availability fails" \
    bash "$VALIDATOR" --root "$missing_index" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local unresolved_dependency="$tmp/unresolved-dependency"
  make_fixture "$unresolved_dependency"
  yq -i '.children[0].predecessor_constraints = [{"predecessor_child_id": "missing-child", "constraint": "must exist"}]' "$unresolved_dependency/.octon/inputs/exploratory/proposals/architecture/program-fixture/resources/child-packet-index.yml"
  assert_failure "child dependency gap fails" \
    bash "$VALIDATOR" --root "$unresolved_dependency" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  local authority="$tmp/authority"
  make_fixture "$authority"
  yq -i '.authority_boundary.authorizes_dispatch = true' "$authority/projection.yml"
  assert_failure "projection dispatch authority claim fails" \
    bash "$VALIDATOR" --root "$authority" --package .octon/inputs/exploratory/proposals/architecture/program-fixture --projection projection.yml --require-terminal-evidence

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
