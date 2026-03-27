#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq

usage() {
  cat <<'EOF'
Usage:
  write-run.sh create --run-id <id> --decision-id <id> --summary <text> --workflow-group <group> --workflow-id <id> --executor-id <id> --lease-seconds <n> [options]
  write-run.sh complete --run-id <id> --status <succeeded|failed|cancelled> --summary <text>
  write-run.sh heartbeat --run-id <id> --lease-seconds <n>
  write-run.sh recovery --run-id <id> --recovery-status <status> [--recovery-reason <text>]
EOF
}

run_control_dir() {
  local run_id="$1"
  printf '%s/%s' "$RUN_CONTROL_ROOT" "$run_id"
}

run_contract_path() {
  local run_id="$1"
  printf '%s/%s/run-contract.yml' "$RUN_CONTROL_ROOT" "$run_id"
}

stage_attempt_dir() {
  local run_id="$1"
  printf '%s/%s/stage-attempts' "$RUN_CONTROL_ROOT" "$run_id"
}

checkpoint_dir() {
  local run_id="$1"
  printf '%s/%s/checkpoints' "$RUN_CONTROL_ROOT" "$run_id"
}

runtime_state_path() {
  local run_id="$1"
  printf '%s/%s/runtime-state.yml' "$RUN_CONTROL_ROOT" "$run_id"
}

rollback_posture_path() {
  local run_id="$1"
  printf '%s/%s/rollback-posture.yml' "$RUN_CONTROL_ROOT" "$run_id"
}

run_evidence_dir() {
  local run_id="$1"
  printf '%s/%s' "$CONTINUITY_RUNS_DIR" "$run_id"
}

receipt_dir() {
  local run_id="$1"
  printf '%s/%s/receipts' "$CONTINUITY_RUNS_DIR" "$run_id"
}

evidence_checkpoint_dir() {
  local run_id="$1"
  printf '%s/%s/checkpoints' "$CONTINUITY_RUNS_DIR" "$run_id"
}

replay_pointers_path() {
  local run_id="$1"
  printf '%s/%s/replay-pointers.yml' "$CONTINUITY_RUNS_DIR" "$run_id"
}

trace_pointers_path() {
  local run_id="$1"
  printf '%s/%s/trace-pointers.yml' "$CONTINUITY_RUNS_DIR" "$run_id"
}

retained_evidence_path() {
  local run_id="$1"
  printf '%s/%s/retained-run-evidence.yml' "$CONTINUITY_RUNS_DIR" "$run_id"
}

run_contract_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/run-contract.yml' "$run_id"
}

stage_attempt_dir_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/stage-attempts' "$run_id"
}

checkpoint_dir_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/checkpoints' "$run_id"
}

runtime_state_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/runtime-state.yml' "$run_id"
}

rollback_posture_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/rollback-posture.yml' "$run_id"
}

run_evidence_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s' "$run_id"
}

receipt_dir_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/receipts' "$run_id"
}

orchestration_receipt_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/receipts/orchestration-lifecycle.yml' "$run_id"
}

evidence_checkpoint_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/checkpoints/bound.yml' "$run_id"
}

control_checkpoint_relpath() {
  local run_id="$1"
  printf '.octon/state/control/execution/runs/%s/checkpoints/bound.yml' "$run_id"
}

replay_pointers_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/replay-pointers.yml' "$run_id"
}

trace_pointers_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/trace-pointers.yml' "$run_id"
}

retained_evidence_relpath() {
  local run_id="$1"
  printf '.octon/state/evidence/runs/%s/retained-run-evidence.yml' "$run_id"
}

contract_status_from_projection() {
  case "$1" in
    succeeded) printf 'completed' ;;
    failed) printf 'failed' ;;
    cancelled) printf 'cancelled' ;;
    running) printf 'running' ;;
    *) printf '%s' "$1" ;;
  esac
}

attempt_status_from_projection() {
  case "$1" in
    completed) printf 'succeeded' ;;
    *) printf '%s' "$1" ;;
  esac
}

collect_scope_in_json() {
  local workflow_group="$1"
  local workflow_id="$2"
  local mission_id="$3"
  local automation_id="$4"
  local incident_id="$5"

  local -a scopes=()
  if [[ -n "$workflow_group" && -n "$workflow_id" ]]; then
    scopes+=(".octon/framework/orchestration/runtime/workflows/$workflow_group/$workflow_id")
  fi
  if [[ -n "$mission_id" ]]; then
    scopes+=(".octon/instance/orchestration/missions/$mission_id")
  fi
  if [[ -n "$automation_id" ]]; then
    scopes+=(".octon/framework/orchestration/runtime/automations/$automation_id")
  fi
  if [[ -n "$incident_id" ]]; then
    scopes+=(".octon/framework/orchestration/runtime/incidents/$incident_id")
  fi
  if [[ "${#scopes[@]}" -eq 0 ]]; then
    scopes+=(".octon/framework/orchestration/runtime")
  fi

  printf '%s\n' "${scopes[@]}" | jq -R . | jq -s .
}

