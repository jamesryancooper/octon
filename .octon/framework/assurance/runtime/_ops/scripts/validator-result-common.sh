#!/usr/bin/env bash

VALIDATOR_EVIDENCE_REFS=()
VALIDATOR_RUNTIME_TESTS=()
VALIDATOR_NEGATIVE_CONTROLS=()
VALIDATOR_LIMITATIONS=()
VALIDATOR_RECOGNIZED_CONTRACTS=()
VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS=()

normalize_depth() {
  case "${1:-}" in
    existence) printf 'existence\n' ;;
    schema) printf 'schema\n' ;;
    semantic) printf 'semantic\n' ;;
    runtime) printf 'runtime\n' ;;
    proof) printf 'proof\n' ;;
    closure-grade|closure_grade|closure) printf 'closure-grade\n' ;;
    *) printf '%s\n' "${1:-}" ;;
  esac
}

depth_rank() {
  case "$(normalize_depth "${1:-}")" in
    existence) printf '1\n' ;;
    schema) printf '2\n' ;;
    semantic) printf '3\n' ;;
    runtime) printf '4\n' ;;
    proof) printf '5\n' ;;
    closure-grade) printf '6\n' ;;
    *) printf '0\n' ;;
  esac
}

depth_at_least() {
  local actual required
  actual="$(depth_rank "${1:-}")"
  required="$(depth_rank "${2:-}")"
  [[ "$actual" -ge "$required" ]]
}

max_depth() {
  local best="existence"
  local candidate
  for candidate in "$@"; do
    if depth_at_least "$candidate" "$best"; then
      best="$(normalize_depth "$candidate")"
    fi
  done
  printf '%s\n' "$best"
}

min_depth() {
  local best=""
  local candidate
  for candidate in "$@"; do
    [[ -n "${candidate:-}" ]] || continue
    if [[ -z "$best" ]] || ! depth_at_least "$candidate" "$best"; then
      best="$(normalize_depth "$candidate")"
    fi
  done
  printf '%s\n' "${best:-existence}"
}

pick_existing_file() {
  local candidate
  for candidate in "$@"; do
    [[ -n "${candidate:-}" ]] || continue
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

yaml_quote() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

emit_yaml_list() {
  local indent="$1"
  shift
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] || continue
    printf '%s- %s\n' "$indent" "$(yaml_quote "$item")"
  done
}

reset_validator_result_metadata() {
  VALIDATOR_EVIDENCE_REFS=()
  VALIDATOR_RUNTIME_TESTS=()
  VALIDATOR_NEGATIVE_CONTROLS=()
  VALIDATOR_LIMITATIONS=()
  VALIDATOR_RECOGNIZED_CONTRACTS=()
  VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS=()
}

validator_result_add_evidence() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_EVIDENCE_REFS+=("$item")
  done
}

validator_result_add_runtime_test() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_RUNTIME_TESTS+=("$item")
  done
}

validator_result_add_negative_control() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_NEGATIVE_CONTROLS+=("$item")
  done
}

validator_result_add_limitation() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_LIMITATIONS+=("$item")
  done
}

validator_result_add_contract() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_RECOGNIZED_CONTRACTS+=("$item")
  done
}

validator_result_add_schema_version() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS+=("$item")
  done
}

print_validator_result() {
  local validator_id="$1"
  local dimension="$2"
  local claimed_depth="$3"
  local achieved_depth="$4"
  local status="$5"

  printf -- '---\n'
  printf 'schema_version: "octon-validator-result-v1"\n'
  printf 'validator_id: %s\n' "$(yaml_quote "$validator_id")"
  printf 'dimension: %s\n' "$(yaml_quote "$dimension")"
  printf 'claimed_depth: %s\n' "$(yaml_quote "$(normalize_depth "$claimed_depth")")"
  printf 'achieved_depth: %s\n' "$(yaml_quote "$(normalize_depth "$achieved_depth")")"
  printf 'status: %s\n' "$(yaml_quote "$status")"

  printf 'evidence_refs:\n'
  emit_yaml_list '  ' "${VALIDATOR_EVIDENCE_REFS[@]-}"

  printf 'runtime_tests_executed:\n'
  emit_yaml_list '  ' "${VALIDATOR_RUNTIME_TESTS[@]-}"

  printf 'negative_controls_executed:\n'
  emit_yaml_list '  ' "${VALIDATOR_NEGATIVE_CONTROLS[@]-}"

  printf 'recognized_contracts:\n'
  emit_yaml_list '  ' "${VALIDATOR_RECOGNIZED_CONTRACTS[@]-}"

  printf 'recognized_schema_versions:\n'
  emit_yaml_list '  ' "${VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS[@]-}"

  printf 'limitations:\n'
  emit_yaml_list '  ' "${VALIDATOR_LIMITATIONS[@]-}"
}

emit_validator_result() {
  local validator_id="$1"
  local dimension="$2"
  local claimed_depth="$3"
  local achieved_depth="$4"
  local status="$5"

  if [[ -n "${OCTON_VALIDATOR_RESULT_FILE:-}" ]]; then
    print_validator_result "$validator_id" "$dimension" "$claimed_depth" "$achieved_depth" "$status" >>"$OCTON_VALIDATOR_RESULT_FILE"
  fi

  if [[ "${OCTON_EMIT_VALIDATOR_RESULT:-0}" == "1" ]]; then
    print_validator_result "$validator_id" "$dimension" "$claimed_depth" "$achieved_depth" "$status"
  fi
}
