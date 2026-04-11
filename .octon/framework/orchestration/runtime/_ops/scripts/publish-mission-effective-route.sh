#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MISSION_ID=""
OUTPUT_ROOT="$OCTON_DIR/generated/effective/orchestration/missions"

usage() {
  cat <<'USAGE'
Usage:
  publish-mission-effective-route.sh --mission-id <id> [--output-root <path>]
USAGE
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

iso_plus_seconds() {
  local ts="$1"
  local seconds="$2"
  jq -nr --arg ts "$ts" --argjson seconds "$seconds" '$ts | fromdateiso8601 + $seconds | todateiso8601'
}

iso_min() {
  printf '%s\n' "$@" | awk 'NF && $0 != "null"' | sort | head -n1
}

first_entry_json() {
  local file="$1"
  yq -o=json '
    .entries[]? |
    select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published") |
    .
  ' "$file" 2>/dev/null | jq -c . | awk 'NF { print; exit }'
}

derive_scenario_family() {
  local mission_class="$1"
  local action_class="$2"
  local externality="$3"
  local reversibility="$4"
  local enter_safing="$5"

  case "$action_class" in
    service.deploy|git.merge|ci.workflow_edit|repo.modify_ci)
      printf 'release_sensitive.publish_gate\taction_class.default\n'
      return
      ;;
  esac

  case "$externality" in
    external|external_sync|external_write)
      printf 'external_sync.api_exchange\texternality.default\n'
      return
      ;;
  esac

  if [[ "$mission_class" == "observe" && "$enter_safing" == "true" ]]; then
    printf 'incident.containment\tdirective.enter_safing\n'
    return
  fi

  if [[ "$reversibility" == "irreversible" ]]; then
    printf 'destructive.irreversible\treversibility.default\n'
    return
  fi

  case "$mission_class" in
    observe) printf 'observe.monitoring\tmission_class.default\n' ;;
    campaign) printf 'campaign.long_refactor\tmission_class.default\n' ;;
    maintenance) printf 'maintenance.repo_housekeeping\tmission_class.default\n' ;;
    reconcile) printf 'reconcile.infra_drift\tmission_class.default\n' ;;
    migration) printf 'migration.chunked_backfill\tmission_class.default\n' ;;
    incident) printf 'incident.containment\tmission_class.default\n' ;;
    destructive) printf 'destructive.irreversible\tmission_class.default\n' ;;
    *) printf '%s.default\tmission_class.default\n' "$mission_class" ;;
  esac
}

