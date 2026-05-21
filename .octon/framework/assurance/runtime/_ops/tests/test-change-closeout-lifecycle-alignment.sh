#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
EXAMPLE_DIR="$ROOT_DIR/.octon/framework/product/contracts/examples/change-receipts"

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

copy_example_receipt() {
  local name="$1"
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cp "$EXAMPLE_DIR/$name" "$file"
  printf '%s\n' "$file"
}

rewrite_json_file() {
  local file="$1"
  local filter="$2"
  local tmp
  tmp="$(mktemp)"
  jq "$filter" "$file" >"$tmp"
  mv "$tmp" "$file"
}

attach_valid_landing_authorization() {
  local receipt="$1"
  local auth tmp
  auth="$(mktemp)"
  CLEANUP_FILES+=("$auth")
  jq '{
    schema_version: "branch-landing-authorization-v1",
    authorization_id: ("fixture-" + .change_id),
    authorization_result: "approved",
    selected_route: "branch-no-pr",
    target_lifecycle_outcome: .target_lifecycle_outcome,
    remote: .hosted_landing.remote,
    target_branch: .hosted_landing.target_branch,
    source_branch: .hosted_landing.source_branch,
    source_ref: .hosted_landing.source_ref,
    remote_source_ref: .hosted_landing.source_ref,
    target_pre_ref: .hosted_landing.target_pre_ref,
    provider_ruleset_ref: .hosted_landing.provider_ruleset_ref,
    no_pr_required: true,
    preflight_status: "passed",
    required_check_refs: .hosted_landing.required_check_refs,
    allow_empty_check_set: false,
    rollback_handle: ((.rollback_handle.kind // "rollback") + ":" + (.rollback_handle.ref // .hosted_landing.source_ref)),
    host_controls_not_bypassed: true,
    runtime_safety_boundary: "Octon authorization is required before hosted mutation, but it does not bypass platform, sandbox, or host safety controls.",
    created_at: .created_at
  }' "$receipt" >"$auth"
  tmp="$(mktemp)"
  jq --arg auth "$auth" '.landing_authorization_ref = $auth' "$receipt" >"$tmp"
  mv "$tmp" "$receipt"
  printf '%s\n' "$auth"
}

run_validator() {
  bash "$VALIDATOR" --receipt "$1" >/dev/null
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_valid_branch_pr_ready_example_passes() {
  run_validator "$EXAMPLE_DIR/valid-branch-pr-ready.json"
}

case_valid_direct_main_landed_example_passes() {
  run_validator "$EXAMPLE_DIR/valid-direct-main-landed.json"
}

case_valid_branch_no_pr_branch_local_example_passes() {
  run_validator "$EXAMPLE_DIR/valid-branch-no-pr-branch-local-complete.json"
}

case_valid_branch_no_pr_published_branch_example_passes() {
  run_validator "$EXAMPLE_DIR/valid-branch-no-pr-published-branch.json"
}

case_schema_defaults_target_to_cleaned() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  jq -e '.properties.target_lifecycle_outcome.default == "cleaned"' "$schema" >/dev/null &&
    yq -e '.closeout_defaults.target_lifecycle_outcome.unspecified_closeout_request == "cleaned"' "$policy" >/dev/null &&
    yq -e '.closeout_defaults.target_lifecycle_outcome.explicit_narrower_lifecycle_outcomes[]? | select(. == "published-branch")' "$policy" >/dev/null &&
    yq -e '.closeout_defaults.target_lifecycle_outcome.explicit_narrower_route_requests[]? | select(. == "stage-only-escalate")' "$policy" >/dev/null
}

case_invalid_draft_pr_full_closeout_example_fails() {
  ! run_validator "$EXAMPLE_DIR/invalid-draft-pr-claimed-full-closeout.json"
}

case_invalid_pushed_only_landed_example_fails() {
  ! run_validator "$EXAMPLE_DIR/invalid-pushed-only-branch-claimed-landed.json"
}

case_invalid_published_branch_completed_closeout_example_fails() {
  ! run_validator "$EXAMPLE_DIR/invalid-published-branch-completed-closeout.json"
}

case_invalid_stale_remote_branch_ref_example_fails() {
  ! run_validator "$EXAMPLE_DIR/invalid-stale-remote-branch-ref.json"
}

case_no_pr_landed_receipt_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "change-1",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "land branch without PR",
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
    "required_check_refs": ["ci@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "route-neutral-main",
    "push_refspec": "def0000000000000000000000000000000000000:refs/heads/main",
    "fast_forward_only": true
  },
  "landing_evaluation": {
    "status": "succeeded",
    "provider_ruleset_ref": "route-neutral-main",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_ref": "origin/main@def0000000000000000000000000000000000000",
    "evidence_refs": ["validator passed"]
  },
  "source_branch_integration": {
    "source_branch_ref": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "integrated": true,
    "method": "fast-forward",
    "evidence_refs": ["origin/main contains feature/no-pr at def0000000000000000000000000000000000000"]
  },
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true,
    "origin_fetch_evidence_ref": "git fetch origin after landing",
    "local_main_sync_evidence_ref": "git switch main && git merge --ff-only origin/main",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["cleanup deferred until operator leaves worktree"],
  "source_branch_cleanup": {
    "status": "deferred",
    "local_branch": "feature/no-pr",
    "remote_branch": "origin/feature/no-pr",
    "blocker_reason": "cleanup deferred until operator leaves worktree",
    "evidence_refs": ["cleanup deferred until operator leaves worktree"]
  },
  "validation_evidence_refs": ["validator passed"],
  "review_waiver_refs": ["solo maintainer no-PR route"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def"},
  "stateful_closeout": {
    "state_machine_version": "change-closeout-state-machine-v1",
    "initial_inventory_ref": "evidence://initial",
    "residue_classification_ref": "evidence://classification",
    "phase_exit_refs": ["evidence://phase"],
    "cleanup_decision_refs": ["evidence://cleanup"],
    "safe_cleanup_evidence_class": "origin-main-containment",
    "hosted_landing_refs": ["evidence://hosted-landing"],
    "branch_cleanup_refs": ["evidence://branch-cleanup"],
    "final_verification_ref": "evidence://final"
  },
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  attach_valid_landing_authorization "$receipt" >/dev/null
  run_validator "$receipt"
}

case_branch_pr_preserved_receipt_passes_without_pr_metadata() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "change-pr-preserved",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "preserve branch-pr state before PR creation",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "review_waiver_refs": ["PR route selected but PR publication not reached"],
  "durable_history": {"kind": "branch", "ref": "feature/pr", "branch": "feature/pr"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
}

case_checkpoint_cannot_claim_landed() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-checkpoint",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "bad landing",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/checkpoint",
  "target_branch_ref": "main@abc",
  "landed_ref": "main@def",
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "checkpoint", "ref": "checkpoint-1", "branch": "feature/checkpoint"},
  "rollback_handle": {"kind": "checkpoint-restore", "ref": "checkpoint-1"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_local_commit_needs_landed_ref() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-branch-local",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "bad branch local",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/local",
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "commit", "ref": "abc", "branch": "feature/local"},
  "rollback_handle": {"kind": "revert-commit", "ref": "abc"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_no_pr_rejects_pr_metadata() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-metadata",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "published-branch",
  "lifecycle_outcome": "published-branch",
  "outcome_intent": "handoff-only",
  "intent": "bad pr metadata",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pr/1"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/no-pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_no_pr_rejects_pr_lifecycle_outcome() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-no-pr-ready",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "ready",
  "lifecycle_outcome": "ready",
  "outcome_intent": "pr-ready",
  "intent": "bad no-pr lifecycle",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/no-pr", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/no-pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_rejects_branch_only_lifecycle_outcome() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-published-branch",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "published-branch",
  "lifecycle_outcome": "published-branch",
  "outcome_intent": "handoff-only",
  "intent": "bad pr lifecycle",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "remote_branch_ref": "origin/feature/pr",
  "integration_status": "not_landed",
  "publication_status": "pushed-branch",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/pr", "branch": "feature/pr"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_draft_not_full_closeout() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-draft",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "published",
  "lifecycle_outcome": "published",
  "outcome_intent": "pr-publication",
  "intent": "bad pr closeout",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "integration_status": "not_landed",
  "publication_status": "pr-opened",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pr/1"},
  "rollback_handle": {"kind": "manual-instructions", "ref": "feature/pr"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_cleanup_claim_requires_evidence() {
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
  "remote_branch_ref": "origin/feature/no-pr",
  "landed_ref": "def0000000000000000000000000000000000000",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "def0000000000000000000000000000000000000",
    "validated_ref": "def0000000000000000000000000000000000000",
    "required_check_refs": ["ci@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "route-neutral-main",
    "push_refspec": "def0000000000000000000000000000000000000:refs/heads/main",
    "fast_forward_only": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "commit", "ref": "abc", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_cleaned_pending_cleanup_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.lifecycle_outcome = "cleaned" | .cleanup_status = "pending" | del(.cleanup_evidence_refs)'
  ! run_validator "$receipt"
}

case_landed_completed_pending_cleanup_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.lifecycle_outcome = "landed" | .cleanup_status = "pending" | .closeout_outcome = "completed" | del(.cleanup_evidence_refs)'
  ! run_validator "$receipt"
}

case_landed_pending_cleanup_continued_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.lifecycle_outcome = "landed" | .cleanup_status = "pending" | .closeout_outcome = "continued" | del(.cleanup_evidence_refs)'
  run_validator "$receipt"
}

case_target_landed_downgraded_requires_not_landed_reason() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | del(.not_landed_reason)'
  ! run_validator "$receipt"
}

