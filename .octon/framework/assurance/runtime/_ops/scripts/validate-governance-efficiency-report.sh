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

SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/governance-efficiency-report-v1.schema.json"
RESULT_COMMON="$SCRIPT_DIR/validator-result-common.sh"
REPORT=""
SCHEMA_ONLY=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-governance-efficiency-report.sh --report <path>
  validate-governance-efficiency-report.sh --schema-only
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
  local file="$1" label="$2"
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
  local expr="$1" expected="$2" label="$3" actual
  actual="$(field "$expr")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_false() {
  local expr="$1" label="$2" actual
  actual="$(yq -r "$expr" "$REPORT" 2>/dev/null || true)"
  if [[ "$actual" == "false" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_nonempty() {
  local expr="$1" label="$2" actual
  actual="$(field "$expr")"
  if [[ -n "$actual" && "$actual" != "null" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_forbidden_consumer() {
  local consumer="$1"
  if yq -e ".consumer.forbidden_consumers[]? | select(. == \"$consumer\")" "$REPORT" >/dev/null 2>&1; then
    pass "forbidden consumer declared: $consumer"
  else
    fail "forbidden consumer declared: $consumer"
  fi
}

validate_findings() {
  local count index authority follow_up confidence evidence_count missing_count
  count="$(yq -r '(.findings // []) | length' "$REPORT" 2>/dev/null || echo 0)"
  if [[ "$count" =~ ^[0-9]+$ ]]; then
    pass "findings list is present"
  else
    fail "findings list is present"
    return 0
  fi

  missing_count="$(yq -r '.uncertainty.missing_evidence_count // 0' "$REPORT" 2>/dev/null || echo 0)"
  for ((index=0; index<count; index++)); do
    require_nonempty ".findings[$index].finding_id" "finding id present: findings[$index]"
    require_nonempty ".findings[$index].category" "finding category present: findings[$index]"
    evidence_count="$(yq -r "(.findings[$index].evidence_refs // []) | length" "$REPORT" 2>/dev/null || echo 0)"
    if [[ "$evidence_count" =~ ^[1-9][0-9]*$ ]]; then
      pass "finding evidence refs non-empty: findings[$index]"
    else
      fail "finding evidence refs non-empty: findings[$index]"
    fi
    authority="$(field ".findings[$index].recommendation_authority")"
    [[ "$authority" == "advisory-only" ]] \
      && pass "finding recommendation authority advisory-only: findings[$index]" \
      || fail "finding recommendation authority advisory-only: findings[$index]"
    follow_up="$(yq -r ".findings[$index].requires_follow_up_proposal // \"\"" "$REPORT" 2>/dev/null || true)"
    [[ "$follow_up" == "true" ]] \
      && pass "finding requires follow-up proposal: findings[$index]" \
      || fail "finding requires follow-up proposal: findings[$index]"
    confidence="$(field ".findings[$index].confidence")"
    if [[ "$missing_count" =~ ^[1-9][0-9]*$ && "$confidence" == "high" ]]; then
      fail "missing evidence cannot produce high confidence: findings[$index]"
    else
      pass "missing evidence confidence boundary held: findings[$index]"
    fi
  done
}

validate_report() {
  [[ -n "$REPORT" ]] || { fail "report path supplied"; return 0; }
  [[ -f "$REPORT" ]] && pass "report exists" || { fail "report exists"; return 0; }
  yq -e '.' "$REPORT" >/dev/null 2>&1 && pass "report parses as YAML/JSON" || fail "report parses as YAML/JSON"

  require_field_eq '.schema_version' 'octon-governance-efficiency-report-v1' 'schema_version is octon-governance-efficiency-report-v1'
  require_field_eq '.artifact_role' 'governance-efficiency-report' 'artifact_role is governance-efficiency-report'
  require_field_eq '.non_authority_classification' 'advisory-only' 'report is advisory-only'
  require_nonempty '.report_id' 'report_id present'
  require_nonempty '.producer.id' 'producer id present'
  require_nonempty '.producer.entrypoint_ref' 'producer entrypoint ref present'
  require_nonempty '.producer.owner' 'producer owner present'
  require_nonempty '.target.path' 'target path present'
  require_nonempty '.target.target_kind' 'target kind present'

  require_false '.authority_boundaries.authorizes_review' 'report does not authorize review'
  require_false '.authority_boundaries.authorizes_validation' 'report does not authorize validation'
  require_false '.authority_boundaries.authorizes_closeout' 'report does not authorize closeout'
  require_false '.authority_boundaries.authorizes_cleanup' 'report does not authorize cleanup'
  require_false '.authority_boundaries.authorizes_archive' 'report does not authorize archive'
  require_false '.authority_boundaries.authorizes_terminal_proof' 'report does not authorize terminal proof'
  require_false '.authority_boundaries.authorizes_policy_mutation' 'report does not authorize policy mutation'
  require_false '.authority_boundaries.authorizes_lifecycle_transition' 'report does not authorize lifecycle transition'
  require_false '.authority_boundaries.replaces_child_receipts' 'report does not replace child receipts'

  local forbidden
  for forbidden in review-authorization validation-gate closeout cleanup archive terminal-proof policy-mutation lifecycle-transition child-receipt-substitution; do
    require_forbidden_consumer "$forbidden"
  done

  if yq -e '(.evidence_inputs // []) | length > 0' "$REPORT" >/dev/null 2>&1; then
    pass "evidence inputs non-empty"
  else
    fail "evidence inputs non-empty"
  fi
  if yq -e '(.uncertainty.notes // []) | length > 0' "$REPORT" >/dev/null 2>&1; then
    pass "uncertainty notes non-empty"
  else
    fail "uncertainty notes non-empty"
  fi
  if yq -e '(.validation.validators_run // []) | length > 0' "$REPORT" >/dev/null 2>&1; then
    pass "validators_run non-empty"
  else
    fail "validators_run non-empty"
  fi
  if yq -e '(.validation.negative_controls // []) | length >= 9' "$REPORT" >/dev/null 2>&1; then
    pass "negative controls cover forbidden authority classes"
  else
    fail "negative controls cover forbidden authority classes"
  fi

  validate_findings
}

main() {
  require_tool yq
  require_tool python3
  require_json_file "$SCHEMA" "governance efficiency report schema"

  if [[ "$SCHEMA_ONLY" -eq 0 ]]; then
    validate_report
  fi

  if [[ -f "$RESULT_COMMON" ]]; then
    # shellcheck source=/dev/null
    source "$RESULT_COMMON"
    reset_validator_result_metadata
    validator_result_add_contract ".octon/framework/product/contracts/governance-efficiency-report-v1.schema.json"
    validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-validate-governance-efficiency-report.sh"
    validator_result_add_negative_control "governance efficiency output cannot authorize review, validation, closeout, cleanup, archive, terminal proof, policy mutation, lifecycle transition, or child receipt substitution"
    validator_result_add_schema_version "octon-governance-efficiency-report-v1"
    emit_validator_result "validate-governance-efficiency-report.sh" "governance_efficiency_report" "semantic" "semantic" "$([[ "$errors" -eq 0 ]] && printf pass || printf fail)"
  fi

  printf 'Validation summary: errors=%s\n' "$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"
