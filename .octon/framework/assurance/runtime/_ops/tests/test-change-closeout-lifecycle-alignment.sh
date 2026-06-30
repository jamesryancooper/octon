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

add_branch_pr_evidence() {
  local receipt="$1"
  local predicate="${2:-hosted-review-required}"
  local tmp filter
  case "$predicate" in
    explicit-operator-pr-request)
      filter='.branch_pr_predicate_evidence = {predicate: $predicate, requirement_ref: "operator://chat/explicit-pr-request", evidence_refs: ["operator requested PR-backed route"], branch_no_pr_rejection_reason: "The operator explicitly requested PR-backed routing.", operator_request_ref: "operator://chat/explicit-pr-request"}'
      ;;
    existing-pr-context)
      filter='.branch_pr_predicate_evidence = {predicate: $predicate, requirement_ref: "github-pr:https://example.invalid/pr/1", evidence_refs: ["existing PR context"], branch_no_pr_rejection_reason: "The Change already has PR review context.", existing_pr_or_review_ref: "github-pr:https://example.invalid/pr/1"}'
      ;;
    protected-or-high-impact-remote-review-required)
      filter='.branch_pr_predicate_evidence = {predicate: $predicate, requirement_ref: "policy://governing-review-required", evidence_refs: ["governing evidence requires hosted review"], branch_no_pr_rejection_reason: "Governing evidence requires hosted review or remote validation.", scope_classification_ref: "evidence://scope/high-impact", governing_review_requirement_ref: "policy://governing-review-required"}'
      ;;
    provider-ruleset-requires-pr-for-requested-pr-backed-landing)
      filter='.branch_pr_predicate_evidence = {predicate: $predicate, requirement_ref: "github-ruleset://requires-pr", evidence_refs: ["provider ruleset requires PR-backed landing"], branch_no_pr_rejection_reason: "Provider ruleset requires PR-backed landing for the requested route.", provider_ruleset_ref: "github-ruleset://requires-pr"}'
      ;;
    *)
      filter='.branch_pr_predicate_evidence = {predicate: $predicate, requirement_ref: ("policy://" + $predicate), evidence_refs: ["predicate requirement proven"], branch_no_pr_rejection_reason: "A documented PR predicate makes branch-no-pr not policy-valid."}'
      ;;
  esac
  tmp="$(mktemp)"
  jq --arg predicate "$predicate" "$filter" "$receipt" >"$tmp"
  mv "$tmp" "$receipt"
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