case_target_landed_downgraded_with_blocker_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | .not_landed_reason = "Provider ruleset blocks hosted no-PR landing." | .landing_evaluation = {"status":"blocked","blocker_reason":"Provider ruleset blocks hosted no-PR landing."}'
  run_validator "$receipt"
}

case_default_cleaned_downgraded_to_published_branch_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .not_landed_reason = "Hosted no-PR landing was not proven during this run." | .not_cleaned_reason = "Landing, local main sync, and branch cleanup evidence are missing for cleaned closeout." | .landing_evaluation = {"status":"blocked","blocker_reason":"Hosted no-PR landing was not proven during this run."}'
  run_validator "$receipt"
}

case_target_cleaned_downgraded_requires_not_cleaned_reason() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .lifecycle_outcome = "landed" | .closeout_outcome = "continued" | del(.not_cleaned_reason)'
  ! run_validator "$receipt"
}

case_branch_no_pr_cleaned_full_evidence_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "completed" | .cleanup_evidence_refs = ["source branch cleanup completed after origin/main containment"] | .source_branch_cleanup.status = "completed" | .source_branch_cleanup.evidence_refs = ["source branch cleanup completed after origin/main containment"] | del(.source_branch_cleanup.blocker_reason)'
  run_validator "$receipt"
}

