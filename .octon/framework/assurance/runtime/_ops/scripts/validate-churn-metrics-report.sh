#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$(cd -- "$OCTON_DIR_OVERRIDE" && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
elif [[ -n "${OCTON_ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd -- "$OCTON_ROOT_DIR" && pwd)"
  OCTON_DIR="$ROOT_DIR/.octon"
else
  OCTON_DIR="$DEFAULT_OCTON_DIR"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
fi

SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/churn-metrics-report-v1.schema.json"
RESULT_COMMON="$SCRIPT_DIR/validator-result-common.sh"
REPORT=""
SCHEMA_ONLY=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-churn-metrics-report.sh --report <path>
  validate-churn-metrics-report.sh --schema-only
USAGE
}

pass() { printf '[OK] %s\n' "$1"; }
fail() {
  printf '[ERROR] %s\n' "$1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      REPORT="$1"
      ;;
    --schema-only)
      SCHEMA_ONLY=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

require_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool available"
  else
    fail "$tool is required"
  fi
}

require_json_file() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    fail "$label exists"
    return 0
  fi
  if python3 -m json.tool "$file" >/dev/null 2>&1; then
    pass "$label parses as JSON"
  else
    fail "$label parses as JSON"
  fi
}

field() {
  yq -r "$1 // \"\"" "$REPORT" 2>/dev/null || true
}

