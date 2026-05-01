#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
RULESET_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"

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

write_file() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cat >"$file"
  printf '%s\n' "$file"
}

run_hosted_validator() {
  bash "$VALIDATOR" --receipt "$1" --skip-live-remote >/dev/null
}

case_static_alignment_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_valid_hosted_no_pr_receipt_passes() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "valid-hosted-no-pr",
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
    "required_check_refs": ["route-neutral-ci@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "main-route-neutral-ruleset",
    "push_refspec": "def0000000000000000000000000000000000000:refs/heads/main",
    "fast_forward_only": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["cleanup deferred while operator remains on branch"],
  "validation_evidence_refs": ["route-neutral-ci passed at def0000000000000000000000000000000000000"],
  "review_waiver_refs": ["solo maintainer no-PR route"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  run_hosted_validator "$receipt"
}

case_pushed_only_branch_cannot_claim_hosted_landing() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pushed-only",
  "selected_route": "branch-no-pr",
  "lifecycle_outcome": "published-branch",
  "intent": "pushed branch only",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "remote_branch_ref": "origin/feature/no-pr",
  "integration_status": "not_landed",
  "publication_status": "pushed-branch",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["local validation"],
  "durable_history": {"kind": "branch", "ref": "feature/no-pr", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "discard-branch", "ref": "feature/no-pr"},
  "closeout_outcome": "continued",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_hosted_validator "$receipt"
}

case_missing_hosted_landing_fails() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-missing-hosted",
  "selected_route": "branch-no-pr",
  "lifecycle_outcome": "landed",
  "intent": "bad landing",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@def",
  "landed_ref": "def",
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["local validation"],
  "durable_history": {"kind": "commit", "ref": "def", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_hosted_validator "$receipt"
}

case_mismatched_landed_ref_fails() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-mismatch",
  "selected_route": "branch-no-pr",
  "lifecycle_outcome": "landed",
  "intent": "bad landing",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "bad0000000000000000000000000000000000000",
    "validated_ref": "def0000000000000000000000000000000000000",
    "required_check_refs": ["route-neutral-ci@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "main-route-neutral-ruleset",
    "fast_forward_only": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["route-neutral-ci passed"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_hosted_validator "$receipt"
}

case_pr_metadata_fails() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "bad-pr-metadata",
  "selected_route": "branch-no-pr",
  "lifecycle_outcome": "landed",
  "intent": "bad landing",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/no-pr",
  "target_branch_ref": "origin/main@def0000000000000000000000000000000000000",
  "landed_ref": "def0000000000000000000000000000000000000",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/no-pr",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_pre_ref": "abc0000000000000000000000000000000000000",
    "target_post_ref": "def0000000000000000000000000000000000000",
    "validated_ref": "def0000000000000000000000000000000000000",
    "required_check_refs": ["route-neutral-ci@def0000000000000000000000000000000000000"],
    "provider_ruleset_ref": "main-route-neutral-ruleset",
    "fast_forward_only": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "pending",
  "validation_evidence_refs": ["route-neutral-ci passed"],
  "durable_history": {"kind": "pr", "ref": "1", "pr_url": "https://example.invalid/pull/1"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  ! run_hosted_validator "$receipt"
}

case_current_pr_required_ruleset_passes_current_expectation() {
  local rules
  rules="$(write_file <<'JSON'
[
  {"type": "pull_request"},
  {"type": "required_status_checks"},
  {"type": "non_fast_forward"}
]
JSON
)"
  bash "$RULESET_VALIDATOR" --expect current-pr-required --ruleset-json "$rules" >/dev/null
}

case_route_neutral_ruleset_passes_target_expectation() {
  local rules
  rules="$(write_file <<'JSON'
[
  {"type": "required_status_checks"},
  {"type": "non_fast_forward"},
  {"type": "deletion"}
]
JSON
)"
  bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

case_pr_rule_fails_target_expectation() {
  local rules
  rules="$(write_file <<'JSON'
[
  {"type": "pull_request"},
  {"type": "required_status_checks"}
]
JSON
)"
  ! bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

main() {
  assert_success "hosted no-PR static alignment passes" case_static_alignment_passes
  assert_success "valid hosted no-PR receipt passes" case_valid_hosted_no_pr_receipt_passes
  assert_success "pushed-only branch cannot claim hosted landing" case_pushed_only_branch_cannot_claim_hosted_landing
  assert_success "missing hosted landing evidence fails" case_missing_hosted_landing_fails
  assert_success "mismatched landed ref fails" case_mismatched_landed_ref_fails
  assert_success "PR metadata fails for branch-no-pr hosted landing" case_pr_metadata_fails
  assert_success "current PR-required ruleset passes current expectation" case_current_pr_required_ruleset_passes_current_expectation
  assert_success "route-neutral ruleset passes target expectation" case_route_neutral_ruleset_passes_target_expectation
  assert_success "PR rule fails target route-neutral expectation" case_pr_rule_fails_target_expectation

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
