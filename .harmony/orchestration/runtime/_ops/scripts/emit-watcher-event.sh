#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq

watcher_id=""
rule_id=""
source_ref=""
event_id=""
emitted_at=""
output_file=""
target_automation_id=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --watcher-id) watcher_id="$2"; shift 2 ;;
    --rule-id) rule_id="$2"; shift 2 ;;
    --source-ref) source_ref="$2"; shift 2 ;;
    --event-id) event_id="$2"; shift 2 ;;
    --emitted-at) emitted_at="$2"; shift 2 ;;
    --output-file) output_file="$2"; shift 2 ;;
    --target-automation-id) target_automation_id="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$watcher_id" && -n "$rule_id" && -n "$source_ref" ]] || { echo "watcher-id, rule-id, and source-ref are required" >&2; exit 1; }
watcher_dir="$RUNTIME_DIR/watchers/$watcher_id"
[[ -f "$watcher_dir/watcher.yml" ]] || { echo "watcher not found: $watcher_id" >&2; exit 1; }
[[ "$(yq -r '.status' "$watcher_dir/watcher.yml")" == "active" ]] || { echo "watcher is not active: $watcher_id" >&2; exit 1; }

rule_json="$(yq -o=json '.rules[]' "$watcher_dir/rules.yml" | jq -c --arg rule_id "$rule_id" 'select(.rule_id == $rule_id)' | head -n1)"
[[ -n "$rule_json" ]] || { echo "rule not found: $rule_id" >&2; exit 1; }
event_type="$(jq -r '.event_type' <<<"$rule_json")"
severity="$(jq -r '.severity' <<<"$rule_json")"
summary="$(jq -r '.summary_template' <<<"$rule_json")"
if [[ -z "$target_automation_id" ]]; then
  target_automation_id="$(jq -r '.routing_hints.target_automation_id // ""' <<<"$rule_json")"
fi
emits_json="$(yq -o=json '.emits[]' "$watcher_dir/emits.yml" | jq -c --arg event_type "$event_type" 'select(.event_type == $event_type)' | head -n1)"
[[ -n "$emits_json" ]] || { echo "emitted event type not declared: $event_type" >&2; exit 1; }
if [[ "$target_automation_id" != "" && "$(jq -r '.routing_hints.allow_target_automation_id' <<<"$emits_json")" != "true" ]]; then
  echo "routing hint target_automation_id is not allowed for $event_type" >&2
  exit 1
fi

[[ -n "$event_id" ]] || event_id="evt-$(date -u +%Y%m%dT%H%M%SZ)-${watcher_id}-${rule_id}"
[[ -n "$emitted_at" ]] || emitted_at="$(now_utc)"
dedupe_key="${watcher_id}:${rule_id}:${source_ref}"

event_json="$(jq -n \
  --arg event_id "$event_id" \
  --arg watcher_id "$watcher_id" \
  --arg rule_id "$rule_id" \
  --arg event_type "$event_type" \
  --arg emitted_at "$emitted_at" \
  --arg severity "$severity" \
  --arg dedupe_key "$dedupe_key" \
  --arg source_ref "$source_ref" \
  --arg summary "$summary" \
  --arg target_automation_id "$target_automation_id" '
  {
    event_id: $event_id,
    watcher_id: $watcher_id,
    rule_id: $rule_id,
    event_type: $event_type,
    emitted_at: $emitted_at,
    severity: $severity,
    dedupe_key: $dedupe_key,
    source_ref: $source_ref,
    summary: $summary
  }
  + (if $target_automation_id != "" then {target_automation_id:$target_automation_id} else {} end)
')"

if [[ -n "$output_file" ]]; then
  printf '%s\n' "$event_json" > "$output_file"
fi

printf '%s\n' "$event_json"
