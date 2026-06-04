#!/usr/bin/env bash

VALIDATOR_EVIDENCE_REFS=()
VALIDATOR_RUNTIME_TESTS=()
VALIDATOR_NEGATIVE_CONTROLS=()
VALIDATOR_RECOGNIZED_NEGATIVE_CONTROLS=()
VALIDATOR_LIMITATIONS=()
VALIDATOR_RECOGNIZED_CONTRACTS=()
VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS=()
VALIDATOR_FAILING_SLICE_REFS=()
VALIDATOR_STDOUT_REF=""
VALIDATOR_STDERR_REF=""

VALIDATOR_RESULT_COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR_RESULT_DEFAULT_ROOT="$(cd -- "$VALIDATOR_RESULT_COMMON_DIR/../../../../../.." && pwd)"

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
  VALIDATOR_RECOGNIZED_NEGATIVE_CONTROLS=()
  VALIDATOR_LIMITATIONS=()
  VALIDATOR_RECOGNIZED_CONTRACTS=()
  VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS=()
  VALIDATOR_FAILING_SLICE_REFS=()
  VALIDATOR_STDOUT_REF=""
  VALIDATOR_STDERR_REF=""
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

validator_result_add_recognized_negative_control() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_RECOGNIZED_NEGATIVE_CONTROLS+=("$item")
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

validator_result_add_failing_slice() {
  local item
  for item in "$@"; do
    [[ -n "${item:-}" ]] && VALIDATOR_FAILING_SLICE_REFS+=("$item")
  done
}

validator_result_set_stdout_ref() {
  VALIDATOR_STDOUT_REF="${1:-}"
}

validator_result_set_stderr_ref() {
  VALIDATOR_STDERR_REF="${1:-}"
}

validator_result_repo_root() {
  if [[ -n "${OCTON_ROOT_DIR:-}" ]]; then
    printf '%s\n' "$OCTON_ROOT_DIR"
  else
    printf '%s\n' "$VALIDATOR_RESULT_DEFAULT_ROOT"
  fi
}

