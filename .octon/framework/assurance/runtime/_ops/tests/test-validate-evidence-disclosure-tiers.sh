#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()
declare -a CLEANUP_FILES=()

cleanup() {
  local dir file
  for file in "${CLEANUP_FILES[@]}"; do
    [[ -n "$file" ]] && rm -f -- "$file"
  done
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf -- "$dir"
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

assert_failure_contains() {
  local label="$1" needle="$2"
  shift 2
  local output="" rc=0
  output="$("$@" 2>&1)" || rc=$?
  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$label"
    return 0
  fi
  fail "$label"
  echo "  expected failure containing: $needle" >&2
  echo "$output" >&2
  return 1
}

fixture_root() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/evidence-tier-validator.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  mkdir -p \
    "$root/.octon/framework/constitution/contracts/retention" \
    "$root/.octon/state/evidence/local"
  cp "$ROOT_DIR/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml" \
    "$root/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml"
  cp "$ROOT_DIR/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json" \
    "$root/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json"
  cp "$ROOT_DIR/.octon/state/evidence/local/README.md" \
    "$root/.octon/state/evidence/local/README.md"
  git -C "$root" init -q
  git -C "$root" add .octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml
  git -C "$root" add .octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json
  git -C "$root" add .octon/state/evidence/local/README.md
  printf '%s\n' "$root"
}

write_valid_publishable_receipt() {
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/publishable-receipt.XXXXXX")"
  CLEANUP_FILES+=("$file")
  cat >"$file" <<'JSON'
{
  "schema_version": "publishable-evidence-receipt-v1",
  "receipt_id": "fixture-valid",
  "receipt_mode": "example_fixture",
  "created_at": "2026-05-28T12:00:00Z",
  "issuer_ref": "test-validate-evidence-disclosure-tiers",
  "disclosure_tier": "repo-publishable",
  "evidence_tier_ref": "repo_publishable_evidence",
  "claim_scope": {
    "claim_id": "fixture-claim",
    "claim_type": "example",
    "statement": "Fixture validates a publishable receipt.",
    "applies_to": [".octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json"]
  },
  "source_summary": {
    "summary": "Raw evidence is cited by digest without publication.",
    "source_refs": [".octon/state/evidence/local/raw.log"],
    "raw_evidence_published": false
  },
  "validation_summary": {
    "verdict": "example-only",
    "commands_or_checks": ["validate-evidence-disclosure-tiers.sh --receipt fixture"],
    "evidence_refs": ["fixture-validator-output"]
  },
  "redactions": {
    "status": "not-required",
    "summary": "No raw payload is included.",
    "redacted_fields": []
  },
  "limitations": [
    {
      "limitation_id": "fixture-only",
      "description": "Fixture evidence only.",
      "impact": "No production claim."
    }
  ],
  "local_evidence_refs": [
    {
      "ref_kind": "repo-relative-path",
      "ref": ".octon/state/evidence/local/raw.log",
      "digest_algorithm": "sha256",
      "digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "raw_evidence_not_published": true,
      "description": "Digest pointer to local-only raw fixture evidence."
    }
  ],
  "outcome": {
    "result": "example-only",
    "summary": "Fixture passes.",
    "decided_at": "2026-05-28T12:00:00Z"
  },
  "rollback_or_discard": {
    "posture": "discard fixture",
    "trigger": "test completion",
    "instructions": "Delete temporary fixture."
  },
  "authority_boundaries": {
    "raw_inputs_not_authority": true,
    "generated_outputs_not_authority": true,
    "proposal_paths_not_authority": true,
    "host_state_not_authority": true,
    "parent_program_evidence_not_substitute": true
  },
  "concision": {
    "declared_receipt_size_bytes": 0,
    "warning_threshold_bytes": 65536,
    "failure_threshold_bytes": 262144,
    "size_exception_authorized": false
  }
}
JSON
  printf '%s\n' "$file"
}