attach_downgrade_landing_authorization() {
  local receipt="$1"
  local auth tmp
  auth="$(mktemp)"
  CLEANUP_FILES+=("$auth")
  jq '{
    schema_version: "branch-landing-authorization-v1",
    authorization_id: ("fixture-runtime-denied-" + .change_id),
    authorization_result: "approved",
    selected_route: "branch-no-pr",
    target_lifecycle_outcome: .target_lifecycle_outcome,
    remote: "origin",
    target_branch: "main",
    source_branch: .source_branch_ref,
    source_ref: (.landing_evaluation.source_ref // .durable_history.ref),
    remote_source_ref: (.landing_evaluation.source_ref // .durable_history.ref),
    target_pre_ref: "cccccccccccccccccccccccccccccccccccccccc",
    provider_ruleset_ref: (.landing_evaluation.provider_ruleset_ref // "route-neutral-main"),
    no_pr_required: true,
    preflight_status: "passed",
    required_check_refs: ["route_neutral_closeout_validation@dddddddddddddddddddddddddddddddddddddddd"],
    allow_empty_check_set: false,
    rollback_handle: ((.rollback_handle.kind // "rollback") + ":" + (.rollback_handle.ref // .durable_history.ref)),
    host_controls_not_bypassed: true,
    runtime_safety_boundary: "Octon authorization is required before hosted mutation, but it does not bypass platform, sandbox, or host safety controls.",
    created_at: .created_at
  }' "$receipt" >"$auth"
  tmp="$(mktemp)"
  jq --arg auth "$auth" '.landing_authorization_ref = $auth' "$receipt" >"$tmp"
  mv "$tmp" "$receipt"
  printf '%s\n' "$auth"
}

attach_valid_cleanup_authorization() {
  local receipt="$1"
  local auth tmp
  auth="$(mktemp)"
  CLEANUP_FILES+=("$auth")
  jq '{
    schema_version: "branch-cleanup-authorization-v1",
    authorization_id: ("fixture-cleanup-" + .change_id),
    authorization_result: "approved",
    selected_route: .selected_route,
    target_lifecycle_outcome: "cleaned",
    remote: (.hosted_landing.remote // "origin"),
    base_branch: "main",
    source_branch: .source_branch_ref,
    landed_ref: .landed_ref,
    origin_main_ref: .main_alignment.origin_main_ref,
    local_main_ref: .main_alignment.local_main_ref,
    local_source_ref: (.source_branch_integration.source_ref // .landed_ref),
    remote_source_ref: (.source_branch_integration.source_ref // .landed_ref),
    local_branch_exists: true,
    remote_branch_exists: true,
    local_main_synced_to_origin_main: true,
    origin_main_contains_landed_ref: true,
    local_main_contains_landed_ref: true,
    source_branch_contained_in_origin_main: true,
    source_branch_protected: false,
    open_pr_count: 0,
    rollback_handle: ((.rollback_handle.kind // "rollback") + ":" + (.rollback_handle.ref // .landed_ref)),
    cleanup_policy_allowed: true,
    delete_remote_requested: true,
    remove_worktrees_requested: true,
    sync_main_requested: true,
    host_controls_not_bypassed: true,
    runtime_safety_boundary: "Octon cleanup authorization is required before branch deletion, but it does not bypass platform, sandbox, provider, or host safety controls.",
    created_at: .created_at
  }' "$receipt" >"$auth"
  tmp="$(mktemp)"
  jq --arg auth "$auth" '.cleanup_authorization_ref = $auth' "$receipt" >"$tmp"
  mv "$tmp" "$receipt"
  printf '%s\n' "$auth"
}

attach_publishable_evidence_receipt_ref() {
  local receipt="$1"
  local tmp
  tmp="$(mktemp)"
  jq '.publishable_evidence_receipt_refs = [
    {
      receipt_ref: ".octon/state/evidence/validation/fixture/publishable-receipt.json",
      schema_ref: ".octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json",
      disclosure_tier: "repo-publishable",
      claim_scope_ref: .change_id,
      receipt_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      raw_evidence_not_published: true
    }
  ]' "$receipt" >"$tmp"
  mv "$tmp" "$receipt"
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
  "branch_pr_predicate": "hosted-review-required",
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
  add_branch_pr_evidence "$receipt" "hosted-review-required"
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
  "branch_pr_predicate": "hosted-review-required",
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
  add_branch_pr_evidence "$receipt" "hosted-review-required"
  ! run_validator "$receipt"
}

case_branch_pr_draft_not_full_closeout() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-draft",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "hosted-review-required",
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
  add_branch_pr_evidence "$receipt" "hosted-review-required"
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

case_cleaned_deferred_cleanup_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .cleanup_evidence_refs = ["cleanup deferred"] | .source_branch_cleanup.status = "deferred" | .source_branch_cleanup.blocker_reason = "cleanup deferred" | .source_branch_cleanup.evidence_refs = ["cleanup deferred"]'
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
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | .landing_stop_reason = "provider_policy_blocked" | del(.not_landed_reason)'
  ! run_validator "$receipt"
}

case_target_landed_downgraded_requires_landing_stop_reason() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | .not_landed_reason = "Provider ruleset blocks hosted no-PR landing." | del(.landing_stop_reason)'
  ! run_validator "$receipt"
}

case_target_landed_downgraded_with_blocker_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "landed" | .outcome_intent = "attempt-landing" | .not_landed_reason = "Provider ruleset blocks hosted no-PR landing." | .landing_stop_reason = "provider_policy_blocked" | .landing_evaluation = {"status":"blocked","blocker_reason":"Provider ruleset blocks hosted no-PR landing."}'
  run_validator "$receipt"
}

case_default_cleaned_downgraded_to_published_branch_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .not_landed_reason = "Hosted no-PR landing was not proven during this run." | .landing_stop_reason = "hosted_checks_pending" | .not_cleaned_reason = "Landing, local main sync, and branch cleanup evidence are missing for cleaned closeout." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","blocker_reason":"Hosted no-PR landing was not proven during this run."}'
  run_validator "$receipt"
}

case_target_cleaned_downgraded_requires_not_cleaned_reason() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .lifecycle_outcome = "landed" | .closeout_outcome = "continued" | .cleanup_stop_reason = "cleanup_deferred_by_operator" | del(.not_cleaned_reason)'
  ! run_validator "$receipt"
}

case_target_cleaned_downgraded_requires_cleanup_stop_reason() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .lifecycle_outcome = "landed" | .closeout_outcome = "continued" | .not_cleaned_reason = "Branch cleanup was deferred." | del(.cleanup_stop_reason)'
  ! run_validator "$receipt"
}

case_runtime_denied_landing_with_authorization_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .not_landed_reason = "Runtime approval boundary denied hosted origin/main mutation after Octon authorization validated." | .landing_stop_reason = "runtime_approval_denied" | .not_cleaned_reason = "Landing did not complete, so cleanup could not run." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","provider_ruleset_ref":"route-neutral-main","source_ref":.durable_history.ref,"blocker_reason":"Runtime approval boundary denied hosted origin/main mutation after Octon authorization validated."}'
  attach_downgrade_landing_authorization "$receipt" >/dev/null
  run_validator "$receipt"
}