require_field_eq() {
  local expr="$1"
  local expected="$2"
  local label="$3"
  local actual
  actual="$(field "$expr")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_false() {
  local expr="$1"
  local label="$2"
  local actual
  actual="$(yq -r "$expr" "$REPORT" 2>/dev/null || true)"
  if [[ "$actual" == "false" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_nonempty() {
  local expr="$1"
  local label="$2"
  local actual
  actual="$(field "$expr")"
  if [[ -n "$actual" && "$actual" != "null" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_nonnegative_number() {
  local expr="$1"
  local label="$2"
  local actual
  actual="$(field "$expr")"
  if [[ "$actual" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_required_metric() {
  local metric="$1"
  if yq -e ".metrics.${metric}" "$REPORT" >/dev/null 2>&1; then
    pass "metric present: $metric"
  else
    fail "metric present: $metric"
  fi
}

validate_report() {
  [[ -n "$REPORT" ]] || { fail "report path supplied"; return 0; }
  [[ -f "$REPORT" ]] && pass "report exists" || { fail "report exists"; return 0; }
  yq -e '.' "$REPORT" >/dev/null 2>&1 && pass "report parses as YAML/JSON" || fail "report parses as YAML/JSON"

  require_field_eq '.schema_version' 'octon-churn-metrics-report-v1' 'schema_version is octon-churn-metrics-report-v1'
  require_field_eq '.artifact_role' 'churn-metrics-report' 'artifact_role is churn-metrics-report'
  require_field_eq '.non_authority_classification' 'measurement-only' 'report is measurement-only'
  require_nonempty '.report_id' 'report_id present'
  require_nonempty '.producer.id' 'producer id present'
  require_nonempty '.producer.entrypoint_ref' 'producer entrypoint ref present'
  require_nonempty '.producer.owner' 'producer owner present'
  require_nonempty '.scope.path_family' 'scope path family present'
  require_nonempty '.scope.authority_classification' 'scope authority classification present'

  require_false '.authority_boundaries.generated_outputs_are_authority' 'metrics do not make generated outputs authority'
  require_false '.authority_boundaries.metrics_replace_freshness_validation' 'metrics do not replace freshness validation'
  require_false '.authority_boundaries.metrics_replace_closeout_validation' 'metrics do not replace closeout validation'
  require_false '.authority_boundaries.metrics_authorize_cleanup' 'metrics do not authorize cleanup'
  require_false '.authority_boundaries.metrics_satisfy_support_claims' 'metrics do not satisfy support claims'

  local forbidden
  for forbidden in runtime policy authority support-claim-evaluation freshness-validation closeout cleanup-authorization; do
    if yq -e ".consumer.forbidden_consumers[]? | select(. == \"$forbidden\")" "$REPORT" >/dev/null 2>&1; then
      pass "forbidden consumer declared: $forbidden"
    else
      fail "forbidden consumer declared: $forbidden"
    fi
  done

  local metric
  for metric in \
    changed_file_count \
    generated_noop_rewrite_rate \
    receipt_fanout_count \
    dirty_worktree_residue_count \
    tmp_byte_file_count \
    process_runtime \
    token_budget_impact \
    validation_coverage_retained \
    freshness_lock_receipt_validation_retained \
    evidence_retrieval_integrity; do
    require_required_metric "$metric"
  done

  require_nonnegative_number '.metrics.changed_file_count.baseline_count' 'changed file baseline count is numeric'
  require_nonnegative_number '.metrics.changed_file_count.post_change_count' 'changed file post-change count is numeric'
  require_nonnegative_number '.metrics.generated_noop_rewrite_rate.noop_invocations' 'no-op invocation count is numeric'
  require_nonnegative_number '.metrics.generated_noop_rewrite_rate.rewrites_detected' 'rewrite count is numeric'
  require_nonnegative_number '.metrics.generated_noop_rewrite_rate.rate' 'rewrite rate is numeric'
  require_nonnegative_number '.metrics.receipt_fanout_count.baseline_count' 'receipt fanout baseline count is numeric'
  require_nonnegative_number '.metrics.receipt_fanout_count.post_change_count' 'receipt fanout post-change count is numeric'
  require_nonnegative_number '.metrics.dirty_worktree_residue_count.baseline_count' 'dirty residue baseline count is numeric'
  require_nonnegative_number '.metrics.dirty_worktree_residue_count.post_change_count' 'dirty residue post-change count is numeric'
  require_nonnegative_number '.metrics.tmp_byte_file_count.file_count' '.tmp file count is numeric'
  require_nonnegative_number '.metrics.tmp_byte_file_count.byte_count' '.tmp byte count is numeric'
  require_nonnegative_number '.metrics.process_runtime.seconds' 'process runtime is numeric'
  require_nonnegative_number '.metrics.token_budget_impact.diff_line_count' 'diff line count is numeric'
  require_nonnegative_number '.metrics.token_budget_impact.estimated_token_count' 'estimated token count is numeric'
  require_nonnegative_number '.metrics.validation_coverage_retained.validators_expected' 'validators expected count is numeric'
  require_nonnegative_number '.metrics.validation_coverage_retained.validators_passed' 'validators passed count is numeric'
  require_nonnegative_number '.metrics.freshness_lock_receipt_validation_retained.checks_expected' 'freshness checks expected count is numeric'
  require_nonnegative_number '.metrics.freshness_lock_receipt_validation_retained.checks_passed' 'freshness checks passed count is numeric'
  require_nonnegative_number '.metrics.evidence_retrieval_integrity.references_checked' 'evidence refs checked count is numeric'
  require_nonnegative_number '.metrics.evidence_retrieval_integrity.references_missing' 'evidence refs missing count is numeric'

  require_field_eq '.metrics.validation_coverage_retained.coverage_retained' 'true' 'validation coverage retained'
  require_field_eq '.metrics.freshness_lock_receipt_validation_retained.coverage_retained' 'true' 'freshness/lock/receipt validation retained'

  if yq -e '.validation.validators_run | length > 0' "$REPORT" >/dev/null 2>&1; then
    pass "validators_run non-empty"
  else
    fail "validators_run non-empty"
  fi
  if yq -e '.validation.negative_controls | length > 0' "$REPORT" >/dev/null 2>&1; then
    pass "negative_controls non-empty"
  else
    fail "negative_controls non-empty"
  fi
}

main() {
  require_tool yq
  require_tool python3
  require_json_file "$SCHEMA" "churn metrics report schema"

  if [[ "$SCHEMA_ONLY" -eq 1 ]]; then
    :
  else
    validate_report
  fi

  if [[ -f "$RESULT_COMMON" ]]; then
    # shellcheck source=/dev/null
    source "$RESULT_COMMON"
    reset_validator_result_metadata
    validator_result_add_contract ".octon/framework/product/contracts/churn-metrics-report-v1.schema.json"
    validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-churn-common-generator-idempotency-metrics.sh"
    validator_result_add_negative_control "churn metrics report cannot claim authority, freshness, closeout, support, or cleanup authorization"
    validator_result_add_schema_version "octon-churn-metrics-report-v1"
    emit_validator_result "validate-churn-metrics-report.sh" "producer_churn_metrics" "semantic" "semantic" "$([[ "$errors" -eq 0 ]] && printf pass || printf fail)"
  fi

  printf 'Validation summary: errors=%s\n' "$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"
