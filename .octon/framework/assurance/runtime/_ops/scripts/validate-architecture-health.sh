#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"

CONTRACT_PATH="$(pick_existing_file \
  "$OCTON_DIR/framework/engine/runtime/spec/architecture-health-contract-v3.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/architecture-health-contract-v2.md")"

default_validators=(
  "validate-architecture-conformance.sh"
  "validate-runtime-resolution.sh"
  "validate-runtime-effective-route-bundle.sh"
  "validate-runtime-effective-artifact-handles.sh"
  "validate-no-raw-generated-effective-runtime-reads.sh"
  "validate-material-side-effect-inventory.sh"
  "validate-authorization-boundary-coverage.sh"
  "validate-run-lifecycle-transition-coverage.sh"
  "validate-support-target-path-normalization.sh"
  "validate-support-target-proofing.sh"
  "validate-proof-bundle-executability.sh"
  "validate-support-pack-admission-alignment.sh"
  "validate-publication-freshness-gates.sh"
  "validate-extension-active-state-compactness.sh"
  "validate-operator-read-models.sh"
  "validate-compatibility-retirement-readiness.sh"
  "validate-compatibility-retirement-cutover.sh"
  "validate-operator-boot-surface.sh"
  "validate-proof-plane-completeness.sh"
)

default_matrix=(
  "structural_contract|semantic|validate-architecture-conformance.sh|required"
  "runtime_effective_handles|runtime|validate-runtime-effective-route-bundle.sh|required"
  "runtime_effective_handles|runtime|validate-runtime-effective-artifact-handles.sh|required"
  "freshness_modes|runtime|validate-generated-effective-freshness.sh|required"
  "publication_receipts|runtime|validate-publication-freshness-gates.sh|required"
  "authorization_coverage|runtime|validate-authorization-boundary-coverage.sh|required"
  "capability_pack_cutover|runtime|validate-support-pack-admission-alignment.sh|required"
  "extension_lifecycle|runtime|validate-extension-active-state-compactness.sh|required"
  "support_proof|proof|validate-support-target-proofing.sh|required"
  "support_proof|proof|validate-proof-bundle-executability.sh|required"
  "operator_read_models|semantic|validate-operator-read-models.sh|required"
  "compatibility_retirement|semantic|validate-compatibility-retirement-cutover.sh|required"
  "authorized_effect_tokens|runtime|validate-material-side-effect-inventory.sh|optional"
  "authorized_effect_tokens|runtime|validate-authorization-boundary-coverage.sh|optional"
)

validators=()
matrix_entries=()
dimension_names=()
dimension_required_depths=()
dimension_achieved_depths=()
dimension_sources=()
dimension_validators=()

validator_failures=0
depth_failures=0
passes=0

STATUS_FILE=""
RESULTS_FILE=""
RESULTS_FILE_IS_TEMP=0

load_entries_from_file() {
  local file="$1"
  local target_name="$2"
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "${line:-}" ]] || continue
    [[ "${line#\#}" != "$line" ]] && continue
    case "$target_name" in
      validators)
        validators+=("$line")
        ;;
      matrix_entries)
        matrix_entries+=("$line")
        ;;
    esac
  done <"$file"
}

load_configuration() {
  if [[ -n "${OCTON_ARCHITECTURE_HEALTH_VALIDATORS_FILE:-}" ]]; then
    load_entries_from_file "$OCTON_ARCHITECTURE_HEALTH_VALIDATORS_FILE" validators
  else
    validators=("${default_validators[@]}")
  fi

  if [[ -n "${OCTON_ARCHITECTURE_HEALTH_MATRIX_FILE:-}" ]]; then
    load_entries_from_file "$OCTON_ARCHITECTURE_HEALTH_MATRIX_FILE" matrix_entries
  else
    matrix_entries=("${default_matrix[@]}")
  fi
}

record_validator_status() {
  printf '%s\t%s\n' "$1" "$2" >>"$STATUS_FILE"
}

validator_status() {
  local validator="$1"
  local status=""

  if [[ -n "$STATUS_FILE" && -f "$STATUS_FILE" ]]; then
    status="$(awk -F'\t' -v target="$validator" '$1 == target { value = $2 } END { print value }' "$STATUS_FILE")"
  fi

  if [[ -z "$status" && -f "$RESULTS_FILE" ]]; then
    status="$(yq -r "select(.validator_id == \"$validator\") | .status" "$RESULTS_FILE" 2>/dev/null | awk 'NF { value = $0 } END { print value }')"
  fi

  printf '%s\n' "$status"
}

