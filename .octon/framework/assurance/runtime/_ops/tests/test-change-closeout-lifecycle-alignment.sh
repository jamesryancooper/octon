#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"

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

case_no_pr_landed_receipt_passes() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "change-1",
  "selected_route": "branch-no-pr",
  "lifecycle_outcome": "landed",
  "intent": "land branch without PR",
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
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["cleanup deferred until operator leaves worktree"],
  "validation_evidence_refs": ["validator passed"],
  "review_waiver_refs": ["solo maintainer no-PR route"],
  "durable_history": {"kind": "commit", "ref": "abc", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  run_validator "$receipt"
}

case_branch_pr_preserved_receipt_passes_without_pr_metadata() {
  local receipt
  receipt="$(write_receipt <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "change-pr-preserved",
  "selected_route": "branch-pr",
  "lifecycle_outcome": "preserved",
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
  "lifecycle_outcome": "landed",
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
  "lifecycle_outcome": "landed",
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
  "lifecycle_outcome": "published-branch",
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
  "lifecycle_outcome": "ready",
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
  "lifecycle_outcome": "published-branch",
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
  "lifecycle_outcome": "published",
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
  "lifecycle_outcome": "cleaned",
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

main() {
  assert_success "lifecycle validator passes live repo" case_live_repo_passes
  assert_success "valid no-PR landed receipt passes" case_no_pr_landed_receipt_passes
  assert_success "branch-pr preserved receipt passes without PR metadata" case_branch_pr_preserved_receipt_passes_without_pr_metadata
  assert_success "checkpoint cannot claim landed" case_checkpoint_cannot_claim_landed
  assert_success "branch-local commit cannot claim landed without main ref" case_branch_local_commit_needs_landed_ref
  assert_success "branch-no-pr rejects PR metadata" case_branch_no_pr_rejects_pr_metadata
  assert_success "branch-no-pr rejects PR lifecycle outcome" case_branch_no_pr_rejects_pr_lifecycle_outcome
  assert_success "branch-pr rejects branch-only lifecycle outcome" case_branch_pr_rejects_branch_only_lifecycle_outcome
  assert_success "branch-pr draft/open cannot claim full closeout" case_branch_pr_draft_not_full_closeout
  assert_success "cleanup claim requires evidence" case_cleanup_claim_requires_evidence

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
