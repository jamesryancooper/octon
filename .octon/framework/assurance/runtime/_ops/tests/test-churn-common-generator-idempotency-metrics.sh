#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
COMMON="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generator-idempotency-common.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-churn-metrics-report.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
  done
}
trap cleanup EXIT

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

new_tmpdir() {
  local dir
  dir="$(mktemp -d "${TMPDIR:-/tmp}/octon-churn-common.XXXXXX")"
  CLEANUP_DIRS+=("$dir")
  printf '%s\n' "$dir"
}

write_valid_report() {
  local path="$1"
  cat >"$path" <<'YAML'
schema_version: "octon-churn-metrics-report-v1"
artifact_role: "churn-metrics-report"
report_id: "fixture-churn-report@2026-07-02T00:00:00Z"
generated_at: "2026-07-02T00:00:00Z"
non_authority_classification: "measurement-only"
producer:
  id: "fixture-producer"
  entrypoint_ref: ".octon/framework/assurance/runtime/_ops/scripts/fixture-producer.sh"
  owner: "fixture owner"
consumer:
  allowed_consumers:
    - "validators"
    - "operators"
  forbidden_consumers:
    - "runtime"
    - "policy"
    - "authority"
    - "support-claim-evaluation"
    - "freshness-validation"
    - "closeout"
    - "cleanup-authorization"
scope:
  path_family: "generated-derived-output"
  authority_classification: "derived-only"
authority_boundaries:
  generated_outputs_are_authority: false
  metrics_replace_freshness_validation: false
  metrics_replace_closeout_validation: false
  metrics_authorize_cleanup: false
  metrics_satisfy_support_claims: false
metrics:
  changed_file_count:
    baseline_count: 4
    post_change_count: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/changed-files.txt"
  generated_noop_rewrite_rate:
    noop_invocations: 1
    rewrites_detected: 0
    rate: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/noop.txt"
  receipt_fanout_count:
    baseline_count: 3
    post_change_count: 1
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/receipts.txt"
  dirty_worktree_residue_count:
    baseline_count: 2
    post_change_count: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/status.txt"
  tmp_byte_file_count:
    file_count: 0
    byte_count: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/tmp.txt"
  process_runtime:
    seconds: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/runtime.txt"
  token_budget_impact:
    diff_line_count: 0
    estimated_token_count: 0
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/tokens.txt"
  validation_coverage_retained:
    validators_expected: 1
    validators_passed: 1
    coverage_retained: true
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/validators.txt"
  freshness_lock_receipt_validation_retained:
    checks_expected: 0
    checks_passed: 0
    coverage_retained: true
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/freshness.txt"
  evidence_retrieval_integrity:
    references_checked: 0
    references_missing: 0
    retrieval_status: "not-applicable"
    evidence_ref: ".octon/state/evidence/validation/churn/fixture/retrieval.txt"
validation:
  validators_run:
    - "validate-churn-metrics-report.sh --report fixture.yml"
  negative_controls:
    - "metrics cannot satisfy freshness, closeout, support, cleanup, or authority gates"
evidence_refs:
  - ".octon/state/evidence/validation/churn/fixture/noop.txt"
YAML
}

case_write_if_changed_skips_identical_content() {
  local root candidate target before after result
  root="$(new_tmpdir)"
  candidate="$root/candidate.txt"
  target="$root/out/target.txt"
  mkdir -p "$(dirname "$target")"
  printf 'stable\n' >"$candidate"
  result="$(bash -c 'source "$1"; octon_churn_write_file_if_changed "$2" "$3"' _ "$COMMON" "$target" "$candidate")"
  [[ "$result" == "changed" ]] || return 1
  before="$(stat -f '%m' "$target" 2>/dev/null || stat -c '%Y' "$target")"
  sleep 1
  result="$(bash -c 'source "$1"; octon_churn_write_file_if_changed "$2" "$3"' _ "$COMMON" "$target" "$candidate")"
  after="$(stat -f '%m' "$target" 2>/dev/null || stat -c '%Y' "$target")"
  [[ "$result" == "unchanged" && "$before" == "$after" ]]
}

case_write_stdin_if_changed_updates_on_semantic_change() {
  local root target result content
  root="$(new_tmpdir)"
  target="$root/out/report.yml"
  result="$(printf 'one\n' | bash -c 'source "$1"; octon_churn_write_stdin_if_changed "$2"' _ "$COMMON" "$target")"
  [[ "$result" == "changed" ]] || return 1
  result="$(printf 'two\n' | bash -c 'source "$1"; octon_churn_write_stdin_if_changed "$2"' _ "$COMMON" "$target")"
  content="$(cat "$target")"
  [[ "$result" == "changed" && "$content" == "two" ]]
}

case_metric_ids_and_path_classification_are_available() {
  bash -c '
    source "$1"
    octon_churn_is_required_metric_id changed_file_count
    ! octon_churn_is_required_metric_id freshness_gate_replacement
    [[ "$(octon_churn_classify_path_family ".octon/generated/effective/runtime/route-bundle.yml")" == "runtime-facing-generated-effective" ]]
    [[ "$(octon_churn_classify_path_family ".octon/state/evidence/validation/demo/receipt.yml")" == "retained-evidence" ]]
    [[ "$(octon_churn_classify_path_family ".codex/skills/demo/SKILL.md")" == "host-projection" ]]
    [[ "$(octon_churn_classify_path_family ".octon/generated/.tmp/engine/build")" == "local-scratch" ]]
  ' _ "$COMMON"
}

case_valid_report_passes() {
  local root report
  root="$(new_tmpdir)"
  report="$root/report.yml"
  write_valid_report "$report"
  bash "$VALIDATOR" --report "$report" >/tmp/octon-churn-report-valid.out 2>&1
}

case_authority_widening_report_fails() {
  local root report
  root="$(new_tmpdir)"
  report="$root/report.yml"
  write_valid_report "$report"
  yq -i '.authority_boundaries.generated_outputs_are_authority = true' "$report"
  ! bash "$VALIDATOR" --report "$report" >/tmp/octon-churn-report-invalid.out 2>&1
}

case_missing_metric_fails() {
  local root report
  root="$(new_tmpdir)"
  report="$root/report.yml"
  write_valid_report "$report"
  yq -i 'del(.metrics.evidence_retrieval_integrity)' "$report"
  ! bash "$VALIDATOR" --report "$report" >/tmp/octon-churn-report-missing.out 2>&1
}

main() {
  assert_success "write-if-changed skips identical content" case_write_if_changed_skips_identical_content
  assert_success "stdin write-if-changed updates changed content" case_write_stdin_if_changed_updates_on_semantic_change
  assert_success "metric ids and path classification are available" case_metric_ids_and_path_classification_are_available
  assert_success "valid churn metric report passes" case_valid_report_passes
  assert_success "authority-widening churn metric report fails" case_authority_widening_report_fails
  assert_success "missing required metric fails" case_missing_metric_fails

  printf '\n%s: passed=%s failed=%s\n' "$(basename "$0")" "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
