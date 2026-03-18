#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "automations"

if ! command -v yq >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  fail "yq and jq are required for automations validation"
  finish_surface_validation "automations"
fi

if ! surface_has_any_marker "README.md" "manifest.yml" "registry.yml" "_scaffold/template/automation.yml"; then
  surface_skip_not_promoted
fi

require_file_rel "README.md"
require_file_rel "manifest.yml"
require_file_rel "registry.yml"
require_dir_rel "_scaffold/template"
require_file_rel "_scaffold/template/automation.yml"
require_file_rel "_scaffold/template/trigger.yml"
require_file_rel "_scaffold/template/bindings.yml"
require_file_rel "_scaffold/template/policy.yml"

validate_automation_unit() {
  local rel_dir="$1"
  local automation_dir="$SURFACE_DIR/$rel_dir"
  local automation_json trigger_json bindings_json policy_json
  local automation_id workflow_group workflow_id status trigger_kind concurrency_mode max_concurrency idempotency_kind

  automation_json="$(yq -o=json '.' "$automation_dir/automation.yml")"
  trigger_json="$(yq -o=json '.' "$automation_dir/trigger.yml")"
  bindings_json="$(yq -o=json '.' "$automation_dir/bindings.yml")"
  policy_json="$(yq -o=json '.' "$automation_dir/policy.yml")"

  automation_id="$(jq -r '.automation_id // ""' <<<"$automation_json")"
  workflow_group="$(jq -r '.workflow_ref.workflow_group // ""' <<<"$automation_json")"
  workflow_id="$(jq -r '.workflow_ref.workflow_id // ""' <<<"$automation_json")"
  status="$(jq -r '.status // ""' <<<"$automation_json")"
  trigger_kind="$(jq -r '.kind // ""' <<<"$trigger_json")"
  concurrency_mode="$(jq -r '.concurrency_mode // ""' <<<"$policy_json")"
  max_concurrency="$(jq -r '.max_concurrency // 0' <<<"$policy_json")"
  idempotency_kind="$(jq -r '.idempotency_strategy.kind // ""' <<<"$policy_json")"

  [[ "$automation_id" == "$rel_dir" ]] && pass "automation '$rel_dir' id matches directory" || fail "automation '$rel_dir' id must match directory"
  [[ -n "$workflow_group" && -n "$workflow_id" ]] && pass "automation '$rel_dir' workflow ref present" || fail "automation '$rel_dir' missing workflow ref"
  case "$status" in
    active|paused|disabled|error) pass "automation '$rel_dir' status valid: $status" ;;
    *) fail "automation '$rel_dir' has invalid status '$status'" ;;
  esac

  case "$trigger_kind" in
    event|schedule) pass "automation '$rel_dir' trigger kind valid: $trigger_kind" ;;
    *) fail "automation '$rel_dir' has invalid trigger kind '$trigger_kind'" ;;
  esac

  if [[ "$trigger_kind" == "event" ]]; then
    jq -e '.event.watcher_ids | length > 0' <<<"$trigger_json" >/dev/null 2>&1 && pass "automation '$rel_dir' event watcher selectors present" || fail "automation '$rel_dir' event trigger missing watcher_ids"
    jq -e '.event.event_types | length > 0' <<<"$trigger_json" >/dev/null 2>&1 && pass "automation '$rel_dir' event type selectors present" || fail "automation '$rel_dir' event trigger missing event_types"
    [[ "$idempotency_kind" == "event-dedupe" ]] && pass "automation '$rel_dir' event idempotency kind valid" || fail "automation '$rel_dir' event trigger requires event-dedupe idempotency"
  else
    jq -e '.schedule.cadence and .schedule.at and .schedule.timezone and .schedule.missed_run_policy' <<<"$trigger_json" >/dev/null 2>&1 && pass "automation '$rel_dir' schedule trigger fields present" || fail "automation '$rel_dir' schedule trigger missing required fields"
    [[ "$idempotency_kind" == "schedule-window" ]] && pass "automation '$rel_dir' schedule idempotency kind valid" || fail "automation '$rel_dir' schedule trigger requires schedule-window idempotency"
    jq -e '.event_to_param_map | not' <<<"$bindings_json" >/dev/null 2>&1 && pass "automation '$rel_dir' schedule bindings carry no event map" || fail "automation '$rel_dir' schedule automation must not declare event_to_param_map"
  fi

  while IFS= read -r binding; do
    from="$(jq -r '.from' <<<"$binding")"
    required="$(jq -r '.required' <<<"$binding")"
    default_present="$(jq -r 'has("default")' <<<"$binding")"
    [[ "$from" == event.* ]] && pass "automation '$rel_dir' binding source path valid: $from" || fail "automation '$rel_dir' binding source path invalid: $from"
    if [[ "$required" == "true" && "$default_present" == "true" ]]; then
      fail "automation '$rel_dir' required binding must not declare default"
    fi
  done < <(jq -c '.event_to_param_map // {} | to_entries[] | .value' <<<"$bindings_json")

  case "$concurrency_mode" in
    serialize|drop|parallel|replace) pass "automation '$rel_dir' concurrency mode valid: $concurrency_mode" ;;
    *) fail "automation '$rel_dir' invalid concurrency mode '$concurrency_mode'" ;;
  esac
  [[ "$max_concurrency" =~ ^[0-9]+$ && "$max_concurrency" -ge 1 ]] && pass "automation '$rel_dir' max_concurrency valid" || fail "automation '$rel_dir' invalid max_concurrency"
  if [[ "$concurrency_mode" == "serialize" || "$concurrency_mode" == "replace" ]]; then
    [[ "$max_concurrency" == "1" ]] && pass "automation '$rel_dir' single-run mode enforces max_concurrency=1" || fail "automation '$rel_dir' serialize/replace requires max_concurrency=1"
  fi

  if [[ -d "$automation_dir/state" ]]; then
    require_file_rel "$rel_dir/state/status.json"
    require_file_rel "$rel_dir/state/last-run.json"
    require_file_rel "$rel_dir/state/counters.json"
  fi
}

while IFS= read -r automation_dir; do
  rel_dir="${automation_dir#$SURFACE_DIR/}"
  require_file_rel "$rel_dir/automation.yml"
  require_file_rel "$rel_dir/trigger.yml"
  require_file_rel "$rel_dir/bindings.yml"
  require_file_rel "$rel_dir/policy.yml"
  validate_automation_unit "$rel_dir"
done < <(find "$SURFACE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' | sort)

finish_surface_validation "automations"
