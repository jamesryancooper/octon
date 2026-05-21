#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_FILES=()

cleanup() {
  local file
  for file in "${CLEANUP_FILES[@]}"; do
    [[ -n "$file" ]] && rm -f -- "$file"
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

write_receipt() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cat >"$file"
  printf '%s\n' "$file"
}

run_validator() {
  bash "$VALIDATOR" --receipt "$1" >/dev/null
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_classifier_is_read_only() {
  local output
  output="$(bash "$CLASSIFIER" --root "$ROOT_DIR")"
  grep -Fq "detection_is_deletion_authority: false" <<<"$output"
}

case_closeout_worktree_wrapper_exists() {
  local wrapper="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
  local contract="$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml"
  [[ -f "$wrapper" ]] &&
    grep -Fq 'singular `closeout-change` runs' "$wrapper" &&
    yq -e '.relationship_to_default_work_unit.dirty_worktree_wrapper.decomposition_rule == "partition residue into singular Change closeouts and delegate each coherent unit to closeout-change"' "$contract" >/dev/null
}

case_unspecified_closeout_defaults_to_cleaned() {
  local contract="$ROOT_DIR/.octon/framework/product/contracts/change-closeout-state-machine.yml"
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  yq -e '.target_lifecycle_defaults.unspecified_closeout_request == "cleaned"' "$contract" >/dev/null &&
    yq -e '.target_lifecycle_defaults.explicit_narrower_lifecycle_targets[]? | select(. == "published-branch")' "$contract" >/dev/null &&
    yq -e '.target_lifecycle_defaults.explicit_narrower_route_requests[]? | select(. == "stage-only-escalate")' "$contract" >/dev/null &&
    jq -e '.properties.target_lifecycle_outcome.default == "cleaned"' "$schema" >/dev/null
}

case_valid_completed_receipt_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "valid-stateful",
  "selected_route": "direct-main",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "direct-main-landing",
  "intent": "land a direct-main change",
  "scope": {"summary": "test"},
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "direct-commit",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "not_applicable",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/final-verification"],
    "cleanup_decision_refs": ["evidence://cleanup/not-applicable"],
    "safe_cleanup_evidence_class": "not-applicable",
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
}

case_completed_without_stateful_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "missing-stateful",
  "selected_route": "direct-main",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "direct-main-landing",
  "intent": "bad",
  "scope": {"summary": "test"},
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "direct-commit",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "not_applicable",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_ready_completed_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "ready-overclaim",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "ready",
  "lifecycle_outcome": "ready",
  "outcome_intent": "pr-ready",
  "intent": "bad",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "integration_status": "not_landed",
  "publication_status": "pr-ready",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pr/1"},
  "rollback_handle": {"kind": "manual-instructions", "ref": "feature/pr"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/ready"],
    "cleanup_decision_refs": ["evidence://cleanup/pending"],
    "safe_cleanup_evidence_class": "not-applicable",
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_detection_only_cleanup_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-cleanup",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "bad cleanup",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "remote_branch_ref": "origin/feature/no-pr@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "def0000000000000000000000000000000000000",
    "validated_ref": "def0000000000000000000000000000000000000",
    "required_check_refs": ["route_neutral_closeout_validation@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "route-neutral-main",
    "fast_forward_only": true
  },
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_evidence_refs": ["detected files"],
  "source_branch_cleanup": {"status": "completed", "local_branch": "feature/no-pr", "remote_branch": "origin/feature/no-pr"},
  "validation_evidence_refs": ["validation"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://inventory",
    "residue_classification_ref": "evidence://residue",
    "phase_exit_refs": ["evidence://phase/branch-cleanup"],
    "cleanup_decision_refs": ["evidence://cleanup/detected"],
    "safe_cleanup_evidence_class": "detection-only",
    "hosted_landing_refs": ["evidence://hosted"],
    "branch_cleanup_refs": ["evidence://branch-cleanup"],
    "final_verification_ref": "evidence://final"
  },
  "created_at": "2026-05-21T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

main() {
  assert_success "state-machine validator passes live repo" case_live_repo_passes
  assert_success "residue classifier is read-only" case_classifier_is_read_only
  assert_success "closeout-worktree wrapper exists and decomposes singular changes" case_closeout_worktree_wrapper_exists
  assert_success "unspecified closeout target defaults to cleaned" case_unspecified_closeout_defaults_to_cleaned
  assert_success "valid completed receipt with stateful evidence passes" case_valid_completed_receipt_passes
  assert_success "completed receipt without stateful evidence fails" case_completed_without_stateful_fails
  assert_success "ready PR cannot claim completed closeout" case_ready_completed_fails
  assert_success "detection-only cleanup evidence fails" case_detection_only_cleanup_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