case_runtime_denied_landing_without_authorization_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .not_landed_reason = "Runtime approval boundary denied hosted origin/main mutation." | .landing_stop_reason = "runtime_approval_denied" | .not_cleaned_reason = "Landing did not complete, so cleanup could not run." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","provider_ruleset_ref":"route-neutral-main","source_ref":.durable_history.ref,"blocker_reason":"Runtime approval boundary denied hosted origin/main mutation."} | del(.landing_authorization_ref)'
  ! run_validator "$receipt"
}

case_runtime_denied_cleanup_with_authorization_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "landed" | .outcome_intent = "attempt-cleaned-closeout" | .closeout_outcome = "continued" | .cleanup_status = "deferred" | .not_cleaned_reason = "Runtime approval boundary denied branch cleanup after Octon cleanup authorization validated." | .cleanup_stop_reason = "runtime_approval_denied" | .cleanup_evidence_refs = ["runtime approval denied cleanup"] | .source_branch_cleanup.status = "deferred" | .source_branch_cleanup.blocker_reason = "Runtime approval boundary denied branch cleanup after Octon cleanup authorization validated." | .source_branch_cleanup.evidence_refs = ["runtime approval denied cleanup"]'
  attach_valid_cleanup_authorization "$receipt" >/dev/null
  run_validator "$receipt"
}

case_runtime_denied_cleanup_without_authorization_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "landed" | .outcome_intent = "attempt-cleaned-closeout" | .closeout_outcome = "continued" | .cleanup_status = "deferred" | .not_cleaned_reason = "Runtime approval boundary denied branch cleanup." | .cleanup_stop_reason = "runtime_approval_denied" | .cleanup_evidence_refs = ["runtime approval denied cleanup"] | .source_branch_cleanup.status = "deferred" | .source_branch_cleanup.blocker_reason = "Runtime approval boundary denied branch cleanup." | .source_branch_cleanup.evidence_refs = ["runtime approval denied cleanup"] | del(.cleanup_authorization_ref)'
  ! run_validator "$receipt"
}

case_branch_no_pr_cleaned_full_evidence_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "completed" | .cleanup_evidence_refs = ["source branch cleanup completed after origin/main containment"] | .source_branch_cleanup.status = "completed" | .source_branch_cleanup.evidence_refs = ["source branch cleanup completed after origin/main containment"] | del(.source_branch_cleanup.blocker_reason)'
  attach_valid_cleanup_authorization "$receipt" >/dev/null
  attach_publishable_evidence_receipt_ref "$receipt"
  run_validator "$receipt"
}

