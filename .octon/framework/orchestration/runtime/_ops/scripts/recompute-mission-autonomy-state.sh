#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-mission-control-receipt.sh"
ROUTE_PUBLISHER="$SCRIPT_DIR/publish-mission-effective-route.sh"
SYNC_RUNTIME_ARTIFACTS="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"

MISSION_ID=""
ISSUED_BY=""
CONTROL_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/control/execution"
RUN_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/runs"

usage() {
  cat <<'USAGE'
Usage:
  recompute-mission-autonomy-state.sh \
    --mission-id <id> \
    [--issued-by <ref>] \
    [--control-evidence-root <path>] \
    [--run-evidence-root <path>]
USAGE
}

count_fixed_matches() {
  local pattern="$1"
  local root="$2"
  [[ -d "$root" ]] || { printf '0'; return; }
  local count=0
  local file
  if command -v rg >/dev/null 2>&1; then
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      if ! grep -Fq 'VALIDATION_COVERAGE' "$file" 2>/dev/null; then
        count=$((count + 1))
      fi
    done < <(rg -l --fixed-strings "$pattern" "$root" 2>/dev/null || true)
  else
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      if ! grep -Fq 'VALIDATION_COVERAGE' "$file" 2>/dev/null; then
        count=$((count + 1))
      fi
    done < <(grep -R -l -F -- "$pattern" "$root" 2>/dev/null || true)
  fi
  printf '%s' "$count"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --control-evidence-root) CONTROL_EVIDENCE_ROOT="$2"; shift 2 ;;
      --run-evidence-root) RUN_EVIDENCE_ROOT="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }

  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local mode_state_file="$control_dir/mode-state.yml"
  local budget_file="$control_dir/autonomy-budget.yml"
  local breaker_file="$control_dir/circuit-breakers.yml"
  local policy_file="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
  [[ -f "$mode_state_file" ]] || { echo "missing mode-state: ${mode_state_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -f "$budget_file" ]] || { echo "missing autonomy-budget: ${budget_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -f "$breaker_file" ]] || { echo "missing circuit-breakers: ${breaker_file#$ROOT_DIR/}" >&2; exit 1; }
  [[ -f "$policy_file" ]] || { echo "missing mission autonomy policy: ${policy_file#$ROOT_DIR/}" >&2; exit 1; }

  local ts old_budget_state old_breaker_state old_safety_state new_budget_state new_breaker_state new_safety_state
  local breaker_trips breaker_resets rollbacks rollback_path_failures denied_promotes out_of_blast_radius high_severity_incidents missing_observability retries compensations
  local budget_transition_receipt="" breaker_receipt="" safing_receipt=""
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  old_budget_state="$(yq -r '.state // "healthy"' "$budget_file")"
  old_breaker_state="$(yq -r '.state // "clear"' "$breaker_file")"
  old_safety_state="$(yq -r '.safety_state // "paused"' "$mode_state_file")"

  breaker_trips="$(count_fixed_matches "control_mutation_class: \"breaker_trip\"" "$CONTROL_EVIDENCE_ROOT")"
  breaker_resets="$(count_fixed_matches "control_mutation_class: \"breaker_reset\"" "$CONTROL_EVIDENCE_ROOT")"
  rollbacks="$(count_fixed_matches "rollback" "$RUN_EVIDENCE_ROOT")"
  rollback_path_failures="$(count_fixed_matches "rollback_path_failure" "$RUN_EVIDENCE_ROOT")"
  denied_promotes="$(count_fixed_matches "MISSION_APPROVAL_REQUIRED" "$RUN_EVIDENCE_ROOT")"
  out_of_blast_radius="$(count_fixed_matches "out_of_blast_radius_side_effect" "$RUN_EVIDENCE_ROOT")"
  high_severity_incidents="$(count_fixed_matches "high_severity_incident" "$RUN_EVIDENCE_ROOT")"
  missing_observability="$(count_fixed_matches "missing_observability_on_risky_work" "$RUN_EVIDENCE_ROOT")"
  retries="$(count_fixed_matches "retry" "$RUN_EVIDENCE_ROOT")"
  compensations="$(count_fixed_matches "compensation" "$RUN_EVIDENCE_ROOT")"

  new_budget_state="healthy"
  if [[ "$breaker_trips" -ge "$(yq -r '.autonomy_burn.exhausted_thresholds.breaker_trips // 2' "$policy_file")" ]] \
    || [[ "$rollback_path_failures" -ge "$(yq -r '.autonomy_burn.exhausted_thresholds.rollback_path_failures // 1' "$policy_file")" ]] \
    || [[ "$out_of_blast_radius" -ge "$(yq -r '.autonomy_burn.exhausted_thresholds.out_of_blast_radius_side_effects // 1' "$policy_file")" ]] \
    || [[ "$high_severity_incidents" -ge "$(yq -r '.autonomy_burn.exhausted_thresholds.high_severity_incidents // 1' "$policy_file")" ]]; then
    new_budget_state="exhausted"
  elif [[ "$breaker_trips" -ge "$(yq -r '.autonomy_burn.warning_thresholds.breaker_trips // 1' "$policy_file")" ]] \
    || [[ "$rollbacks" -ge "$(yq -r '.autonomy_burn.warning_thresholds.rollbacks // 2' "$policy_file")" ]] \
    || [[ "$denied_promotes" -ge "$(yq -r '.autonomy_burn.warning_thresholds.veto_or_denied_promotes // 3' "$policy_file")" ]]; then
    new_budget_state="warning"
  fi

  new_breaker_state="clear"
  if [[ "$new_budget_state" == "exhausted" || "$breaker_trips" -gt "$breaker_resets" ]]; then
    new_breaker_state="tripped"
  fi

  new_safety_state="$old_safety_state"
  if [[ "$new_breaker_state" != "clear" && "$old_safety_state" != "safe" && "$old_safety_state" != "break_glass" ]]; then
    new_safety_state="safe"
  elif [[ "$new_breaker_state" == "clear" && "$old_safety_state" == "safe" ]]; then
    new_safety_state="paused"
  fi

  BUDGET_STATE="$new_budget_state" \
  UPDATED_AT="$ts" \
  BREAKER_TRIPS="$breaker_trips" \
  BREAKER_RESETS="$breaker_resets" \
  ROLLBACKS="$rollbacks" \
  ROLLBACK_PATH_FAILURES="$rollback_path_failures" \
  DENIED_PROMOTES="$denied_promotes" \
  OUT_OF_BLAST_RADIUS="$out_of_blast_radius" \
  HIGH_SEVERITY_INCIDENTS="$high_severity_incidents" \
  MISSING_OBSERVABILITY="$missing_observability" \
  RETRIES="$retries" \
  COMPENSATIONS="$compensations" \
  yq -i '
    .state = strenv(BUDGET_STATE) |
    .updated_at = strenv(UPDATED_AT) |
    .last_recomputed_at = strenv(UPDATED_AT) |
    .counters = {
      "breaker_trips": (strenv(BREAKER_TRIPS) | tonumber),
      "breaker_resets": (strenv(BREAKER_RESETS) | tonumber),
      "rollbacks": (strenv(ROLLBACKS) | tonumber),
      "rollback_path_failures": (strenv(ROLLBACK_PATH_FAILURES) | tonumber),
      "denied_promotes": (strenv(DENIED_PROMOTES) | tonumber),
      "out_of_blast_radius_side_effects": (strenv(OUT_OF_BLAST_RADIUS) | tonumber),
      "high_severity_incidents": (strenv(HIGH_SEVERITY_INCIDENTS) | tonumber),
      "missing_observability_on_risky_work": (strenv(MISSING_OBSERVABILITY) | tonumber),
      "retries": (strenv(RETRIES) | tonumber),
      "compensations": (strenv(COMPENSATIONS) | tonumber)
    }
  ' "$budget_file"

  BREAKER_STATE="$new_breaker_state" \
  UPDATED_AT="$ts" \
  yq -i '
    .state = strenv(BREAKER_STATE) |
    .updated_at = strenv(UPDATED_AT)
  ' "$breaker_file"

  BUDGET_STATE="$new_budget_state" \
  BREAKER_STATE="$new_breaker_state" \
  SAFETY_STATE="$new_safety_state" \
  UPDATED_AT="$ts" \
  yq -i '
    .autonomy_burn_state = strenv(BUDGET_STATE) |
    .breaker_state = strenv(BREAKER_STATE) |
    .safety_state = strenv(SAFETY_STATE) |
    .updated_at = strenv(UPDATED_AT)
  ' "$mode_state_file"

  if [[ -z "$ISSUED_BY" ]]; then
    ISSUED_BY="$(yq -r '.owners[0] // "operator://octon-maintainers"' "$control_dir/subscriptions.yml" 2>/dev/null || true)"
    [[ -n "$ISSUED_BY" ]] || ISSUED_BY="operator://octon-maintainers"
  fi

  if [[ "$new_budget_state" != "$old_budget_state" ]]; then
    budget_transition_receipt="$(bash "$RECEIPT_WRITER" \
      --mission-id "$MISSION_ID" \
      --receipt-type "budget_transition" \
      --issued-by "$ISSUED_BY" \
      --reason "Recompute autonomy budget from retained evidence" \
      --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/autonomy-budget.yml" \
      --reason-code "AUTONOMY_BUDGET_RECOMPUTED" \
      --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
      --affected-path ".octon/state/control/execution/missions/$MISSION_ID/autonomy-budget.yml")"
    LAST_RECEIPT="${budget_transition_receipt#$ROOT_DIR/}" \
    yq -i '.last_recomputation_receipt_ref = strenv(LAST_RECEIPT)' "$budget_file"
  fi

  if [[ "$new_breaker_state" != "$old_breaker_state" ]]; then
    local breaker_receipt_type="breaker_trip"
    local breaker_reason_code="BREAKER_TRIPPED"
    if [[ "$new_breaker_state" == "clear" ]]; then
      breaker_receipt_type="breaker_reset"
      breaker_reason_code="BREAKER_RESET"
    fi
    breaker_receipt="$(bash "$RECEIPT_WRITER" \
      --mission-id "$MISSION_ID" \
      --receipt-type "$breaker_receipt_type" \
      --issued-by "$ISSUED_BY" \
      --reason "Recompute circuit-breaker state from retained evidence" \
      --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/circuit-breakers.yml" \
      --reason-code "$breaker_reason_code" \
      --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
      --affected-path ".octon/state/control/execution/missions/$MISSION_ID/circuit-breakers.yml" \
      --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml")"
  fi

  if [[ "$new_safety_state" != "$old_safety_state" && "$new_safety_state" != "break_glass" ]]; then
    local safing_receipt_type="safing_enter"
    local safing_reason_code="MISSION_SAFING_ENTERED"
    if [[ "$new_safety_state" == "paused" ]]; then
      safing_receipt_type="safing_exit"
      safing_reason_code="MISSION_SAFING_EXITED"
    fi
    safing_receipt="$(bash "$RECEIPT_WRITER" \
      --mission-id "$MISSION_ID" \
      --receipt-type "$safing_receipt_type" \
      --issued-by "$ISSUED_BY" \
      --reason "Align mission safety state with recomputed breaker posture" \
      --new-state-ref ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml" \
      --reason-code "$safing_reason_code" \
      --policy-ref ".octon/instance/governance/policies/mission-autonomy.yml" \
      --affected-path ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml")"
  fi

  if [[ -x "$ROUTE_PUBLISHER" ]]; then
    bash "$ROUTE_PUBLISHER" --mission-id "$MISSION_ID" >/dev/null
  fi
  if [[ -x "$SYNC_RUNTIME_ARTIFACTS" ]]; then
    bash "$SYNC_RUNTIME_ARTIFACTS" --target missions >/dev/null
  fi

  jq -n \
    --arg mission_id "$MISSION_ID" \
    --arg old_budget_state "$old_budget_state" \
    --arg new_budget_state "$new_budget_state" \
    --arg old_breaker_state "$old_breaker_state" \
    --arg new_breaker_state "$new_breaker_state" \
    --arg old_safety_state "$old_safety_state" \
    --arg new_safety_state "$new_safety_state" \
    --arg budget_transition_receipt "${budget_transition_receipt#$ROOT_DIR/}" \
    --arg breaker_receipt "${breaker_receipt#$ROOT_DIR/}" \
    --arg safing_receipt "${safing_receipt#$ROOT_DIR/}" \
    --argjson breaker_trips "$breaker_trips" \
    --argjson breaker_resets "$breaker_resets" \
    --argjson rollbacks "$rollbacks" \
    --argjson rollback_path_failures "$rollback_path_failures" \
    --argjson denied_promotes "$denied_promotes" \
    '{
      mission_id: $mission_id,
      budget: {
        old_state: $old_budget_state,
        new_state: $new_budget_state,
        breaker_trips: $breaker_trips,
        breaker_resets: $breaker_resets,
        rollbacks: $rollbacks,
        rollback_path_failures: $rollback_path_failures,
        denied_promotes: $denied_promotes
      },
      breaker: {
        old_state: $old_breaker_state,
        new_state: $new_breaker_state
      },
      safety_state: {
        old_state: $old_safety_state,
        new_state: $new_safety_state
      },
      receipts: {
        budget_transition: (if $budget_transition_receipt == "" then null else $budget_transition_receipt end),
        breaker: (if $breaker_receipt == "" then null else $breaker_receipt end),
        safing: (if $safing_receipt == "" then null else $safing_receipt end)
      }
    }'
}

main "$@"