write_change_receipt() {
  local evidence_ref="$1"
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/change-receipt.XXXXXX")"
  CLEANUP_FILES+=("$file")
  cat >"$file" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-hosted-closeout",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "landed",
  "lifecycle_outcome": "landed",
  "outcome_intent": "attempt-landing",
  "intent": "Fixture hosted closeout.",
  "scope": {
    "summary": "Fixture hosted closeout.",
    "diff_refs": ["origin/fixture@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  },
  "validation_evidence_refs": ["$evidence_ref"],
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "deferred",
  "rollback_handle": {"kind": "git-ref", "ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
  "closeout_outcome": "completed",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "fixture",
    "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "target_pre_ref": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "target_post_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "validated_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "required_check_refs": ["ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
    "provider_ruleset_ref": "route-neutral-main",
    "fast_forward_only": true
  },
  "created_at": "2026-05-28T12:00:00Z"
}
JSON
  printf '%s\n' "$file"
}

digest_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

write_local_terminal_sink() {
  local root="$1"
  local change_id="${2:-fixture-hosted-closeout}"
  local content="${3:-terminal proof fixture}"
  local dir proof manifest digest
  dir="$root/.octon/state/evidence/local/terminal-closeout/$change_id"
  mkdir -p "$dir"
  proof="$dir/terminal-current-state-proof.yml"
  manifest="$dir/manifest.json"
  printf '%s\n' "$content" >"$proof"
  digest="$(digest_file "$proof")"
  cat >"$manifest" <<JSON
{
  "schema_version": "terminal-closeout-local-evidence-v1",
  "change_id": "$change_id",
  "non_authority_classification": "retained-evidence-only"
}
JSON
  printf '%s %s\n' ".octon/state/evidence/local/terminal-closeout/$change_id/terminal-current-state-proof.yml" "$digest"
}

write_change_receipt_with_terminal_sink() {
  local terminal_ref="$1"
  local terminal_digest="$2"
  local landing_auth_ref="${3:-.octon/state/evidence/runs/skills/closeout-change/fixture/landing-authorization.json}"
  local required_check_ref="${4:-ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}"
  local final_verification_ref="${5:-.octon/state/evidence/runs/skills/closeout-change/fixture/final-verification.yml}"
  local cleanup_auth_ref="${6:-.octon/state/evidence/runs/skills/closeout-change/fixture/branch-cleanup-authorization.json}"
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/change-receipt-terminal.XXXXXX")"
  CLEANUP_FILES+=("$file")
  cat >"$file" <<JSON
{
  "schema_version": "change-receipt-v1",
  "change_id": "fixture-hosted-closeout",
  "selected_route": "branch-no-pr",
  "target_lifecycle_outcome": "cleaned",
  "lifecycle_outcome": "cleaned",
  "outcome_intent": "attempt-cleaned-closeout",
  "intent": "Fixture hosted closeout.",
  "scope": {
    "summary": "Fixture hosted closeout.",
    "diff_refs": ["origin/fixture@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  },
  "validation_evidence_refs": [".octon/state/evidence/validation/fixture/publishable-receipt.json"],
  "landing_authorization_ref": "$landing_auth_ref",
  "cleanup_authorization_ref": "$cleanup_auth_ref",
  "terminal_current_state_proof_ref": "$terminal_ref",
  "terminal_current_state_proof_digest": "$terminal_digest",
  "integration_status": "landed",
  "publication_status": "hosted-main-updated",
  "cleanup_status": "completed",
  "cleanup_evidence_refs": [
    "$cleanup_auth_ref",
    ".octon/state/evidence/runs/skills/closeout-change/fixture/branch-cleanup.yml"
  ],
  "publishable_evidence_receipt_refs": [
    {
      "receipt_ref": ".octon/state/evidence/validation/fixture/publishable-receipt.json",
      "schema_ref": ".octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json",
      "disclosure_tier": "repo-publishable",
      "claim_scope_ref": "fixture-hosted-closeout-cleaned",
      "receipt_digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "raw_evidence_not_published": true
    }
  ],
  "rollback_handle": {"kind": "git-ref", "ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
  "closeout_outcome": "completed",
  "hosted_landing": {
    "remote": "origin",
    "target_branch": "main",
    "source_branch": "fixture",
    "source_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "target_pre_ref": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "target_post_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "validated_ref": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "required_check_refs": ["$required_check_ref"],
    "provider_ruleset_ref": "route-neutral-main",
    "fast_forward_only": true
  },
  "stateful_closeout": {
    "phase_exit_refs": [".octon/state/evidence/runs/skills/closeout-change/fixture/phase.yml"],
    "hosted_landing_refs": [".octon/state/evidence/runs/skills/closeout-change/fixture/hosted.yml"],
    "cleanup_decision_refs": ["$cleanup_auth_ref"],
    "branch_cleanup_refs": [".octon/state/evidence/runs/skills/closeout-change/fixture/branch-cleanup.yml"],
    "final_verification_ref": "$final_verification_ref"
  },
  "source_branch_cleanup": {
    "status": "completed",
    "local_branch": "fixture",
    "remote_branch": "origin/fixture",
    "evidence_refs": [
      "$cleanup_auth_ref",
      ".octon/state/evidence/runs/skills/closeout-change/fixture/branch-cleanup.yml"
    ]
  },
  "created_at": "2026-05-28T12:00:00Z"
}
JSON
  printf '%s\n' "$file"
}

run_validator() {
  local root="$1"
  shift
  bash "$VALIDATOR" --root "$root" "$@"
}

case_static_contract_passes() {
  local root
  root="$(fixture_root)"
  run_validator "$root" >/dev/null
}

case_valid_publishable_receipt_passes() {
  local root receipt
  root="$(fixture_root)"
  receipt="$(write_valid_publishable_receipt)"
  run_validator "$root" --receipt "$receipt" >/dev/null
}

case_missing_tier_metadata_fails() {
  local root receipt tmp
  root="$(fixture_root)"
  receipt="$(write_valid_publishable_receipt)"
  tmp="$(mktemp "${TMPDIR:-/tmp}/publishable-missing-tier.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  jq 'del(.disclosure_tier)' "$receipt" >"$tmp"
  assert_failure_contains "missing tier metadata is rejected" "missing disclosure_tier" run_validator "$root" --receipt "$tmp"
}

case_tracked_local_evidence_fails() {
  local root
  root="$(fixture_root)"
  printf 'raw local evidence\n' >"$root/.octon/state/evidence/local/raw.log"
  git -C "$root" add .octon/state/evidence/local/raw.log
  assert_failure_contains "tracked local-only evidence is rejected" "tracked local-only evidence is forbidden" run_validator "$root"
}

case_oversized_receipt_warns() {
  local root receipt tmp pad output
  root="$(fixture_root)"
  receipt="$(write_valid_publishable_receipt)"
  tmp="$(mktemp "${TMPDIR:-/tmp}/publishable-warning.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  pad="$(perl -e 'print "x" x 70000')"
  jq --arg pad "$pad" '.source_summary.summary = $pad' "$receipt" >"$tmp"
  output="$(run_validator "$root" --receipt "$tmp" 2>&1)"
  grep -Fq "[WARN] publishable receipt exceeds 64 KiB warning threshold" <<<"$output"
}

case_oversized_receipt_fails() {
  local root receipt tmp pad
  root="$(fixture_root)"
  receipt="$(write_valid_publishable_receipt)"
  tmp="$(mktemp "${TMPDIR:-/tmp}/publishable-fail.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  pad="$(perl -e 'print "x" x 270000')"
  jq --arg pad "$pad" '.source_summary.summary = $pad' "$receipt" >"$tmp"
  assert_failure_contains "oversized receipt is blocking without exception" "exceeds 256 KiB without size exception" run_validator "$root" --receipt "$tmp"
}

case_hosted_closeout_local_only_fails() {
  local root receipt
  root="$(fixture_root)"
  receipt="$(write_change_receipt ".octon/state/evidence/local/raw.log")"
  assert_failure_contains "hosted closeout local-only dependency is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_generated_ref_fails() {
  local root receipt
  root="$(fixture_root)"
  receipt="$(write_change_receipt ".octon/generated/effective/runtime/route-bundle.yml")"
  assert_failure_contains "hosted closeout generated dependency is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_publishable_ref_passes() {
  local root receipt
  root="$(fixture_root)"
  receipt="$(write_change_receipt ".octon/state/evidence/validation/fixture/publishable-receipt.json")"
  run_validator "$root" --change-receipt "$receipt" >/dev/null
}

case_hosted_closeout_local_terminal_ref_with_digest_passes() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  run_validator "$root" --change-receipt "$receipt" >/dev/null
}

case_hosted_closeout_local_terminal_ref_without_digest_fails() {
  local root sink terminal_ref terminal_digest receipt tmp
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/change-receipt-terminal-no-digest.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  jq 'del(.terminal_current_state_proof_digest)' "$receipt" >"$tmp"
  assert_failure_contains "local terminal ref without digest is rejected" "requires terminal_current_state_proof_digest" run_validator "$root" --change-receipt "$tmp"
}

case_hosted_closeout_local_terminal_ref_digest_mismatch_fails() {
  local root sink terminal_ref receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")"
  assert_failure_contains "local terminal digest mismatch is rejected" "digest must match" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_terminal_wrong_change_root_fails() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root" "other-change")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  assert_failure_contains "local terminal wrong change root is rejected" "must be under .octon/state/evidence/local/terminal-closeout/<change-id>/" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_sink_as_landing_authorization_fails() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest" "$terminal_ref")"
  assert_failure_contains "local sink as landing authorization is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_sink_as_hosted_check_fails() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest" ".octon/state/evidence/runs/skills/closeout-change/fixture/landing-authorization.json" "$terminal_ref")"
  assert_failure_contains "local sink as hosted check is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_sink_as_final_verification_fails() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest" ".octon/state/evidence/runs/skills/closeout-change/fixture/landing-authorization.json" "ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "$terminal_ref")"
  assert_failure_contains "local sink as final verification is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_sink_as_cleanup_authorization_fails() {
  local root sink terminal_ref terminal_digest receipt
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest" ".octon/state/evidence/runs/skills/closeout-change/fixture/landing-authorization.json" "ci@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" ".octon/state/evidence/runs/skills/closeout-change/fixture/final-verification.yml" "$terminal_ref")"
  assert_failure_contains "local sink as cleanup authorization is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_closeout_local_sink_as_cleanup_evidence_fails() {
  local root sink terminal_ref terminal_digest receipt tmp
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/change-receipt-local-cleanup-evidence.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  jq --arg ref "$terminal_ref" '.cleanup_evidence_refs = [$ref]' "$receipt" >"$tmp"
  assert_failure_contains "local sink as cleanup evidence is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$tmp"
}

case_hosted_closeout_proposal_path_ref_fails() {
  local root receipt
  root="$(fixture_root)"
  receipt="$(write_change_receipt ".octon/inputs/exploratory/proposals/architecture/fixture/proposal.yml")"
  assert_failure_contains "hosted closeout proposal-path dependency is rejected" "non-publishable evidence ref" run_validator "$root" --change-receipt "$receipt"
}

case_hosted_cleaned_missing_publishable_receipt_fails() {
  local root sink terminal_ref terminal_digest receipt tmp
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/change-receipt-no-publishable.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  jq 'del(.publishable_evidence_receipt_refs)' "$receipt" >"$tmp"
  assert_failure_contains "hosted cleaned claim without publishable evidence is rejected" "requires publishable_evidence_receipt_refs" run_validator "$root" --change-receipt "$tmp"
}

case_hosted_cleaned_blocked_routing_passes_without_publishable_success() {
  local root sink terminal_ref terminal_digest receipt tmp
  root="$(fixture_root)"
  sink="$(write_local_terminal_sink "$root")"
  terminal_ref="${sink% *}"
  terminal_digest="${sink##* }"
  receipt="$(write_change_receipt_with_terminal_sink "$terminal_ref" "$terminal_digest")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/change-receipt-blocked-cleaned.XXXXXX")"
  CLEANUP_FILES+=("$tmp")
  jq '
    .lifecycle_outcome = "landed"
    | .closeout_outcome = "continued"
    | .cleanup_status = "deferred"
    | .not_cleaned_reason = "Cleanup authorization is not yet publishable."
    | .cleanup_stop_reason = "governance_authorization_missing"
    | .source_branch_cleanup.status = "deferred"
    | .source_branch_cleanup.blocker_reason = "Cleanup authorization is not yet publishable."
    | .source_branch_cleanup.evidence_refs = [".octon/state/evidence/runs/skills/closeout-change/fixture/cleanup-blocker.yml"]
    | .cleanup_evidence_refs = [".octon/state/evidence/runs/skills/closeout-change/fixture/cleanup-blocker.yml"]
    | del(.cleanup_authorization_ref, .publishable_evidence_receipt_refs)
  ' "$receipt" >"$tmp"
  run_validator "$root" --change-receipt "$tmp" >/dev/null
}