case_branch_no_pr_cleaned_requires_cleanup_authorization() {
  local receipt
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "completed" | .cleanup_evidence_refs = ["source branch cleanup completed after origin/main containment"] | .source_branch_cleanup.status = "completed" | .source_branch_cleanup.evidence_refs = ["source branch cleanup completed after origin/main containment"] | del(.source_branch_cleanup.blocker_reason, .cleanup_authorization_ref)'
  attach_publishable_evidence_receipt_ref "$receipt"
  ! run_validator "$receipt"
}

case_branch_no_pr_cleaned_rejects_denied_cleanup_authorization() {
  local receipt auth
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "completed" | .cleanup_evidence_refs = ["source branch cleanup completed after origin/main containment"] | .source_branch_cleanup.status = "completed" | .source_branch_cleanup.evidence_refs = ["source branch cleanup completed after origin/main containment"] | del(.source_branch_cleanup.blocker_reason)'
  auth="$(attach_valid_cleanup_authorization "$receipt")"
  attach_publishable_evidence_receipt_ref "$receipt"
  rewrite_json_file "$auth" '.authorization_result = "denied"'
  ! run_validator "$receipt"
}

case_branch_no_pr_cleaned_rejects_stale_cleanup_authorization() {
  local receipt auth
  receipt="$(copy_example_receipt valid-hosted-branch-no-pr-landed.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "completed" | .cleanup_evidence_refs = ["source branch cleanup completed after origin/main containment"] | .source_branch_cleanup.status = "completed" | .source_branch_cleanup.evidence_refs = ["source branch cleanup completed after origin/main containment"] | del(.source_branch_cleanup.blocker_reason)'
  auth="$(attach_valid_cleanup_authorization "$receipt")"
  attach_publishable_evidence_receipt_ref "$receipt"
  rewrite_json_file "$auth" '.landed_ref = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
  ! run_validator "$receipt"
}

case_deferred_actual_outcome_requires_blocker_evidence() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "deferred" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .not_landed_reason = "Required hosted checks are pending." | .landing_stop_reason = "hosted_checks_pending" | .not_cleaned_reason = "Required hosted checks are pending before landing and cleanup." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","blocker_reason":"Required hosted checks are pending."} | .external_blocker_refs = ["required hosted checks pending"] | .remaining_blockers = ["Required hosted checks are pending."]'
  run_validator "$receipt"
}

case_deferred_actual_outcome_without_blocker_fails() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .lifecycle_outcome = "deferred" | .outcome_intent = "attempt-cleaned-closeout" | .cleanup_status = "deferred" | .not_landed_reason = "Required hosted checks are pending." | .landing_stop_reason = "hosted_checks_pending" | .not_cleaned_reason = "Required hosted checks are pending before landing and cleanup." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","blocker_reason":"Required hosted checks are pending."} | del(.remaining_blockers)'
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
  "branch_pr_predicate": "hosted-review-required",
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
  add_branch_pr_evidence "$receipt" "hosted-review-required"
  ! run_validator "$receipt"
}

case_direct_main_blocked_then_pr_without_transition_authority_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-direct-main-to-pr",
  "selected_route": "branch-pr",
  "initial_route": "direct-main",
  "branch_pr_predicate": "hosted-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad silent reroute after direct push was blocked",
  "scope": {"summary": "test", "diff_refs": ["GH013 direct push blocked by required checks"]},
  "source_branch_ref": "feature/reroute",
  "landing_evaluation": {
    "status": "blocked",
    "blocker_reason": "GH013 direct push blocked by required checks"
  },
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/reroute", "branch": "feature/reroute"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/reroute"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "hosted-review-required"
  ! run_validator "$receipt"
}

case_branch_no_pr_blocked_then_pr_without_transition_authority_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-no-pr-to-pr",
  "selected_route": "branch-pr",
  "initial_route": "branch-no-pr",
  "branch_pr_predicate": "hosted-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad silent reroute after hosted no-PR landing was blocked",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr-reroute",
  "landing_evaluation": {
    "status": "blocked",
    "blocker_reason": "hosted no-PR branch-no-pr landing blocked by required checks"
  },
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/no-pr-reroute", "branch": "feature/no-pr-reroute"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/no-pr-reroute"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "hosted-review-required"
  ! run_validator "$receipt"
}

