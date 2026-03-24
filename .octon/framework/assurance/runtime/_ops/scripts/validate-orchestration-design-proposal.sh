#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

DEFAULT_PACKAGE_PATH=".octon/inputs/exploratory/proposals/.archive/design/orchestration-domain-design-package"
PACKAGE_ARG="${1:-$DEFAULT_PACKAGE_PATH}"
USING_DEFAULT_PACKAGE=0
if [[ "$#" -eq 0 ]]; then
  USING_DEFAULT_PACKAGE=1
fi
if [[ "$PACKAGE_ARG" = /* ]]; then
  PACKAGE_DIR="$PACKAGE_ARG"
else
  PACKAGE_DIR="$ROOT_DIR/$PACKAGE_ARG"
fi
CONTRACTS_DIR="$PACKAGE_DIR/contracts"
SCHEMAS_DIR="$CONTRACTS_DIR/schemas"
VALID_FIXTURES_DIR="$CONTRACTS_DIR/fixtures/valid"
INVALID_FIXTURES_DIR="$CONTRACTS_DIR/fixtures/invalid"
CONTRACTS_README="$CONTRACTS_DIR/README.md"
CONFORMANCE_DIR="$PACKAGE_DIR/conformance"
CONFORMANCE_VALIDATOR="$CONFORMANCE_DIR/validate_scenarios.py"
IMPLEMENTATION_READINESS="$PACKAGE_DIR/normative/assurance/implementation-readiness.md"

REQUIRED_NORMATIVE_DOCS=(
  "$PACKAGE_DIR/normative/architecture/domain-model.md"
  "$PACKAGE_DIR/normative/architecture/runtime-architecture.md"
  "$PACKAGE_DIR/normative/execution/orchestration-execution-model.md"
  "$PACKAGE_DIR/normative/execution/dependency-resolution.md"
  "$PACKAGE_DIR/normative/execution/concurrency-control-model.md"
  "$PACKAGE_DIR/normative/governance/approval-and-override-contract.md"
  "$PACKAGE_DIR/normative/execution/automation-bindings-contract.md"
  "$PACKAGE_DIR/normative/execution/run-liveness-and-recovery-spec.md"
  "$PACKAGE_DIR/normative/governance/approver-authority-model.md"
  "$PACKAGE_DIR/normative/assurance/surface-artifact-schemas.md"
  "$PACKAGE_DIR/normative/execution/orchestration-lifecycle.md"
  "$PACKAGE_DIR/normative/governance/governance-and-policy.md"
  "$PACKAGE_DIR/normative/assurance/failure-model.md"
  "$PACKAGE_DIR/normative/assurance/observability.md"
)

REQUIRED_MODULE_DIRS=(
  "navigation"
  "normative"
  "contracts"
  "conformance"
  "implementation"
  "reference"
  "history"
)

SUPPLEMENTARY_SCHEMA_BASES=(
  "approval-and-override"
  "approver-authority-registry"
  "automation-definition"
  "automation-bindings"
  "automation-trigger"
  "automation-policy"
  "coordination-lock"
  "workflow-execution"
  "watcher-definition"
  "watcher-sources"
  "watcher-rules"
  "watcher-emits"
  "incident-actions"
)

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

skip() {
  echo "[SKIP] $1"
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

check_python_available() {
  if command -v python3 >/dev/null 2>&1; then
    pass "python3 is available"
  else
    fail "python3 is required for orchestration design package semantic conformance"
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

skip_if_default_package_missing() {
  if [[ "$USING_DEFAULT_PACKAGE" -eq 1 && ! -d "$PACKAGE_DIR" ]]; then
    skip "default orchestration design package not present in checkout: ${PACKAGE_DIR#$ROOT_DIR/}"
    echo
    echo "Orchestration design package validation summary: errors=0 warnings=0 skipped=1"
    exit 0
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
    and ((has("override_ref") | not) or (.override_ref | nonempty_string))
    and (
      (has("lock_required") | not)
      or (
        .lock_required == false
        or (
          (.coordination_key | nonempty_string)
          and (.lock_status == "acquired" or .lock_status == "not-required" or .lock_status == "deferred" or .lock_status == "failed")
        )
      )
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
    and (.rule_id | nonempty_string)
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
    and (.continuity_run_path | nonempty_string and startswith(".octon/state/evidence/runs/"))
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
      (.status != "running")
      or (
        (.executor_id | nonempty_string)
        and (.executor_acknowledged_at | valid_time)
        and (.last_heartbeat_at | valid_time)
        and (.lease_expires_at | valid_time)
        and (.recovery_status as $r | ["healthy","suspect","recovery_pending","recovered","abandoned"] | index($r) != null)
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

validate_campaign_object_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.campaign_id | nonempty_string)
    and (.title | nonempty_string)
    and (.objective | nonempty_string)
    and ((.status as $s | ["proposed","active","paused","completed","cancelled","archived"] | index($s)) != null)
    and (.owner | nonempty_string)
    and (.created_at | valid_time)
    and (.mission_ids | type == "array" and all(.[]; type == "string" and length > 0))
    and ((.mission_ids | length) == (.mission_ids | unique | length))
    and (.success_criteria | type == "array" and length > 0 and all(.[]; type == "string" and length > 0))
    and (.milestones | type == "array")
    and (([.milestones[]?.milestone_id] | length) == ([.milestones[]?.milestone_id] | unique | length))
    and (
      (.status == "proposed")
      or (.mission_ids | length > 0)
    )
    and (
      (.status != "completed")
      or (has("completed_at") and (.completed_at | valid_time))
    )
    and (
      (.status != "cancelled")
      or (has("cancelled_at") and (.cancelled_at | valid_time))
    )
    and (
      (.status != "archived")
      or (has("archived_at") and (.archived_at | valid_time))
    )
    and (
      .mission_ids as $campaign_missions
      | all(
          .milestones[];
          (.milestone_id | nonempty_string)
          and (.title | nonempty_string)
          and ((.status as $ms | ["planned","in_progress","completed","waived"] | index($ms)) != null)
          and (
            (has("mission_ids") | not)
            or (
              .mission_ids as $milestone_missions
              | ($milestone_missions | type == "array")
              and ($milestone_missions | all(.[]; . as $mission_id | type == "string" and length > 0 and (($campaign_missions | index($mission_id)) != null)))
              and (($milestone_missions | length) == ($milestone_missions | unique | length))
            )
          )
          and (
            (.status != "completed")
            or (has("completed_at") and (.completed_at | valid_time))
          )
          and (
            (.status != "waived")
            or (has("waiver_note") and (.waiver_note | nonempty_string))
          )
        )
    )
  ' "$file" >/dev/null
}

validate_automation_execution_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def iso_duration: type == "string" and test("^P(T.*)?[0-9A-Z]+.*$");
    def scalar_param_map_valid:
      type == "object"
      and all(
        to_entries[];
        (.key | type == "string" and length > 0)
        and (.value | type == "string" or type == "number" or type == "boolean")
      );
    def binding_map_valid:
      type == "object"
      and all(
        to_entries[];
        (.key | type == "string" and length > 0)
        and (.value | type == "object")
        and (.value.from | type == "string" and test("^event(\\.[A-Za-z0-9_-]+)+$"))
        and (.value.required | type == "boolean")
        and (.value.value_type as $t | ["string","integer","number","boolean"] | index($t) != null)
        and (
          (.value.required == false)
          or ((.value | has("default")) | not)
        )
      );
    def incident_policy_valid:
      type == "object"
      and (.open_incident_on | type == "array" and length > 0)
      and all(
        .open_incident_on[];
        ["repeated-terminal-failure","retry-exhausted","launch-commit-failure","evidence-write-failure"] | index(.) != null
      );
    def workflow_ref_valid:
      type == "object"
      and (.workflow_group | nonempty_string)
      and (.workflow_id | nonempty_string);
    def positive_integer:
      type == "number"
      and . >= 1
      and floor == .;
    def string_array:
      type == "array"
      and length > 0
      and all(.[]; type == "string" and length > 0)
      and ((unique | length) == length);
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
        and (.trigger.schedule.cadence | type == "string" and test("^(hourly:(?:[1-9]|1[0-9]|2[0-4])|daily|weekly:(?:MO|TU|WE|TH|FR|SA|SU)(?:,(?:MO|TU|WE|TH|FR|SA|SU))*)$"))
        and (.trigger.schedule.at | type == "string" and test("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$"))
        and (.trigger.schedule.timezone | nonempty_string)
        and ((.trigger.schedule.missed_run_policy as $m | ["skip","run_immediately","next_window"] | index($m)) != null)
        and ((.trigger | has("event")) | not)
      )
    )
    and (
      (.trigger.kind != "event")
      or (
        (.trigger.event | type == "object")
        and (.trigger.event.watcher_ids | string_array)
        and (.trigger.event.event_types | string_array)
        and ((.trigger.event.match_mode as $m | ["all","any"] | index($m)) != null)
        and (
          ((.trigger.event | has("dedupe_window")) | not)
          or (.trigger.event.dedupe_window | iso_duration)
        )
        and ((.trigger | has("schedule")) | not)
      )
    )
    and (.bindings | type == "object")
    and (
      ((.bindings | has("default_params")) | not)
      or (.bindings.default_params | scalar_param_map_valid)
    )
    and (
      ((.bindings | has("event_to_param_map")) | not)
      or (.bindings.event_to_param_map | binding_map_valid)
    )
    and (.policy | type == "object")
    and (.policy.max_concurrency | positive_integer)
    and ((.policy.concurrency_mode as $m | ["serialize","drop","replace","parallel"] | index($m)) != null)
    and (.policy.idempotency_strategy | type == "object")
    and ((.policy.idempotency_strategy.kind as $k | ["event-dedupe","schedule-window"] | index($k)) != null)
    and (.policy.idempotency_strategy.key_fields | string_array)
    and (.policy.retry_policy | type == "object")
    and (.policy.retry_policy.max_attempts | positive_integer)
    and ((.policy.retry_policy.backoff as $b | ["fixed","linear","exponential"] | index($b)) != null)
    and (
      .policy.retry_policy.retryable_classes
      | type == "array"
      and length > 0
      and ((unique | length) == length)
      and all(
        .[];
        ["validation_failure","reference_resolution_failure","policy_denied","approval_missing","transient_runtime_failure","terminal_runtime_failure","concurrency_conflict","binding_validation_failure","lock_acquisition_failure","lock_lost_during_execution","executor_liveness_failure","stale_claim","evidence_write_failure","launch_commit_failure","manual_quarantine"] | index(.) != null
      )
    )
    and (.policy.pause_on_error | type == "boolean")
    and (
      ((.policy | has("incident_policy")) | not)
      or (.policy.incident_policy | incident_policy_valid)
    )
    and (
      if (.policy.concurrency_mode == "serialize" or .policy.concurrency_mode == "replace")
      then (.policy.max_concurrency == 1)
      else true
      end
    )
  ' "$file" >/dev/null
}

validate_workflow_execution_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def string_array: type == "array" and all(.[]; type == "string" and length > 0);
    type == "object"
    and (.schema_version == "workflow-contract-v2")
    and (.name | nonempty_string)
    and (.description | nonempty_string)
    and (.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    and (.entry_mode | nonempty_string)
    and ((.execution_profile as $p | ["core","external-dependent"] | index($p)) != null)
    and ((.side_effect_class as $c | ["none","read_only","mutating","destructive"] | index($c)) != null)
    and (.execution_controls | type == "object")
    and (.execution_controls.cancel_safe | type == "boolean")
    and (.coordination_key_strategy | type == "object")
    and ((.coordination_key_strategy.kind as $k | ["none","workflow-target","mission-target","incident-target","explicit-input"] | index($k)) != null)
    and (.inputs | type == "array")
    and all(
      .inputs[];
      (.name | nonempty_string)
      and ((.type as $t | ["text","boolean","file","folder","integer","number","object","array"] | index($t)) != null)
      and (.required | type == "boolean")
    )
    and (.stages | type == "array" and length > 0)
    and all(
      .stages[];
      (.id | nonempty_string)
      and (.asset | type == "string" and test("^stages/.+\\.md$"))
      and ((.kind as $k | ["analysis","mutation","projection","verification"] | index($k)) != null)
      and (.consumes | string_array or (.consumes | type == "array" and length == 0))
      and (.produces | string_array or (.produces | type == "array" and length == 0))
      and (.mutation_scope | string_array or (.mutation_scope | type == "array" and length == 0))
      and (.authorization | type == "object")
      and (.authorization.action_type | nonempty_string)
      and (.authorization.requested_capabilities | string_array)
      and (.authorization.side_effects | type == "object")
      and (.authorization.risk_tier | nonempty_string)
      and (.authorization.scope.read | string_array)
      and (.authorization.scope.write | string_array)
      and (.authorization.review_requirements | type == "object")
      and (.authorization.allowed_executor_profiles | string_array)
    )
    and (.artifacts | type == "array")
    and all(
      .artifacts[];
      (.name | nonempty_string)
      and (.path | nonempty_string)
      and ((.kind as $k | ["file","directory"] | index($k)) != null)
      and (.format | nonempty_string)
      and (.determinism | nonempty_string)
      and (.description | nonempty_string)
    )
    and (.done_gate | type == "object")
    and (.done_gate.checks | string_array)
    and (.constraints | type == "object")
    and (.constraints.fail_closed == true)
    and (.constraints.require_relative_local_assets == true)
    and (
      ((.constraints | has("forbid_design_packages")) | not)
      or (.constraints.forbid_design_packages | type == "boolean")
    )
    and (.executor_interface_version == "workflow-executor-v1")
    and (
      (.side_effect_class == "none" or .side_effect_class == "read_only")
      or (
        .coordination_key_strategy.kind != "none"
        and (.coordination_key_strategy.source_fields | type == "array" and length > 0)
        and (.coordination_key_strategy.format | nonempty_string)
      )
    )
  ' "$file" >/dev/null
}

validate_mission_object_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    def workflow_ref_valid:
      type == "object"
      and (.workflow_group | nonempty_string)
      and (.workflow_id | nonempty_string);
    def string_array_or_empty:
      type == "array"
      and all(.[]; type == "string" and length > 0);
    type == "object"
    and (.schema_version == "octon-mission-v2")
    and (.mission_id | nonempty_string)
    and (.title | nonempty_string)
    and (.summary | nonempty_string)
    and ((.status as $s | ["created","active","completed","cancelled","archived"] | index($s)) != null)
    and (.mission_class | nonempty_string)
    and (.owner_ref | nonempty_string)
    and (.created_at | valid_time)
    and (.risk_ceiling | nonempty_string)
    and (.allowed_action_classes | string_array_or_empty)
    and (.default_safing_subset | string_array_or_empty)
    and (.default_schedule_hint | nonempty_string)
    and (.default_overlap_policy | nonempty_string)
    and (
      .success_criteria
      | type == "array"
      and length > 0
      and all(.[]; type == "string" and length > 0)
    )
    and (
      (has("campaign_id") | not)
      or (.campaign_id | nonempty_string)
    )
    and (
      (has("default_workflow_refs") | not)
      or (
        .default_workflow_refs
        | type == "array"
        and all(.[]; workflow_ref_valid)
      )
    )
    and (
      (has("active_run_ids") | not)
      or (.active_run_ids | string_array_or_empty)
    )
    and (
      (has("recent_run_ids") | not)
      or (.recent_run_ids | string_array_or_empty)
    )
    and (
      (has("related_run_ids") | not)
      or (.related_run_ids | string_array_or_empty)
    )
    and (
      (.status != "archived")
      or (.archived_from_status == "completed" or .archived_from_status == "cancelled")
    )
  ' "$file" >/dev/null
}

validate_coordination_lock_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.lock_id | nonempty_string)
    and (.coordination_key | nonempty_string)
    and ((.lock_class as $c | ["exclusive","shared-read","shared-compatible"] | index($c)) != null)
    and (.owner_run_id | nonempty_string)
    and ((.lock_state as $s | ["held","released","expired","transferred"] | index($s)) != null)
    and (.acquired_at | valid_time)
    and (.lease_expires_at | valid_time)
    and (.lock_version | type == "number" and . >= 1)
    and (
      (.lock_state != "released")
      or (has("released_at") and (.released_at | valid_time))
    )
    and (
      (.lock_state != "transferred")
      or (has("previous_lock_id") and (.previous_lock_id | nonempty_string))
    )
  ' "$file" >/dev/null
}

validate_approval_and_override_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.approval_id | nonempty_string)
    and ((.artifact_type as $t | ["approval","waiver","override"] | index($t)) != null)
    and (.action_class | nonempty_string)
    and (.scope | type == "object")
    and (.scope.surface | nonempty_string)
    and (.scope.action | nonempty_string)
    and (.approved_by | nonempty_string)
    and (.issued_at | valid_time)
    and (.expires_at | valid_time)
    and (.rationale | nonempty_string)
    and (.review_required | type == "boolean")
    and (
      (.review_required == false)
      or (has("review_by") and (.review_by | valid_time))
    )
    and (
      (.artifact_type != "override")
      or (has("override_reason") and (.override_reason | nonempty_string))
    )
  ' "$file" >/dev/null
}

validate_automation_bindings_fixture() {
  local file="$1"
  jq -e '
    type == "object"
    and (
      ((has("default_params") | not)
      or (
        .default_params
        | type == "object"
        and all(
          to_entries[];
          (.key | type == "string" and length > 0)
          and (.value | type == "string" or type == "number" or type == "boolean")
        )
      ))
    )
    and (
      ((has("event_to_param_map") | not)
      or (
        .event_to_param_map
        | type == "object"
        and all(
          to_entries[];
          (.key | type == "string" and length > 0)
          and (.value.from | type == "string" and test("^event(\\.[A-Za-z0-9_-]+)+$"))
          and (.value.required | type == "boolean")
          and (.value.value_type as $t | ["string","integer","number","boolean"] | index($t) != null)
          and ((.value.required == false) or ((.value | has("default")) | not))
        )
      ))
    )
  ' "$file" >/dev/null
}

validate_automation_definition_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.automation_id | nonempty_string)
    and (.title | nonempty_string)
    and (.workflow_ref | type == "object")
    and (.workflow_ref.workflow_group | nonempty_string)
    and (.workflow_ref.workflow_id | nonempty_string)
    and (.owner | nonempty_string)
    and ((.status as $s | ["active","paused","disabled","error"] | index($s)) != null)
  ' "$file" >/dev/null
}

validate_automation_trigger_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def iso_duration: type == "string" and test("^P(T.*)?[0-9A-Z]+.*$");
    def string_array:
      type == "array"
      and length > 0
      and all(.[]; type == "string" and length > 0);
    type == "object"
    and ((.kind as $k | ["schedule","event"] | index($k)) != null)
    and (
      (.kind != "schedule")
      or (
        (.schedule | type == "object")
        and (.schedule.cadence | type == "string" and test("^(hourly:(?:[1-9]|1[0-9]|2[0-4])|daily|weekly:(?:MO|TU|WE|TH|FR|SA|SU)(?:,(?:MO|TU|WE|TH|FR|SA|SU))*)$"))
        and (.schedule.at | type == "string" and test("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$"))
        and (.schedule.timezone | nonempty_string)
        and ((.schedule.missed_run_policy as $m | ["skip","run_immediately","next_window"] | index($m)) != null)
        and ((has("event")) | not)
      )
    )
    and (
      (.kind != "event")
      or (
        (.event | type == "object")
        and (.event.watcher_ids | string_array)
        and (.event.event_types | string_array)
        and ((.event.match_mode as $m | ["all","any"] | index($m)) != null)
        and (
          ((.event | has("severity_at_or_above")) | not)
          or (.event.severity_at_or_above as $s | ["info","warning","high","critical"] | index($s) != null)
        )
        and (
          ((.event | has("source_ref_globs")) | not)
          or (.event.source_ref_globs | string_array)
        )
        and (
          ((.event | has("dedupe_window")) | not)
          or (.event.dedupe_window | iso_duration)
        )
        and ((has("schedule")) | not)
      )
    )
  ' "$file" >/dev/null
}

validate_automation_policy_fixture() {
  local file="$1"
  jq -e '
    def string_array:
      type == "array"
      and length > 0
      and all(.[]; type == "string" and length > 0);
    type == "object"
    and (.max_concurrency | type == "number" and . >= 1)
    and ((.concurrency_mode as $m | ["serialize","drop","replace","parallel"] | index($m)) != null)
    and (.idempotency_strategy | type == "object")
    and ((.idempotency_strategy.kind as $k | ["event-dedupe","schedule-window"] | index($k)) != null)
    and (.idempotency_strategy.key_fields | string_array)
    and (.retry_policy | type == "object")
    and (.retry_policy.max_attempts | type == "number" and . >= 1)
    and ((.retry_policy.backoff as $b | ["fixed","linear","exponential"] | index($b)) != null)
    and (
      .retry_policy.retryable_classes
      | type == "array"
      and length > 0
      and all(
        .[];
        ["validation_failure","reference_resolution_failure","policy_denied","approval_missing","transient_runtime_failure","terminal_runtime_failure","concurrency_conflict","binding_validation_failure","lock_acquisition_failure","lock_lost_during_execution","executor_liveness_failure","stale_claim","evidence_write_failure","launch_commit_failure","manual_quarantine"] | index(.) != null
      )
    )
    and (.pause_on_error | type == "boolean")
    and (
      ((has("incident_policy")) | not)
      or (
        .incident_policy
        | type == "object"
        and (.open_incident_on | type == "array" and length > 0)
        and all(
          .open_incident_on[];
          ["repeated-terminal-failure","retry-exhausted","launch-commit-failure","evidence-write-failure"] | index(.) != null
        )
      )
    )
    and (
      if (.concurrency_mode == "serialize" or .concurrency_mode == "replace")
      then (.max_concurrency == 1)
      else true
      end
    )
  ' "$file" >/dev/null
}

validate_watcher_definition_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.watcher_id | nonempty_string)
    and (.title | nonempty_string)
    and (.owner | nonempty_string)
    and ((.status as $s | ["active","paused","disabled","error"] | index($s)) != null)
    and (.runner | type == "object")
    and ((.runner.kind as $k | ["poll","subscription"] | index($k)) != null)
    and (
      (.runner.kind != "poll")
      or (
        (.runner | has("cadence"))
        and (.runner.cadence | type == "string" and test("^P(T.*)?[0-9A-Z]+.*$"))
      )
    )
    and ((.cursor_mode as $m | ["none","per-source-watermark","opaque"] | index($m)) != null)
    and (
      (has("suppression_window") | not)
      or (.suppression_window | type == "string" and test("^P(T.*)?[0-9A-Z]+.*$"))
    )
  ' "$file" >/dev/null
}

validate_watcher_sources_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.sources | type == "array" and length > 0)
    and all(
      .sources[];
      (.source_id | nonempty_string)
      and (.kind | nonempty_string)
      and (.ref | nonempty_string)
      and ((.required_access as $a | ["read","read-metadata"] | index($a)) != null)
      and ((has("cursor_field") | not) or (.cursor_field | nonempty_string))
    )
  ' "$file" >/dev/null
}

validate_watcher_rules_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.rules | type == "array" and length > 0)
    and all(
      .rules[];
      (.rule_id | nonempty_string)
      and (.source_ids | type == "array" and length > 0 and all(.[]; nonempty_string))
      and (.condition | type == "object")
      and ((.condition.kind as $k | ["threshold","absence","change","match"] | index($k)) != null)
      and (
        (has("condition") | not)
        or (
          ((.condition | has("window")) | not)
          or (.condition.window | type == "string" and test("^P(T.*)?[0-9A-Z]+.*$"))
        )
      )
      and (.event_type | nonempty_string)
      and ((.severity as $s | ["info","warning","high","critical"] | index($s)) != null)
      and (.summary_template | nonempty_string)
      and (
        (has("dedupe_key_fields") | not)
        or (.dedupe_key_fields | type == "array" and length > 0 and all(.[]; nonempty_string))
      )
      and (
        (has("routing_hints") | not)
        or (
          (.routing_hints | type == "object")
          and (
            ((.routing_hints | has("target_automation_id")) | not)
            or (.routing_hints.target_automation_id | nonempty_string)
          )
          and (
            ((.routing_hints | has("candidate_incident_id")) | not)
            or (.routing_hints.candidate_incident_id | nonempty_string)
          )
        )
      )
    )
  ' "$file" >/dev/null
}

validate_watcher_emits_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    type == "object"
    and (.emits | type == "array" and length > 0)
    and all(
      .emits[];
      (.event_type | nonempty_string)
      and (.payload_fields | type == "array" and all(.[]; nonempty_string))
      and (.allow_payload_ref | type == "boolean")
      and (.routing_hints | type == "object")
      and (.routing_hints.allow_target_automation_id | type == "boolean")
      and (.routing_hints.allow_candidate_incident_id | type == "boolean")
    )
  ' "$file" >/dev/null
}

validate_incident_actions_fixture() {
  local file="$1"
  jq -e '
    type == "object"
    and (.actions | type == "array" and length > 0)
    and all(
      .actions[];
      (.action_id | type == "string" and length > 0)
      and ((.action_type as $t | ["containment","rollback","remediation","review"] | index($t)) != null)
      and ((.status as $s | ["pending","in_progress","completed","cancelled"] | index($s)) != null)
    )
  ' "$file" >/dev/null
}

validate_approver_authority_registry_fixture() {
  local file="$1"
  jq -e '
    def nonempty_string: type == "string" and length > 0;
    def valid_time: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$");
    type == "object"
    and (.registry_version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    and (.approvers | type == "array" and length > 0)
    and all(
      .approvers[];
      (.approver_id | nonempty_string)
      and (.role | nonempty_string)
      and (.approved_scopes | type == "array" and length > 0)
      and (.issued_at | valid_time)
      and (.expires_at | valid_time)
      and (.revoked | type == "boolean")
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
    campaign-object)
      validate_campaign_object_fixture "$file"
      ;;
    automation-execution)
      validate_automation_execution_fixture "$file"
      ;;
    workflow-execution)
      validate_workflow_execution_fixture "$file"
      ;;
    mission-object)
      validate_mission_object_fixture "$file"
      ;;
    coordination-lock)
      validate_coordination_lock_fixture "$file"
      ;;
    approval-and-override)
      validate_approval_and_override_fixture "$file"
      ;;
    approver-authority-registry)
      validate_approver_authority_registry_fixture "$file"
      ;;
    automation-definition)
      validate_automation_definition_fixture "$file"
      ;;
    automation-bindings)
      validate_automation_bindings_fixture "$file"
      ;;
    automation-trigger)
      validate_automation_trigger_fixture "$file"
      ;;
    automation-policy)
      validate_automation_policy_fixture "$file"
      ;;
    watcher-definition)
      validate_watcher_definition_fixture "$file"
      ;;
    watcher-sources)
      validate_watcher_sources_fixture "$file"
      ;;
    watcher-rules)
      validate_watcher_rules_fixture "$file"
      ;;
    watcher-emits)
      validate_watcher_emits_fixture "$file"
      ;;
    incident-actions)
      validate_incident_actions_fixture "$file"
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

  if grep -Fq "schema-backed" "$CONTRACTS_README" && grep -Fq "package-normative" "$CONTRACTS_README"; then
    pass "contracts README documents schema-backed and package-normative coverage"
  else
    fail "contracts README missing proof coverage annotations"
  fi
}

check_required_normative_docs() {
  local file
  for file in "${REQUIRED_NORMATIVE_DOCS[@]}"; do
    require_file "$file"
  done
}

check_module_layout() {
  local module
  for module in "${REQUIRED_MODULE_DIRS[@]}"; do
    require_dir "$PACKAGE_DIR/$module"
  done

  local root_file
  while IFS= read -r root_file; do
    [[ -z "$root_file" ]] && continue
    if [[ "$(basename "$root_file")" != "README.md" && "$(basename "$root_file")" != "proposal.yml" && "$(basename "$root_file")" != "design-proposal.yml" ]]; then
      fail "unexpected root-level file in package: ${root_file#$ROOT_DIR/}"
    fi
  done < <(find "$PACKAGE_DIR" -maxdepth 1 -type f | sort)
}

check_conformance_module() {
  require_file "$PACKAGE_DIR/conformance/README.md" || return
  require_file "$CONFORMANCE_VALIDATOR" || return
  require_dir "$PACKAGE_DIR/conformance/scenarios/routing" || return
  require_dir "$PACKAGE_DIR/conformance/scenarios/scheduling" || return
  require_dir "$PACKAGE_DIR/conformance/scenarios/recovery" || return
}

check_required_hardening_sections() {
  local spec
  local file
  local pattern

  while IFS='|' read -r file pattern; do
    [[ -z "$file" ]] && continue
    if grep -Fq "$pattern" "$file"; then
      pass "found hardening section '$pattern' in ${file#$ROOT_DIR/}"
    else
      fail "missing hardening section '$pattern' in ${file#$ROOT_DIR/}"
    fi
  done <<EOF
$PACKAGE_DIR/normative/architecture/runtime-architecture.md|## Coordination Protocol
$PACKAGE_DIR/normative/execution/orchestration-execution-model.md|## Execution Handshake
$PACKAGE_DIR/normative/execution/dependency-resolution.md|## Binding Validation
$PACKAGE_DIR/normative/governance/governance-and-policy.md|## Privileged Action Classes
$PACKAGE_DIR/normative/execution/lifecycle-and-state-machine-spec.md|### Run Liveness Substate
$PACKAGE_DIR/contracts/workflow-execution-contract.md|## Workflow Execution Interface
$PACKAGE_DIR/contracts/coordination-lock-contract.md|## Acquisition Algorithm
$PACKAGE_DIR/normative/governance/approver-authority-model.md|## Approval Verification Algorithm
EOF
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

check_supplementary_schema_packs() {
  local schema_base
  for schema_base in "${SUPPLEMENTARY_SCHEMA_BASES[@]}"; do
    validate_fixture_pack_for_schema "$schema_base"
  done
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
    elif [[ "$line" == *"package-normative"* ]]; then
      pass "required contract explicitly marked package-normative: ${contract_rel}"
    else
      fail "required contract missing validation coverage marker: ${contract_rel}"
    fi
  done < <(extract_required_contract_entries)

  if [[ "$found_contracts" -eq 0 ]]; then
    fail "could not extract Required Contract Set from implementation-readiness.md"
  fi
}

run_conformance_scenarios() {
  require_file "$CONFORMANCE_VALIDATOR" || return
  if python3 "$CONFORMANCE_VALIDATOR" "$CONFORMANCE_DIR"; then
    pass "semantic conformance scenarios passed"
  else
    fail "semantic conformance scenarios failed"
  fi
}

main() {
  echo "== Validate Orchestration Design Package =="

  skip_if_default_package_missing

  check_jq_available
  check_python_available
  require_dir "$PACKAGE_DIR"
  check_module_layout
  check_required_normative_docs
  check_conformance_module
  check_required_hardening_sections
  check_contracts_readme
  check_schema_directory
  check_required_contract_coverage
  check_supplementary_schema_packs
  run_conformance_scenarios

  echo
  echo "Orchestration design package validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
