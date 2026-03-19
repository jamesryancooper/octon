#!/usr/bin/env bash
# enforce-deny-by-default.sh - Runtime deny-by-default guard for shell service entrypoints.

set -o pipefail

OCTON_ENFORCER_START_TS="${OCTON_ENFORCER_START_TS:-$(date +%s)}"

octon_acp_collect_git_diff_counters() {
  local repo_root="$1"
  local files_touched=0
  local loc_delta=0
  local adds deletes path

  if command -v git >/dev/null 2>&1 && git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    while IFS=$'\t' read -r adds deletes path; do
      [[ -n "${path:-}" ]] || continue
      [[ "$adds" == "-" ]] && adds=0
      [[ "$deletes" == "-" ]] && deletes=0
      [[ "$adds" =~ ^[0-9]+$ ]] || adds=0
      [[ "$deletes" =~ ^[0-9]+$ ]] || deletes=0
      files_touched=$((files_touched + 1))
      loc_delta=$((loc_delta + adds + deletes))
    done < <(git -C "$repo_root" diff --numstat 2>/dev/null || true)

    jq -cn \
      --argjson files_touched "$files_touched" \
      --argjson loc_delta "$loc_delta" \
      '{
        "repo.files_touched": $files_touched,
        "repo.max_files_touched": $files_touched,
        "repo.loc_delta": $loc_delta,
        "repo.max_loc_delta": $loc_delta,
        "repo.git_diff_unknown": 0
      }'
    return 0
  fi

  jq -cn '{
    "repo.files_touched": 0,
    "repo.max_files_touched": 0,
    "repo.loc_delta": 0,
    "repo.max_loc_delta": 0,
    "repo.git_diff_unknown": 1
  }'
}

octon_acp_default_counters_json() {
  local repo_root="$1"
  local now start elapsed command_count net_calls git_diff_json

  now="$(date +%s)"
  start="${OCTON_ENFORCER_START_TS:-$now}"
  if [[ ! "$start" =~ ^[0-9]+$ ]]; then
    start="$now"
  fi
  elapsed=$((now - start))
  if (( elapsed < 0 )); then
    elapsed=0
  fi

  command_count="${OCTON_COMMAND_COUNT:-0}"
  if [[ ! "$command_count" =~ ^[0-9]+$ ]]; then
    command_count=0
  fi
  command_count=$((command_count + 1))

  net_calls="${OCTON_NET_CALLS:-0}"
  if [[ ! "$net_calls" =~ ^[0-9]+$ ]]; then
    net_calls=0
  fi

  git_diff_json="$(octon_acp_collect_git_diff_counters "$repo_root")"
  jq -cn \
    --argjson git "$git_diff_json" \
    --argjson command_count "$command_count" \
    --argjson net_calls "$net_calls" \
    --argjson elapsed "$elapsed" \
    '$git + {
      "commands.count": $command_count,
      "net.calls": $net_calls,
      "time.elapsed_seconds": $elapsed,
      "time.max_seconds": $elapsed,
      "repo.max_commits": 0
    }'
}

octon_acp_default_instruction_layers_json() {
  jq -cn '[
    {
      "layer_id": "provider",
      "source": "upstream",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "bytes": 0,
      "visibility": "partial"
    },
    {
      "layer_id": "system",
      "source": "octon-system",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "bytes": 0,
      "visibility": "partial"
    },
    {
      "layer_id": "developer",
      "source": "AGENTS.md",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "bytes": 0,
      "visibility": "full"
    },
    {
      "layer_id": "user",
      "source": "runtime-request",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "bytes": 0,
      "visibility": "full"
    }
  ]'
}