derive_boundary_class() {
  local explicit="$1"
  local scenario_family="$2"
  local action_class="$3"
  local policy_file="$4"
  local configured=""
  local boundary_key=""

  case "$explicit" in
    file_batch_boundary|task_boundary|resource_batch_boundary|chunk_boundary|deployment_step_boundary|api_page_boundary|playbook_step_boundary|publish_gate|contract_phase_boundary)
      printf '%s\taction_slice.safe_interrupt_boundary_class\n' "$explicit"
      return
      ;;
  esac

  case "$action_class" in
    git.commit|fs.write)
      printf 'task_boundary\taction_class.default\n'
      return
      ;;
    service.deploy)
      printf 'deployment_step_boundary\taction_class.default\n'
      return
      ;;
    fs.hard_delete|db.hard_delete|resource.finalize_destroy)
      printf 'contract_phase_boundary\taction_class.default\n'
      return
      ;;
    fs.soft_delete|db.tombstone|resource.detach)
      printf 'contract_phase_boundary\taction_class.default\n'
      return
      ;;
  esac

  case "$scenario_family" in
    maintenance.repo_housekeeping) boundary_key="repo_housekeeping" ;;
    campaign.long_refactor) boundary_key="coding" ;;
    reconcile.infra_drift) boundary_key="infra_drift" ;;
    migration.chunked_backfill) boundary_key="migration" ;;
    external_sync.api_exchange) boundary_key="external_sync" ;;
    observe.monitoring) boundary_key="monitoring" ;;
    incident.containment) boundary_key="incident" ;;
    release_sensitive.publish_gate) boundary_key="release_sensitive" ;;
    destructive.irreversible) boundary_key="destructive" ;;
    *) boundary_key="" ;;
  esac

  if [[ -n "$boundary_key" ]]; then
    configured="$(yq -r ".safe_interrupt_boundaries.\"$boundary_key\" // \"\"" "$policy_file" 2>/dev/null || true)"
    if [[ -n "$configured" ]]; then
      printf '%s\tmission_autonomy_policy.safe_interrupt_boundaries.%s\n' "$configured" "$boundary_key"
      return
    fi
  fi

  printf 'task_boundary\tmission_autonomy_policy.safe_interrupt_boundaries.default\n'
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mission-id) MISSION_ID="$2"; shift 2 ;;
      --output-root) OUTPUT_ROOT="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$MISSION_ID" ]] || { echo "--mission-id is required" >&2; exit 1; }

  local mission_file="$OCTON_DIR/instance/orchestration/missions/$MISSION_ID/mission.yml"
  local policy_file="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
  local ownership_file="$OCTON_DIR/instance/governance/ownership/registry.yml"
  local deny_policy_file="$OCTON_DIR/framework/capabilities/governance/policy/deny-by-default.v2.yml"
  local root_manifest="$OCTON_DIR/octon.yml"
  local control_dir="$OCTON_DIR/state/control/execution/missions/$MISSION_ID"
  local classification_file="$control_dir/mission-classification.yml"
  local lease_file="$control_dir/lease.yml"
  local mode_state_file="$control_dir/mode-state.yml"
  local intent_register_file="$control_dir/intent-register.yml"
  local action_slices_dir="$control_dir/action-slices"
  local directives_file="$control_dir/directives.yml"
  local authorize_updates_file="$control_dir/authorize-updates.yml"
  local schedule_file="$control_dir/schedule.yml"
  local autonomy_budget_file="$control_dir/autonomy-budget.yml"
  local circuit_breakers_file="$control_dir/circuit-breakers.yml"
  local subscriptions_file="$control_dir/subscriptions.yml"
  local out_dir="$OUTPUT_ROOT/$MISSION_ID"
  local out_file="$out_dir/scenario-resolution.yml"

  for path in \
    "$mission_file" \
    "$policy_file" \
    "$ownership_file" \
    "$deny_policy_file" \
    "$root_manifest" \
    "$classification_file" \
    "$lease_file" \
    "$mode_state_file" \
    "$intent_register_file" \
    "$directives_file" \
    "$authorize_updates_file" \
    "$schedule_file" \
    "$autonomy_budget_file" \
    "$circuit_breakers_file" \
    "$subscriptions_file"
  do
    [[ -f "$path" ]] || { echo "missing route input: ${path#$ROOT_DIR/}" >&2; exit 1; }
  done
  [[ -d "$action_slices_dir" ]] || { echo "missing route input directory: ${action_slices_dir#$ROOT_DIR/}" >&2; exit 1; }

  local generated_at fresh_candidate fresh_until
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  fresh_candidate="$(iso_plus_seconds "$generated_at" 900)"

  local mission_class risk_ceiling default_safing_subset oversight_mode execution_posture safety_state phase
  local budget_state breaker_state overlap_policy backfill_policy digest_route preview_lead next_planned_run_at lease_expires
  local block_finalize enter_safing suspend_future_runs_directive resume_future_runs_directive reprioritize_pending narrow_scope_active exclude_target_active approval_update_present grant_exception_active break_glass_active break_glass_expires_at exception_grant_ref exception_grant_expires_at
  local classification_id ambiguity_level novelty_level proposal_requirement proposal_refs_present
  local selected_entry_json action_slice_path slice_id intent_id intent_ref_id intent_ref_version entry_action_class predicted_acp
  local reversibility_class earliest_start feedback_deadline default_on_silence expected_externality entry_state
  local action_title action_scope_ids safe_interrupt_boundary_class rollback_primitive compensation_primitive
  local action_executor_profile action_approval_required owner_attestation_required action_rationale
  local effective_scenario_family effective_action_class primitive recovery_window rollback_handle_type
  local scenario_family_source boundary_source recovery_source
  local break_glass_required required_quorum allow_proceed_on_silence approval_required
  local active_mode next_safe_interrupt_boundary_id current_slice_ref_path
  local -a reason_codes=()
  local -a tightening_overlays=()

  mission_class="$(yq -r '.mission_class // ""' "$mission_file")"
  risk_ceiling="$(yq -r '.risk_ceiling // "ACP-1"' "$mission_file")"
  default_safing_subset="$(yq -r '.default_safing_subset[]? // ""' "$mission_file" | paste -sd ',' -)"
  oversight_mode="$(yq -r '.oversight_mode // ""' "$mode_state_file")"
  execution_posture="$(yq -r '.execution_posture // ""' "$mode_state_file")"
  safety_state="$(yq -r '.safety_state // ""' "$mode_state_file")"
  phase="$(yq -r '.phase // ""' "$mode_state_file")"
  budget_state="$(yq -r '.state // ""' "$autonomy_budget_file")"
  breaker_state="$(yq -r '.state // "clear"' "$circuit_breakers_file")"
  classification_id="$(yq -r '.classification_id // ""' "$classification_file")"
  ambiguity_level="$(yq -r '.ambiguity_level // "bounded"' "$classification_file")"
  novelty_level="$(yq -r '.novelty_level // "known-pattern"' "$classification_file")"
  proposal_requirement="$(yq -r '.proposal_requirement // "not_required"' "$classification_file")"
  proposal_refs_present="$(yq -r '(.proposal_refs // []) | length > 0' "$classification_file")"
  overlap_policy="$(yq -r '.overlap_policy // ""' "$schedule_file")"
  backfill_policy="$(yq -r '.backfill_policy // ""' "$schedule_file")"
  next_planned_run_at="$(yq -r '.next_planned_run_at // ""' "$schedule_file")"
  preview_lead="$(yq -r '.preview_lead // ""' "$schedule_file")"
  digest_route="$(yq -r '.digest_route_override // ""' "$schedule_file")"
  lease_expires="$(yq -r '.expires_at // ""' "$lease_file")"
  break_glass_expires_at="$(yq -r '.break_glass_expires_at // ""' "$mode_state_file")"
  exception_grant_ref="$(yq -r '.exception_grant_ref // ""' "$mode_state_file")"
  exception_grant_expires_at="$(yq -r '.exception_grant_expires_at // ""' "$mode_state_file")"

  [[ -n "$mission_class" ]] || mission_class="maintenance"
  [[ -n "$oversight_mode" ]] || oversight_mode="$(yq -r ".mode_defaults.\"$mission_class\" // \"notify\"" "$policy_file")"
  [[ -n "$execution_posture" ]] || execution_posture="$(yq -r ".execution_postures.\"$mission_class\" // \"interruptible_scheduled\"" "$policy_file")"
  [[ -n "$overlap_policy" ]] || overlap_policy="$(yq -r ".overlap_defaults.\"$mission_class\" // \"skip\"" "$policy_file")"
  [[ -n "$backfill_policy" ]] || backfill_policy="$(yq -r ".backfill_defaults.\"$mission_class\" // \"none\"" "$policy_file")"
  [[ -n "$preview_lead" ]] || preview_lead="$(yq -r '.preview_defaults.interval_gte_24h.preview_lead // "PT24H"' "$policy_file")"
  [[ -n "$digest_route" ]] || digest_route="$(yq -r ".digest_cadence_defaults.\"$mission_class\".route // \"preview_plus_closure_digest\"" "$policy_file")"

  local finalize_override schedule_override
  finalize_override="$(yq -r '.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select(((.type // .kind) == "block_finalize") or ((.type // .kind) == "unblock_finalize")) | (.type // .kind // "")' "$directives_file" 2>/dev/null | awk 'NF {value=$0} END {print value}')"
  block_finalize="false"
  if [[ "$finalize_override" == "block_finalize" ]]; then
    block_finalize="true"
  fi
  enter_safing="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "enter_safing")] | length > 0' "$directives_file")"
  schedule_override="$(yq -r '.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select(((.type // .kind) == "suspend_future_runs") or ((.type // .kind) == "resume_future_runs")) | (.type // .kind // "")' "$directives_file" 2>/dev/null | awk 'NF {value=$0} END {print value}')"
  suspend_future_runs_directive="false"
  resume_future_runs_directive="false"
  if [[ "$schedule_override" == "suspend_future_runs" ]]; then
    suspend_future_runs_directive="true"
  elif [[ "$schedule_override" == "resume_future_runs" ]]; then
    resume_future_runs_directive="true"
  fi
  reprioritize_pending="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "reprioritize")] | length > 0' "$directives_file")"
  narrow_scope_active="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "narrow_scope")] | length > 0' "$directives_file")"
  exclude_target_active="$(yq -r '[.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | select((.type // .kind) == "exclude_target")] | length > 0' "$directives_file")"
  approval_update_present="$(yq -r '[.authorize_updates[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied")) | select(.type == "approve")] | length > 0' "$authorize_updates_file")"
  break_glass_active="$(yq -r '[.authorize_updates[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied")) | select(.type == "enter_break_glass")] | length > 0' "$authorize_updates_file")"
  grant_exception_active="false"
  if [[ -n "$exception_grant_ref" ]]; then
    if [[ -z "$exception_grant_expires_at" || "$exception_grant_expires_at" > "$generated_at" ]]; then
      grant_exception_active="true"
    fi
  fi
  if [[ "$safety_state" == "break_glass" ]]; then
    break_glass_active="true"
  fi

  selected_entry_json="$(first_entry_json "$intent_register_file" || true)"
  if [[ -n "$selected_entry_json" ]]; then
    intent_id="$(jq -r '.intent_id // .intent_ref.id // ""' <<<"$selected_entry_json")"
    action_slice_path="$(jq -r '.action_slice_ref // .slice_ref.path // ""' <<<"$selected_entry_json")"
    slice_id="$(jq -r '.slice_ref.id // ""' <<<"$selected_entry_json")"
    intent_ref_id="$(jq -r '.intent_ref.id // ""' <<<"$selected_entry_json")"
    intent_ref_version="$(jq -r '.intent_ref.version // ""' <<<"$selected_entry_json")"
    entry_action_class="$(jq -r '.action_class // ""' <<<"$selected_entry_json")"
    predicted_acp="$(jq -r '.predicted_acp // ""' <<<"$selected_entry_json")"
    reversibility_class="$(jq -r '.reversibility_class // .planned_reversibility_class // ""' <<<"$selected_entry_json")"
    earliest_start="$(jq -r '.earliest_start // .earliest_start_at // ""' <<<"$selected_entry_json")"
    feedback_deadline="$(jq -r '.feedback_deadline // .feedback_deadline_at // ""' <<<"$selected_entry_json")"
    default_on_silence="$(jq -r '.default_on_silence // ""' <<<"$selected_entry_json")"
    expected_externality="$(jq -r '.expected_externality_class // "repo_local"' <<<"$selected_entry_json")"
    entry_state="$(jq -r '.state // .status // ""' <<<"$selected_entry_json")"
    if [[ -z "$action_slice_path" && -n "$slice_id" ]]; then
      action_slice_path=".octon/state/control/execution/missions/$MISSION_ID/action-slices/$slice_id.yml"
    fi
  fi

  if [[ -n "${action_slice_path:-}" ]]; then
    local action_slice_file="$ROOT_DIR/$action_slice_path"
    if [[ -f "$action_slice_file" ]]; then
      entry_action_class="$(yq -r '.action_class // "'"$entry_action_class"'"' "$action_slice_file")"
      predicted_acp="$(yq -r '.predicted_acp // "'"$predicted_acp"'"' "$action_slice_file")"
      reversibility_class="$(yq -r '.reversibility_class // "'"$reversibility_class"'"' "$action_slice_file")"
      expected_externality="$(yq -r '.expected_externality_class // "'"${expected_externality:-repo_local}"'"' "$action_slice_file")"
      safe_interrupt_boundary_class="$(yq -r '.safe_interrupt_boundary_class // ""' "$action_slice_file")"
      rollback_primitive="$(yq -r '.rollback_primitive // ""' "$action_slice_file")"
      compensation_primitive="$(yq -r '.compensation_primitive // ""' "$action_slice_file")"
      action_executor_profile="$(yq -r '.executor_profile // ""' "$action_slice_file")"
      action_approval_required="$(yq -r '.approval_required // false' "$action_slice_file")"
      owner_attestation_required="$(yq -r '.owner_attestation_required // false' "$action_slice_file")"
      action_rationale="$(yq -r '.rationale // ""' "$action_slice_file")"
      action_title="$(yq -r '.title // ""' "$action_slice_file")"
      action_scope_ids="$(yq -r '.scope_ids[]? // ""' "$action_slice_file" | paste -sd ',' -)"
    fi
  fi

  [[ -n "${predicted_acp:-}" ]] || predicted_acp="$risk_ceiling"
  [[ -n "${reversibility_class:-}" ]] || reversibility_class="reversible"
  [[ -n "${expected_externality:-}" ]] || expected_externality="repo_local"

  active_mode="false"
  if [[ -n "${entry_state:-}" ]]; then
    active_mode="true"
    reason_codes+=("INTENT_ENTRY_PRESENT")
  else
    reason_codes+=("INTENT_ENTRY_ABSENT")
  fi

  if [[ "$active_mode" == "true" ]]; then
    effective_action_class="$entry_action_class"
    current_slice_ref_path="$action_slice_path"
  else
    effective_action_class="mission.idle"
    current_slice_ref_path=""
  fi

  if [[ -z "${effective_action_class:-}" ]]; then
    effective_action_class="mission.idle"
  fi

  IFS=$'\t' read -r effective_scenario_family scenario_family_source < <(derive_scenario_family "$mission_class" "$effective_action_class" "$expected_externality" "$reversibility_class" "$enter_safing")
  IFS=$'\t' read -r safe_interrupt_boundary_class boundary_source < <(derive_boundary_class "${safe_interrupt_boundary_class:-}" "$effective_scenario_family" "$effective_action_class" "$policy_file")
  next_safe_interrupt_boundary_id="$safe_interrupt_boundary_class"

  primitive="$(ACTION_CLASS="$effective_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.reversibility.primitive // ""' "$deny_policy_file" | awk 'NF {print; exit}')"
  recovery_window="$(ACTION_CLASS="$effective_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.reversibility.recovery_window_default // ""' "$deny_policy_file" | awk 'NF {print; exit}')"
  rollback_handle_type="$(PRIMITIVE="$primitive" yq -r '.reversibility.primitives[strenv(PRIMITIVE)].rollback_handle_type // ""' "$deny_policy_file" 2>/dev/null || true)"
  recovery_source="deny_by_default_policy"
  if [[ -n "${rollback_primitive:-}" ]]; then
    primitive="$rollback_primitive"
    rollback_handle_type="action-slice"
    recovery_source="action_slice.rollback_primitive"
  elif [[ -n "${compensation_primitive:-}" ]]; then
    primitive="$compensation_primitive"
    rollback_handle_type="action-slice"
    recovery_source="action_slice.compensation_primitive"
  fi
  break_glass_required="$(ACTION_CLASS="$effective_action_class" yq -r '.acp.rules[]? | select(.match.class == strenv(ACTION_CLASS)) | .require.break_glass_required // false' "$deny_policy_file" | awk 'NF {print; exit}')"
  [[ -n "$break_glass_required" ]] || break_glass_required="false"
  [[ -n "$recovery_window" ]] || recovery_window="$(yq -r '.recovery_windows.local_reversible_repo_change // "PT72H"' "$policy_file")"

  if [[ "$effective_action_class" == "mission.idle" ]]; then
    primitive=""
    rollback_handle_type=""
    recovery_window=""
    reason_codes+=("ROUTE_IDLE_NO_MATERIAL_SLICE")
  else
    reason_codes+=("ROUTE_ACTION_CLASS_${effective_action_class//[^A-Za-z0-9]/_}")
  fi

  required_quorum="$(ACP_LEVEL="${predicted_acp:-ACP-1}" yq -r '.quorum[strenv(ACP_LEVEL)].required // 1' "$policy_file" | awk 'NF {print; exit}')"
  [[ -n "$required_quorum" ]] || required_quorum="1"

  if [[ "$effective_scenario_family" != "$mission_class" ]]; then
    reason_codes+=("ROUTE_SCENARIO_FAMILY_UPGRADED")
  fi
  if [[ "$enter_safing" == "true" || "$safety_state" == "safe" || "$safety_state" == "degraded" || "$breaker_state" != "clear" ]]; then
    reason_codes+=("ROUTE_SAFING_ACTIVE")
  fi
  if [[ "$block_finalize" == "true" ]]; then
    reason_codes+=("FINALIZE_BLOCK_ACTIVE")
  fi
  if [[ "$suspend_future_runs_directive" == "true" ]]; then
    reason_codes+=("ROUTE_SUSPEND_FUTURE_RUNS_DIRECTIVE")
  fi
  if [[ "$resume_future_runs_directive" == "true" ]]; then
    reason_codes+=("ROUTE_RESUME_FUTURE_RUNS_DIRECTIVE")
  fi
  if [[ "$reprioritize_pending" == "true" ]]; then
    reason_codes+=("ROUTE_REPRIORITIZE_PENDING")
  fi
  if [[ "$narrow_scope_active" == "true" ]]; then
    reason_codes+=("ROUTE_SCOPE_NARROWED")
  fi
  if [[ "$exclude_target_active" == "true" ]]; then
    reason_codes+=("ROUTE_TARGET_EXCLUDED")
  fi
  if [[ "$break_glass_active" == "true" ]]; then
    reason_codes+=("BREAK_GLASS_ACTIVE")
  fi
  if [[ "$grant_exception_active" == "true" ]]; then
    reason_codes+=("GRANT_EXCEPTION_ACTIVE")
  fi
  if [[ "$proposal_requirement" == "required" && "$proposal_refs_present" != "true" ]]; then
    reason_codes+=("MISSION_PROPOSAL_REF_REQUIRED")
  elif [[ "$proposal_requirement" == "recommended" && "$proposal_refs_present" != "true" ]]; then
    reason_codes+=("MISSION_PROPOSAL_REF_RECOMMENDED")
  fi
  if [[ "$block_finalize" == "true" ]]; then
    tightening_overlays+=("directive:block_finalize")
  fi
  if [[ "$suspend_future_runs_directive" == "true" ]]; then
    tightening_overlays+=("directive:suspend_future_runs")
  fi
  if [[ "$reprioritize_pending" == "true" ]]; then
    tightening_overlays+=("directive:reprioritize")
  fi
  if [[ "$narrow_scope_active" == "true" ]]; then
    tightening_overlays+=("directive:narrow_scope")
  fi
  if [[ "$exclude_target_active" == "true" ]]; then
    tightening_overlays+=("directive:exclude_target")
  fi
  if [[ "$enter_safing" == "true" ]]; then
    tightening_overlays+=("directive:enter_safing")
  fi
  if [[ "$breaker_state" != "clear" ]]; then
    tightening_overlays+=("breaker:${breaker_state}")
  fi
  if [[ "$safety_state" == "safe" || "$safety_state" == "degraded" ]]; then
    tightening_overlays+=("safety_state:${safety_state}")
  fi
  if [[ "$break_glass_active" == "true" ]]; then
    tightening_overlays+=("authorize_update:break_glass")
  fi
  if [[ "$grant_exception_active" == "true" ]]; then
    tightening_overlays+=("authorize_update:grant_exception")
  fi
  if [[ "$proposal_requirement" != "not_required" ]]; then
    tightening_overlays+=("mission_classification:${proposal_requirement}")
  fi

  approval_required="false"
  if [[ "$oversight_mode" == "approval_required" || "$break_glass_required" == "true" || "${action_approval_required:-false}" == "true" ]]; then
    approval_required="true"
  fi
  if [[ "$proposal_requirement" == "required" && "$proposal_refs_present" != "true" ]]; then
    approval_required="true"
    block_finalize="true"
  fi
  if [[ "$grant_exception_active" == "true" ]]; then
    approval_required="false"
    break_glass_required="false"
  fi

  allow_proceed_on_silence="false"
  if [[ "$oversight_mode" == "proceed_on_silence" && "$budget_state" == "healthy" && "$breaker_state" == "clear" && "$reversibility_class" != "irreversible" && "$effective_action_class" != "mission.idle" ]]; then
    allow_proceed_on_silence="true"
  fi

  if [[ "$enter_safing" == "true" || "$safety_state" == "safe" || "$safety_state" == "degraded" || "$breaker_state" != "clear" ]]; then
    if [[ "$mission_class" == "incident" || "$effective_scenario_family" == "incident" ]]; then
      default_safing_subset="$(yq -r '.safing_defaults.incident_subset[]? // ""' "$policy_file" | paste -sd ',' -)"
    fi
  fi

  fresh_until="$(iso_min "$fresh_candidate" "$lease_expires" "$next_planned_run_at" "$break_glass_expires_at")"
  [[ -n "$fresh_until" ]] || fresh_until="$fresh_candidate"

  mkdir -p "$out_dir"
  cat > "$out_file" <<EOF
