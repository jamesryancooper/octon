#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
RULESET_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"
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

write_file() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cat >"$file"
  printf '%s\n' "$file"
}

copy_valid_hosted_receipt() {
  local file
  file="$(mktemp)"
  CLEANUP_FILES+=("$file")
  cp "$EXAMPLE_DIR/valid-hosted-branch-no-pr-landed.json" "$file"
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

run_hosted_validator() {
  bash "$VALIDATOR" --receipt "$1" --skip-live-remote >/dev/null
}

case_static_alignment_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_valid_hosted_no_pr_example_passes() {
  run_hosted_validator "$EXAMPLE_DIR/valid-hosted-branch-no-pr-landed.json"
}

case_invalid_pushed_only_example_fails() {
  ! run_hosted_validator "$EXAMPLE_DIR/invalid-pushed-only-branch-claimed-landed.json"
}

case_valid_hosted_no_pr_receipt_passes() {
  local receipt
  receipt="$(write_file <<'JSON'
{
  "schema_version": "change-receipt-v1",
  "change_id": "valid-hosted-no-pr",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
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
    "required_check_refs": [
      "route_neutral_closeout_validation@def0000000000000000000000000000000000000",
      "branch_naming_validation@def0000000000000000000000000000000000000",
      "route_aware_autonomy_validation@def0000000000000000000000000000000000000",
      "exact_source_sha_validation@def0000000000000000000000000000000000000"
    ],
    "provider_ruleset_ref": "main-route-neutral-ruleset",
    "push_refspec": "def0000000000000000000000000000000000000:refs/heads/main",
    "fast_forward_only": true
  },
  "landing_evaluation": {
    "status": "succeeded",
    "provider_ruleset_ref": "main-route-neutral-ruleset",
    "source_ref": "def0000000000000000000000000000000000000",
    "target_ref": "origin/main@def0000000000000000000000000000000000000",
    "evidence_refs": ["route-neutral checks passed at def0000000000000000000000000000000000000"]
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
    "origin_fetch_evidence_ref": "git fetch origin after hosted landing",
    "local_main_sync_evidence_ref": "git switch main && git merge --ff-only origin/main",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["cleanup deferred while operator remains on branch"],
  "source_branch_cleanup": {
    "status": "deferred",
    "local_branch": "feature/no-pr",
    "remote_branch": "origin/feature/no-pr",
    "blocker_reason": "cleanup deferred while operator remains on branch",
    "evidence_refs": ["cleanup deferred while operator remains on branch"]
  },
  "validation_evidence_refs": ["route-neutral checks passed at def0000000000000000000000000000000000000"],
  "review_waiver_refs": ["solo maintainer no-PR route"],
  "durable_history": {"kind": "commit", "ref": "def0000000000000000000000000000000000000", "branch": "feature/no-pr"},
  "rollback_handle": {"kind": "revert-commit", "ref": "def0000000000000000000000000000000000000"},
  "closeout_outcome": "completed",
  "created_at": "2026-05-01T00:00:00Z"
}
JSON
)"
  attach_valid_landing_authorization "$receipt" >/dev/null
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

case_missing_route_neutral_check_fails() {
  local receipt
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" 'del(.hosted_landing.required_check_refs[3])'
  ! run_hosted_validator "$receipt"
}

case_check_ref_without_source_sha_fails() {
  local receipt
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" '.hosted_landing.required_check_refs[1] = "branch_naming_validation@bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
  ! run_hosted_validator "$receipt"
}

case_authorized_empty_check_set_passes() {
  local receipt auth
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" '
    .hosted_landing.required_check_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .landing_evaluation.evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .validation_evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  '
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '
    .allow_empty_check_set = true
    | .empty_check_set_rationale = "Fixture explicitly records why this branch-no-pr landing has no hosted required checks."
  '
  run_hosted_validator "$receipt"
}

case_unauthorized_empty_check_set_fails() {
  local receipt
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" '
    .hosted_landing.required_check_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .landing_evaluation.evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .validation_evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  '
  attach_valid_landing_authorization "$receipt" >/dev/null
  ! run_hosted_validator "$receipt"
}

case_empty_check_set_authorization_mismatch_fails() {
  local receipt auth
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" '
    .hosted_landing.required_check_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .landing_evaluation.evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .validation_evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  '
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '
    .allow_empty_check_set = true
    | .empty_check_set_rationale = "Fixture explicitly records why this branch-no-pr landing has no hosted required checks."
    | .required_check_refs = ["empty-check-set-explicitly-allowed@bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"]
  '
  ! run_hosted_validator "$receipt"
}

case_empty_check_set_missing_rationale_fails() {
  local receipt auth
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" '
    .hosted_landing.required_check_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .landing_evaluation.evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    | .validation_evidence_refs = ["empty-check-set-explicitly-allowed@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  '
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '.allow_empty_check_set = true'
  ! run_hosted_validator "$receipt"
}

case_missing_pushed_source_branch_evidence_fails() {
  local receipt
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" 'del(.remote_branch_ref)'
  ! run_hosted_validator "$receipt"
}

case_missing_landing_authorization_fails() {
  local receipt
  receipt="$(copy_valid_hosted_receipt)"
  rewrite_json_file "$receipt" 'del(.landing_authorization_ref)'
  ! run_hosted_validator "$receipt"
}

case_denied_landing_authorization_fails() {
  local receipt auth
  receipt="$(copy_valid_hosted_receipt)"
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '.authorization_result = "denied"'
  ! run_hosted_validator "$receipt"
}

case_stale_landing_authorization_fails() {
  local receipt auth
  receipt="$(copy_valid_hosted_receipt)"
  auth="$(attach_valid_landing_authorization "$receipt")"
  rewrite_json_file "$auth" '.target_pre_ref = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
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

write_live_descendant_receipt() {
  local receipt landed_ref current_ref pre_ref
  current_ref="$(git -C "$ROOT_DIR" rev-parse origin/main)"
  landed_ref="$(git -C "$ROOT_DIR" rev-parse origin/main^)"
  pre_ref="$(git -C "$ROOT_DIR" rev-parse origin/main^^)"
  git -C "$ROOT_DIR" merge-base --is-ancestor "$landed_ref" origin/main
  [[ "$current_ref" != "$landed_ref" ]]

  receipt="$(write_file <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "live-descendant-post-evidence",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "validate historical landing after closeout evidence retention",
  "scope": {"summary": "test"},
  "source_branch_ref": "feature/post-evidence",
  "target_branch_ref": "origin/main@${landed_ref}",
  "remote_branch_ref": "origin/feature/post-evidence@${landed_ref}",
  "landed_ref": "${landed_ref}",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "feature/post-evidence",
    "source_ref": "${landed_ref}",
    "target_pre_ref": "${pre_ref}",
    "target_post_ref": "${landed_ref}",
    "validated_ref": "${landed_ref}",
    "required_check_refs": [
      "route_neutral_closeout_validation@${landed_ref}",
      "branch_naming_validation@${landed_ref}",
      "route_aware_autonomy_validation@${landed_ref}",
      "exact_source_sha_validation@${landed_ref}"
    ],
    "provider_ruleset_ref": "live-provider-rules:origin/main",
    "push_refspec": "${landed_ref}:refs/heads/main",
    "fast_forward_only": true
  },
  "landing_evaluation": {
    "status": "succeeded",
    "provider_ruleset_ref": "live-provider-rules:origin/main",
    "source_ref": "${landed_ref}",
    "target_ref": "origin/main@${landed_ref}",
    "evidence_refs": ["origin/main equaled ${landed_ref} before later evidence-retention commit ${current_ref}"]
  },
  "source_branch_integration": {
    "source_branch_ref": "feature/post-evidence",
    "source_ref": "${landed_ref}",
    "landed_ref": "${landed_ref}",
    "origin_main_ref": "${landed_ref}",
    "integrated": true,
    "method": "fast-forward",
    "evidence_refs": ["origin/main contains feature/post-evidence at ${landed_ref}"]
  },
  "main_alignment": {
    "local_main_ref": "${landed_ref}",
    "origin_main_ref": "${landed_ref}",
    "landed_ref": "${landed_ref}",
    "aligned": true,
    "origin_fetch_evidence_ref": "git fetch origin after hosted landing",
    "local_main_sync_evidence_ref": "git switch main && git merge --ff-only origin/main",
    "origin_main_contains_landed_ref": true,
    "local_main_contains_landed_ref": true
  },
  "integration_method": "fast-forward",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "deferred",
  "cleanup_evidence_refs": ["cleanup deferred while validating historical landing receipt"],
  "source_branch_cleanup": {
    "status": "deferred",
    "local_branch": "feature/post-evidence",
    "remote_branch": "origin/feature/post-evidence",
    "blocker_reason": "cleanup deferred while validating historical landing receipt",
    "evidence_refs": ["cleanup deferred while validating historical landing receipt"]
  },
  "validation_evidence_refs": ["route-neutral checks passed at ${landed_ref}"],
  "review_waiver_refs": ["solo maintainer no-PR route"],
  "durable_history": {"kind": "commit", "ref": "${landed_ref}", "branch": "feature/post-evidence"},
  "rollback_handle": {"kind": "revert-commit", "ref": "${landed_ref}"},
  "closeout_outcome": "completed",
  "created_at": "2026-06-23T00:00:00Z"
}
JSON
)"
  attach_valid_landing_authorization "$receipt" >/dev/null
  printf '%s\n' "$receipt"
}