octon_acp_default_context_acquisition_json() {
  local now start elapsed_ms command_count

  now="$(date +%s)"
  start="${OCTON_ENFORCER_START_TS:-$now}"
  if [[ ! "$start" =~ ^[0-9]+$ ]]; then
    start="$now"
  fi
  elapsed_ms=$(( (now - start) * 1000 ))
  if (( elapsed_ms < 0 )); then
    elapsed_ms=0
  fi

  command_count="${OCTON_COMMAND_COUNT:-0}"
  if [[ ! "$command_count" =~ ^[0-9]+$ ]]; then
    command_count=0
  fi
  command_count=$((command_count + 1))

  jq -cn \
    --argjson commands "$command_count" \
    --argjson duration_ms "$elapsed_ms" \
    '{
      file_reads: 0,
      search_queries: 0,
      commands: $commands,
      subagent_spawns: 0,
      duration_ms: $duration_ms
    }'
}

octon_ddb_split_allowed_tools() {
  local raw="$1"
  local token=""
  local depth=0
  local ch
  local i

  for ((i=0; i<${#raw}; i++)); do
    ch="${raw:i:1}"
    case "$ch" in
      "(")
        depth=$((depth + 1))
        token+="$ch"
        ;;
      ")")
        if [[ $depth -gt 0 ]]; then
          depth=$((depth - 1))
        fi
        token+="$ch"
        ;;
      " " | $'\t')
        if [[ $depth -eq 0 ]]; then
          if [[ -n "$token" ]]; then
            echo "$token"
            token=""
          fi
        else
          token+="$ch"
        fi
        ;;
      *)
        token+="$ch"
        ;;
    esac
  done

  if [[ -n "$token" ]]; then
    echo "$token"
  fi
}

octon_ddb_manifest_field() {
  local manifest="$1"
  local service_id="$2"
  local field="$3"

  awk -v target="$service_id" -v field="$field" '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      found=(id==target)
      next
    }
    found && $1 == field":" {
      line=$0
      sub("^[[:space:]]*"field":[[:space:]]*", "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    found && /^[[:space:]]*- id:/ {exit}
  ' "$manifest"
}

octon_ddb_log_enforcement() {
  local log_file="$1"
  local service_id="$2"
  local requested="$3"
  local rc="$4"

  mkdir -p "$(dirname "$log_file")"
  printf '%s\t%s\t%s\t%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$service_id" "$rc" "$requested" >> "$log_file"
}

octon_ddb_log_decision_json() {
  local json_log_file="$1"
  local service_id="$2"
  local decision_json="$3"

  mkdir -p "$(dirname "$json_log_file")"

  if command -v jq >/dev/null 2>&1; then
    local compact
    compact="$(jq -c --arg service "$service_id" --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '. + {service:$service,timestamp:$ts}' <<<"$decision_json" 2>/dev/null || true)"
    if [[ -n "$compact" ]]; then
      printf '%s\n' "$compact" >> "$json_log_file"
      return 0
    fi
  fi

  local flattened
  flattened="$(echo "$decision_json" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')"
  printf '{"timestamp":"%s","service":"%s","raw":"%s"}\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$service_id" "$flattened" >> "$json_log_file"
}

octon_ddb_emit_deny() {
  local decision_json="$1"

  if command -v jq >/dev/null 2>&1; then
    local code message hint
    code="$(jq -r '.deny.code // "DDB025_RUNTIME_DECISION_ENGINE_ERROR"' <<<"$decision_json" 2>/dev/null)"
    message="$(jq -r '.deny.message // "Denied by policy"' <<<"$decision_json" 2>/dev/null)"
    hint="$(jq -r '.deny.remediation_hint // empty' <<<"$decision_json" 2>/dev/null)"

    echo "[deny-by-default][$code] $message" >&2
    if [[ -n "$hint" ]]; then
      echo "[deny-by-default] remediation: $hint" >&2
    fi
  else
    echo "[deny-by-default] $decision_json" >&2
  fi
}

octon_acp_should_gate_phase() {
  local phase="${1:-stage}"
  case "$phase" in
    promote|finalize) return 0 ;;
    *) return 1 ;;
  esac
}

octon_acp_phase_valid() {
  local phase="${1:-}"
  case "$phase" in
    stage|promote|finalize) return 0 ;;
    *) return 1 ;;
  esac
}