case_explicit_operator_reroute_to_pr_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-operator-reroute-to-pr",
  "selected_route": "branch-pr",
  "initial_route": "branch-no-pr",
  "route_transition_reason": "Operator explicitly rerouted the blocked hosted no-PR landing to PR-backed review.",
  "route_transition_authority": "explicit-operator-reroute",
  "route_transition_authority_ref": "operator://chat/explicit-pr-reroute",
  "route_transition_evidence_refs": ["chat://operator-requested-pr-after-blocker"],
  "branch_pr_predicate": "explicit-operator-pr-request",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid explicit reroute to PR",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/operator-reroute",
  "landing_evaluation": {
    "status": "blocked",
    "blocker_reason": "hosted no-PR branch-no-pr landing blocked before operator reroute"
  },
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/operator-reroute", "branch": "feature/operator-reroute"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/operator-reroute"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "explicit-operator-pr-request"
  run_validator "$receipt"
}

case_policy_reroute_to_pr_after_new_evidence_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-policy-reroute-to-pr",
  "selected_route": "branch-pr",
  "initial_route": "branch-no-pr",
  "route_transition_reason": "New evidence showed hosted review is required for this Change.",
  "route_transition_authority": "policy-reroute-after-new-evidence",
  "route_transition_authority_ref": ".octon/framework/product/contracts/default-work-unit.yml#branch-pr",
  "route_transition_evidence_refs": ["evidence://validation/analysis/hosted-review-required.md"],
  "branch_pr_predicate": "hosted-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid policy reroute to PR",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/policy-reroute",
  "landing_evaluation": {
    "status": "blocked",
    "blocker_reason": "branch-no-pr hosted landing blocked by new hosted review requirement"
  },
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/policy-reroute", "branch": "feature/policy-reroute"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/policy-reroute"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "hosted-review-required"
  run_validator "$receipt"
}

case_branch_pr_selected_up_front_from_release_automation_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-release-automation-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "release-automation",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid PR route selected up front",
  "scope": {"summary": "test"},
  "source_branch_ref": "release/example",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "release/example", "branch": "release/example"},
  "rollback_handle": {"kind": "discard-branch", "ref": "release/example"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "release-automation"
  run_validator "$receipt"
}

case_branch_pr_selected_up_front_from_preview_publication_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-preview-publication-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "preview-publication-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid PR route selected for preview publication",
  "scope": {"summary": "test"},
  "source_branch_ref": "preview/example",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "preview/example", "branch": "preview/example"},
  "rollback_handle": {"kind": "discard-branch", "ref": "preview/example"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "preview-publication-required"
  run_validator "$receipt"
}

case_branch_pr_protected_high_impact_governing_review_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-protected-high-impact-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "protected-or-high-impact-remote-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid PR route selected by governing review requirement",
  "scope": {"summary": "test", "touched_paths": [".octon/framework/product/contracts/default-work-unit.yml"]},
  "source_branch_ref": "feature/governed-review",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/governed-review", "branch": "feature/governed-review"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/governed-review"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "protected-or-high-impact-remote-review-required"
  run_validator "$receipt"
}

case_branch_pr_missing_predicate_evidence_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-missing-predicate-evidence",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "hosted-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad missing predicate evidence",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/missing-evidence",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/missing-evidence", "branch": "feature/missing-evidence"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/missing-evidence"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_predicate_evidence_mismatch_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-predicate-evidence-mismatch",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "hosted-review-required",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad mismatched predicate evidence",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/mismatched-evidence",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/mismatched-evidence", "branch": "feature/mismatched-evidence"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/mismatched-evidence"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  add_branch_pr_evidence "$receipt" "release-automation"
  ! run_validator "$receipt"
}

