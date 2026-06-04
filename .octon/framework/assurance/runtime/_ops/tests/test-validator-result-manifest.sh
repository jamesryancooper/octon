#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
HELPER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validator-result-common.sh"
RESULT_FILE="$(mktemp "${TMPDIR:-/tmp}/octon-validator-result-manifest.XXXXXX")"
trap 'rm -f "$RESULT_FILE"' EXIT

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

emit_fixture_result() {
  local status="$1"
  OCTON_ROOT_DIR="$ROOT_DIR" OCTON_VALIDATOR_RESULT_FILE="$RESULT_FILE" bash -c '
    source "$1"
    reset_validator_result_metadata
    validator_result_add_evidence ".octon/framework/engine/runtime/spec/operator-read-models-v1.md"
    validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-validator-result-manifest.sh"
    validator_result_add_contract ".octon/framework/engine/runtime/spec/operator-read-models-v1.md"
    validator_result_add_negative_control "fixture-negative-executed"
    validator_result_add_recognized_negative_control "fixture-negative-recognized"
    validator_result_add_schema_version "fixture-schema-v1"
    validator_result_add_failing_slice ".octon/state/evidence/runs/demo/failing-slice-manifest.yml"
    validator_result_set_stdout_ref ".octon/state/evidence/runs/demo/stdout.txt"
    validator_result_set_stderr_ref ".octon/state/evidence/runs/demo/stderr.txt"
    emit_validator_result "fixture-validator.sh" "fixture_dimension" "runtime" "runtime" "$2"
  ' _ "$HELPER" "$status"
}

case_manifest_fields_present() {
  : >"$RESULT_FILE"
  emit_fixture_result pass
  yq -e 'select(.validator_id == "fixture-validator.sh") | .schema_version == "octon-validator-result-v1"' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .manifest_schema_version == "octon-validator-result-manifest-v1"' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .artifact_role == "validator-result-manifest"' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .producer.helper_ref == ".octon/framework/assurance/runtime/_ops/scripts/validator-result-common.sh"' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .consumer.allowed_consumers[] | select(. == "validators")' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .consumer.forbidden_consumers[] | select(. == "runtime")' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .source_refs[] | select(. == ".octon/framework/engine/runtime/spec/operator-read-models-v1.md")' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .source_digests[] | select(.ref == ".octon/framework/engine/runtime/spec/operator-read-models-v1.md" and .status == "present" and (.sha256 | test("^sha256:[0-9a-f]{64}$")))' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .validation.pass_count == 1 and .validation.fail_count == 0' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh") | .failure_behavior.fail_closed_on[] | select(. == "source-digest-mismatch")' "$RESULT_FILE" >/dev/null
}

case_fail_manifest_records_failing_slice() {
  : >"$RESULT_FILE"
  emit_fixture_result fail
  yq -e 'select(.validator_id == "fixture-validator.sh" and .status == "fail") | .validation.fail_count == 1 and .validation.pass_count == 0' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh" and .status == "fail") | .validation.failing_slice_refs[] | select(. == ".octon/state/evidence/runs/demo/failing-slice-manifest.yml")' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh" and .status == "fail") | .validation.stdout_ref == ".octon/state/evidence/runs/demo/stdout.txt"' "$RESULT_FILE" >/dev/null
  yq -e 'select(.validator_id == "fixture-validator.sh" and .status == "fail") | .validation.stderr_ref == ".octon/state/evidence/runs/demo/stderr.txt"' "$RESULT_FILE" >/dev/null
}

main() {
  assert_success "validator result manifest fields are present" case_manifest_fields_present
  assert_success "failing validator manifest records slices and stream refs" case_fail_manifest_records_failing_slice

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
