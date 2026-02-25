#!/usr/bin/env bash
# policy-acp-request.sh - Build normalized ACP request payload JSON.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  policy-acp-request.sh --output <path> --run-id <id> --phase <stage|promote|finalize> --profile <profile> --operation-class <class> [options]

Options:
  --actor-id <id>                 Actor id (default: HARMONY_AGENT_ID or agent.local)
  --actor-type <type>             Actor type (default: agent)
  --target-json <json>            Operation target metadata JSON object
  --targets-json <json>           Operation targets JSON array
  --resources-json <json>         Operation resources JSON array
  --reversibility-json <json>     Reversibility JSON object
  --evidence-json <json>          Evidence JSON array
  --attestations-json <json>      Attestations JSON array
  --budgets-json <json>           Budgets JSON object
  --counters-json <json>          Counters JSON object
  --signals-json <json>           Circuit signal JSON array
  --instruction-layers-json <json>
                                  Instruction-layer manifest JSON array
  --context-acquisition-json <json>
                                  Context-acquisition counters JSON object
  --context-overhead-ratio <num>  Context-overhead ratio as number
  --plan-hash <hash>              Plan hash binding
  --evidence-hash <hash>          Evidence hash binding
  --intent <text>                 Intent summary
  --boundaries <text>             Boundary summary
  --break-glass                   Enable break-glass posture flag
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-acp-request.sh" >&2
    exit 1
  fi
}

ensure_json_type() {
  local raw="$1"
  local expected_type="$2"
  local label="$3"
  if ! jq -e --arg t "$expected_type" 'type == $t' <<<"$raw" >/dev/null 2>&1; then
    echo "$label must be valid JSON type '$expected_type'" >&2
    exit 1
  fi
}

main() {
  require_jq

  local output="" run_id="" phase="" profile="" operation_class=""
  local actor_id="${HARMONY_AGENT_ID:-agent.local}"
  local actor_type="agent"
  local target_json='{}'
  local targets_json='[]'
  local resources_json='[]'
  local reversibility_json='{}'
  local evidence_json='[]'
  local attestations_json='[]'
  local budgets_json='{}'
  local counters_json='{}'
  local signals_json='[]'
  local instruction_layers_json='[]'
  local context_acquisition_json='{}'
  local context_overhead_ratio='0'
  local plan_hash="" evidence_hash="" intent="" boundaries=""
  local break_glass=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output) output="$2"; shift 2 ;;
      --run-id) run_id="$2"; shift 2 ;;
      --phase) phase="$2"; shift 2 ;;
      --profile) profile="$2"; shift 2 ;;
      --operation-class) operation_class="$2"; shift 2 ;;
      --actor-id) actor_id="$2"; shift 2 ;;
      --actor-type) actor_type="$2"; shift 2 ;;
      --target-json) target_json="$2"; shift 2 ;;
      --targets-json) targets_json="$2"; shift 2 ;;
      --resources-json) resources_json="$2"; shift 2 ;;
      --reversibility-json) reversibility_json="$2"; shift 2 ;;
      --evidence-json) evidence_json="$2"; shift 2 ;;
      --attestations-json) attestations_json="$2"; shift 2 ;;
      --budgets-json) budgets_json="$2"; shift 2 ;;
      --counters-json) counters_json="$2"; shift 2 ;;
      --signals-json) signals_json="$2"; shift 2 ;;
      --instruction-layers-json) instruction_layers_json="$2"; shift 2 ;;
      --context-acquisition-json) context_acquisition_json="$2"; shift 2 ;;
      --context-overhead-ratio) context_overhead_ratio="$2"; shift 2 ;;
      --plan-hash) plan_hash="$2"; shift 2 ;;
      --evidence-hash) evidence_hash="$2"; shift 2 ;;
      --intent) intent="$2"; shift 2 ;;
      --boundaries) boundaries="$2"; shift 2 ;;
      --break-glass) break_glass=true; shift ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$output" ]] || { echo "--output is required" >&2; exit 1; }
  [[ -n "$run_id" ]] || { echo "--run-id is required" >&2; exit 1; }
  [[ -n "$phase" ]] || { echo "--phase is required" >&2; exit 1; }
  [[ -n "$profile" ]] || { echo "--profile is required" >&2; exit 1; }
  [[ -n "$operation_class" ]] || { echo "--operation-class is required" >&2; exit 1; }

  ensure_json_type "$target_json" "object" "--target-json"
  ensure_json_type "$targets_json" "array" "--targets-json"
  ensure_json_type "$resources_json" "array" "--resources-json"
  ensure_json_type "$reversibility_json" "object" "--reversibility-json"
  ensure_json_type "$evidence_json" "array" "--evidence-json"
  ensure_json_type "$attestations_json" "array" "--attestations-json"
  ensure_json_type "$budgets_json" "object" "--budgets-json"
  ensure_json_type "$counters_json" "object" "--counters-json"
  ensure_json_type "$signals_json" "array" "--signals-json"
  ensure_json_type "$instruction_layers_json" "array" "--instruction-layers-json"
  ensure_json_type "$context_acquisition_json" "object" "--context-acquisition-json"
  if ! jq -en --arg ratio "$context_overhead_ratio" '$ratio | tonumber' >/dev/null 2>&1; then
    echo "--context-overhead-ratio must be a numeric value" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$output")"

  jq -n \
    --arg run_id "$run_id" \
    --arg actor_id "$actor_id" \
    --arg actor_type "$actor_type" \
    --arg profile "$profile" \
    --arg phase "$phase" \
    --arg op_class "$operation_class" \
    --argjson target "$target_json" \
    --argjson targets "$targets_json" \
    --argjson resources "$resources_json" \
    --argjson reversibility "$reversibility_json" \
    --argjson evidence "$evidence_json" \
    --argjson attestations "$attestations_json" \
    --argjson budgets "$budgets_json" \
    --argjson counters "$counters_json" \
    --argjson signals "$signals_json" \
    --argjson instruction_layers "$instruction_layers_json" \
    --argjson context_acquisition "$context_acquisition_json" \
    --arg context_overhead_ratio "$context_overhead_ratio" \
    --arg plan_hash "$plan_hash" \
    --arg evidence_hash "$evidence_hash" \
    --arg intent "$intent" \
    --arg boundaries "$boundaries" \
    --argjson break_glass "$break_glass" \
    '{
      run_id: $run_id,
      actor: {id: $actor_id, type: $actor_type},
      profile: $profile,
      phase: $phase,
      operation: {class: $op_class, target: $target, targets: $targets, resources: $resources},
      break_glass: $break_glass,
      reversibility: (if $reversibility == {} then null else $reversibility end),
      evidence: $evidence,
      attestations: $attestations,
      budgets: $budgets,
      counters: $counters,
      instruction_layers: $instruction_layers,
      context_acquisition: $context_acquisition,
      context_overhead_ratio: ($context_overhead_ratio | tonumber),
      circuit_signals: $signals,
      plan_hash: (if ($plan_hash|length)==0 then null else $plan_hash end),
      evidence_hash: (if ($evidence_hash|length)==0 then null else $evidence_hash end),
      intent: (if ($intent|length)==0 then null else $intent end),
      boundaries: (if ($boundaries|length)==0 then null else $boundaries end)
    }' > "$output"

  jq -c . "$output"
}

main "$@"