validator_result_resolve_ref() {
  local ref="${1:-}"
  local root
  root="$(validator_result_repo_root)"
  case "$ref" in
    /.octon/*|/.github/*)
      printf '%s/%s\n' "$root" "${ref#/}"
      ;;
    .octon/*|.github/*)
      printf '%s/%s\n' "$root" "$ref"
      ;;
    *)
      printf '%s\n' "$ref"
      ;;
  esac
}

validator_result_hash_file() {
  local path="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{print "sha256:" $1}'
  else
    sha256sum "$path" | awk '{print "sha256:" $1}'
  fi
}

validator_result_add_unique_ref() {
  local item="$1"
  local seen="$2"
  [[ -n "${item:-}" ]] || return 1
  case "$item" in
    .octon/*|/.octon/*|.github/*|/.github/*) ;;
    *) return 1 ;;
  esac
  case "$seen" in
    *"|$item|"*) return 1 ;;
    *) printf '%s\n' "$item" ;;
  esac
}

emit_validator_result_source_refs() {
  local indent="$1"
  local seen="|"
  local item added emitted=0
  for item in \
    "${VALIDATOR_EVIDENCE_REFS[@]-}" \
    "${VALIDATOR_RUNTIME_TESTS[@]-}" \
    "${VALIDATOR_RECOGNIZED_CONTRACTS[@]-}" \
    "${OCTON_VALIDATOR_EXTRA_SOURCE_REFS:-}"; do
    added="$(validator_result_add_unique_ref "$item" "$seen" || true)"
    [[ -n "$added" ]] || continue
    seen="${seen}${added}|"
    printf '%s- %s\n' "$indent" "$(yaml_quote "$added")"
    emitted=$((emitted + 1))
  done
  [[ "$emitted" -gt 0 ]] || printf '%s[]\n' "$indent"
}

emit_validator_result_source_digests() {
  local indent="$1"
  local seen="|"
  local item added path digest status emitted=0
  for item in \
    "${VALIDATOR_EVIDENCE_REFS[@]-}" \
    "${VALIDATOR_RUNTIME_TESTS[@]-}" \
    "${VALIDATOR_RECOGNIZED_CONTRACTS[@]-}" \
    "${OCTON_VALIDATOR_EXTRA_SOURCE_REFS:-}"; do
    added="$(validator_result_add_unique_ref "$item" "$seen" || true)"
    [[ -n "$added" ]] || continue
    seen="${seen}${added}|"
    path="$(validator_result_resolve_ref "$added")"
    if [[ -f "$path" ]]; then
      digest="$(validator_result_hash_file "$path")"
      status="present"
    elif [[ -e "$path" ]]; then
      digest="not-file"
      status="not-digestible"
    else
      digest="missing"
      status="missing"
    fi
    printf '%s- ref: %s\n' "$indent" "$(yaml_quote "$added")"
    printf '%s  sha256: %s\n' "$indent" "$(yaml_quote "$digest")"
    printf '%s  status: %s\n' "$indent" "$(yaml_quote "$status")"
    emitted=$((emitted + 1))
  done
  [[ "$emitted" -gt 0 ]] || printf '%s[]\n' "$indent"
}

print_validator_result() {
  local validator_id="$1"
  local dimension="$2"
  local claimed_depth="$3"
  local achieved_depth="$4"
  local status="$5"

  printf -- '---\n'
  printf 'schema_version: "octon-validator-result-v1"\n'
  printf 'manifest_schema_version: "octon-validator-result-manifest-v1"\n'
  printf 'artifact_role: "validator-result-manifest"\n'
  printf 'validator_id: %s\n' "$(yaml_quote "$validator_id")"
  printf 'dimension: %s\n' "$(yaml_quote "$dimension")"
  printf 'claimed_depth: %s\n' "$(yaml_quote "$(normalize_depth "$claimed_depth")")"
  printf 'achieved_depth: %s\n' "$(yaml_quote "$(normalize_depth "$achieved_depth")")"
  printf 'status: %s\n' "$(yaml_quote "$status")"

  printf 'producer:\n'
  printf '  id: %s\n' "$(yaml_quote "$validator_id")"
  printf '  helper_ref: ".octon/framework/assurance/runtime/_ops/scripts/validator-result-common.sh"\n'

  printf 'consumer:\n'
  printf '  preferred: "validator-result-manifest"\n'
  printf '  allowed_consumers:\n'
  printf '    - "validators"\n'
  printf '    - "operators"\n'
  printf '  forbidden_consumers:\n'
  printf '    - "runtime"\n'
  printf '    - "policy"\n'
  printf '    - "authority"\n'
  printf '    - "support-claim-evaluation"\n'

  printf 'source_refs:\n'
  emit_validator_result_source_refs '  '

  printf 'source_digests:\n'
  emit_validator_result_source_digests '  '

  printf 'validation:\n'
  printf '  status: %s\n' "$(yaml_quote "$status")"
  printf '  pass_count: %s\n' "$([[ "$status" == "pass" ]] && printf '1' || printf '0')"
  printf '  fail_count: %s\n' "$([[ "$status" == "pass" ]] && printf '0' || printf '1')"
  printf '  claimed_depth: %s\n' "$(yaml_quote "$(normalize_depth "$claimed_depth")")"
  printf '  achieved_depth: %s\n' "$(yaml_quote "$(normalize_depth "$achieved_depth")")"
  printf '  stdout_ref: %s\n' "$(yaml_quote "${VALIDATOR_STDOUT_REF:-${OCTON_VALIDATOR_STDOUT_REF:-}}")"
  printf '  stderr_ref: %s\n' "$(yaml_quote "${VALIDATOR_STDERR_REF:-${OCTON_VALIDATOR_STDERR_REF:-}}")"
  printf '  failing_slice_refs:\n'
  emit_yaml_list '    ' "${VALIDATOR_FAILING_SLICE_REFS[@]-}"

  printf 'evidence_refs:\n'
  emit_yaml_list '  ' "${VALIDATOR_EVIDENCE_REFS[@]-}"

  printf 'runtime_tests_executed:\n'
  emit_yaml_list '  ' "${VALIDATOR_RUNTIME_TESTS[@]-}"

  printf 'negative_controls_executed:\n'
  emit_yaml_list '  ' "${VALIDATOR_NEGATIVE_CONTROLS[@]-}"

  printf 'negative_controls_recognized:\n'
  emit_yaml_list '  ' "${VALIDATOR_RECOGNIZED_NEGATIVE_CONTROLS[@]-}"

  printf 'recognized_contracts:\n'
  emit_yaml_list '  ' "${VALIDATOR_RECOGNIZED_CONTRACTS[@]-}"

  printf 'recognized_schema_versions:\n'
  emit_yaml_list '  ' "${VALIDATOR_RECOGNIZED_SCHEMA_VERSIONS[@]-}"

  printf 'limitations:\n'
  emit_yaml_list '  ' "${VALIDATOR_LIMITATIONS[@]-}"

  printf 'failure_behavior:\n'
  printf '  fail_closed_on:\n'
  printf '    - "missing-source"\n'
  printf '    - "source-digest-mismatch"\n'
  printf '    - "stale-freshness"\n'
  printf '    - "authority-boundary-violation"\n'
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