case_branch_pr_high_impact_only_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-high-impact-only-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "protected-or-high-impact-remote-review-required",
  "branch_pr_predicate_evidence": {
    "predicate": "protected-or-high-impact-remote-review-required",
    "requirement_ref": "scope://high-impact",
    "evidence_refs": ["high-impact alone"],
    "branch_no_pr_rejection_reason": "high-impact alone"
  },
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad high-impact-only PR route",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/high-impact-only",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/high-impact-only", "branch": "feature/high-impact-only"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/high-impact-only"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_branch_isolation_only_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-branch-isolation-only-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "hosted-review-required",
  "branch_pr_predicate_evidence": {
    "predicate": "hosted-review-required",
    "requirement_ref": "scope://branch-isolation",
    "evidence_refs": ["branch isolation"],
    "branch_no_pr_rejection_reason": "branch isolation"
  },
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad branch-isolation-only PR route",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/branch-isolation-only",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/branch-isolation-only", "branch": "feature/branch-isolation-only"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/branch-isolation-only"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_provider_caution_only_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-provider-caution-pr",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "provider-ruleset-requires-pr-for-requested-pr-backed-landing",
  "branch_pr_predicate_evidence": {
    "predicate": "provider-ruleset-requires-pr-for-requested-pr-backed-landing",
    "requirement_ref": "provider-caution://main",
    "evidence_refs": ["provider caution"],
    "branch_no_pr_rejection_reason": "provider caution"
  },
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad provider-caution-only PR route",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/provider-caution",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/provider-caution", "branch": "feature/provider-caution"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/provider-caution"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_pr_blocked_no_pr_landing_inference_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-blocked-no-pr-inference",
  "selected_route": "branch-pr",
  "branch_pr_predicate": "hosted-review-required",
  "branch_pr_predicate_evidence": {
    "predicate": "hosted-review-required",
    "requirement_ref": "hosted no-PR branch-no-pr landing blocked by required checks",
    "evidence_refs": ["hosted no-PR landing blocked"],
    "branch_no_pr_rejection_reason": "hosted no-PR landing blocked"
  },
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad blocked no-PR landing PR inference",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/blocked-no-pr",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/blocked-no-pr", "branch": "feature/blocked-no-pr"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/blocked-no-pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_branch_no_pr_high_impact_branch_isolation_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-branch-local-complete.json)"
  rewrite_json_file "$receipt" '.scope.summary = "High-impact branch-isolated work without a PR predicate stays branch-no-pr." | .scope.touched_paths = [".octon/framework/product/contracts/default-work-unit.yml"] | .review_waiver_refs = ["high-impact alone is not a PR predicate"]'
  run_validator "$receipt"
}

case_branch_no_pr_blocked_missing_landing_authorization_passes() {
  local receipt
  receipt="$(copy_example_receipt valid-branch-no-pr-published-branch.json)"
  rewrite_json_file "$receipt" '.target_lifecycle_outcome = "cleaned" | .outcome_intent = "attempt-cleaned-closeout" | .not_landed_reason = "Governed hosted no-PR landing authorization is missing." | .landing_stop_reason = "governance_authorization_missing" | .not_cleaned_reason = "Landing did not complete, so cleanup could not run." | .cleanup_stop_reason = "landing_not_completed" | .landing_evaluation = {"status":"blocked","provider_ruleset_ref":"route-neutral-main","source_ref":.durable_history.ref,"blocker_reason":"Governed hosted no-PR landing authorization is missing."} | .external_blocker_refs = ["missing branch-landing-authorization-v1"] | .remaining_blockers = ["Governed hosted no-PR landing authorization is missing."]'
  run_validator "$receipt"
}

case_transition_authority_none_changed_route_fails() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-none-authority-changed-route",
  "selected_route": "branch-no-pr",
  "initial_route": "direct-main",
  "route_transition_authority": "none",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "bad route transition authority",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/bad-none-authority",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/bad-none-authority", "branch": "feature/bad-none-authority"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/bad-none-authority"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_validator "$receipt"
}

