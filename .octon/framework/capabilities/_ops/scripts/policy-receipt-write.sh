#!/usr/bin/env bash
# policy-receipt-write.sh - Emit ACP receipts and append-only decision summaries.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_POLICY="$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml"

usage() {
  cat <<'USAGE'
Usage:
  policy-receipt-write.sh --request <request.json> --decision <decision.json> [--policy <policy.yml>]
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-receipt-write.sh" >&2
    exit 1
  fi
}

read_policy_paths() {
  local policy="$1"
  local runs_dir receipt_name digest_name acp_log
  runs_dir="$(awk '/^[[:space:]]*runs_dir:[[:space:]]*/{print $2; exit}' "$policy" | tr -d '"'"'"'\''')"
  receipt_name="$(awk '/^[[:space:]]*receipt_filename:[[:space:]]*/{print $2; exit}' "$policy" | tr -d '"'"'"'\''')"
  digest_name="$(awk '/^[[:space:]]*digest_filename:[[:space:]]*/{print $2; exit}' "$policy" | tr -d '"'"'"'\''')"
  acp_log="$(awk '/^[[:space:]]*acp_decision_log:[[:space:]]*/{print $2; exit}' "$policy" | tr -d '"'"'"'\''')"

  [[ -n "$runs_dir" ]] || runs_dir=".octon/state/evidence/runs"
  [[ -n "$receipt_name" ]] || receipt_name="receipt.json"
  [[ -n "$digest_name" ]] || digest_name="digest.md"
  [[ -n "$acp_log" ]] || acp_log=".octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl"

  printf '%s\n' "$runs_dir" "$receipt_name" "$digest_name" "$acp_log"
}