collect_requested_capabilities_json() {
  local workflow_group="$1"
  local workflow_id="$2"
  local mission_id="$3"
  local automation_id="$4"

  local -a capabilities=("evidence.write" "state.write")
  if [[ -n "$workflow_group" && -n "$workflow_id" ]]; then
    capabilities+=("workflow.execute")
  fi
  if [[ -n "$mission_id" ]]; then
    capabilities+=("mission.context")
  fi
  if [[ -n "$automation_id" ]]; then
    capabilities+=("automation.launch")
  fi

  printf '%s\n' "${capabilities[@]}" | awk '!seen[$0]++' | jq -R . | jq -s .
}

yaml_json_or_default() {
  local file="$1"
  local query="${2:-.}"
  local fallback="${3-}"
  if [[ -z "$fallback" ]]; then
    fallback='{}'
  fi
  if [[ -f "$file" ]]; then
    yq -o=json "$query" "$file" 2>/dev/null || printf '%s' "$fallback"
  else
    printf '%s' "$fallback"
  fi
}

merge_string_arrays_json() {
  local base_json="$1"
  local extra_json="$2"
  printf '%s\n%s\n' "$base_json" "$extra_json" \
    | jq -cs 'add | map(select(type == "string" and length > 0)) | unique'
}

write_runtime_state_file() {
  local run_id="$1"
  local status="$2"
  local created_at="$3"
  local updated_at="$4"
  local mission_id="$5"
  local parent_run_id="$6"
  local last_receipt_ref="${7:-}"
  local runtime_state_file existing_created_at existing_last_receipt_ref existing_last_checkpoint_ref
  local resolved_created_at resolved_last_receipt_ref resolved_last_checkpoint_ref
  runtime_state_file="$(runtime_state_path "$run_id")"
  existing_created_at="$( [[ -f "$runtime_state_file" ]] && yq -r '.created_at // ""' "$runtime_state_file" 2>/dev/null || printf '' )"
  existing_last_receipt_ref="$( [[ -f "$runtime_state_file" ]] && yq -r '.last_receipt_ref // ""' "$runtime_state_file" 2>/dev/null || printf '' )"
  existing_last_checkpoint_ref="$( [[ -f "$runtime_state_file" ]] && yq -r '.last_checkpoint_ref // ""' "$runtime_state_file" 2>/dev/null || printf '' )"
  resolved_created_at="$created_at"
  resolved_last_receipt_ref="$last_receipt_ref"
  resolved_last_checkpoint_ref="$(control_checkpoint_relpath "$run_id")"
  if [[ -n "$existing_created_at" && "$existing_created_at" != "null" ]]; then
    resolved_created_at="$existing_created_at"
  fi
  if [[ -z "$resolved_last_receipt_ref" && -n "$existing_last_receipt_ref" && "$existing_last_receipt_ref" != "null" ]]; then
    resolved_last_receipt_ref="$existing_last_receipt_ref"
  fi
  if [[ -n "$existing_last_checkpoint_ref" && "$existing_last_checkpoint_ref" != "null" ]]; then
    resolved_last_checkpoint_ref="$existing_last_checkpoint_ref"
  fi

  jq -n \
    --arg run_id "$run_id" \
    --arg status "$status" \
    --arg workflow_mode "$( [[ -n "$mission_id" ]] && printf 'autonomous' || printf 'human-only' )" \
    --arg decision_state "$( [[ "$status" == "failed" || "$status" == "cancelled" ]] && printf 'deny' || printf 'allow' )" \
    --arg run_contract_ref "$(run_contract_relpath "$run_id")" \
    --arg stage_attempt_root "$(stage_attempt_dir_relpath "$run_id")" \
    --arg checkpoint_root "$(checkpoint_dir_relpath "$run_id")" \
    --arg evidence_root "$(run_evidence_relpath "$run_id")" \
    --arg receipt_root "$(receipt_dir_relpath "$run_id")" \
    --arg control_checkpoint_ref "$resolved_last_checkpoint_ref" \
    --arg last_receipt_ref "$resolved_last_receipt_ref" \
    --arg mission_id "$mission_id" \
    --arg parent_run_ref "$( [[ -n "$parent_run_id" ]] && printf '.octon/state/control/execution/runs/%s/run-contract.yml' "$parent_run_id" || printf '' )" \
    --arg created_at "$resolved_created_at" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "run-runtime-state-v1",
        run_id: $run_id,
        status: $status,
        workflow_mode: $workflow_mode,
        decision_state: $decision_state,
        run_contract_ref: $run_contract_ref,
        stage_attempt_root: $stage_attempt_root,
        control_checkpoint_root: $checkpoint_root,
        evidence_root: $evidence_root,
        receipt_root: $receipt_root,
        current_stage_attempt_id: "initial",
        last_checkpoint_ref: $control_checkpoint_ref,
        created_at: $created_at,
        updated_at: $updated_at
      }
      + (if $last_receipt_ref != "" then {last_receipt_ref: $last_receipt_ref} else {} end)
      + (if $mission_id != "" then {mission_id: $mission_id} else {} end)
      + (if $parent_run_ref != "" then {parent_run_ref: $parent_run_ref} else {} end)
    ' | yq -P -p=json '.' > "$runtime_state_file"
}