schema_version: "scenario-resolution-v1"
mission_id: "$MISSION_ID"
source_refs:
  mission_charter: ".octon/instance/orchestration/missions/$MISSION_ID/mission.yml"
  mission_autonomy_policy: ".octon/instance/governance/policies/mission-autonomy.yml"
  mission_classification: ".octon/state/control/execution/missions/$MISSION_ID/mission-classification.yml"
  ownership_registry: ".octon/instance/governance/ownership/registry.yml"
  deny_by_default_policy: ".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"
  root_manifest: ".octon/octon.yml"
  lease: ".octon/state/control/execution/missions/$MISSION_ID/lease.yml"
  mode_state: ".octon/state/control/execution/missions/$MISSION_ID/mode-state.yml"
  intent_register: ".octon/state/control/execution/missions/$MISSION_ID/intent-register.yml"
  directives: ".octon/state/control/execution/missions/$MISSION_ID/directives.yml"
  authorize_updates: ".octon/state/control/execution/missions/$MISSION_ID/authorize-updates.yml"
  schedule: ".octon/state/control/execution/missions/$MISSION_ID/schedule.yml"
  autonomy_budget: ".octon/state/control/execution/missions/$MISSION_ID/autonomy-budget.yml"
  circuit_breakers: ".octon/state/control/execution/missions/$MISSION_ID/circuit-breakers.yml"
  subscriptions: ".octon/state/control/execution/missions/$MISSION_ID/subscriptions.yml"