require_context_telemetry() {
  local request_file="$1"
  jq -e '
    def is_nonneg_int:
      (type == "number") and (. >= 0) and (. == floor);

    .instruction_layers as $layers |
    .context_acquisition as $acq |
    .context_overhead_ratio as $ratio |

    ($layers | type == "array" and length > 0) and
    ($acq | type == "object") and
    (($acq.file_reads? // null) | is_nonneg_int) and
    (($acq.search_queries? // null) | is_nonneg_int) and
    (($acq.commands? // null) | is_nonneg_int) and
    (($acq.subagent_spawns? // null) | is_nonneg_int) and
    (($acq.duration_ms? // null) | is_nonneg_int) and
    (($ratio | type == "number") and ($ratio >= 0))
  ' "$request_file" >/dev/null || {
    echo "request missing required instruction layer or context-acquisition telemetry fields" >&2
    exit 1
  }
}

render_digest() {
  local receipt_path="$1"
  local output_path="$2"
  local run_id timestamp decision effective_acp operation_class phase reason_codes rollback_handle recovery_window telemetry_profile material_side_effect remediation
  local intent_ref boundary_id boundary_set_version workflow_mode capability_classification instruction_layers reason_details
  local mission_id slice_id oversight_mode execution_posture reversibility_class autonomy_budget_state breaker_state compensation_handle
  local support_tier ownership_sources approval_request_ref approval_grant_refs exception_refs revocation_refs network_egress_route

  run_id="$(jq -r '.run_id // ""' "$receipt_path")"
  timestamp="$(jq -r '.timestamp // ""' "$receipt_path")"
  decision="$(jq -r '.decision // ""' "$receipt_path")"
  effective_acp="$(jq -r '.effective_acp // ""' "$receipt_path")"
  operation_class="$(jq -r '.operation.class // ""' "$receipt_path")"
  phase="$(jq -r '.phase // ""' "$receipt_path")"
  reason_codes="$(jq -r '(.reason_codes // []) | join(",")' "$receipt_path")"
  rollback_handle="$(jq -r '.rollback_handle // ""' "$receipt_path")"
  recovery_window="$(jq -r '.recovery_window // ""' "$receipt_path")"
  telemetry_profile="$(jq -r '.telemetry_profile // ""' "$receipt_path")"
  material_side_effect="$(jq -r '.material_side_effect // ""' "$receipt_path")"
  intent_ref="$(jq -r 'if .intent_ref == null then "" else (.intent_ref.id // "") + "@" + (.intent_ref.version // "") end' "$receipt_path")"
  boundary_id="$(jq -r '.boundary_id // ""' "$receipt_path")"
  boundary_set_version="$(jq -r '.boundary_set_version // ""' "$receipt_path")"
  workflow_mode="$(jq -r '.workflow_mode // ""' "$receipt_path")"
  capability_classification="$(jq -r '.capability_classification // ""' "$receipt_path")"
  mission_id="$(jq -r '.mission_ref.id // ""' "$receipt_path")"
  slice_id="$(jq -r '.slice_ref.id // ""' "$receipt_path")"
  oversight_mode="$(jq -r '.oversight_mode // ""' "$receipt_path")"
  execution_posture="$(jq -r '.execution_posture // ""' "$receipt_path")"
  reversibility_class="$(jq -r '.reversibility_class // ""' "$receipt_path")"
  compensation_handle="$(jq -r '.compensation_handle // ""' "$receipt_path")"
  autonomy_budget_state="$(jq -r '.autonomy_budget_state // ""' "$receipt_path")"
  breaker_state="$(jq -r '.breaker_state // ""' "$receipt_path")"
  support_tier="$(jq -r '.support_tier.support_tier // .support_tier // ""' "$receipt_path")"
  ownership_sources="$(jq -r '(.ownership.owner_refs // []) | join(",")' "$receipt_path")"
  approval_request_ref="$(jq -r '.approval_request_ref // ""' "$receipt_path")"
  approval_grant_refs="$(jq -r '(.approval_grant_refs // []) | join(",")' "$receipt_path")"
  exception_refs="$(jq -r '(.exception_refs // []) | join(",")' "$receipt_path")"
  revocation_refs="$(jq -r '(.revocation_refs // []) | join(",")' "$receipt_path")"
  network_egress_route="$(jq -r '.network_egress.route // ""' "$receipt_path")"
  remediation="$(jq -r '.remediation // ""' "$receipt_path")"
  instruction_layers="$(jq -r '(.instruction_layers // []) | map("\(.layer_id):\(.source):\(.visibility):\(.bytes):\(.sha256)") | join(",")' "$receipt_path")"
  reason_details="$(jq -r '(.reason_details // [])[]? | "- `" + (.code // "") + "`: " + (.remediation // "")' "$receipt_path")"

  {
    echo "# ACP Decision Digest (v2)"
    echo
    echo "- Digest Format: \`policy-digest-v2\`"
    echo "- Run ID: \`$run_id\`"
    echo "- Timestamp: \`$timestamp\`"
    echo "- Decision: \`$decision\`"
    echo "- Effective ACP: \`$effective_acp\`"
    echo "- Operation Class: \`$operation_class\`"
    echo "- Phase: \`$phase\`"
    echo "- Reason Codes: \`$reason_codes\`"
    echo "- Material Side Effect: \`$material_side_effect\`"
    echo "- Telemetry Profile: \`$telemetry_profile\`"
    echo "- Intent Ref: \`$intent_ref\`"
    echo "- Boundary ID: \`$boundary_id\`"
    echo "- Boundary Set Version: \`$boundary_set_version\`"
    echo "- Workflow Mode: \`$workflow_mode\`"
    echo "- Capability Classification: \`$capability_classification\`"
    echo "- Mission ID: \`$mission_id\`"
    echo "- Slice ID: \`$slice_id\`"
    echo "- Oversight Mode: \`$oversight_mode\`"
    echo "- Execution Posture: \`$execution_posture\`"
    echo "- Reversibility Class: \`$reversibility_class\`"
    echo "- Instruction Layers: \`$instruction_layers\`"
    echo "- Rollback Handle: \`$rollback_handle\`"
    echo "- Compensation Handle: \`$compensation_handle\`"
    echo "- Recovery Window: \`$recovery_window\`"
    echo "- Autonomy Budget State: \`$autonomy_budget_state\`"
    echo "- Breaker State: \`$breaker_state\`"
    echo "- Support Tier: \`$support_tier\`"
    echo "- Ownership Refs: \`$ownership_sources\`"
    echo "- Approval Request Ref: \`$approval_request_ref\`"
    echo "- Approval Grant Refs: \`$approval_grant_refs\`"
    echo "- Exception Refs: \`$exception_refs\`"
    echo "- Revocation Refs: \`$revocation_refs\`"
    echo "- Network Egress Route: \`$network_egress_route\`"
    echo "- Remediation Summary: $remediation"
    echo
    echo "## Reason Detail"
    if [[ -n "$reason_details" ]]; then
      printf '%s\n' "$reason_details"
    else
      echo "- none"
    fi
  } > "$output_path"
}

main() {
  require_jq

  local request_file="" decision_file="" policy_file="$DEFAULT_POLICY"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --request) request_file="$2"; shift 2 ;;
      --decision) decision_file="$2"; shift 2 ;;
      --policy) policy_file="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$request_file" ]] || { echo "--request is required" >&2; exit 1; }
  [[ -n "$decision_file" ]] || { echo "--decision is required" >&2; exit 1; }
  [[ -f "$request_file" ]] || { echo "Missing request file: $request_file" >&2; exit 1; }
  [[ -f "$decision_file" ]] || { echo "Missing decision file: $decision_file" >&2; exit 1; }
  [[ -f "$policy_file" ]] || { echo "Missing policy file: $policy_file" >&2; exit 1; }
  require_context_telemetry "$request_file"

  local runs_dir receipt_name digest_name decision_log
  mapfile -t _paths < <(read_policy_paths "$policy_file")
  runs_dir="${_paths[0]}"
  receipt_name="${_paths[1]}"
  digest_name="${_paths[2]}"
  decision_log="${_paths[3]}"

  local run_id
  run_id="$(jq -r '.run_id' "$request_file")"
  [[ -n "$run_id" && "$run_id" != "null" ]] || { echo "request.run_id is required" >&2; exit 1; }

  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  local run_dir receipt_path digest_path receipts_dir digests_dir latest_receipt_path latest_digest_path index_path
  run_dir="$runs_dir/$run_id"
  receipt_path="$run_dir/$receipt_name"
  digest_path="$run_dir/$digest_name"
  receipts_dir="$run_dir/receipts"
  digests_dir="$run_dir/digests"
  latest_receipt_path="$run_dir/receipt.latest.json"
  latest_digest_path="$run_dir/digest.latest.md"
  index_path="$run_dir/receipt-index.jsonl"
  mkdir -p "$run_dir" "$receipts_dir" "$digests_dir" "$(dirname "$decision_log")"

  local tmp_receipt
  # Keep the mktemp template portable (BSD/GNU): trailing X run only.
  tmp_receipt="$(mktemp "${TMPDIR:-/tmp}/acp-receipt.XXXXXX")"

  jq -n \
    --arg timestamp "$timestamp" \
    --slurpfile req "$request_file" \
    --slurpfile dec "$decision_file" '
    {
      schema_version: "policy-receipt-v2",
      run_id: ($req[0].run_id),
      timestamp: $timestamp,
      actor: ($req[0].actor // {}),
      profile: ($req[0].profile // ""),
      intent: ($req[0].intent // null),
      intent_ref: (
        if $req[0].intent_ref != null then $req[0].intent_ref
        elif ($req[0].intent | type == "object") and (($req[0].intent.id // "") | tostring | length) > 0 then
          {
            id: ($req[0].intent.id | tostring),
            version: (($req[0].intent.version // "v0") | tostring)
          }
        elif ($req[0].intent | type == "string") and (($req[0].intent // "") | tostring | length) > 0 then
          {
            id: ($req[0].intent | tostring),
            version: "v0"
          }
        else null
        end
      ),
      boundaries: ($req[0].boundaries // null),
      boundary_id: (
        $req[0].boundary_id //
        (
          if (($req[0].boundaries // null) | type) == "object"
          then ($req[0].boundaries.boundary_id // $req[0].boundaries.id // null)
          elif (($req[0].boundaries // null) | type) == "string" and (($req[0].boundaries // "") | tostring | length) > 0
          then ($req[0].boundaries | tostring)
          else "boundary.unspecified"
          end
        ) //
        null
      ),
      boundary_set_version: (
        $req[0].boundary_set_version //
        (
          if (($req[0].boundaries // null) | type) == "object"
          then ($req[0].boundaries.version // null)
          else "v1"
          end
        ) //
        null
      ),
      workflow_mode: (
        $req[0].workflow_mode //
        $req[0].operation.target.workflow_mode //
        "autonomous"
      ),
      mission_ref: ($req[0].mission_ref // null),
      slice_ref: ($req[0].slice_ref // null),
      oversight_mode: ($req[0].oversight_mode // null),
      execution_posture: ($req[0].execution_posture // null),
      reversibility_class: (
        $req[0].reversibility_class //
        $req[0].reversibility.class //
        null
      ),
      compensation_handle: (
        $req[0].reversibility.compensation_handle //
        null
      ),
      autonomy_budget_state: ($req[0].autonomy_budget_state // null),
      breaker_state: ($req[0].breaker_state // null),
      capability_classification: (
        $req[0].capability_classification //
        $req[0].operation.target.capability_classification //
        "agent-ready"
      ),
      budget_rule_id: ($req[0].budget_rule_id // null),
      budget_reason_codes: ($req[0].budget_reason_codes // []),
      cost_evidence_path: ($req[0].cost_evidence_path // null),
      ownership: ($req[0].ownership // {}),
      support_tier: ($req[0].support_tier // null),
      approval_request_ref: ($req[0].approval_request_ref // null),
      approval_grant_refs: ($req[0].approval_grant_refs // []),
      exception_refs: ($req[0].exception_refs // []),
      revocation_refs: ($req[0].revocation_refs // []),
      network_egress: ($req[0].network_egress // {}),
      operation: ($req[0].operation // {}),
      phase: ($req[0].phase // ""),
      material_side_effect: (
        $req[0].operation.target.material_side_effect //
        $req[0].operation.target.meaningful_behavior_change //
        $req[0].operation.target.durable_effect //
        $req[0].operation.target.promotion //
        null
      ),
      telemetry_profile: ($req[0].operation.target.telemetry_profile // null),
      effective_acp: ($dec[0].effective_acp // "ACP-0"),
      decision: ($dec[0].decision // "DENY"),
      reason_codes: ($dec[0].reason_codes // []),
      remediation: (
        if (($dec[0].remediation // "") | tostring | length) > 0
        then ($dec[0].remediation | tostring)
        else "Review policy decision reason codes and rerun ACP evaluation."
        end
      ),
      remediation_steps: ($dec[0].remediation_steps // []),
      reason_details: (
        ($dec[0].reason_codes // []) as $codes |
        ($dec[0].remediation_steps // []) as $steps |
        [
          range(0; ($codes | length)) as $i |
          {
            code: $codes[$i],
            remediation: (
              if (($steps | length) > $i) and (($steps[$i] // "") | tostring | length) > 0
              then ($steps[$i] | tostring)
              else (
                if (($dec[0].remediation // "") | tostring | length) > 0
                then ($dec[0].remediation | tostring)
                else "Review policy decision reason codes and rerun ACP evaluation."
                end
              )
              end
            )
          }
        ]
      ),
      evidence: ($req[0].evidence // []),
      attestations: ($req[0].attestations // []),
      flag_metadata_valid: ($req[0].operation.target.flag_metadata_valid // null),
      reversibility: ($req[0].reversibility // {}),
      rollback_handle: ($req[0].reversibility.rollback_handle // null),
      recovery_window: ($req[0].reversibility.recovery_window // null),
      budgets: ($req[0].budgets // {}),
      counters: ($req[0].counters // {}),
      instruction_layers: (
        $req[0].instruction_layers //
        []
      ),
      context_acquisition: (
        $req[0].context_acquisition //
        {}
      ),
      context_overhead_ratio: (
        $req[0].context_overhead_ratio //
        0
      ),
      requirements: ($dec[0].requirements // {})
    }' | jq -S . > "$tmp_receipt"

  local decision_slug timestamp_slug sequence immutable_receipt_path immutable_digest_path
  decision_slug="$(jq -r '.decision // "deny"' "$tmp_receipt" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  timestamp_slug="$(date -u +"%Y%m%dT%H%M%SZ")"
  sequence=1
  immutable_receipt_path="$receipts_dir/${timestamp_slug}-${decision_slug}-${sequence}.json"
  while [[ -e "$immutable_receipt_path" ]]; do
    sequence=$((sequence + 1))
    immutable_receipt_path="$receipts_dir/${timestamp_slug}-${decision_slug}-${sequence}.json"
  done
  immutable_digest_path="$digests_dir/${timestamp_slug}-${decision_slug}-${sequence}.md"

  mv "$tmp_receipt" "$immutable_receipt_path"
  render_digest "$immutable_receipt_path" "$immutable_digest_path"

  cp "$immutable_receipt_path" "$receipt_path"
  cp "$immutable_digest_path" "$digest_path"

  cp "$immutable_receipt_path" "$latest_receipt_path"
  cp "$immutable_digest_path" "$latest_digest_path"

  jq -n --slurpfile receipt "$immutable_receipt_path" '
    {
      run_id: $receipt[0].run_id,
      timestamp: $receipt[0].timestamp,
      decision: $receipt[0].decision,
      effective_acp: $receipt[0].effective_acp,
      reason_codes: $receipt[0].reason_codes,
      profile: $receipt[0].profile,
      operation_class: ($receipt[0].operation.class // ""),
      phase: $receipt[0].phase
    }' | jq -c . >> "$decision_log"

  jq -n \
    --arg run_id "$run_id" \
    --arg timestamp "$timestamp" \
    --arg receipt "$immutable_receipt_path" \
    --arg digest "$immutable_digest_path" \
    '{run_id:$run_id,timestamp:$timestamp,receipt:$receipt,digest:$digest}' | jq -c . >> "$index_path"

  jq -n \
    --arg receipt "$immutable_receipt_path" \
    --arg digest "$immutable_digest_path" \
    --arg latest_receipt "$latest_receipt_path" \
    --arg latest_digest "$latest_digest_path" \
    --arg canonical_receipt "$receipt_path" \
    --arg canonical_digest "$digest_path" \
    '{receipt:$receipt,digest:$digest,latest_receipt:$latest_receipt,latest_digest:$latest_digest,canonical_receipt:$canonical_receipt,canonical_digest:$canonical_digest}' | jq -c .
}

main "$@"