write_orchestration_receipt_file() {
  local run_id="$1"
  local status="$2"
  local summary="$3"
  local recorded_at="$4"

  jq -n \
    --arg run_id "$run_id" \
    --arg status "$status" \
    --arg summary "$summary" \
    --arg recorded_at "$recorded_at" '
      {
        schema_version: "orchestration-run-lifecycle-receipt-v1",
        run_id: $run_id,
        status: $status,
        summary: $summary,
        recorded_at: $recorded_at
      }
    ' | yq -P -p=json '.' > "$(receipt_dir "$run_id")/orchestration-lifecycle.yml"
}

write_rollback_posture_file() {
  local run_id="$1"
  local updated_at="$2"
  local rollback_file existing_json
  local reversibility_class rollback_strategy contamination_state hard_reset_required posture_source
  rollback_file="$(rollback_posture_path "$run_id")"
  existing_json="$(yaml_json_or_default "$rollback_file" '.' '{}')"
  reversibility_class="$(jq -r '.reversibility_class // "reversible"' <<<"$existing_json")"
  rollback_strategy="$(jq -r '.rollback_strategy // "rollback"' <<<"$existing_json")"
  contamination_state="$(jq -r '.contamination_state // "clean"' <<<"$existing_json")"
  hard_reset_required="$(jq -r '.hard_reset_required // false' <<<"$existing_json")"
  posture_source="$(jq -r '.posture_source // "orchestration-runtime"' <<<"$existing_json")"

  jq -n \
    --arg run_id "$run_id" \
    --arg reversibility_class "$reversibility_class" \
    --arg rollback_strategy "$rollback_strategy" \
    --arg contamination_state "$contamination_state" \
    --arg posture_source "$posture_source" \
    --argjson hard_reset_required "$hard_reset_required" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "run-rollback-posture-v1",
        run_id: $run_id,
        reversibility_class: $reversibility_class,
        rollback_strategy: $rollback_strategy,
        contamination_state: $contamination_state,
        hard_reset_required: $hard_reset_required,
        posture_source: $posture_source,
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$rollback_file"
}

write_bound_checkpoint_files() {
  local run_id="$1"
  local created_at="$2"
  local control_path evidence_path
  control_path="$(checkpoint_dir "$run_id")/bound.yml"
  evidence_path="$(evidence_checkpoint_dir "$run_id")/bound.yml"
  jq -n \
    --arg run_id "$run_id" \
    --arg created_at "$created_at" \
    --arg control_ref "$(control_checkpoint_relpath "$run_id")" \
    --arg evidence_ref "$(evidence_checkpoint_relpath "$run_id")" '
      {
        schema_version: "run-checkpoint-v1",
        run_id: $run_id,
        checkpoint_id: "bound",
        stage_attempt_id: "initial",
        checkpoint_kind: "binding",
        status: "materialized",
        control_ref: $control_ref,
        evidence_ref: $evidence_ref,
        notes: "Canonical run root bound for orchestration-managed execution.",
        created_at: $created_at,
        updated_at: $created_at
      }
    ' | yq -P -p=json '.' > "$control_path"
  jq -n \
    --arg run_id "$run_id" \
    --arg created_at "$created_at" \
    --arg control_ref "$(control_checkpoint_relpath "$run_id")" \
    --arg evidence_ref "$(evidence_checkpoint_relpath "$run_id")" '
      {
        schema_version: "run-checkpoint-v1",
        run_id: $run_id,
        checkpoint_id: "bound",
        stage_attempt_id: "initial",
        checkpoint_kind: "binding",
        status: "materialized",
        control_ref: $control_ref,
        evidence_ref: $evidence_ref,
        notes: "Canonical run root bound for orchestration-managed execution.",
        created_at: $created_at,
        updated_at: $created_at
      }
    ' | yq -P -p=json '.' > "$evidence_path"
}

write_replay_pointer_file() {
  local run_id="$1"
  local updated_at="$2"
  local replay_file existing_receipts_json existing_checkpoints_json existing_trace_json existing_external_json
  local new_receipts_json new_checkpoints_json merged_receipts_json merged_checkpoints_json merged_trace_json merged_external_json
  replay_file="$(replay_pointers_path "$run_id")"
  local receipt_ref=""
  if [[ -f "$(receipt_dir "$run_id")/orchestration-lifecycle.yml" ]]; then
    receipt_ref="$(orchestration_receipt_relpath "$run_id")"
  fi
  existing_receipts_json="$(yaml_json_or_default "$replay_file" '.receipt_refs // []' '[]')"
  existing_checkpoints_json="$(yaml_json_or_default "$replay_file" '.checkpoint_refs // []' '[]')"
  existing_trace_json="$(yaml_json_or_default "$replay_file" '.trace_refs // []' '[]')"
  existing_external_json="$(yaml_json_or_default "$replay_file" '.external_replay_refs // []' '[]')"
  new_receipts_json="$(jq -cn --arg receipt_ref "$receipt_ref" 'if $receipt_ref != "" then [$receipt_ref] else [] end')"
  new_checkpoints_json="$(jq -cn --arg checkpoint_ref "$(evidence_checkpoint_relpath "$run_id")" '[$checkpoint_ref]')"
  merged_receipts_json="$(merge_string_arrays_json "$existing_receipts_json" "$new_receipts_json")"
  merged_checkpoints_json="$(merge_string_arrays_json "$existing_checkpoints_json" "$new_checkpoints_json")"
  merged_trace_json="$(merge_string_arrays_json "$existing_trace_json" '[]')"
  merged_external_json="$(merge_string_arrays_json "$existing_external_json" '[]')"
  jq -n \
    --arg run_id "$run_id" \
    --argjson receipt_refs "$merged_receipts_json" \
    --argjson checkpoint_refs "$merged_checkpoints_json" \
    --argjson trace_refs "$merged_trace_json" \
    --argjson external_replay_refs "$merged_external_json" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "run-replay-pointers-v1",
        run_id: $run_id,
        receipt_refs: $receipt_refs,
        checkpoint_refs: $checkpoint_refs,
        trace_refs: $trace_refs,
        external_replay_refs: $external_replay_refs,
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$replay_file"
}

