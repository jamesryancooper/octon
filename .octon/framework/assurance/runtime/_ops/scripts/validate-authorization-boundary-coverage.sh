#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"
RECEIPT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/coverage.yml"
TOKEN_CONTRACT="$(pick_existing_file "$OCTON_DIR/framework/engine/runtime/spec/authorized-effect-token-v1.md" || true)"

errors=0
token_mode_active=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    pass "yq available"
  else
    fail "yq is required for authorization boundary coverage validation"
    exit 1
  fi
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|/.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "${raw#/}"
      ;;
    .octon/*|.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "$raw"
      ;;
    *)
      printf '%s\n' "$raw"
      ;;
  esac
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq -- "$text" "$file"
  else
    grep -Fq -- "$text" "$file"
  fi
}

token_mode_enabled() {
  local coverage_map_file="$1"

  if [[ "${OCTON_ENFORCE_EFFECT_TOKENS:-0}" == "1" || -n "${TOKEN_CONTRACT:-}" ]]; then
    return 0
  fi

  yq -e '.paths[]? | select((.authorized_effect_token_type // .token_type // .authorized_effect_token_ref // .token_mediation.token_type // .token_mediation.ref // "") != "")' "$coverage_map_file" >/dev/null 2>&1
}

token_runtime_enforced() {
  has_text 'execution_artifact_effects(' "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs" \
    && has_text 'service_invocation_effect(' "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs" \
    && has_text 'service_invocation_effect(' "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/stdio.rs" \
    && has_text 'execution_artifact_effects(' "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs" \
    && has_text 'execution_artifact_effects(' "$ROOT_DIR/.octon/framework/engine/runtime/crates/kernel/src/workflow.rs" \
    && has_text 'validate_authorized_effect<' "$ROOT_DIR/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs"
}

path_token_ref() {
  local coverage_map_file="$1" path_id="$2"
  yq -r ".paths[] | select(.path_id == \"$path_id\") | (.authorized_effect_token_type // .token_type // .authorized_effect_token_ref // .token_mediation.token_type // .token_mediation.ref // \"\")" "$coverage_map_file"
}

path_has_token_negative_control() {
  local coverage_map_file="$1" path_id="$2"
  local control
  while IFS= read -r control; do
    [[ -n "$control" ]] || continue
    case "$control" in
      *token*|*bypass*)
        return 0
        ;;
    esac
  done < <(yq -r ".paths[] | select(.path_id == \"$path_id\") | .negative_controls[]? // \"\"" "$coverage_map_file")
  return 1
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/coverage.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-authorization-boundary-coverage.sh" \
  ".octon/framework/assurance/runtime/_ops/tests/test-authorization-boundary-negative-controls.sh" \
  ".octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh"
validator_result_add_negative_control \
  "negative-controls-declared-for-each-path" \
  "token-bypass-denial-declared-when-token-mode-active"
validator_result_add_schema_version \
  "authorization-boundary-coverage-v1" \
  "authorization-boundary-coverage-v2"
[[ -n "${TOKEN_CONTRACT:-}" ]] && validator_result_add_contract "${TOKEN_CONTRACT#$ROOT_DIR/}"

main() {
  echo "== Authorization Boundary Coverage Validation =="

  require_yq
  [[ -f "$RECEIPT" ]] && pass "authorization coverage receipt present" || { fail "missing receipt $RECEIPT"; echo "Validation summary: errors=$errors"; exit 1; }

  case "$(yq -r '.schema_version // ""' "$RECEIPT")" in
    authorization-boundary-coverage-v1|authorization-boundary-coverage-v2)
      pass "authorization coverage receipt schema is current"
      ;;
    *)
      fail "authorization coverage receipt schema must be a supported authorization-boundary-coverage version"
      ;;
  esac

  local spec_ref coverage_map_ref
  spec_ref="$(yq -r '.spec_ref // ""' "$RECEIPT")"
  coverage_map_ref="$(yq -r '.coverage_map_ref // ""' "$RECEIPT")"
  local coverage_map_file
  coverage_map_file="$(resolve_repo_path "$coverage_map_ref")"
  if [[ -f "$coverage_map_file" ]] && token_mode_enabled "$coverage_map_file"; then
    token_mode_active=1
    pass "authorized-effect token validation active"
  else
    validator_result_add_limitation "authorized-effect token contract is not active in the current authorization coverage map"
  fi

  if [[ -n "$spec_ref" && -f "$(resolve_repo_path "$spec_ref")" ]]; then
    pass "authorization boundary spec present"
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$(resolve_repo_path "$spec_ref")"; then
        pass "authorization spec covers: $required_text"
      else
        fail "authorization spec must cover: $required_text"
      fi
    done < <(yq -r '.spec_assertions[]? // ""' "$RECEIPT")
  else
    fail "authorization boundary spec missing: $spec_ref"
  fi

  while IFS= read -r path_id; do
    [[ -n "$path_id" ]] || continue
    local file_ref
    file_ref="$(yq -r ".inventory[] | select(.path_id == \"$path_id\") | .file" "$RECEIPT")"
    local resolved_file
    resolved_file="$(resolve_repo_path "$file_ref")"
    if [[ -f "$resolved_file" ]]; then
      pass "$path_id file present"
    else
      fail "$path_id file missing: $file_ref"
      continue
    fi

    while IFS= read -r required_pattern; do
      [[ -n "$required_pattern" ]] || continue
      if has_text "$required_pattern" "$resolved_file"; then
        pass "$path_id contains pattern: $required_pattern"
      else
        fail "$path_id missing pattern: $required_pattern"
      fi
    done < <(yq -r ".inventory[] | select(.path_id == \"$path_id\") | .required_patterns[]? // \"\"" "$RECEIPT")

    local denial_reason_code negative_control_count test_count
    denial_reason_code="$(yq -r ".paths[] | select(.path_id == \"$path_id\") | .denial_reason_code // \"\"" "$coverage_map_file")"
    negative_control_count="$(yq -r ".paths[] | select(.path_id == \"$path_id\") | (.negative_controls // []) | length" "$coverage_map_file")"
    test_count="$(yq -r ".paths[] | select(.path_id == \"$path_id\") | (.tests // []) | length" "$coverage_map_file")"
    [[ -n "$denial_reason_code" && "$denial_reason_code" != "null" ]] && pass "$path_id declares denial reason code" || fail "$path_id must declare denial reason code"
    [[ "$negative_control_count" != "0" ]] && pass "$path_id declares negative controls" || fail "$path_id must declare negative controls"
    [[ "$test_count" != "0" ]] && pass "$path_id declares test coverage" || fail "$path_id must declare test coverage"

    if [[ $token_mode_active -eq 1 ]]; then
      local token_ref
      token_ref="$(path_token_ref "$coverage_map_file" "$path_id")"
      [[ -n "$token_ref" && "$token_ref" != "null" ]] \
        && pass "$path_id declares authorized-effect token mediation" \
        || fail "$path_id must declare authorized-effect token mediation"

      if path_has_token_negative_control "$coverage_map_file" "$path_id"; then
        pass "$path_id declares token bypass negative control"
      else
        fail "$path_id must declare a token bypass negative control"
      fi
    fi
  done < <(yq -r '.inventory[]?.path_id // ""' "$RECEIPT")

  while IFS= read -r workflow_ref; do
    [[ -n "$workflow_ref" ]] || continue
    local resolved_workflow
    resolved_workflow="$(resolve_repo_path "$workflow_ref")"
    if [[ -f "$resolved_workflow" ]]; then
      pass "workflow gate present: $workflow_ref"
    else
      fail "workflow gate missing: $workflow_ref"
      continue
    fi
    while IFS= read -r required_text; do
      [[ -n "$required_text" ]] || continue
      if has_text "$required_text" "$resolved_workflow"; then
        pass "$workflow_ref contains gate text: $required_text"
      else
        fail "$workflow_ref must contain gate text: $required_text"
      fi
    done < <(yq -r ".workflow_gates[] | select(.workflow_ref == \"$workflow_ref\") | .required_text[]? // \"\"" "$RECEIPT")
  done < <(yq -r '.workflow_gates[]?.workflow_ref // ""' "$RECEIPT")

  echo "Validation summary: errors=$errors"
  if [[ $errors -eq 0 ]]; then
    emit_validator_result "validate-authorization-boundary-coverage.sh" "authorization_coverage" "runtime" "runtime" "pass"
    if [[ $token_mode_active -eq 1 ]]; then
      if token_runtime_enforced; then
        emit_validator_result "validate-authorization-boundary-coverage.sh" "authorized_effect_tokens" "runtime" "runtime" "pass"
      else
        emit_validator_result "validate-authorization-boundary-coverage.sh" "authorized_effect_tokens" "semantic" "semantic" "pass"
      fi
    fi
  else
    emit_validator_result "validate-authorization-boundary-coverage.sh" "authorization_coverage" "runtime" "existence" "fail"
    if [[ $token_mode_active -eq 1 ]]; then
      emit_validator_result "validate-authorization-boundary-coverage.sh" "authorized_effect_tokens" "runtime" "existence" "fail"
    fi
  fi
  [[ $errors -eq 0 ]]
}

main "$@"