case_live_origin_main_descendant_requires_explicit_mode() {
  local receipt
  receipt="$(write_live_descendant_receipt)"
  ! bash "$VALIDATOR" --receipt "$receipt" --require-live-remote >/dev/null
}

case_live_origin_main_descendant_mode_passes() {
  local receipt
  receipt="$(write_live_descendant_receipt)"
  bash "$VALIDATOR" --receipt "$receipt" --require-live-remote --allow-live-origin-main-descendant >/dev/null
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

write_valid_target_route_neutral_ruleset() {
  write_file <<'JSON'
[
  {
    "type": "required_status_checks",
    "parameters": {
      "strict_required_status_checks_policy": true,
      "required_status_checks": [
        {"context": "route_neutral_closeout_validation"},
        {"context": "branch_naming_validation"},
        {"context": "route_aware_autonomy_validation"},
        {"context": "exact_source_sha_validation"}
      ]
    }
  },
  {"type": "non_fast_forward"},
  {"type": "deletion"},
  {"type": "required_linear_history"}
]
JSON
}

case_route_neutral_ruleset_passes_target_expectation() {
  local rules
  rules="$(write_valid_target_route_neutral_ruleset)"
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

case_missing_linear_history_rule_fails_target_expectation() {
  local rules
  rules="$(write_valid_target_route_neutral_ruleset)"
  rewrite_json_file "$rules" 'map(select(.type != "required_linear_history"))'
  ! bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

case_missing_deletion_rule_fails_target_expectation() {
  local rules
  rules="$(write_valid_target_route_neutral_ruleset)"
  rewrite_json_file "$rules" 'map(select(.type != "deletion"))'
  ! bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

case_missing_non_fast_forward_rule_fails_target_expectation() {
  local rules
  rules="$(write_valid_target_route_neutral_ruleset)"
  rewrite_json_file "$rules" 'map(select(.type != "non_fast_forward"))'
  ! bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

case_pr_only_universal_check_fails_target_expectation() {
  local rules
  rules="$(write_valid_target_route_neutral_ruleset)"
  rewrite_json_file "$rules" 'map(if .type == "required_status_checks" then .parameters.required_status_checks += [{"context": "AI Review Gate / decision"}] else . end)'
  ! bash "$RULESET_VALIDATOR" --expect target-route-neutral --ruleset-json "$rules" >/dev/null
}

main() {
  assert_success "hosted no-PR static alignment passes" case_static_alignment_passes
  assert_success "valid hosted no-PR example passes" case_valid_hosted_no_pr_example_passes
  assert_success "invalid pushed-only example fails" case_invalid_pushed_only_example_fails
  assert_success "valid hosted no-PR receipt passes" case_valid_hosted_no_pr_receipt_passes
  assert_success "pushed-only branch cannot claim hosted landing" case_pushed_only_branch_cannot_claim_hosted_landing
  assert_success "missing hosted landing evidence fails" case_missing_hosted_landing_fails
  assert_success "mismatched landed ref fails" case_mismatched_landed_ref_fails
  assert_success "hosted no-PR receipt missing one route-neutral check fails" case_missing_route_neutral_check_fails
  assert_success "hosted no-PR check ref not bound to source SHA fails" case_check_ref_without_source_sha_fails
  assert_success "authorized empty-check-set hosted no-PR receipt passes" case_authorized_empty_check_set_passes
  assert_success "unauthorized empty-check-set hosted no-PR receipt fails" case_unauthorized_empty_check_set_fails
  assert_success "empty-check-set receipt and authorization mismatch fails" case_empty_check_set_authorization_mismatch_fails
  assert_success "empty-check-set authorization missing rationale fails" case_empty_check_set_missing_rationale_fails
  assert_success "hosted no-PR receipt missing pushed source branch evidence fails" case_missing_pushed_source_branch_evidence_fails
  assert_success "hosted no-PR receipt missing landing authorization fails" case_missing_landing_authorization_fails
  assert_success "hosted no-PR receipt denied landing authorization fails" case_denied_landing_authorization_fails
  assert_success "hosted no-PR receipt stale landing authorization fails" case_stale_landing_authorization_fails
  assert_success "PR metadata fails for branch-no-pr hosted landing" case_pr_metadata_fails
  assert_success "live origin/main descendant still fails strict live equality" case_live_origin_main_descendant_requires_explicit_mode
  assert_success "live origin/main descendant mode passes after evidence retention" case_live_origin_main_descendant_mode_passes
  assert_success "current PR-required ruleset passes current expectation" case_current_pr_required_ruleset_passes_current_expectation
  assert_success "route-neutral ruleset passes target expectation" case_route_neutral_ruleset_passes_target_expectation
  assert_success "PR rule fails target route-neutral expectation" case_pr_rule_fails_target_expectation
  assert_success "missing linear history rule fails target route-neutral expectation" case_missing_linear_history_rule_fails_target_expectation
  assert_success "missing deletion rule fails target route-neutral expectation" case_missing_deletion_rule_fails_target_expectation
  assert_success "missing non-fast-forward rule fails target route-neutral expectation" case_missing_non_fast_forward_rule_fails_target_expectation
  assert_success "PR-only universal check fails target route-neutral expectation" case_pr_only_universal_check_fails_target_expectation

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