write_trace_pointer_file() {
  local run_id="$1"
  local updated_at="$2"
  local trace_file existing_trace_json merged_trace_json
  trace_file="$(trace_pointers_path "$run_id")"
  existing_trace_json="$(yaml_json_or_default "$trace_file" '.trace_refs // []' '[]')"
  merged_trace_json="$(merge_string_arrays_json "$existing_trace_json" '[]')"
  jq -n \
    --arg run_id "$run_id" \
    --argjson trace_refs "$merged_trace_json" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "run-trace-pointers-v1",
        run_id: $run_id,
        trace_refs: $trace_refs,
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$trace_file"
}

write_retained_evidence_file() {
  local run_id="$1"
  local updated_at="$2"
  local retained_file existing_map_json new_map_json merged_map_json
  retained_file="$(retained_evidence_path "$run_id")"
  existing_map_json="$(yaml_json_or_default "$retained_file" '.evidence_refs // {}' '{}')"
  new_map_json="$(jq -n \
    --arg run_contract "$(run_contract_relpath "$run_id")" \
    --arg runtime_state "$(runtime_state_relpath "$run_id")" \
    --arg rollback_posture "$(rollback_posture_relpath "$run_id")" \
    --arg control_checkpoint "$(control_checkpoint_relpath "$run_id")" \
    --arg evidence_checkpoint "$(evidence_checkpoint_relpath "$run_id")" \
    --arg orchestration_receipt "$(orchestration_receipt_relpath "$run_id")" \
    --arg replay_pointers "$(replay_pointers_relpath "$run_id")" \
    --arg trace_pointers "$(trace_pointers_relpath "$run_id")" \
    '{
      run_contract: $run_contract,
      runtime_state: $runtime_state,
      rollback_posture: $rollback_posture,
      control_checkpoint: $control_checkpoint,
      evidence_checkpoint: $evidence_checkpoint,
      orchestration_receipt: $orchestration_receipt,
      replay_pointers: $replay_pointers,
      trace_pointers: $trace_pointers
    }')"
  merged_map_json="$(printf '%s\n%s\n' "$existing_map_json" "$new_map_json" | jq -s '.[0] * .[1]')"
  jq -n \
    --arg run_id "$run_id" \
    --argjson evidence_refs "$merged_map_json" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "retained-run-evidence-v1",
        run_id: $run_id,
        evidence_refs: $evidence_refs,
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$retained_file"
}

ensure_run_lifecycle_roots() {
  local run_id="$1"
  ensure_dir "$(run_control_dir "$run_id")"
  ensure_dir "$(stage_attempt_dir "$run_id")"
  ensure_dir "$(checkpoint_dir "$run_id")"
  ensure_dir "$(run_evidence_dir "$run_id")"
  ensure_dir "$(receipt_dir "$run_id")"
  ensure_dir "$(evidence_checkpoint_dir "$run_id")"
  ensure_dir "$(run_evidence_dir "$run_id")/replay"
}

