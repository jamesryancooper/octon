#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "queue"

if ! command -v jq >/dev/null 2>&1; then
  fail "jq is required for queue validation"
  finish_surface_validation "queue"
fi

if ! surface_has_any_marker "README.md" "registry.yml" "schema.yml"; then
  surface_skip_not_promoted
fi

require_file_rel "README.md"
require_file_rel "registry.yml"
require_file_rel "schema.yml"
require_file_rel "queue-item-and-lease-contract.md"
require_file_rel "schemas/queue-item-and-lease.schema.json"
require_dir_rel "pending"
require_dir_rel "claimed"
require_dir_rel "retry"
require_dir_rel "dead-letter"
require_dir_rel "receipts"

require_fixed() {
  local needle="$1"
  local rel="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$SURFACE_DIR/$rel"; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_definition_surfaces_are_local() {
  local matches=""
  matches="$(
    grep -R -n -F -- ".design-packages/" \
      "$SURFACE_DIR/README.md" \
      "$SURFACE_DIR/registry.yml" \
      "$SURFACE_DIR/schema.yml" \
      "$SURFACE_DIR/queue-item-and-lease-contract.md" \
      "$SURFACE_DIR/schemas" 2>/dev/null || true
  )"
  if [[ -n "$matches" ]]; then
    fail "queue surface definition artifacts must not depend on temporary .design-packages paths"
    printf '%s\n' "$matches"
  else
    pass "queue surface definition artifacts avoid temporary .design-packages paths"
  fi
}

require_fixed 'contract: "queue-item-and-lease-contract.md"' "registry.yml" "queue registry points to the live contract"
require_fixed 'schema: "schemas/queue-item-and-lease.schema.json"' "registry.yml" "queue registry points to the live schema"
require_fixed 'queue_item_contract: "queue-item-and-lease-contract.md"' "schema.yml" "queue schema projection points to the live contract"
require_fixed 'queue_item_schema: "schemas/queue-item-and-lease.schema.json"' "schema.yml" "queue schema projection points to the live schema"
check_definition_surfaces_are_local

validate_queue_item() {
  local lane="$1"
  local file="$2"
  local status queue_item_id target_automation_id available_at attempt_count max_attempts summary enqueued_at

  if jq empty "$file" >/dev/null 2>&1; then
    pass "valid queue JSON: ${file#$ROOT_DIR/}"
  else
    fail "invalid queue JSON: ${file#$ROOT_DIR/}"
    return
  fi

  status="$(jq -r '.status // ""' "$file")"
  queue_item_id="$(jq -r '.queue_item_id // ""' "$file")"
  target_automation_id="$(jq -r '.target_automation_id // ""' "$file")"
  available_at="$(jq -r '.available_at // ""' "$file")"
  attempt_count="$(jq -r '.attempt_count // -1' "$file")"
  max_attempts="$(jq -r '.max_attempts // -1' "$file")"
  summary="$(jq -r '.summary // ""' "$file")"
  enqueued_at="$(jq -r '.enqueued_at // ""' "$file")"

  [[ -n "$queue_item_id" ]] && pass "queue item id present: $queue_item_id" || fail "queue item missing queue_item_id"
  [[ -n "$target_automation_id" ]] && pass "queue item target present: $queue_item_id" || fail "queue item '$queue_item_id' missing target_automation_id"
  [[ "$available_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "queue item '$queue_item_id' available_at is ISO-like" || fail "queue item '$queue_item_id' missing available_at"
  [[ "$enqueued_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "queue item '$queue_item_id' enqueued_at is ISO-like" || fail "queue item '$queue_item_id' missing enqueued_at"
  [[ "$attempt_count" =~ ^[0-9]+$ ]] && pass "queue item '$queue_item_id' attempt_count valid" || fail "queue item '$queue_item_id' attempt_count invalid"
  [[ "$max_attempts" =~ ^[0-9]+$ && "$max_attempts" -ge 1 ]] && pass "queue item '$queue_item_id' max_attempts valid" || fail "queue item '$queue_item_id' max_attempts invalid"
  [[ -n "$summary" ]] && pass "queue item '$queue_item_id' summary present" || fail "queue item '$queue_item_id' summary missing"

  if [[ "$status" == "$lane" || ( "$lane" == "pending" && "$status" == "pending" ) || ( "$lane" == "claimed" && "$status" == "claimed" ) || ( "$lane" == "retry" && "$status" == "retry" ) || ( "$lane" == "dead-letter" && "$status" == "dead_letter" ) ]]; then
    pass "queue item '$queue_item_id' status matches lane $lane"
  else
    fail "queue item '$queue_item_id' status '$status' does not match lane '$lane'"
  fi

  if [[ "$lane" == "claimed" ]]; then
    jq -e '.claimed_by and .claimed_at and .claim_deadline and .claim_token' "$file" >/dev/null 2>&1 && pass "claimed queue item '$queue_item_id' lease fields present" || fail "claimed queue item '$queue_item_id' missing lease fields"
  fi
}

for lane in pending claimed retry dead-letter; do
  while IFS= read -r file; do
    validate_queue_item "$lane" "$file"
  done < <(find "$SURFACE_DIR/$lane" -type f -name '*.json' | sort)
done

while IFS= read -r receipt; do
  if jq empty "$receipt" >/dev/null 2>&1; then
    pass "valid queue receipt JSON: ${receipt#$ROOT_DIR/}"
  else
    fail "invalid queue receipt JSON: ${receipt#$ROOT_DIR/}"
  fi
done < <(find "$SURFACE_DIR/receipts" -type f -name '*.json' | sort)

finish_surface_validation "queue"
