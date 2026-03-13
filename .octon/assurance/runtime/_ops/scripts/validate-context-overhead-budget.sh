#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"

POLICY_FILE="$OCTON_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
RUNS_DIR="$OCTON_DIR/continuity/runs"
CLEAN_BREAK_CUTOFF="${OCTON_CONTEXT_GOV_CUTOVER_AT:-2026-02-25T00:00:00Z}"
errors=0
warnings=0
checked=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

read_threshold_value() {
  local key="$1"
  awk -v key="$key" '
    /^[[:space:]]*thresholds:[[:space:]]*$/ {in_thresholds=1; next}
    in_thresholds && /^[[:space:]]*required_receipt_fields:[[:space:]]*$/ {in_thresholds=0}
    in_thresholds && $1 == key ":" {
      print $2
      exit
    }
  ' "$POLICY_FILE"
}

read_required_receipt_fields() {
  awk '
    /^[[:space:]]*required_receipt_fields:[[:space:]]*$/ {in_required=1; next}
    in_required && /^[[:space:]]*[a-z_]+:[[:space:]]*$/ {in_required=0}
    in_required && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$POLICY_FILE"
}

float_ge() {
  local left="$1"
  local right="$2"
  awk -v a="$left" -v b="$right" 'BEGIN { exit !(a + 0 >= b + 0) }'
}

validate_receipt_fields() {
  local receipt="$1"
  shift
  local -a required_fields=("$@")
  local field

  for field in "${required_fields[@]}"; do
    if ! jq -e --arg field "$field" 'has($field)' "$receipt" >/dev/null; then
      fail "$receipt missing required receipt field: $field"
    fi
  done

  if ! jq -e '
    (.context_acquisition | type == "object") and
    (.context_acquisition.file_reads | type == "number" and . >= 0 and . == floor) and
    (.context_acquisition.search_queries | type == "number" and . >= 0 and . == floor) and
    (.context_acquisition.commands | type == "number" and . >= 0 and . == floor) and
    (.context_acquisition.subagent_spawns | type == "number" and . >= 0 and . == floor) and
    (.context_acquisition.duration_ms | type == "number" and . >= 0 and . == floor) and
    (.context_overhead_ratio | type == "number" and . >= 0)
  ' "$receipt" >/dev/null; then
    fail "$receipt has invalid context_acquisition or context_overhead_ratio values"
  fi
}

validate_receipt_budget() {
  local receipt="$1"
  local warn_ratio="$2"
  local soft_fail_ratio="$3"
  local hard_fail_ratio="$4"
  local max_context_files_read="$5"
  local max_context_acquisition_ms="$6"

  local ratio file_reads duration_ms
  ratio="$(jq -r '.context_overhead_ratio // 0' "$receipt")"
  file_reads="$(jq -r '.context_acquisition.file_reads // 0' "$receipt")"
  duration_ms="$(jq -r '.context_acquisition.duration_ms // 0' "$receipt")"

  if ! jq -en --arg ratio "$ratio" '$ratio | tonumber' >/dev/null 2>&1; then
    fail "$receipt context_overhead_ratio is not numeric: $ratio"
    return
  fi

  if float_ge "$ratio" "$hard_fail_ratio"; then
    fail "$receipt exceeds hard_fail_ratio ($ratio >= $hard_fail_ratio)"
  elif float_ge "$ratio" "$soft_fail_ratio"; then
    fail "$receipt exceeds soft_fail_ratio ($ratio >= $soft_fail_ratio)"
  elif float_ge "$ratio" "$warn_ratio"; then
    warn "$receipt exceeds warn_ratio ($ratio >= $warn_ratio)"
  fi

  if [[ "$file_reads" =~ ^[0-9]+$ ]] && (( file_reads > max_context_files_read )); then
    fail "$receipt exceeds max_context_files_read ($file_reads > $max_context_files_read)"
  fi
  if [[ "$duration_ms" =~ ^[0-9]+$ ]] && (( duration_ms > max_context_acquisition_ms )); then
    fail "$receipt exceeds max_context_acquisition_ms ($duration_ms > $max_context_acquisition_ms)"
  fi
}

main() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq is required for validate-context-overhead-budget.sh" >&2
    exit 1
  fi
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "[ERROR] policy file not found: $POLICY_FILE" >&2
    exit 1
  fi
  if [[ ! -d "$RUNS_DIR" ]]; then
    pass "runs directory not found; nothing to validate"
    exit 0
  fi

  local warn_ratio soft_fail_ratio hard_fail_ratio max_context_files_read max_context_acquisition_ms
  warn_ratio="$(read_threshold_value "warn_ratio")"
  soft_fail_ratio="$(read_threshold_value "soft_fail_ratio")"
  hard_fail_ratio="$(read_threshold_value "hard_fail_ratio")"
  max_context_files_read="$(read_threshold_value "max_context_files_read")"
  max_context_acquisition_ms="$(read_threshold_value "max_context_acquisition_ms")"

  local -a required_fields=()
  mapfile -t required_fields < <(read_required_receipt_fields)

  if [[ -z "$warn_ratio" || -z "$soft_fail_ratio" || -z "$hard_fail_ratio" ]]; then
    fail "context_overhead_gate thresholds are incomplete in policy"
  fi
  if [[ -z "$max_context_files_read" || ! "$max_context_files_read" =~ ^[0-9]+$ ]]; then
    fail "max_context_files_read threshold is missing or invalid"
  fi
  if [[ -z "$max_context_acquisition_ms" || ! "$max_context_acquisition_ms" =~ ^[0-9]+$ ]]; then
    fail "max_context_acquisition_ms threshold is missing or invalid"
  fi
  if [[ ${#required_fields[@]} -eq 0 ]]; then
    fail "required_receipt_fields list is missing or empty"
  fi
  if (( errors > 0 )); then
    echo "[FAIL] context overhead budget validation failed with $errors error(s)"
    exit 1
  fi

  local -a receipts=()
  mapfile -t receipts < <(find "$RUNS_DIR" -type f -name 'receipt*.json' | sort)
  if [[ ${#receipts[@]} -eq 0 ]]; then
    pass "no receipt artifacts found under $RUNS_DIR"
    exit 0
  fi

  local receipt timestamp
  for receipt in "${receipts[@]}"; do
    timestamp="$(jq -r '.timestamp // ""' "$receipt" 2>/dev/null || echo "")"
    if [[ -z "$timestamp" || "$timestamp" < "$CLEAN_BREAK_CUTOFF" ]]; then
      continue
    fi
    checked=$((checked + 1))
    validate_receipt_fields "$receipt" "${required_fields[@]}"
    validate_receipt_budget "$receipt" "$warn_ratio" "$soft_fail_ratio" "$hard_fail_ratio" "$max_context_files_read" "$max_context_acquisition_ms"
  done

  if (( checked == 0 )); then
    pass "no post-cutover receipts found (cutover=$CLEAN_BREAK_CUTOFF)"
    exit 0
  fi
  if (( errors > 0 )); then
    echo "[FAIL] context overhead budget validation failed with $errors error(s), $warnings warning(s), checked=$checked"
    exit 1
  fi

  echo "[PASS] context overhead budget validation passed (checked=$checked, warnings=$warnings)"
}

main "$@"