upsert_run_contract() {
  local run_id="$1"
  local status="$2"
  local created_at="$3"
  local workflow_group="$4"
  local workflow_id="$5"
  local mission_id="$6"
  local automation_id="$7"
  local incident_id="$8"
  local summary="$9"

  local run_dir contract_file stage_dir scope_in_json requested_capabilities_json mission_ref
  run_dir="$(run_control_dir "$run_id")"
  contract_file="$(run_contract_path "$run_id")"
  stage_dir="$(stage_attempt_dir "$run_id")"
  ensure_run_lifecycle_roots "$run_id"

  scope_in_json="$(collect_scope_in_json "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id")"
  requested_capabilities_json="$(collect_requested_capabilities_json "$workflow_group" "$workflow_id" "$mission_id" "$automation_id")"
  mission_ref=""
  if [[ -n "$mission_id" ]]; then
    mission_ref=".octon/instance/orchestration/missions/$mission_id/mission.yml"
  fi

  jq -n \
    --arg run_id "$run_id" \
    --arg status "$status" \
    --arg created_at "$created_at" \
    --arg updated_at "$created_at" \
    --arg summary "$summary" \
    --arg mission_id "$mission_id" \
    --arg mission_ref "$mission_ref" \
    --arg stage_attempt_root "$(stage_attempt_dir_relpath "$run_id")" \
    --arg control_checkpoint_root "$(checkpoint_dir_relpath "$run_id")" \
    --arg runtime_state_ref "$(runtime_state_relpath "$run_id")" \
    --arg rollback_posture_ref "$(rollback_posture_relpath "$run_id")" \
    --arg evidence_root "$(run_evidence_relpath "$run_id")" \
    --arg receipt_root "$(receipt_dir_relpath "$run_id")" \
    --arg replay_pointers_ref "$(replay_pointers_relpath "$run_id")" \
    --arg notes_ref ".octon/framework/orchestration/runtime/runs/$run_id.yml" \
    --argjson scope_in "$scope_in_json" \
    --argjson requested_capabilities "$requested_capabilities_json" \
    '
      {
        schema_version: "run-contract-v1",
        run_id: $run_id,
        objective_refs: {
          workspace_objective_ref: ".octon/instance/bootstrap/OBJECTIVE.md",
          workspace_intent_ref: ".octon/instance/cognition/context/shared/intent.contract.yml"
        },
        scope_in: $scope_in,
        scope_out: [],
        requested_capabilities: $requested_capabilities,
        risk_class: "low",
        reversibility_class: "reversible",
        support_tier: "repo-local-transitional",
        required_approvals: [],
        required_evidence: [
          "decision-artifact",
          "run-evidence-root",
          "orchestration-run-projection",
          "policy-receipt",
          "replay-pointers",
          "trace-pointers"
        ],
        closure_conditions: [
          "Run reaches a terminal projection status.",
          "Decision and retained run evidence remain linked."
        ],
        stage_attempt_root: $stage_attempt_root,
        control_checkpoint_root: $control_checkpoint_root,
        runtime_state_ref: $runtime_state_ref,
        rollback_posture_ref: $rollback_posture_ref,
        evidence_root: $evidence_root,
        receipt_root: $receipt_root,
        replay_pointers_ref: $replay_pointers_ref,
        rollback_or_compensation_expectation: "Rollback or compensation posture is handled by downstream runtime lifecycle waves; Wave 1 records the execution contract and initial attempt root.",
        status: $status,
        created_at: $created_at,
        updated_at: $updated_at,
        notes_ref: $notes_ref
      }
      | if $mission_id != "" then
          .objective_refs += {
            mission_id: $mission_id,
            mission_ref: $mission_ref
          }
        else .
        end
    ' | yq -P -p=json '.' > "$contract_file"

  local initial_attempt="$stage_dir/initial.yml"
  if [[ ! -f "$initial_attempt" ]]; then
    jq -n \
      --arg run_id "$run_id" \
      --arg status "$status" \
      --arg created_at "$created_at" \
      --arg updated_at "$created_at" \
      --arg objective_ref "$(run_contract_relpath "$run_id")" \
      --argjson requested_capabilities "$requested_capabilities_json" \
      '
        {
          schema_version: "stage-attempt-v1",
          run_id: $run_id,
          stage_attempt_id: "initial",
          stage_ref: "orchestration-projection",
          attempt_kind: "initial",
          status: $status,
          objective_ref: $objective_ref,
          requested_capabilities: $requested_capabilities,
          evidence_refs: [],
          rollback_candidate: true,
          created_at: $created_at,
          updated_at: $updated_at
        }
      ' | yq -P -p=json '.' > "$initial_attempt"
  fi

  write_orchestration_receipt_file "$run_id" "$status" "$summary" "$created_at"
  write_runtime_state_file "$run_id" "$status" "$created_at" "$created_at" "$mission_id" "" "$(orchestration_receipt_relpath "$run_id")"
  write_rollback_posture_file "$run_id" "$created_at"
  write_bound_checkpoint_files "$run_id" "$created_at"
  write_replay_pointer_file "$run_id" "$created_at"
  write_trace_pointer_file "$run_id" "$created_at"
  write_retained_evidence_file "$run_id" "$created_at"
}