$(if [[ -n "$current_slice_ref_path" ]]; then printf '  current_action_slice: "%s"\n' "$current_slice_ref_path"; fi)
effective:
  mission_class: "$mission_class"
  classification_id: "$classification_id"
  ambiguity_level: "$ambiguity_level"
  novelty_level: "$novelty_level"
  proposal_requirement: "$proposal_requirement"
  proposal_refs_present: $proposal_refs_present
  effective_scenario_family: "$effective_scenario_family"
  effective_action_class: "$effective_action_class"
  scenario_family: "$effective_scenario_family"
  scenario_family_source: "$scenario_family_source"
  boundary_source: "$boundary_source"
  recovery_source: "$recovery_source"
  tightening_overlays:
$(printf '%s\n' "${tightening_overlays[@]}" | awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}')
  oversight_mode: "$oversight_mode"
  execution_posture: "$execution_posture"
  preview_policy:
    lead: $(yaml_quote "$preview_lead")
    source: "mission-autonomy-policy"
  feedback_window_required: $( [[ "$oversight_mode" == "feedback_window" ]] && printf 'true' || printf 'false' )
  proceed_on_silence_allowed: $allow_proceed_on_silence
  approval_required: $approval_required
  safe_interrupt_boundary_class: "$safe_interrupt_boundary_class"
  overlap_policy: "$overlap_policy"
  backfill_policy: "$backfill_policy"
  pause_on_failure:
    enabled: $(yq -r '.pause_on_failure_rules.enabled // false' "$schedule_file")
    triggers:
$(yq -r '.pause_on_failure_rules.triggers[]? // ""' "$schedule_file" | awk 'NF {count++; printf "      - \"%s\"\n", $0} END {if (count == 0) printf "      []\n"}')
  digest_route: "$digest_route"
  alert_route: "$( [[ "$digest_route" == "immediate_alert" ]] && printf 'owners-first-alert' || printf 'owners-first-digest' )"
  required_quorum: "$(printf '%s' "$required_quorum")"
  recovery_profile:
    action_class: "$effective_action_class"
    predicted_acp: "$predicted_acp"
    reversibility_class: "$reversibility_class"
    primitive: $(yaml_quote "${primitive:-}")
    rollback_handle_type: $(yaml_quote "${rollback_handle_type:-}")
    recovery_window: $(yaml_quote "${recovery_window:-}")
  finalize_policy:
    approval_required: $approval_required
    block_finalize: $block_finalize
    break_glass_required: $break_glass_required
    exception_active: $grant_exception_active
  safing_subset:
$(printf '%s\n' "$default_safing_subset" | tr ',' '\n' | awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}')
  route_reason_codes:
$(printf '%s\n' "${reason_codes[@]}" | awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}')
rationale:
  - "mission charter, mission classification, mission policy, live control state, and retained governance policy compile into one effective route"
  - "material route behavior derives from the current intent entry plus action-slice when present"
  - "route linkage, safing state, and finalize gates must stay freshness-bounded"