best_emitted_depth() {
  local validator="$1"
  local dimension="$2"
  local candidate
  local best=""

  [[ -f "$RESULTS_FILE" ]] || return 0

  while IFS= read -r candidate; do
    [[ -n "${candidate:-}" ]] || continue
    if [[ -z "$best" ]]; then
      best="$(normalize_depth "$candidate")"
    else
      best="$(max_depth "$best" "$candidate")"
    fi
  done < <(yq -r "select(.validator_id == \"$validator\" and .dimension == \"$dimension\") | .achieved_depth" "$RESULTS_FILE" 2>/dev/null || true)

  printf '%s\n' "$best"
}

best_emitted_status() {
  local validator="$1"
  local dimension="$2"
  local candidate
  local best=""

  [[ -f "$RESULTS_FILE" ]] || return 0

  while IFS= read -r candidate; do
    [[ -n "${candidate:-}" ]] || continue
    best="$candidate"
  done < <(yq -r "select(.validator_id == \"$validator\" and .dimension == \"$dimension\") | .status" "$RESULTS_FILE" 2>/dev/null || true)

  printf '%s\n' "$best"
}

dimension_index() {
  local dimension="$1"
  local i

  for ((i = 0; i < ${#dimension_names[@]}; i++)); do
    if [[ "${dimension_names[$i]}" == "$dimension" ]]; then
      printf '%s\n' "$i"
      return 0
    fi
  done

  return 1
}

append_unique_csv() {
  local current="$1"
  local item="$2"

  if [[ -z "$current" ]]; then
    printf '%s\n' "$item"
    return 0
  fi

  case ",$current," in
    *,"$item",*)
      printf '%s\n' "$current"
      ;;
    *)
      printf '%s,%s\n' "$current" "$item"
      ;;
  esac
}

update_dimension_state() {
  local dimension="$1"
  local required_depth="$2"
  local achieved_depth="$3"
  local validator="$4"
  local source="$5"
  local idx

  if idx="$(dimension_index "$dimension" 2>/dev/null)"; then
    dimension_required_depths[$idx]="$(max_depth "${dimension_required_depths[$idx]}" "$required_depth")"
    dimension_achieved_depths[$idx]="$(max_depth "${dimension_achieved_depths[$idx]}" "$achieved_depth")"
    dimension_sources[$idx]="$(append_unique_csv "${dimension_sources[$idx]}" "$source")"
    dimension_validators[$idx]="$(append_unique_csv "${dimension_validators[$idx]}" "$validator")"
    return 0
  fi

  dimension_names+=("$dimension")
  dimension_required_depths+=("$(normalize_depth "$required_depth")")
  dimension_achieved_depths+=("$(normalize_depth "$achieved_depth")")
  dimension_sources+=("$source")
  dimension_validators+=("$validator")
}

prepare_results_file() {
  if [[ -n "${OCTON_ARCHITECTURE_HEALTH_RESULTS_FILE:-}" ]]; then
    RESULTS_FILE="$OCTON_ARCHITECTURE_HEALTH_RESULTS_FILE"
    return 0
  fi

  RESULTS_FILE="$(mktemp)"
  RESULTS_FILE_IS_TEMP=1
}

run_validators() {
  local validator output
  local previous_result_file="${OCTON_VALIDATOR_RESULT_FILE:-}"

  STATUS_FILE="$(mktemp)"

  for validator in "${validators[@]}"; do
    if output="$(OCTON_VALIDATOR_RESULT_FILE="$RESULTS_FILE" bash "$SCRIPT_DIR/$validator" 2>&1)"; then
      echo "- PASS \`$validator\`"
      record_validator_status "$validator" "pass"
      passes=$((passes + 1))
    else
      echo "- FAIL \`$validator\`"
      if [[ -n "$output" ]]; then
        echo "$output" >&2
      fi
      record_validator_status "$validator" "fail"
      validator_failures=$((validator_failures + 1))
    fi
  done

  if [[ -n "$previous_result_file" ]]; then
    export OCTON_VALIDATOR_RESULT_FILE="$previous_result_file"
  else
    unset OCTON_VALIDATOR_RESULT_FILE || true
  fi
}

evaluate_dimensions() {
  local entry dimension required_depth validator requirement_mode
  local row_depth row_source emitted_depth emitted_status invocation_status

  for entry in "${matrix_entries[@]}"; do
    IFS='|' read -r dimension required_depth validator requirement_mode <<<"$entry"
    requirement_mode="${requirement_mode:-required}"

    emitted_depth="$(best_emitted_depth "$validator" "$dimension")"
    emitted_status="$(best_emitted_status "$validator" "$dimension")"
    invocation_status="$(validator_status "$validator")"

    row_source="missing"
    row_depth="existence"

    if [[ "$emitted_status" == "fail" || "$invocation_status" == "fail" ]]; then
      row_source="validator-failed"
      row_depth="existence"
    elif [[ -n "$emitted_depth" ]]; then
      row_source="emitted"
      row_depth="$emitted_depth"
    elif [[ "$requirement_mode" == "optional" ]]; then
      continue
    elif [[ "$invocation_status" == "pass" ]]; then
      row_source="fallback"
      row_depth="$required_depth"
    fi

    update_dimension_state "$dimension" "$required_depth" "$row_depth" "$validator" "$row_source"
  done
}

report_dimensions() {
  local i dimension required_depth achieved_depth source validators_csv overall_depth
  local active_depths=()

  echo
  echo "## Dimension Depths"

  for ((i = 0; i < ${#dimension_names[@]}; i++)); do
    dimension="${dimension_names[$i]}"
    required_depth="${dimension_required_depths[$i]}"
    achieved_depth="${dimension_achieved_depths[$i]}"
    source="${dimension_sources[$i]}"
    validators_csv="${dimension_validators[$i]}"

    active_depths+=("$achieved_depth")
    if depth_at_least "$achieved_depth" "$required_depth"; then
      echo "- PASS \`$dimension\`: required_depth=\`$required_depth\`, achieved_depth=\`$achieved_depth\`, source=\`$source\`, validators=\`$validators_csv\`"
    else
      echo "- FAIL \`$dimension\`: required_depth=\`$required_depth\`, achieved_depth=\`$achieved_depth\`, source=\`$source\`, validators=\`$validators_csv\`"
      depth_failures=$((depth_failures + 1))
    fi
  done

  overall_depth="$(min_depth "${active_depths[@]}")"
  echo
  echo "Summary: pass=$passes validator_fail=$validator_failures depth_fail=$depth_failures"

  reset_validator_result_metadata
  [[ -n "${CONTRACT_PATH:-}" ]] && validator_result_add_evidence "${CONTRACT_PATH#$ROOT_DIR/}"
  validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-architecture-health-depth.sh"
  validator_result_add_negative_control "shallow-achieved-depth-refuses-closure-grade"
  [[ -n "${CONTRACT_PATH:-}" ]] && validator_result_add_contract "${CONTRACT_PATH#$ROOT_DIR/}"
  validator_result_add_schema_version "architecture-health-contract-v2" "architecture-health-contract-v3"

  if [[ "${CONTRACT_PATH##*/}" != "architecture-health-contract-v3.md" ]]; then
    validator_result_add_limitation "architecture-health-contract-v3.md is not present; the validator emits v3-style achieved-depth records against the live contract"
  fi

  if [[ $validator_failures -eq 0 && $depth_failures -eq 0 ]]; then
    emit_validator_result "validate-architecture-health.sh" "architecture_health" "closure-grade" "closure-grade" "pass"
  else
    emit_validator_result "validate-architecture-health.sh" "architecture_health" "closure-grade" "$overall_depth" "fail"
  fi
}

cleanup() {
  [[ -n "$STATUS_FILE" && -f "$STATUS_FILE" ]] && rm -f "$STATUS_FILE"
  if [[ $RESULTS_FILE_IS_TEMP -eq 1 && -n "$RESULTS_FILE" && -f "$RESULTS_FILE" ]]; then
    rm -f "$RESULTS_FILE"
  fi
}

trap cleanup EXIT

echo "## Architecture Health"
[[ -n "${CONTRACT_PATH:-}" ]] || echo "- WARN \`architecture-health contract\` missing" >&2

load_configuration
prepare_results_file

if [[ -z "${OCTON_ARCHITECTURE_HEALTH_RESULTS_FILE:-}" ]]; then
  run_validators
else
  echo "- Using precomputed validator results: \`$RESULTS_FILE\`"
fi

evaluate_dimensions
report_dimensions

[[ $validator_failures -eq 0 && $depth_failures -eq 0 ]]