assert_success "static evidence disclosure tier contracts pass" case_static_contract_passes
assert_success "valid publishable receipt passes" case_valid_publishable_receipt_passes
assert_success "missing tier metadata fails" case_missing_tier_metadata_fails
assert_success "tracked local-only evidence fails" case_tracked_local_evidence_fails
assert_success "oversized receipt emits warning without failing" case_oversized_receipt_warns
assert_success "oversized receipt fails without exception" case_oversized_receipt_fails
assert_success "hosted closeout rejects local-only evidence" case_hosted_closeout_local_only_fails
assert_success "hosted closeout rejects generated evidence" case_hosted_closeout_generated_ref_fails
assert_success "hosted closeout accepts publishable evidence ref" case_hosted_closeout_publishable_ref_passes
assert_success "hosted closeout accepts local terminal ref with digest" case_hosted_closeout_local_terminal_ref_with_digest_passes
assert_success "hosted closeout rejects local terminal ref without digest" case_hosted_closeout_local_terminal_ref_without_digest_fails
assert_success "hosted closeout rejects local terminal digest mismatch" case_hosted_closeout_local_terminal_ref_digest_mismatch_fails
assert_success "hosted closeout rejects local terminal wrong change root" case_hosted_closeout_local_terminal_wrong_change_root_fails
assert_success "hosted closeout rejects local sink as landing authorization" case_hosted_closeout_local_sink_as_landing_authorization_fails
assert_success "hosted closeout rejects local sink as hosted check evidence" case_hosted_closeout_local_sink_as_hosted_check_fails
assert_success "hosted closeout rejects local sink as final verification" case_hosted_closeout_local_sink_as_final_verification_fails
assert_success "hosted closeout rejects local sink as cleanup authorization" case_hosted_closeout_local_sink_as_cleanup_authorization_fails
assert_success "hosted closeout rejects local sink as cleanup evidence" case_hosted_closeout_local_sink_as_cleanup_evidence_fails
assert_success "hosted closeout rejects proposal-path evidence" case_hosted_closeout_proposal_path_ref_fails
assert_success "hosted cleaned claim rejects missing publishable evidence" case_hosted_cleaned_missing_publishable_receipt_fails
assert_success "blocked cleaned target routes without publishable success claim" case_hosted_cleaned_blocked_routing_passes_without_publishable_success

echo "Tests passed: $pass_count"
if [[ "$fail_count" -ne 0 ]]; then
  echo "Tests failed: $fail_count" >&2
  exit 1
fi