update_run_contract_status() {
  local run_id="$1"
  local projection_status="$2"
  local updated_at="$3"
  local contract_status attempt_status current_contract_status current_attempt_status contract_file initial_attempt
  contract_file="$(run_contract_path "$run_id")"
  initial_attempt="$(stage_attempt_dir "$run_id")/initial.yml"
  contract_status="$(contract_status_from_projection "$projection_status")"
  attempt_status="$(attempt_status_from_projection "$projection_status")"

  if [[ -f "$contract_file" ]]; then
    current_contract_status="$(yq -r '.status // ""' "$contract_file")"
    case "$current_contract_status" in
      completed|failed|cancelled)
        if [[ "$contract_status" == "running" ]]; then
          contract_status="$current_contract_status"
        fi
        ;;
    esac
    yq -o=json '.' "$contract_file" | jq --arg status "$contract_status" --arg updated_at "$updated_at" '.status=$status | .updated_at=$updated_at' | yq -P -p=json '.' > "$contract_file.tmp"
    mv "$contract_file.tmp" "$contract_file"
  fi

  if [[ -f "$initial_attempt" ]]; then
    current_attempt_status="$(yq -r '.status // ""' "$initial_attempt")"
    case "$current_attempt_status" in
      succeeded|failed|cancelled)
        if [[ "$attempt_status" == "running" ]]; then
          attempt_status="$current_attempt_status"
        fi
        ;;
    esac
    yq -o=json '.' "$initial_attempt" | jq --arg status "$attempt_status" --arg updated_at "$updated_at" '.status=$status | .updated_at=$updated_at' | yq -P -p=json '.' > "$initial_attempt.tmp"
    mv "$initial_attempt.tmp" "$initial_attempt"
  fi

  local mission_id parent_run_id
  mission_id="$( [[ -f "$RUNTIME_RUNS_DIR/$run_id.yml" ]] && yq -r '.mission_id // ""' "$RUNTIME_RUNS_DIR/$run_id.yml" 2>/dev/null || printf '' )"
  parent_run_id="$( [[ -f "$RUNTIME_RUNS_DIR/$run_id.yml" ]] && yq -r '.parent_run_id // ""' "$RUNTIME_RUNS_DIR/$run_id.yml" 2>/dev/null || printf '' )"
  local summary=""
  summary="$( [[ -f "$RUNTIME_RUNS_DIR/$run_id.yml" ]] && yq -r '.summary // ""' "$RUNTIME_RUNS_DIR/$run_id.yml" 2>/dev/null || printf '' )"
  write_orchestration_receipt_file "$run_id" "$projection_status" "$summary" "$updated_at"
  local created_at=""
  created_at="$( [[ -f "$(runtime_state_path "$run_id")" ]] && yq -r '.created_at // ""' "$(runtime_state_path "$run_id")" 2>/dev/null || printf '' )"
  [[ -n "$created_at" ]] || created_at="$updated_at"
  write_runtime_state_file "$run_id" "$projection_status" "$created_at" "$updated_at" "$mission_id" "$parent_run_id" "$(orchestration_receipt_relpath "$run_id")"
  write_rollback_posture_file "$run_id" "$updated_at"
  write_replay_pointer_file "$run_id" "$updated_at"
  write_trace_pointer_file "$run_id" "$updated_at"
  write_retained_evidence_file "$run_id" "$updated_at"
}

ensure_run_surface() {
  ensure_dir "$RUNTIME_RUNS_DIR"
  ensure_dir "$RUN_CONTROL_ROOT"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/workflows"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/missions"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/automations"
  ensure_dir "$RUNTIME_RUNS_DIR/by-surface/incidents"
  [[ -f "$RUNTIME_RUNS_DIR/index.yml" ]] || cat > "$RUNTIME_RUNS_DIR/index.yml" <<'EOF'
schema_version: "orchestration-runs-index-v1"
runs: []
EOF
}

projection_file() {
  local surface="$1"
  local key="$2"
  local encoded
  encoded="$(printf '%s' "$key" | tr '/:' '__' | tr ' ' '-')"
  printf '%s/by-surface/%s/%s.yml' "$RUNTIME_RUNS_DIR" "$surface" "$encoded"
}

upsert_projection() {
  local surface="$1"
  local key="$2"
  local run_id="$3"
  local file
  file="$(projection_file "$surface" "$key")"
  if [[ ! -f "$file" ]]; then
    cat > "$file" <<EOF
schema_version: "orchestration-run-projection-v1"
surface: "$surface"
key: "$key"
run_ids:
  - "$run_id"
EOF
    return
  fi
  projection_json="$(yq -o=json '.' "$file" | jq --arg run_id "$run_id" '.run_ids += [$run_id] | .run_ids |= unique')"
  printf '%s\n' "$projection_json" | yq -P -p=json '.' > "$file"
}

upsert_index() {
  local run_id="$1"
  local status="$2"
  local workflow_group="$3"
  local workflow_id="$4"
  local mission_id="$5"
  local automation_id="$6"
  local incident_id="$7"
  local continuity_run_path="$8"

  index_json="$(
    yq -o=json '.' "$RUNTIME_RUNS_DIR/index.yml" | jq \
      --arg run_id "$run_id" \
      --arg status "$status" \
      --arg workflow_group "$workflow_group" \
      --arg workflow_id "$workflow_id" \
      --arg mission_id "$mission_id" \
      --arg automation_id "$automation_id" \
      --arg incident_id "$incident_id" \
      --arg continuity_run_path "$continuity_run_path" '
        .runs = (.runs // []) |
        .runs |= map(select(.run_id != $run_id)) |
        .runs += [{
          run_id: $run_id,
          status: $status,
          path: ($run_id + ".yml"),
          continuity_run_path: $continuity_run_path
        }
        + (if $workflow_group != "" and $workflow_id != "" then {workflow_ref:{workflow_group:$workflow_group,workflow_id:$workflow_id}} else {} end)
        + (if $mission_id != "" then {mission_id:$mission_id} else {} end)
        + (if $automation_id != "" then {automation_id:$automation_id} else {} end)
        + (if $incident_id != "" then {incident_id:$incident_id} else {} end)]
      '
  )"
  printf '%s\n' "$index_json" | yq -P -p=json '.' > "$RUNTIME_RUNS_DIR/index.yml"
}

