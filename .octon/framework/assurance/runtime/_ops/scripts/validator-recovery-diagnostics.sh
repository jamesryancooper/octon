#!/usr/bin/env bash

# Compact machine-readable recovery diagnostics for shell validators.
# Validators keep their existing human-readable [ERROR]/[WARN] output and may
# add one JSON-line diagnostic per actionable failure.

validator_recovery_json_escape() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

validator_recovery_json_array() {
  local raw="${1:-}"
  local item sep=""
  local -a items=()
  printf '['
  if [[ -n "$raw" ]]; then
    IFS='|' read -r -a items <<<"$raw"
    for item in "${items[@]}"; do
      printf '%s"%s"' "$sep" "$(validator_recovery_json_escape "$item")"
      sep=","
    done
  fi
  printf ']'
}

validator_recovery_field() {
  local key="$1"
  local value="${2:-}"
  [[ -n "$value" ]] || return 1
  printf '"%s":"%s"\n' "$key" "$(validator_recovery_json_escape "$value")"
}

emit_recovery_diagnostic() {
  local recovery_class=""
  local failing_path=""
  local observed_value=""
  local accepted_values=""
  local stale_source_ref=""
  local stale_cause=""
  local expected_digest=""
  local minimal_repair_hint=""
  local rerun_gate=""
  local hard_blocker_reason=""
  local -a fields=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --recovery-class)
        recovery_class="${2:-}"
        shift 2
        ;;
      --failing-path)
        failing_path="${2:-}"
        shift 2
        ;;
      --observed-value)
        observed_value="${2:-}"
        shift 2
        ;;
      --accepted-values)
        accepted_values="${2:-}"
        shift 2
        ;;
      --stale-source-ref)
        stale_source_ref="${2:-}"
        shift 2
        ;;
      --stale-cause)
        stale_cause="${2:-}"
        shift 2
        ;;
      --expected-digest)
        expected_digest="${2:-}"
        shift 2
        ;;
      --minimal-repair-hint)
        minimal_repair_hint="${2:-}"
        shift 2
        ;;
      --rerun-gate)
        rerun_gate="${2:-}"
        shift 2
        ;;
      --hard-blocker-reason)
        hard_blocker_reason="${2:-}"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  [[ -n "$recovery_class" && -n "$failing_path" ]] || return 0

  local field
  field="$(validator_recovery_field "recovery_class" "$recovery_class")" && fields+=("$field")
  field="$(validator_recovery_field "failing_path" "$failing_path")" && fields+=("$field")
  field="$(validator_recovery_field "observed_value" "$observed_value")" && fields+=("$field")
  if [[ -n "$accepted_values" ]]; then
    fields+=("\"accepted_values\":$(validator_recovery_json_array "$accepted_values")")
  fi
  field="$(validator_recovery_field "stale_source_ref" "$stale_source_ref")" && fields+=("$field")
  field="$(validator_recovery_field "stale_cause" "$stale_cause")" && fields+=("$field")
  field="$(validator_recovery_field "expected_digest" "$expected_digest")" && fields+=("$field")
  field="$(validator_recovery_field "minimal_repair_hint" "$minimal_repair_hint")" && fields+=("$field")
  field="$(validator_recovery_field "rerun_gate" "$rerun_gate")" && fields+=("$field")
  field="$(validator_recovery_field "hard_blocker_reason" "$hard_blocker_reason")" && fields+=("$field")

  local IFS=,
  printf '[RECOVERY_DIAGNOSTIC] {%s}\n' "${fields[*]}"
}

emit_enum_recovery_diagnostic() {
  local failing_path="$1"
  local observed_value="$2"
  local accepted_values="$3"
  local rerun_gate="$4"
  local accepted_display="${accepted_values//|/, }"
  emit_recovery_diagnostic \
    --recovery-class "enum_drift" \
    --failing-path "$failing_path" \
    --observed-value "$observed_value" \
    --accepted-values "$accepted_values" \
    --minimal-repair-hint "set $failing_path to one of: $accepted_display" \
    --rerun-gate "$rerun_gate"
}

emit_stale_evidence_recovery_diagnostic() {
  local failing_path="$1"
  local observed_value="$2"
  local expected_digest="$3"
  local stale_source_ref="$4"
  local stale_cause="$5"
  local rerun_gate="$6"
  local minimal_repair_hint="$7"
  emit_recovery_diagnostic \
    --recovery-class "stale_evidence" \
    --failing-path "$failing_path" \
    --observed-value "$observed_value" \
    --expected-digest "$expected_digest" \
    --stale-source-ref "$stale_source_ref" \
    --stale-cause "$stale_cause" \
    --minimal-repair-hint "$minimal_repair_hint" \
    --rerun-gate "$rerun_gate"
}

emit_generated_freshness_recovery_diagnostic() {
  local failing_path="$1"
  local stale_source_ref="$2"
  local stale_cause="$3"
  local rerun_gate="$4"
  local minimal_repair_hint="$5"
  emit_recovery_diagnostic \
    --recovery-class "generated_freshness_drift" \
    --failing-path "$failing_path" \
    --stale-source-ref "$stale_source_ref" \
    --stale-cause "$stale_cause" \
    --minimal-repair-hint "$minimal_repair_hint" \
    --rerun-gate "$rerun_gate"
}

emit_hard_blocker_recovery_diagnostic() {
  local failing_path="$1"
  local hard_blocker_reason="$2"
  local rerun_gate="$3"
  local observed_value="${4:-}"
  emit_recovery_diagnostic \
    --recovery-class "hard_blocker" \
    --failing-path "$failing_path" \
    --observed-value "$observed_value" \
    --hard-blocker-reason "$hard_blocker_reason" \
    --rerun-gate "$rerun_gate"
}