generated_at: "$generated_at"
fresh_until: "$fresh_until"
EOF

  local route_ref=".octon/generated/effective/orchestration/missions/$MISSION_ID/scenario-resolution.yml"
  if [[ -n "$current_slice_ref_path" ]]; then
    CURRENT_SLICE_ID="${slice_id:-$(basename "$current_slice_ref_path" .yml)}" \
    CURRENT_SLICE_PATH="$current_slice_ref_path" \
    ROUTE_REF="$route_ref" \
    OVERSIGHT_MODE="$oversight_mode" \
    EXECUTION_POSTURE="$execution_posture" \
    BUDGET_STATE="$budget_state" \
    BREAKER_STATE="$breaker_state" \
    UPDATED_AT="$generated_at" \
    NEXT_BOUNDARY="$next_safe_interrupt_boundary_id" \
    yq -i '
      .current_slice_ref = {"id": strenv(CURRENT_SLICE_ID), "path": strenv(CURRENT_SLICE_PATH)} |
      .effective_scenario_resolution_ref = strenv(ROUTE_REF) |
      .oversight_mode = strenv(OVERSIGHT_MODE) |
      .execution_posture = strenv(EXECUTION_POSTURE) |
      .autonomy_burn_state = strenv(BUDGET_STATE) |
      .breaker_state = strenv(BREAKER_STATE) |
      .next_safe_interrupt_boundary_id = strenv(NEXT_BOUNDARY) |
      .updated_at = strenv(UPDATED_AT)
    ' "$mode_state_file"
  else
    ROUTE_REF="$route_ref" \
    OVERSIGHT_MODE="$oversight_mode" \
    EXECUTION_POSTURE="$execution_posture" \
    BUDGET_STATE="$budget_state" \
    BREAKER_STATE="$breaker_state" \
    UPDATED_AT="$generated_at" \
    NEXT_BOUNDARY="$next_safe_interrupt_boundary_id" \
    yq -i '
      .current_slice_ref = null |
      .effective_scenario_resolution_ref = strenv(ROUTE_REF) |
      .oversight_mode = strenv(OVERSIGHT_MODE) |
      .execution_posture = strenv(EXECUTION_POSTURE) |
      .autonomy_burn_state = strenv(BUDGET_STATE) |
      .breaker_state = strenv(BREAKER_STATE) |
      .next_safe_interrupt_boundary_id = strenv(NEXT_BOUNDARY) |
      .updated_at = strenv(UPDATED_AT)
    ' "$mode_state_file"
  fi

  printf '%s\n' "$out_file"
}

main "$@"
