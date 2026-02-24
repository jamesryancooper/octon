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

  [[ -n "$runs_dir" ]] || runs_dir=".harmony/continuity/runs"
  [[ -n "$receipt_name" ]] || receipt_name="receipt.json"
  [[ -n "$digest_name" ]] || digest_name="digest.md"
  [[ -n "$acp_log" ]] || acp_log=".harmony/capabilities/_ops/state/logs/acp-decisions.jsonl"

  printf '%s\n' "$runs_dir" "$receipt_name" "$digest_name" "$acp_log"
}

render_digest() {
  local receipt_path="$1"
  local output_path="$2"
  local run_id timestamp decision effective_acp operation_class phase reason_codes rollback_handle recovery_window telemetry_profile material_side_effect remediation
  local reason_details

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
  remediation="$(jq -r '.remediation // ""' "$receipt_path")"
  reason_details="$(jq -r '(.reason_details // [])[]? | "- `" + (.code // "") + "`: " + (.remediation // "")' "$receipt_path")"

  {
    echo "# ACP Decision Digest (v1)"
    echo
    echo "- Digest Format: \`policy-digest-v1\`"
    echo "- Run ID: \`$run_id\`"
    echo "- Timestamp: \`$timestamp\`"
    echo "- Decision: \`$decision\`"
    echo "- Effective ACP: \`$effective_acp\`"
    echo "- Operation Class: \`$operation_class\`"
    echo "- Phase: \`$phase\`"
    echo "- Reason Codes: \`$reason_codes\`"
    echo "- Material Side Effect: \`$material_side_effect\`"
    echo "- Telemetry Profile: \`$telemetry_profile\`"
    echo "- Rollback Handle: \`$rollback_handle\`"
    echo "- Recovery Window: \`$recovery_window\`"
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
  tmp_receipt="$(mktemp "${TMPDIR:-/tmp}/acp-receipt.XXXXXX.json")"

  jq -n \
    --arg timestamp "$timestamp" \
    --slurpfile req "$request_file" \
    --slurpfile dec "$decision_file" '
    {
      schema_version: "policy-receipt-v1",
      run_id: ($req[0].run_id),
      timestamp: $timestamp,
      actor: ($req[0].actor // {}),
      profile: ($req[0].profile // ""),
      intent: ($req[0].intent // null),
      boundaries: ($req[0].boundaries // null),
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

  # Backward compatibility path: populate once and preserve immutable history.
  if [[ ! -f "$receipt_path" ]]; then
    cp "$immutable_receipt_path" "$receipt_path"
  fi
  if [[ ! -f "$digest_path" ]]; then
    cp "$immutable_digest_path" "$digest_path"
  fi

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
    --arg compatibility_receipt "$receipt_path" \
    --arg compatibility_digest "$digest_path" \
    '{receipt:$receipt,digest:$digest,latest_receipt:$latest_receipt,latest_digest:$latest_digest,compatibility_receipt:$compatibility_receipt,compatibility_digest:$compatibility_digest}' | jq -c .
}

main "$@"