case_deferred_actual_outcome_requires_blocker_evidence() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "deferred" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .not_landed_reason = "Required hosted checks are pending." | .not_cleaned_reason = "Required hosted checks are pending before landing and cleanup." | .landing_evaluation = {"status":"blocked","blocker_reason":"Required hosted checks are pending."} | .external_blocker_refs = ["required hosted checks pending"] | .remaining_blockers = ["Required hosted checks are pending."]'
  run_validator "$receipt"
}

case_deferred_actual_outcome_without_blocker_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "deferred" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .not_landed_reason = "Required hosted checks are pending." | .not_cleaned_reason = "Required hosted checks are pending before landing and cleanup." | .landing_evaluation = {"status":"blocked","blocker_reason":"Required hosted checks are pending."} | del(.remaining_blockers)'
  ! run_validator "$receipt"
}

case_completed_branch_requires_source_integration() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" 'del(.source_branch_integration)'
  ! run_validator "$receipt"
}

case_completed_branch_requires_post_fetch_sync_evidence() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" 'del(.main_alignment.origin_fetch_evidence_ref, .main_alignment.local_main_sync_evidence_ref)'
  ! run_validator "$receipt"
}

case_completed_branch_requires_landed_ref_containment() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.main_alignment.local_main_contains_landed_ref = false'
  ! run_validator "$receipt"
}

case_completed_branch_requires_stateful_closeout() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" 'del(.stateful_closeout)'
  ! run_validator "$receipt"
}

case_branch_no_pr_landed_requires_landing_authorization() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" 'del(.landing_authorization_ref)'
  ! run_validator "$receipt"
}

case_branch_no_pr_landed_rejects_denied_authorization() {
  local receipt auth
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '.authorization_result = "denied"'
  ! run_validator "$receipt"
}

case_branch_no_pr_landed_rejects_stale_authorization() {
  local receipt auth
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '.source_ref = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
  ! run_validator "$receipt"
}

case_branch_pr_landed_completed_pending_cleanup_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-landed-cleanup-pending",
  "selected_route": "branch-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "pr-landing",
  "intent": "bad pr landed cleanup",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/pr",
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "main_alignment": {
    "local_main_ref": "def0000000000000000000000000000000000000",
    "origin_main_ref": "def0000000000000000000000000000000000000",
    "landed_ref": "def0000000000000000000000000000000000000",
    "aligned": true
  },
  "integration_method": "github-merge",
  "integration_status": "landed",
  "publication_status": "pr-merged",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pr/1", "branch": "feature/pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