octon_acp_is_mutating_operation_class() {
  local operation_class="${1:-}"
  local normalized="${operation_class,,}"

  case "$normalized" in
    observe.*|read.*|query.*|audit.*|verify.*|inspect.*|report.*|status.*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

octon_acp_emit_receipt() {
  local receipt_writer="$1"
  local policy_file="$2"
  local request_file="$3"
  local decision_file="$4"

  if [[ ! -x "$receipt_writer" ]]; then
    return 0
  fi

  "$receipt_writer" --policy "$policy_file" --request "$request_file" --decision "$decision_file" >/dev/null 2>&1 || true
}

octon_acp_gate_enforce() {
  local service_id="$1"
  local octon_root="$2"
  local policy_file="$3"

  local phase operation_class run_id profile actor_id actor_type break_glass keep_tmp
  local phase_raw phase_reason phase_note
  local target_json evidence_json attestations_json counters_json budgets_json signals_json reversibility_json
  local instruction_layers_json context_acquisition_json context_overhead_ratio
  local request_builder acp_eval receipt_writer breaker_actions_script
  local tmp_dir request_file decision_file decision_output rc request_rc
  local continuity_run_dir rollback_dir decision_kind
  local repo_root

  operation_class="${OCTON_OPERATION_CLASS:-service.execute}"
  phase_raw="${OCTON_OPERATION_PHASE-}"
  phase_reason=""
  phase_note=""

  if [[ -n "${OCTON_OPERATION_PHASE+x}" && -n "${phase_raw//[[:space:]]/}" ]]; then
    phase="$(printf '%s' "$phase_raw" | tr '[:upper:]' '[:lower:]')"
    if ! octon_acp_phase_valid "$phase"; then
      if octon_acp_is_mutating_operation_class "$operation_class"; then
        phase="promote"
        phase_reason="ACP_PHASE_INVALID"
        phase_note="operation.phase must be one of stage|promote|finalize for mutating operation classes"
      else
        phase="stage"
      fi
    fi
  else
    if octon_acp_is_mutating_operation_class "$operation_class"; then
      phase="promote"
      phase_reason="ACP_PHASE_REQUIRED"
      phase_note="operation.phase must be explicit for mutating operation classes"
    else
      phase="stage"
    fi
  fi

  if ! octon_acp_should_gate_phase "$phase"; then
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "[acp] jq is required for ACP promote/finalize gating" >&2
    return 13
  fi

  run_id="${OCTON_RUN_ID:-run-$(date -u +"%Y%m%dT%H%M%SZ")-$$}"
  profile="${OCTON_POLICY_PROFILE:-refactor}"
  actor_id="${OCTON_AGENT_ID:-agent-local}"
  actor_type="${OCTON_ACTOR_TYPE:-agent}"
  break_glass="${OCTON_BREAK_GLASS:-false}"
  keep_tmp="${OCTON_ACP_KEEP_TMP:-false}"

  target_json="${OCTON_ACP_TARGET_JSON:-}"
  [[ -n "$target_json" ]] || target_json='{}'
  target_json="$(jq -c '
    if type != "object" then
      {
        workflow_mode: "autonomous",
        capability_classification: "agent-ready",
        boundary_route: "allow"
      }
    else
      . + {
        workflow_mode: (.workflow_mode // "autonomous"),
        capability_classification: (.capability_classification // "agent-ready"),
        boundary_route: (.boundary_route // "allow")
      }
    end
  ' <<<"$target_json" 2>/dev/null || echo '{"workflow_mode":"autonomous","capability_classification":"agent-ready","boundary_route":"allow"}')"
  if [[ -n "${OCTON_TARGET_BRANCH:-}" ]]; then
    target_json="$(jq -c --arg branch "$OCTON_TARGET_BRANCH" '
      if type != "object" then
        {branch: $branch}
      else
        . + {branch: (.branch // $branch)}
      end
    ' <<<"$target_json" 2>/dev/null || echo "{\"branch\":\"$OCTON_TARGET_BRANCH\"}")"
  fi
  if [[ "$operation_class" == "fs.soft_delete" ]]; then
    target_json="$(jq -c '
      if type != "object" then
        {scope:"broad"}
      elif has("scope") then
        .
      else
        . + {scope:"broad"}
      end
    ' <<<"$target_json" 2>/dev/null || echo '{"scope":"broad"}')"
  fi

  evidence_json="${OCTON_ACP_EVIDENCE_JSON:-}"
  [[ -n "$evidence_json" ]] || evidence_json='[]'
  attestations_json="${OCTON_ACP_ATTESTATIONS_JSON:-}"
  [[ -n "$attestations_json" ]] || attestations_json='[]'
  counters_json="${OCTON_ACP_COUNTERS_JSON:-}"
  if [[ -z "$counters_json" || "$counters_json" == "{}" || "$counters_json" == "null" ]]; then
    repo_root="$(cd "$octon_root/.." && pwd)"
    counters_json="$(octon_acp_default_counters_json "$repo_root")"
  fi
  budgets_json="${OCTON_ACP_BUDGETS_JSON:-}"
  [[ -n "$budgets_json" ]] || budgets_json='{}'
  signals_json="${OCTON_ACP_SIGNALS_JSON:-}"
  [[ -n "$signals_json" ]] || signals_json='[]'
  instruction_layers_json="${OCTON_ACP_INSTRUCTION_LAYERS_JSON:-}"
  [[ -n "$instruction_layers_json" ]] || instruction_layers_json="$(octon_acp_default_instruction_layers_json)"
  context_acquisition_json="${OCTON_ACP_CONTEXT_ACQUISITION_JSON:-}"
  [[ -n "$context_acquisition_json" ]] || context_acquisition_json="$(octon_acp_default_context_acquisition_json)"
  context_overhead_ratio="${OCTON_ACP_CONTEXT_OVERHEAD_RATIO:-0}"
  reversibility_json="${OCTON_ACP_REVERSIBILITY_JSON:-}"
  if [[ -z "$reversibility_json" ]]; then
    local default_primitive default_recovery_window
    default_primitive="git.revert_commit"
    default_recovery_window="P30D"
    case "$operation_class" in
      git.merge) default_primitive="git.revert_merge" ;;
      fs.soft_delete) default_primitive="fs.move_to_trash" ;;
      db.migrate) default_primitive="db.down_migration_or_shadow" ;;
      service.deploy) default_primitive="deploy.rollback" ;;
      resource.detach) default_primitive="infra.detach_archive" ;;
    esac
    reversibility_json="$(jq -cn \
      --arg primitive "${OCTON_REVERSIBLE_PRIMITIVE:-$default_primitive}" \
      --arg rollback_handle "${OCTON_ROLLBACK_HANDLE:-$default_primitive:$run_id}" \
      --arg recovery_window "${OCTON_RECOVERY_WINDOW:-$default_recovery_window}" \
      --arg rollback_proof "${OCTON_ROLLBACK_PROOF:-}" \
      '{
        reversible: true,
        primitive: (if ($primitive|length)==0 then null else $primitive end),
        rollback_handle: (if ($rollback_handle|length)==0 then null else $rollback_handle end),
        recovery_window: (if ($recovery_window|length)==0 then null else $recovery_window end),
        rollback_proof: (if ($rollback_proof|length)==0 then null else $rollback_proof end)
      }')"
  fi

  request_builder="$octon_root/capabilities/_ops/scripts/policy-acp-request.sh"
  acp_eval="$octon_root/capabilities/_ops/scripts/policy-acp-eval.sh"
  receipt_writer="$octon_root/capabilities/_ops/scripts/policy-receipt-write.sh"
  breaker_actions_script="$octon_root/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh"

  if [[ ! -x "$request_builder" || ! -x "$acp_eval" ]]; then
    echo "[acp] missing ACP helper scripts under .octon/framework/capabilities/_ops/scripts" >&2
    return 13
  fi

  tmp_dir="$repo_root/generated/.tmp/capabilities/policy/acp"
  mkdir -p "$tmp_dir"
  request_file="$tmp_dir/${run_id}-${service_id}-request.json"
  decision_file="$tmp_dir/${run_id}-${service_id}-decision.json"

  request_rc=0
  "$request_builder" \
    --output "$request_file" \
    --run-id "$run_id" \
    --phase "$phase" \
    --profile "$profile" \
    --operation-class "$operation_class" \
    --actor-id "$actor_id" \
    --actor-type "$actor_type" \
    --target-json "$target_json" \
    --reversibility-json "$reversibility_json" \
    --evidence-json "$evidence_json" \
    --attestations-json "$attestations_json" \
    --budgets-json "$budgets_json" \
    --counters-json "$counters_json" \
    --signals-json "$signals_json" \
    --instruction-layers-json "$instruction_layers_json" \
    --context-acquisition-json "$context_acquisition_json" \
    --context-overhead-ratio "$context_overhead_ratio" \
    --plan-hash "${OCTON_PLAN_HASH:-}" \
    --evidence-hash "${OCTON_EVIDENCE_HASH:-}" \
    --intent "${OCTON_ACP_INTENT:-runtime-service-enforcement}" \
    --boundaries "${OCTON_ACP_BOUNDARIES:-service policy envelope}" \
    $( [[ "$break_glass" == "true" ]] && echo "--break-glass" ) >/dev/null || request_rc=$?

  if [[ "$request_rc" -ne 0 ]]; then
    echo "[acp] request envelope generation failed; failing closed" >&2
    return 13
  fi

  rc=0
  decision_output="$("$acp_eval" enforce --policy "$policy_file" --request "$request_file" 2>&1)" || rc=$?

  if jq -e . >/dev/null 2>&1 <<<"$decision_output"; then
    printf '%s\n' "$decision_output" > "$decision_file"
  else
    jq -n \
      --arg decision "DENY" \
      --arg effective_acp "ACP-0" \
      --arg msg "$decision_output" \
      '{allow:false,decision:$decision,effective_acp:$effective_acp,reason_codes:["DDB025_RUNTIME_DECISION_ENGINE_ERROR"],notes:[$msg],requirements:{}}' > "$decision_file"
  fi

  if [[ -n "$phase_reason" ]]; then
    local phase_tmp_file
    phase_tmp_file="${decision_file}.phase"
    jq -c \
      --arg reason "$phase_reason" \
      --arg note "$phase_note" \
      '.allow = false
       | .decision = "STAGE_ONLY"
       | .reason_codes = ((.reason_codes // []) + [$reason, "ACP_STAGE_ONLY_REQUIRED"] | unique)
       | .notes = ((.notes // []) + [$note])' \
      "$decision_file" > "$phase_tmp_file"
    mv "$phase_tmp_file" "$decision_file"
    rc=13
  fi

  octon_acp_emit_receipt "$receipt_writer" "$policy_file" "$request_file" "$decision_file"
  decision_kind="$(jq -r '.decision // "DENY"' "$decision_file" 2>/dev/null || echo "DENY")"

  continuity_run_dir="$repo_root/state/evidence/runs/$run_id"
  rollback_dir="$continuity_run_dir/rollback"
  mkdir -p "$continuity_run_dir"
  if [[ -x "$breaker_actions_script" ]]; then
    "$breaker_actions_script" run \
      --run-id "$run_id" \
      --decision "$decision_file" \
      --request "$request_file" \
      --rollback-dir "$rollback_dir" \
      --scope "service:$service_id" \
      --owner "$actor_id" >/dev/null 2>&1 || true
  fi

  if [[ "$keep_tmp" != "true" ]]; then
    rm -f "$request_file" "$decision_file" >/dev/null 2>&1 || true
    rmdir "$tmp_dir" >/dev/null 2>&1 || true
  fi

  case "$rc" in
    0)
      return 0
      ;;
    13)
      echo "[acp][$decision_kind] promotion blocked for operation '$operation_class' phase '$phase'" >&2
      return 13
      ;;
    *)
      echo "[acp] policy engine failure; failing closed" >&2
      return 13
      ;;
  esac
}

octon_enforce_service_policy() {
  local service_id="$1"
  local script_path="$2"
  shift 2 || true

  local script_dir services_root octon_root repo_root service_dir service_md manifest policy_file exceptions_file
  local policy_runner enforcement_log decision_json_log requested_command category

  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
  services_root="$(cd "$script_dir/../../.." && pwd)"
  octon_root="$(cd "$services_root/../../.." && pwd)"
  repo_root="$(cd "$octon_root/.." && pwd)"
  service_dir="$(cd "$script_dir/.." && pwd)"

  service_md="$service_dir/SERVICE.md"
  manifest="$services_root/manifest.yml"
  policy_file="$octon_root/capabilities/governance/policy/deny-by-default.v2.yml"
  exceptions_file="$repo_root/state/control/capabilities/deny-by-default-exceptions.yml"
  policy_runner="$octon_root/engine/runtime/policy"
  enforcement_log="$repo_root/state/evidence/runs/services/logs/deny-by-default-enforcement.log"
  decision_json_log="$repo_root/state/evidence/decisions/repo/capabilities/deny-by-default-decisions.jsonl"

  if [[ ! -x "$policy_runner" ]]; then
    echo "[deny-by-default] missing policy runner script: $policy_runner" >&2
    exit 13
  fi
  if [[ ! -f "$manifest" ]]; then
    echo "[deny-by-default] missing services manifest: $manifest" >&2
    exit 13
  fi
  if [[ ! -f "$service_md" ]]; then
    echo "[deny-by-default] missing SERVICE.md: $service_md" >&2
    exit 13
  fi
  if [[ ! -f "$policy_file" ]]; then
    echo "[deny-by-default] missing policy file: $policy_file" >&2
    exit 13
  fi

  local script_rel
  script_rel="${script_path#$services_root/}"
  requested_command="bash ${script_rel}"
  if [[ $# -gt 0 ]]; then
    requested_command+=" $*"
  fi

  category="$(octon_ddb_manifest_field "$manifest" "$service_id" "category")"

  # Agent-only checks are always enforced by the policy engine.
  export OCTON_AGENT_ID="${OCTON_AGENT_ID:-agent-local}"
  export OCTON_AGENT_IDS="${OCTON_AGENT_IDS:-$OCTON_AGENT_ID}"
  export OCTON_RISK_TIER="${OCTON_RISK_TIER:-low}"

  local decision_output
  local rc=0

  if [[ -n "$category" ]]; then
    decision_output="$(
      "$policy_runner" enforce \
        --kind service \
        --id "$service_id" \
        --manifest "$manifest" \
        --artifact "$service_md" \
        --policy "$policy_file" \
        --exceptions "$exceptions_file" \
        --requested-command "$requested_command" \
        --category "$category" 2>&1
    )" || rc=$?
  else
    decision_output="$(
      "$policy_runner" enforce \
        --kind service \
        --id "$service_id" \
        --manifest "$manifest" \
        --artifact "$service_md" \
        --policy "$policy_file" \
        --exceptions "$exceptions_file" \
        --requested-command "$requested_command" 2>&1
    )" || rc=$?
  fi

  octon_ddb_log_enforcement "$enforcement_log" "$service_id" "$requested_command" "$rc"
  octon_ddb_log_decision_json "$decision_json_log" "$service_id" "$decision_output"

  case "$rc" in
    0)
      if ! octon_acp_gate_enforce "$service_id" "$octon_root" "$policy_file"; then
        exit 13
      fi
      return 0
      ;;
    13)
      octon_ddb_emit_deny "$decision_output"
      exit 13
      ;;
    *)
      echo "[deny-by-default] policy engine failed; failing closed" >&2
      octon_ddb_emit_deny "$decision_output"
      exit 13
      ;;
  esac
}
