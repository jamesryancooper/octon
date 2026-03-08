#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

PACKAGE_DIR="$ROOT_DIR/.design-packages/orchestration-domain-design-package"
CONTRACTS_DIR="$PACKAGE_DIR/contracts"
SCHEMAS_DIR="$CONTRACTS_DIR/schemas"
VALID_FIXTURES_DIR="$CONTRACTS_DIR/fixtures/valid"
INVALID_FIXTURES_DIR="$CONTRACTS_DIR/fixtures/invalid"
CONTRACTS_README="$CONTRACTS_DIR/README.md"
IMPLEMENTATION_READINESS="$PACKAGE_DIR/implementation-readiness.md"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found file: ${file#$ROOT_DIR/}"
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
    return 1
  fi
  pass "found directory: ${dir#$ROOT_DIR/}"
}

check_jq_available() {
  if command -v jq >/dev/null 2>&1; then
    pass "jq is available"
  else
    fail "jq is required for orchestration design package validation"
  fi
}

validate_json_file() {
  local file="$1"
  if jq empty "$file" >/dev/null 2>&1; then
    pass "valid JSON: ${file#$ROOT_DIR/}"
  else
    fail "invalid JSON: ${file#$ROOT_DIR/}"
  fi
}

extract_required_contract_entries() {
  awk '
    /^## Required Contract Set$/ { in_list=1; next }
    /^## / { if (in_list) exit }
    in_list && /^- `contracts\// { print }
  ' "$IMPLEMENTATION_READINESS"
}

validate_decision_record_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and ((.decision_id | nonempty_string) and (.decision_id | startswith("dec-")))
    and ((.outcome as $o | ["allow","block","escalate"] | index($o)) != null)
    and (.surface | nonempty_string)
    and (.action | nonempty_string)
    and (.actor | nonempty_string)
    and (((.decided_at // "") | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$")))
    and (.reason_codes | type == "array" and length > 0 and all(.[]; type == "string" and length > 0))
    and (.summary | nonempty_string)
    and (
      (has("workflow_ref") | not)
      or (
        (.workflow_ref | type == "object")
        and (.workflow_ref.workflow_group | nonempty_string)
        and (.workflow_ref.workflow_id | nonempty_string)
      )
    )
    and (
      (has("approval_refs") | not)
      or (.approval_refs | type == "array" and all(.[]; type == "string" and length > 0))
    )
    and ((has("run_id") | not) or (.run_id | nonempty_string))
    and ((.outcome == "allow") or (has("run_id") | not))
  ' "$file" >/dev/null
}

validate_watcher_event_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.event_id | nonempty_string)
    and (.watcher_id | nonempty_string)
    and (.event_type | nonempty_string)
    and (((.emitted_at // "") | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$")))
    and ((.severity as $s | ["info","warning","high","critical"] | index($s)) != null)
    and (.dedupe_key | nonempty_string)
    and (.source_ref | nonempty_string)
    and (.summary | nonempty_string)
    and ((has("target_automation_id") | not) or (.target_automation_id | nonempty_string))
    and ((has("candidate_incident_id") | not) or (.candidate_incident_id | nonempty_string))
  ' "$file" >/dev/null
}

validate_queue_item_and_lease_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.queue_item_id | nonempty_string)
    and (.target_automation_id | nonempty_string)
    and ((.status as $s | ["pending","claimed","retry","dead_letter"] | index($s)) != null)
    and ((.priority | type) == "number" or (.priority | nonempty_string))
    and (.available_at | valid_time)
    and (.attempt_count | type == "number" and . >= 0)
    and (.max_attempts | type == "number" and . >= 1)
    and (.summary | nonempty_string)
    and (.enqueued_at | valid_time)
    and (
      (.status != "claimed")
      or (
        (.claimed_by | nonempty_string)
        and (.claimed_at | valid_time)
        and (.claim_deadline | valid_time)
        and (.claim_deadline > .claimed_at)
        and (.claim_token | nonempty_string)
      )
    )
  ' "$file" >/dev/null
}

validate_run_linkage_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.run_id | nonempty_string)
    and ((.status as $s | ["running","succeeded","failed","cancelled"] | index($s)) != null)
    and (.started_at | valid_time)
    and (.decision_id | nonempty_string and startswith("dec-"))
    and (.continuity_run_path | nonempty_string and startswith(".harmony/continuity/runs/"))
    and (.summary | nonempty_string)
    and (
      (has("workflow_ref") | not)
      or (
        (.workflow_ref | type == "object")
        and (.workflow_ref.workflow_group | nonempty_string)
        and (.workflow_ref.workflow_id | nonempty_string)
      )
    )
    and ((.status == "running") or (has("completed_at") and (.completed_at | valid_time)))
  ' "$file" >/dev/null
}

validate_incident_object_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.incident_id | nonempty_string)
    and (.title | nonempty_string)
    and ((.severity as $s | ["sev0","sev1","sev2","sev3"] | index($s)) != null)
    and ((.status as $s | ["open","acknowledged","mitigating","monitoring","resolved","closed","cancelled"] | index($s)) != null)
    and (.owner | nonempty_string)
    and (.created_at | valid_time)
    and (.summary | nonempty_string)
    and (
      (.status != "closed")
      or (
        (has("closed_at") and (.closed_at | valid_time))
        and (has("closed_by") and (.closed_by | nonempty_string))
      )
    )
  ' "$file" >/dev/null
}

validate_automation_execution_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def workflow_ref_valid:
      type == "object"
      and (.workflow_group | nonempty_string)
      and (.workflow_id | nonempty_string);
    def string_array:
      type == "array"
      and length > 0
      and all(.[]; type == "string" and length > 0);
    type == "object"
    and (.automation | type == "object")
    and (.automation.automation_id | nonempty_string)
    and (.automation.title | nonempty_string)
    and (.automation.workflow_ref | workflow_ref_valid)
    and (.automation.owner | nonempty_string)
    and ((.automation.status as $s | ["active","paused","disabled","error"] | index($s)) != null)
    and (.trigger | type == "object")
    and ((.trigger.kind as $k | ["schedule","event"] | index($k)) != null)
    and (
      (.trigger.kind != "schedule")
      or (
        (.trigger.schedule | type == "object")
        and (.trigger.schedule.cadence | nonempty_string)
        and (.trigger.schedule.at | nonempty_string)
        and (.trigger.schedule.timezone | nonempty_string)
        and ((.trigger.schedule.missed_run_policy as $m | ["skip","run_immediately","next_window"] | index($m)) != null)
      )
    )
    and (
      (.trigger.kind != "event")
      or (
        (.trigger.event | type == "object")
        and (.trigger.event.watcher_ids | string_array)
        and (.trigger.event.event_types | string_array)
        and ((.trigger.event.match_mode as $m | ["all","any"] | index($m)) != null)
      )
    )
    and (.policy | type == "object")
    and (.policy.max_concurrency | type == "number" and . >= 1)
    and ((.policy.concurrency_mode as $m | ["serialize","drop","replace","parallel"] | index($m)) != null)
    and (.policy.idempotency_strategy | type == "object")
    and ((.policy.idempotency_strategy.kind as $k | ["event-dedupe","schedule-window"] | index($k)) != null)
    and (.policy.idempotency_strategy.key_fields | string_array)
    and (.policy.retry_policy | type == "object")
    and (.policy.retry_policy.max_attempts | type == "number" and . >= 1)
    and (.policy.retry_policy.backoff | nonempty_string)
    and (.policy.retry_policy.retryable_classes | string_array)
    and (.policy.pause_on_error | type == "boolean")
    and (
      if (.policy.concurrency_mode == "serialize" or .policy.concurrency_mode == "replace")
      then (.policy.max_concurrency == 1)
      else true
      end
    )
  ' "$file" >/dev/null
}

validate_schema_fixture() {
  local schema_base="$1"
  local file="$2"
  case "$schema_base" in
    decision-record)
      validate_decision_record_fixture "$file"
      ;;
    watcher-event)
      validate_watcher_event_fixture "$file"
      ;;
    queue-item-and-lease)
      validate_queue_item_and_lease_fixture "$file"
      ;;
    run-linkage)
      validate_run_linkage_fixture "$file"
      ;;
    incident-object)
      validate_incident_object_fixture "$file"
      ;;
    automation-execution)
      validate_automation_execution_fixture "$file"
      ;;
    *)
      fail "no validator implemented for schema-backed contract: $schema_base"
      return 1
      ;;
  esac
}

check_contracts_readme() {
  require_file "$CONTRACTS_README" || return

  if grep -Fq "## Proof Layer" "$CONTRACTS_README"; then
    pass "contracts README includes proof layer section"
  else
    fail "contracts README missing proof layer section"
  fi

  if grep -Fq "schema-backed" "$CONTRACTS_README" && grep -Fq "live-authority-backed" "$CONTRACTS_README"; then
    pass "contracts README documents schema-backed and live-authority-backed coverage"
  else
    fail "contracts README missing proof coverage annotations"
  fi
}

check_schema_directory() {
  require_dir "$SCHEMAS_DIR" || return
  require_dir "$VALID_FIXTURES_DIR" || return
  require_dir "$INVALID_FIXTURES_DIR" || return

  local schema_file
  while IFS= read -r schema_file; do
    [[ -z "$schema_file" ]] && continue
    validate_json_file "$schema_file"
  done < <(find "$SCHEMAS_DIR" -type f -name '*.schema.json' | sort)
}

validate_fixture_pack_for_schema() {
  local schema_base="$1"
  local valid_fixture="$VALID_FIXTURES_DIR/$schema_base.valid.json"

  require_file "$valid_fixture" || return
  validate_json_file "$valid_fixture"
  if validate_schema_fixture "$schema_base" "$valid_fixture"; then
    pass "schema-backed valid fixture passed: ${valid_fixture#$ROOT_DIR/}"
  else
    fail "schema-backed valid fixture failed: ${valid_fixture#$ROOT_DIR/}"
  fi

  local invalid_found=0
  local invalid_fixture
  while IFS= read -r invalid_fixture; do
    [[ -z "$invalid_fixture" ]] && continue
    invalid_found=1
    validate_json_file "$invalid_fixture"
    if validate_schema_fixture "$schema_base" "$invalid_fixture"; then
      fail "schema-backed invalid fixture unexpectedly passed: ${invalid_fixture#$ROOT_DIR/}"
    else
      pass "schema-backed invalid fixture failed as expected: ${invalid_fixture#$ROOT_DIR/}"
    fi
  done < <(find "$INVALID_FIXTURES_DIR" -type f -name "$schema_base*.invalid.json" | sort)

  if [[ "$invalid_found" -eq 0 ]]; then
    fail "no invalid fixtures found for schema-backed contract: $schema_base"
  fi
}

check_required_contract_coverage() {
  require_file "$IMPLEMENTATION_READINESS" || return

  local line contract_rel contract_abs schema_rel schema_abs schema_base
  local found_contracts=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    found_contracts=1
    contract_rel="$(printf '%s\n' "$line" | sed -E 's/^- `([^`]+)`.*/\1/')"
    contract_abs="$PACKAGE_DIR/${contract_rel#contracts/}"
    contract_abs="$CONTRACTS_DIR/$(basename "$contract_rel")"
    require_file "$contract_abs" || continue

    if [[ "$line" == *"schema-backed"* ]]; then
      schema_rel="$(printf '%s\n' "$line" | sed -nE 's/.*via `([^`]+)`.*/\1/p')"
      if [[ -z "$schema_rel" ]]; then
        fail "schema-backed contract missing schema reference: ${contract_rel}"
        continue
      fi
      schema_abs="$PACKAGE_DIR/$schema_rel"
      if ! require_file "$schema_abs"; then
        fail "missing schema for schema-backed contract: ${contract_rel}"
        continue
      fi
      validate_json_file "$schema_abs"
      schema_base="$(basename "$schema_rel" .schema.json)"
      validate_fixture_pack_for_schema "$schema_base"
      pass "required contract coverage recorded as schema-backed: ${contract_rel}"
    elif [[ "$line" == *"live-authority-backed"* ]]; then
      pass "required contract explicitly marked live-authority-backed: ${contract_rel}"
    else
      fail "required contract missing validation coverage marker: ${contract_rel}"
    fi
  done < <(extract_required_contract_entries)

  if [[ "$found_contracts" -eq 0 ]]; then
    fail "could not extract Required Contract Set from implementation-readiness.md"
  fi
}

main() {
  echo "== Validate Orchestration Design Package =="

  check_jq_available
  require_dir "$PACKAGE_DIR"
  check_contracts_readme
  check_schema_directory
  check_required_contract_coverage

  echo
  echo "Orchestration design package validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
