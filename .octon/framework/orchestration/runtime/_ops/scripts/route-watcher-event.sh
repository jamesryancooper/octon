#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools yq jq

event_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event-file) event_file="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$event_file" && -f "$event_file" ]] || { echo "event-file is required" >&2; exit 1; }

event_json="$(cat "$event_file")"
watcher_id="$(jq -r '.watcher_id' <<<"$event_json")"
event_type="$(jq -r '.event_type' <<<"$event_json")"
event_id="$(jq -r '.event_id' <<<"$event_json")"
source_ref="$(jq -r '.source_ref' <<<"$event_json")"
severity="$(jq -r '.severity' <<<"$event_json")"

severity_rank() {
  case "$1" in
    info) echo 0 ;;
    warning) echo 1 ;;
    high) echo 2 ;;
    critical) echo 3 ;;
    *) echo -1 ;;
  esac
}

selector_match() {
  local trigger_json="$1"
  local watcher_id="$2"
  local event_type="$3"
  local severity="$4"
  local source_ref="$5"
  local match_mode watcher_match event_type_match severity_match glob_match result_count matched_count threshold

  match_mode="$(jq -r '.event.match_mode' <<<"$trigger_json")"
  result_count=0
  matched_count=0

  if jq -e '.event.watcher_ids' <<<"$trigger_json" >/dev/null 2>&1; then
    result_count=$((result_count + 1))
    watcher_match="$(jq -r --arg watcher_id "$watcher_id" '.event.watcher_ids | index($watcher_id) != null' <<<"$trigger_json")"
    [[ "$watcher_match" == "true" ]] && matched_count=$((matched_count + 1))
  fi

  if jq -e '.event.event_types' <<<"$trigger_json" >/dev/null 2>&1; then
    result_count=$((result_count + 1))
    event_type_match="$(jq -r --arg event_type "$event_type" '.event.event_types | index($event_type) != null' <<<"$trigger_json")"
    [[ "$event_type_match" == "true" ]] && matched_count=$((matched_count + 1))
  fi

  threshold="$(jq -r '.event.severity_at_or_above // ""' <<<"$trigger_json")"
  if [[ -n "$threshold" && "$threshold" != "null" ]]; then
    result_count=$((result_count + 1))
    if (( $(severity_rank "$severity") >= $(severity_rank "$threshold") )); then
      matched_count=$((matched_count + 1))
    fi
  fi

  if jq -e '.event.source_ref_globs // empty' <<<"$trigger_json" >/dev/null 2>&1; then
    result_count=$((result_count + 1))
    glob_match="false"
    while IFS= read -r pattern; do
      [[ "$source_ref" == $pattern ]] && glob_match="true"
    done < <(jq -r '.event.source_ref_globs[]' <<<"$trigger_json")
    [[ "$glob_match" == "true" ]] && matched_count=$((matched_count + 1))
  fi

  if [[ "$result_count" -eq 0 ]]; then
    return 0
  fi

  case "$match_mode" in
    all) [[ "$matched_count" -eq "$result_count" ]] ;;
    any) [[ "$matched_count" -gt 0 ]] ;;
    *) return 1 ;;
  esac
}

dedupe_hit_exists() {
  local event_id="$1"
  local automation_id="$2"
  if find "$QUEUE_DIR/pending" "$QUEUE_DIR/claimed" "$QUEUE_DIR/retry" "$QUEUE_DIR/dead-letter" -type f -name "q-${event_id}-${automation_id}.json" | grep -q .; then
    return 0
  fi
  if [[ -d "$DECISIONS_DIR/dec-${automation_id}-${event_id}-allow" || -f "$RUNTIME_RUNS_DIR/run-${automation_id}-${event_id}.yml" ]]; then
    return 0
  fi
  return 1
}

matches=()
while IFS= read -r automation_dir; do
  rel_dir="${automation_dir#$RUNTIME_DIR/automations/}"
  [[ -f "$automation_dir/automation.yml" ]] || continue
  [[ "$(yq -r '.status' "$automation_dir/automation.yml")" == "active" ]] || continue
  [[ "$(yq -r '.kind' "$automation_dir/trigger.yml")" == "event" ]] || continue

  trigger_json="$(yq -o=json '.' "$automation_dir/trigger.yml")"
  if ! selector_match "$trigger_json" "$watcher_id" "$event_type" "$severity" "$source_ref"; then
    continue
  fi

  automation_id="$(yq -r '.automation_id' "$automation_dir/automation.yml")"
  if [[ -n "$(jq -r '.target_automation_id // ""' <<<"$event_json")" && "$(jq -r '.target_automation_id' <<<"$event_json")" != "$automation_id" ]]; then
    continue
  fi
  if [[ -n "$(jq -r '.event.dedupe_window // ""' <<<"$trigger_json")" && "$(jq -r '.event.dedupe_window // ""' <<<"$trigger_json")" != "null" ]]; then
    if dedupe_hit_exists "$event_id" "$automation_id"; then
      continue
    fi
  fi
  queue_item_id="q-${event_id}-${automation_id}"
  queue_path="$(bash "$SCRIPT_DIR/manage-queue.sh" enqueue \
    --queue-item-id "$queue_item_id" \
    --target-automation-id "$automation_id" \
    --summary "Queued from watcher event ${event_id}" \
    --event-id "$event_id" \
    --watcher-id "$watcher_id" \
    --payload-ref "$event_file")"
  matches+=("$(jq -n --arg automation_id "$automation_id" --arg queue_item_id "$queue_item_id" --arg queue_path "$queue_path" '{automation_id:$automation_id,queue_item_id:$queue_item_id,queue_path:$queue_path}')")
done < <(find "$RUNTIME_DIR/automations" -mindepth 1 -maxdepth 1 -type d ! -name '_*' | sort)

printf '%s\n' "${matches[@]:-}" | jq -s '.'
