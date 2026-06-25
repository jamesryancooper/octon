#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
source "$ROOT_DIR/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"

extensions_common_init "$ROOT_DIR/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"

pass_count=0

pass() {
  printf 'PASS: %s\n' "$1"
  pass_count=$((pass_count + 1))
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

case_cached_compatibility_result_is_reused() {
  local key called=0
  key="$(ext_pack_key cached bundled)"
  EXT_SELECTED_KEYS=("$key")
  EXT_COMPAT_RESULT_STATUS["$key"]="compatible"
  EXT_COMPAT_PROFILE_REL["$key"]=".octon/inputs/additive/extensions/cached/validation/compatibility.yml"
  EXT_COMPAT_REQUIRED_INPUTS["$key"]=".octon/inputs/additive/extensions/cached/pack.yml"
  EXT_COMPAT_OVERALL_STATUS="incompatible"

  ext_validate_pack_core_contract() {
    called=1
    return 1
  }
  ext_evaluate_pack_host_compatibility() {
    called=1
    return 1
  }

  ext_collect_selected_compatibility_results

  [[ "$called" -eq 0 ]] || fail "cached compatibility result should not re-run heavy validation"
  [[ "${EXT_COMPAT_OVERALL_STATUS}" == "compatible" ]] || fail "cached compatible result should drive overall status"
  pass "cached compatibility result is reused"
}

case_uncached_compatibility_result_still_evaluates() {
  local key called=0
  key="$(ext_pack_key uncached bundled)"
  EXT_SELECTED_KEYS=("$key")
  unset 'EXT_COMPAT_RESULT_STATUS[$key]'
  EXT_COMPAT_OVERALL_STATUS="incompatible"

  ext_validate_pack_core_contract() {
    return 0
  }
  ext_evaluate_pack_host_compatibility() {
    called=1
    EXT_VALIDATED_COMPATIBILITY_STATUS="compatible"
    EXT_VALIDATED_COMPATIBILITY_PROFILE_REL=".octon/inputs/additive/extensions/uncached/validation/compatibility.yml"
    EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA="sha256:test"
    EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS=".octon/inputs/additive/extensions/uncached/pack.yml"
    EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_FILES=""
    EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_DIRECTORIES=""
    EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_COMMANDS=""
    EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_BEHAVIORS=""
    EXT_VALIDATED_COMPATIBILITY_DEGRADED_FEATURES=""
    EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS=""
    return 0
  }

  ext_collect_selected_compatibility_results

  [[ "$called" -eq 1 ]] || fail "uncached compatibility result should run validation"
  [[ "${EXT_COMPAT_RESULT_STATUS["$key"]}" == "compatible" ]] || fail "uncached compatibility result should be captured"
  [[ "${EXT_COMPAT_OVERALL_STATUS}" == "compatible" ]] || fail "uncached compatible result should drive overall status"
  pass "uncached compatibility result still evaluates"
}

case_cached_compatibility_result_is_reused
case_uncached_compatibility_result_still_evaluates

printf 'PASS: extension compatibility cache tests completed (%s cases)\n' "$pass_count"
