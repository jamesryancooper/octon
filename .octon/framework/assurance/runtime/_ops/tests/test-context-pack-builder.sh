#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1"

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

run_case() {
  local case_id="$1"
  bash "$VALIDATOR" \
    --root "$FIXTURE_ROOT" \
    --pack "cases/$case_id/pack.json" \
    --receipt "cases/$case_id/receipt.json" >/dev/null
}

run_missing_receipt_case() {
  bash "$VALIDATOR" \
    --root "$FIXTURE_ROOT" \
    --pack "cases/durable-valid-identical/pack.json" \
    --receipt "cases/missing-receipt/receipt.json" >/dev/null 2>&1
}

case_identical_inputs_pass() {
  run_case "durable-valid-identical"
}

case_shuffled_inputs_pass() {
  run_case "durable-valid-shuffled"
}

case_duplicate_inputs_fail() {
  ! run_case "durable-duplicate-sources"
}

case_forbidden_source_class_fails() {
  ! run_case "durable-forbidden-source-class"
}

case_generated_read_model_as_authority_fails() {
  ! run_case "durable-generated-authority"
}

case_raw_input_as_authority_fails() {
  ! run_case "durable-raw-authority"
}

case_stale_pack_fails() {
  ! run_case "durable-stale"
}

case_invalidated_pack_fails() {
  ! run_case "durable-invalidated"
}

case_missing_receipt_fails() {
  ! run_missing_receipt_case
}

case_missing_model_hash_file_fails() {
  ! run_case "durable-missing-model-hash-file"
}

case_missing_source_manifest_fails() {
  ! run_case "durable-missing-source-manifest"
}

case_replay_refs_missing_hash_fails() {
  ! run_case "durable-replay-refs-missing-hash"
}

case_retained_source_manifest_mismatch_fails() {
  ! run_case "durable-retained-source-manifest-mismatch"
}

case_replay_reconstruction_passes() {
  run_case "durable-valid-identical"
}

case_model_hash_mismatch_fails() {
  ! run_case "durable-model-hash-mismatch"
}

case_request_id_mismatch_fails() {
  ! run_case "durable-request-id-mismatch"
}

case_policy_ref_mismatch_fails() {
  ! run_case "durable-policy-ref-mismatch"
}

case_source_digest_mismatch_fails() {
  ! run_case "durable-source-digest-mismatch"
}

case_dot_journal_event_fails() {
  ! run_case "durable-dot-journal"
}

case_replay_mismatch_fails() {
  ! run_case "durable-replay-mismatch"
}

main() {
  assert_success "identical inputs pass deterministically" case_identical_inputs_pass
  assert_success "shuffled inputs pass with same canonical digest" case_shuffled_inputs_pass
  assert_success "duplicate inputs fail closed" case_duplicate_inputs_fail
  assert_success "forbidden source class fails closed" case_forbidden_source_class_fails
  assert_success "generated read model as authority fails closed" case_generated_read_model_as_authority_fails
  assert_success "raw input as authority fails closed" case_raw_input_as_authority_fails
  assert_success "model-visible hash mismatch fails closed" case_model_hash_mismatch_fails
  assert_success "request id mismatch fails closed" case_request_id_mismatch_fails
  assert_success "policy ref mismatch fails closed" case_policy_ref_mismatch_fails
  assert_success "source digest mismatch fails closed" case_source_digest_mismatch_fails
  assert_success "dot-named canonical journal event fails closed" case_dot_journal_event_fails
  assert_success "stale pack fails closed" case_stale_pack_fails
  assert_success "invalidated pack fails closed" case_invalidated_pack_fails
  assert_success "missing receipt fails closed" case_missing_receipt_fails
  assert_success "missing model-visible hash file fails closed" case_missing_model_hash_file_fails
  assert_success "missing source manifest fails closed" case_missing_source_manifest_fails
  assert_success "replay refs missing model-visible hash fail closed" case_replay_refs_missing_hash_fails
  assert_success "retained source manifest mismatch fails closed" case_retained_source_manifest_mismatch_fails
  assert_success "replay reconstruction passes" case_replay_reconstruction_passes
  assert_success "replay mismatch fails closed" case_replay_mismatch_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