main() {
  assert_success "lifecycle validator passes live repo" case_live_repo_passes
  assert_success "valid direct-main landed example passes" case_valid_direct_main_landed_example_passes
  assert_success "valid branch-pr ready example passes" case_valid_branch_pr_ready_example_passes
  assert_success "valid branch-no-pr branch-local example passes" case_valid_branch_no_pr_branch_local_example_passes
  assert_success "valid branch-no-pr published-branch example passes" case_valid_branch_no_pr_published_branch_example_passes
  assert_success "schema and policy default unspecified target to cleaned" case_schema_defaults_target_to_cleaned
  assert_success "invalid draft PR full closeout example fails" case_invalid_draft_pr_full_closeout_example_fails
  assert_success "invalid pushed-only landed example fails" case_invalid_pushed_only_landed_example_fails
  assert_success "invalid published-branch completed closeout example fails" case_invalid_published_branch_completed_closeout_example_fails
  assert_success "invalid stale remote branch ref example fails" case_invalid_stale_remote_branch_ref_example_fails
  assert_success "valid no-PR landed receipt passes" case_no_pr_landed_receipt_passes
  assert_success "branch-pr preserved receipt passes without PR metadata" case_branch_pr_preserved_receipt_passes_without_pr_metadata
  assert_success "checkpoint cannot claim landed" case_checkpoint_cannot_claim_landed
  assert_success "branch-local commit cannot claim landed without main ref" case_branch_local_commit_needs_landed_ref
  assert_success "branch-no-pr rejects PR metadata" case_branch_no_pr_rejects_pr_metadata
  assert_success "branch-no-pr rejects PR lifecycle outcome" case_branch_no_pr_rejects_pr_lifecycle_outcome
  assert_success "branch-pr rejects branch-only lifecycle outcome" case_branch_pr_rejects_branch_only_lifecycle_outcome
  assert_success "branch-pr draft/open cannot claim full closeout" case_branch_pr_draft_not_full_closeout
  assert_success "cleanup claim requires evidence" case_cleanup_claim_requires_evidence
  assert_success "cleaned with pending cleanup fails" case_cleaned_pending_cleanup_fails
  assert_success "completed landed branch closeout with pending cleanup fails" case_landed_completed_pending_cleanup_fails
  assert_success "landed with pending cleanup remains valid before full closeout" case_landed_pending_cleanup_continued_passes
  assert_success "target landed downgrade requires not_landed_reason" case_target_landed_downgraded_requires_not_landed_reason
  assert_success "target landed downgrade with blocker passes" case_target_landed_downgraded_with_blocker_passes
  assert_success "default cleaned target can downgrade to explicit published-branch evidence" case_default_cleaned_downgraded_to_published_branch_passes
  assert_success "target cleaned downgrade requires not_cleaned_reason" case_target_cleaned_downgraded_requires_not_cleaned_reason
  assert_success "branch-no-pr cleaned full evidence passes" case_branch_no_pr_cleaned_full_evidence_passes
  assert_success "deferred actual outcome with blocker evidence passes" case_deferred_actual_outcome_requires_blocker_evidence
  assert_success "deferred actual outcome without blocker evidence fails" case_deferred_actual_outcome_without_blocker_fails
  assert_success "completed branch closeout requires source integration evidence" case_completed_branch_requires_source_integration
  assert_success "completed branch closeout requires post-fetch sync evidence" case_completed_branch_requires_post_fetch_sync_evidence
  assert_success "completed branch closeout requires landed-ref containment" case_completed_branch_requires_landed_ref_containment
  assert_success "completed branch closeout requires stateful closeout evidence" case_completed_branch_requires_stateful_closeout
  assert_success "branch-no-pr landed requires governed landing authorization" case_branch_no_pr_landed_requires_landing_authorization
  assert_success "branch-no-pr landed rejects denied landing authorization" case_branch_no_pr_landed_rejects_denied_authorization
  assert_success "branch-no-pr landed rejects stale landing authorization" case_branch_no_pr_landed_rejects_stale_authorization
  assert_success "branch-pr landed completed closeout with pending cleanup fails" case_branch_pr_landed_completed_pending_cleanup_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