case_transition_authority_none_unchanged_route_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "good-none-authority-unchanged-route",
  "selected_route": "branch-no-pr",
  "initial_route": "branch-no-pr",
  "route_transition_authority": "none",
  "target_lifecycle_outcome": "preserved",
  "lifecycle_outcome": "preserved",
  "outcome_intent": "preserve-only",
  "intent": "valid unchanged route with explicit none authority",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/good-none-authority",
  "integration_status": "not_landed",
  "publication_status": "none",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["validator passed"],
  "durable_history": {"kind": "branch", "ref": "feature/good-none-authority", "branch": "feature/good-none-authority"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/good-none-authority"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
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
  assert_success "cleaned with deferred cleanup fails" case_cleaned_deferred_cleanup_fails
  assert_success "completed landed branch closeout with pending cleanup fails" case_landed_completed_pending_cleanup_fails
  assert_success "landed with pending cleanup remains valid before full closeout" case_landed_pending_cleanup_continued_passes
  assert_success "target landed downgrade requires not_landed_reason" case_target_landed_downgraded_requires_not_landed_reason
  assert_success "target landed downgrade requires landing_stop_reason" case_target_landed_downgraded_requires_landing_stop_reason
  assert_success "target landed downgrade with blocker passes" case_target_landed_downgraded_with_blocker_passes
  assert_success "default cleaned target can downgrade to explicit published-branch evidence" case_default_cleaned_downgraded_to_published_branch_passes
  assert_success "target cleaned downgrade requires not_cleaned_reason" case_target_cleaned_downgraded_requires_not_cleaned_reason
  assert_success "target cleaned downgrade requires cleanup_stop_reason" case_target_cleaned_downgraded_requires_cleanup_stop_reason
  assert_success "runtime-denied landing with governance authorization passes" case_runtime_denied_landing_with_authorization_passes
  assert_success "runtime-denied landing without governance authorization fails" case_runtime_denied_landing_without_authorization_fails
  assert_success "runtime-denied cleanup with governance authorization passes" case_runtime_denied_cleanup_with_authorization_passes
  assert_success "runtime-denied cleanup without governance authorization fails" case_runtime_denied_cleanup_without_authorization_fails
  assert_success "branch-no-pr cleaned full evidence passes" case_branch_no_pr_cleaned_full_evidence_passes
  assert_success "branch-no-pr cleaned requires governed cleanup authorization" case_branch_no_pr_cleaned_requires_cleanup_authorization
  assert_success "branch-no-pr cleaned rejects denied cleanup authorization" case_branch_no_pr_cleaned_rejects_denied_cleanup_authorization
  assert_success "branch-no-pr cleaned rejects stale cleanup authorization" case_branch_no_pr_cleaned_rejects_stale_cleanup_authorization
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
  assert_success "direct-main blocked then PR without transition authority fails" case_direct_main_blocked_then_pr_without_transition_authority_fails
  assert_success "hosted branch-no-pr blocked then PR without transition authority fails" case_branch_no_pr_blocked_then_pr_without_transition_authority_fails
  assert_success "explicit operator reroute to PR passes" case_explicit_operator_reroute_to_pr_passes
  assert_success "policy reroute to PR after new evidence passes" case_policy_reroute_to_pr_after_new_evidence_passes
  assert_success "branch-pr selected up front from release automation passes" case_branch_pr_selected_up_front_from_release_automation_passes
  assert_success "branch-pr selected up front from preview publication passes" case_branch_pr_selected_up_front_from_preview_publication_passes
  assert_success "branch-pr protected/high-impact governing review evidence passes" case_branch_pr_protected_high_impact_governing_review_passes
  assert_success "branch-pr missing predicate evidence fails" case_branch_pr_missing_predicate_evidence_fails
  assert_success "branch-pr predicate evidence mismatch fails" case_branch_pr_predicate_evidence_mismatch_fails
  assert_success "branch-pr high-impact alone fails" case_branch_pr_high_impact_only_fails
  assert_success "branch-pr branch isolation alone fails" case_branch_pr_branch_isolation_only_fails
  assert_success "branch-pr provider caution alone fails" case_branch_pr_provider_caution_only_fails
  assert_success "branch-pr blocked no-PR landing inference fails" case_branch_pr_blocked_no_pr_landing_inference_fails
  assert_success "branch-no-pr high-impact branch isolation passes" case_branch_no_pr_high_impact_branch_isolation_passes
  assert_success "branch-no-pr missing landing authorization blocks without PR reroute" case_branch_no_pr_blocked_missing_landing_authorization_passes
  assert_success "route transition authority none fails when route changed" case_transition_authority_none_changed_route_fails
  assert_success "route transition authority none passes when route unchanged" case_transition_authority_none_unchanged_route_passes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