write_run_file() {
  local run_file="$1"
  local json="$2"
  printf '%s\n' "$json" | yq -P -p=json '.' > "$run_file"
}

cmd="${1:-}"
shift || true
ensure_run_surface

case "$cmd" in
  create)
    run_id=""
    decision_id=""
    summary=""
    workflow_group=""
    workflow_id=""
    mission_id=""
    automation_id=""
    incident_id=""
    event_id=""
    queue_item_id=""
    parent_run_id=""
    coordination_key=""
    executor_id=""
    started_at="$(now_utc)"
    executor_acknowledged_at=""
    last_heartbeat_at=""
    lease_expires_at=""
    lease_seconds=""
    recovery_status="healthy"
    recovery_reason=""
    status="running"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --decision-id) decision_id="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --workflow-group) workflow_group="$2"; shift 2 ;;
        --workflow-id) workflow_id="$2"; shift 2 ;;
        --mission-id) mission_id="$2"; shift 2 ;;
        --automation-id) automation_id="$2"; shift 2 ;;
        --incident-id) incident_id="$2"; shift 2 ;;
        --event-id) event_id="$2"; shift 2 ;;
        --queue-item-id) queue_item_id="$2"; shift 2 ;;
        --parent-run-id) parent_run_id="$2"; shift 2 ;;
        --coordination-key) coordination_key="$2"; shift 2 ;;
        --executor-id) executor_id="$2"; shift 2 ;;
        --started-at) started_at="$2"; shift 2 ;;
        --executor-acknowledged-at) executor_acknowledged_at="$2"; shift 2 ;;
        --last-heartbeat-at) last_heartbeat_at="$2"; shift 2 ;;
        --lease-expires-at) lease_expires_at="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        --recovery-status) recovery_status="$2"; shift 2 ;;
        --recovery-reason) recovery_reason="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done

    [[ -n "$run_id" && -n "$decision_id" && -n "$summary" && -n "$executor_id" ]] || { usage; exit 1; }
    [[ -f "$DECISIONS_DIR/$decision_id/decision.json" ]] || { echo "decision does not exist: $decision_id" >&2; exit 1; }
    if [[ -n "$workflow_group" || -n "$workflow_id" ]]; then
      [[ -n "$workflow_group" && -n "$workflow_id" ]] || { echo "workflow_group and workflow_id must be supplied together" >&2; exit 1; }
      bash "$SCRIPT_DIR/load-orchestration-discovery.sh" resolve-workflow --workflow-group "$workflow_group" --workflow-id "$workflow_id" >/dev/null
    fi
    if [[ -n "$mission_id" ]]; then
      bash "$SCRIPT_DIR/load-orchestration-discovery.sh" resolve-mission --mission-id "$mission_id" >/dev/null
    fi

    if [[ -z "$lease_expires_at" && -n "$lease_seconds" ]]; then
      lease_expires_at="$(date -u -v+"${lease_seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${lease_seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
)"
    fi
    [[ -n "$lease_expires_at" ]] || { echo "lease-expires-at or lease-seconds is required" >&2; exit 1; }
    [[ -n "$executor_acknowledged_at" ]] || executor_acknowledged_at="$started_at"
    [[ -n "$last_heartbeat_at" ]] || last_heartbeat_at="$executor_acknowledged_at"

    continuity_run_path="$(run_evidence_relpath "$run_id")/"
    ensure_run_lifecycle_roots "$run_id"
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ ! -f "$run_file" ]] || { echo "run already exists: $run_id" >&2; exit 1; }

    upsert_run_contract "$run_id" "running" "$started_at" "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id" "$summary"

    run_json="$(
      jq -n \
        --arg run_id "$run_id" \
        --arg status "$status" \
        --arg started_at "$started_at" \
        --arg workflow_group "$workflow_group" \
        --arg workflow_id "$workflow_id" \
        --arg mission_id "$mission_id" \
        --arg automation_id "$automation_id" \
        --arg incident_id "$incident_id" \
        --arg event_id "$event_id" \
        --arg queue_item_id "$queue_item_id" \
        --arg parent_run_id "$parent_run_id" \
        --arg coordination_key "$coordination_key" \
        --arg executor_id "$executor_id" \
        --arg executor_acknowledged_at "$executor_acknowledged_at" \
        --arg last_heartbeat_at "$last_heartbeat_at" \
        --arg lease_expires_at "$lease_expires_at" \
        --arg recovery_status "$recovery_status" \
        --arg recovery_reason "$recovery_reason" \
        --arg decision_id "$decision_id" \
        --arg continuity_run_path "$continuity_run_path" \
        --arg run_contract_path "$(run_contract_relpath "$run_id")" \
        --arg stage_attempt_root "$(stage_attempt_dir_relpath "$run_id")" \
        --arg runtime_state_path "$(runtime_state_relpath "$run_id")" \
        --arg rollback_posture_path "$(rollback_posture_relpath "$run_id")" \
        --arg receipt_root "$(receipt_dir_relpath "$run_id")" \
        --arg replay_pointers_path "$(replay_pointers_relpath "$run_id")" \
        --arg trace_pointers_path "$(trace_pointers_relpath "$run_id")" \
        --arg summary "$summary" '
          {
            run_id: $run_id,
            status: $status,
            started_at: $started_at,
            decision_id: $decision_id,
            continuity_run_path: $continuity_run_path,
            run_contract_path: $run_contract_path,
            stage_attempt_root: $stage_attempt_root,
            runtime_state_path: $runtime_state_path,
            rollback_posture_path: $rollback_posture_path,
            receipt_root: $receipt_root,
            replay_pointers_path: $replay_pointers_path,
            trace_pointers_path: $trace_pointers_path,
            summary: $summary,
            executor_id: $executor_id,
            executor_acknowledged_at: $executor_acknowledged_at,
            last_heartbeat_at: $last_heartbeat_at,
            lease_expires_at: $lease_expires_at,
            recovery_status: $recovery_status
          }
          + (if $workflow_group != "" and $workflow_id != "" then {workflow_ref:{workflow_group:$workflow_group,workflow_id:$workflow_id}} else {} end)
          + (if $mission_id != "" then {mission_id:$mission_id} else {} end)
          + (if $automation_id != "" then {automation_id:$automation_id} else {} end)
          + (if $incident_id != "" then {incident_id:$incident_id} else {} end)
          + (if $event_id != "" then {event_id:$event_id} else {} end)
          + (if $queue_item_id != "" then {queue_item_id:$queue_item_id} else {} end)
          + (if $parent_run_id != "" then {parent_run_id:$parent_run_id} else {} end)
          + (if $coordination_key != "" then {coordination_key:$coordination_key} else {} end)
          + (if $recovery_reason != "" then {recovery_reason:$recovery_reason} else {} end)
        '
    )"
    write_run_file "$run_file" "$run_json"

    upsert_index "$run_id" "$status" "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id" "$continuity_run_path"
    [[ -n "$workflow_group" && -n "$workflow_id" ]] && upsert_projection "workflows" "$workflow_group--$workflow_id" "$run_id"
    [[ -n "$mission_id" ]] && upsert_projection "missions" "$mission_id" "$run_id"
    [[ -n "$automation_id" ]] && upsert_projection "automations" "$automation_id" "$run_id"
    [[ -n "$incident_id" ]] && upsert_projection "incidents" "$incident_id" "$run_id"
    echo "$run_file"
    ;;
  complete)
    run_id=""
    status=""
    summary=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --status) status="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$status" && -n "$summary" ]] || { usage; exit 1; }
    case "$status" in
      succeeded|failed|cancelled) ;;
      *) echo "invalid completion status: $status" >&2; exit 1 ;;
    esac
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    completed_at="$(now_utc)"
    run_json="$(yq -o=json '.' "$run_file" | jq --arg status "$status" --arg summary "$summary" --arg completed_at "$completed_at" '.status=$status | .summary=$summary | .completed_at=$completed_at')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    update_run_contract_status "$run_id" "$status" "$completed_at"
    workflow_group="$(yq -r '.workflow_ref.workflow_group // ""' "$run_file")"
    workflow_id="$(yq -r '.workflow_ref.workflow_id // ""' "$run_file")"
    mission_id="$(yq -r '.mission_id // ""' "$run_file")"
    automation_id="$(yq -r '.automation_id // ""' "$run_file")"
    incident_id="$(yq -r '.incident_id // ""' "$run_file")"
    continuity_run_path="$(yq -r '.continuity_run_path' "$run_file")"
    upsert_index "$run_id" "$status" "$workflow_group" "$workflow_id" "$mission_id" "$automation_id" "$incident_id" "$continuity_run_path"
    echo "$run_file"
    ;;
  heartbeat)
    run_id=""
    lease_seconds=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$lease_seconds" ]] || { usage; exit 1; }
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    heartbeat_at="$(now_utc)"
    lease_expires_at="$(date -u -v+"${lease_seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${lease_seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
)"
    run_json="$(yq -o=json '.' "$run_file" | jq --arg heartbeat_at "$heartbeat_at" --arg lease_expires_at "$lease_expires_at" '.last_heartbeat_at=$heartbeat_at | .lease_expires_at=$lease_expires_at')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    update_run_contract_status "$run_id" "running" "$heartbeat_at"
    echo "$run_file"
    ;;
  recovery)
    run_id=""
    recovery_status=""
    recovery_reason=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-id) run_id="$2"; shift 2 ;;
        --recovery-status) recovery_status="$2"; shift 2 ;;
        --recovery-reason) recovery_reason="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$run_id" && -n "$recovery_status" ]] || { usage; exit 1; }
    run_file="$RUNTIME_RUNS_DIR/$run_id.yml"
    [[ -f "$run_file" ]] || { echo "run not found: $run_id" >&2; exit 1; }
    run_json="$(yq -o=json '.' "$run_file" | jq --arg recovery_status "$recovery_status" --arg recovery_reason "$recovery_reason" '.recovery_status=$recovery_status | (if $recovery_reason != "" then .recovery_reason=$recovery_reason else . end)')"
    printf '%s\n' "$run_json" | yq -P -p=json '.' > "$run_file"
    update_run_contract_status "$run_id" "running" "$(now_utc)"
    echo "$run_file"
    ;;
  *)
    usage
    exit 1
    ;;
esac
