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

assert_success "static evidence disclosure tier contracts pass" case_static_contract_passes
assert_success "valid publishable receipt passes" case_valid_publishable_receipt_passes
assert_success "missing tier metadata fails" case_missing_tier_metadata_fails
assert_success "tracked local-only evidence fails" case_tracked_local_evidence_fails
assert_success "oversized receipt emits warning without failing" case_oversized_receipt_warns
assert_success "oversized receipt fails without exception" case_oversized_receipt_fails
assert_success "hosted closeout rejects local-only evidence" case_hosted_closeout_local_only_fails
assert_success "hosted closeout rejects generated evidence" case_hosted_closeout_generated_ref_fails
assert_success "hosted closeout accepts publishable evidence ref" case_hosted_closeout_publishable_ref_passes

echo "Tests passed: $pass_count"
if [[ "$fail_count" -ne 0 ]]; then
  echo "Tests failed: $fail_count" >&2
  exit 1
fi
