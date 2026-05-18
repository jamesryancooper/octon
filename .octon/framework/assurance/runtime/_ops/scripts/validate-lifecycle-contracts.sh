#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$(cd -- "$OCTON_DIR_OVERRIDE" && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
elif [[ -n "${OCTON_ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd -- "$OCTON_ROOT_DIR" && pwd)"
  OCTON_DIR="$ROOT_DIR/.octon"
fi

CONTRACT_PATH=""
errors=0
warnings=0

pass() { echo "[OK] $1"; }
warn() { echo "[WARN] $1"; warnings=$((warnings + 1)); }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

usage() {
  cat <<'EOF'
usage:
  validate-lifecycle-contracts.sh [--contract <path>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --contract)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      CONTRACT_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

repo_abs() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

rel_from_root() {
  local path="$1"
  if [[ "$path" = "$ROOT_DIR/"* ]]; then
    printf '%s\n' "${path#$ROOT_DIR/}"
  else
    printf '%s\n' "$path"
  fi
}

pack_id_for_contract() {
  local rel="$1"
  rel="${rel#./}"
  case "$rel" in
    .octon/inputs/additive/extensions/*/context/lifecycle.contract.yml)
      rel="${rel#.octon/inputs/additive/extensions/}"
      printf '%s\n' "${rel%%/*}"
      ;;
    .octon/inputs/additive/extensions/*/context/lifecycles/*.contract.yml)
      rel="${rel#.octon/inputs/additive/extensions/}"
      printf '%s\n' "${rel%%/*}"
      ;;
    *)
      printf '\n'
      ;;
  esac
}

valid_rel_path() {
  local value="$1"
  [[ -n "$value" \
    && "$value" != /* \
    && "$value" != "." \
    && "$value" != ./* \
    && "$value" != */./* \
    && "$value" != */. \
    && "$value" != *"../"* \
    && "$value" != ../* \
    && "$value" != *"/.." \
    && "$value" != ".." ]]
}

contract_files() {
  if [[ -n "$CONTRACT_PATH" ]]; then
    repo_abs "$CONTRACT_PATH"
  else
    find "$OCTON_DIR/inputs/additive/extensions" \
      \( -path '*/context/lifecycle.contract.yml' -o -path '*/context/lifecycles/*.contract.yml' \) \
      -type f | sort
  fi
}

id_list_contains() {
  local needle="$1"
  shift
  printf '%s\n' "$@" | grep -Fx "$needle" >/dev/null 2>&1
}

load_ids() {
  local file="$1" query="$2"
  yq -r "$query // \"\"" "$file" 2>/dev/null | awk 'NF' | LC_ALL=C sort -u
}

load_values() {
  local file="$1" query="$2"
  yq -r "$query // \"\"" "$file" 2>/dev/null | awk 'NF'
}

validate_unique_ids() {
  local contract="$1" query="$2" label="$3"
  local ids duplicates
  ids="$(load_values "$contract" "$query")"
  duplicates="$(printf '%s\n' "$ids" | sort | uniq -d | awk 'NF' || true)"
  [[ -z "$duplicates" ]] && pass "$label ids unique" || fail "$label ids duplicate: $duplicates"
}

validator_script_from_argv() {
  local contract="$1" index="$2" first second
  first="$(yq -r ".validators[$index].argv[0] // \"\"" "$contract" 2>/dev/null || true)"
  second="$(yq -r ".validators[$index].argv[1] // \"\"" "$contract" 2>/dev/null || true)"
  case "$first" in
    bash|sh)
      printf '%s\n' "$second"
      ;;
    *)
      printf '%s\n' "$first"
      ;;
  esac
}

validate_validator_argv() {
  local contract="$1" owner="$2"
  local count index validator_id script script_abs
  count="$(yq -r '(.validators // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<count; index++)); do
    validator_id="$(yq -r ".validators[$index].validator_id // \"\"" "$contract" 2>/dev/null || true)"
    yq -e ".validators[$index].argv | tag == \"!!seq\" and length > 0" "$contract" >/dev/null 2>&1 \
      && pass "validator argv declared: $validator_id" \
      || fail "validator argv missing or invalid: $validator_id"
    script="$(validator_script_from_argv "$contract" "$index")"
    if [[ -z "$script" ]]; then
      fail "validator script missing: $validator_id"
      continue
    fi
    if ! valid_rel_path "$script"; then
      fail "validator script path is not repo-relative: $validator_id"
      continue
    fi
    case "$script" in
      .octon/framework/assurance/runtime/_ops/scripts/*|.octon/inputs/additive/extensions/"$owner"/validation/*)
        ;;
      *)
        fail "validator script outside allowed roots: $validator_id"
        continue
        ;;
    esac
    script_abs="$ROOT_DIR/$script"
    [[ -f "$script_abs" ]] && pass "validator script exists: $validator_id" || fail "validator script missing on disk: $script"
  done
}

validate_condition_receipt_ref() {
  local receipt_id="$1" receipt_ids="$2" label="$3"
  if [[ -z "$receipt_id" || "$receipt_id" == "null" ]]; then
    fail "condition receipt missing: $label"
  elif id_list_contains "$receipt_id" "$receipt_ids"; then
    pass "condition receipt exists: $label -> $receipt_id"
  else
    fail "condition receipt missing: $label -> $receipt_id"
  fi
}

validate_condition_receipt_refs() {
  local contract="$1" expr="$2" label="$3" receipt_ids="$4"
  local key receipt_id

  for key in receipt_absent receipt_stale receipt_fresh receipt_complete; do
    while IFS= read -r receipt_id; do
      [[ -n "$receipt_id" || "$receipt_id" == "null" ]] || continue
      validate_condition_receipt_ref "$receipt_id" "$receipt_ids" "$label $key"
    done < <(yq -r "$expr | .. | select(tag == \"!!map\" and has(\"$key\")) | .$key // \"\"" "$contract" 2>/dev/null || true)
  done

  for key in receipt_verdict receipt_field_equals; do
    while IFS= read -r receipt_id; do
      validate_condition_receipt_ref "$receipt_id" "$receipt_ids" "$label $key"
    done < <(yq -r "$expr | .. | select(tag == \"!!map\" and has(\"$key\")) | .$key.receipt_id // \"\"" "$contract" 2>/dev/null || true)
  done
}

validate_condition_path_refs() {
  local contract="$1" expr="$2" label="$3"
  local key path

  for key in file_absent file_present; do
    while IFS= read -r path; do
      [[ -n "$path" && "$path" != "null" ]] || continue
      valid_rel_path "$path" \
        && pass "condition path valid: $label $key -> $path" \
        || fail "condition path invalid: $label $key -> $path"
    done < <(yq -r "$expr | .. | select(tag == \"!!map\" and has(\"$key\")) | .$key // \"\"" "$contract" 2>/dev/null || true)
  done
}

valid_program_execution_mode() {
  case "$1" in
    sequential|gated-parallel|approval-gated|parallel-independent|program-atomic)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_lifecycle_execution_strategy() {
  case "$1" in
    route-progression|orchestrated-replan-loop)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_blocker_class() {
  case "$1" in
    policy-override|authority-ambiguity|authority-ambiguity|\
stale-receipt|validation-failed|missing-evidence|executor-failed|executor-timed-out|executor-preflight-blocked|\
publication-drift|\
unsupported-mode|unsupported-mode-config|unsupported-mode-authority|\
write-scope-conflict|write-scope-serialization-required|atomic-write-scope-conflict|\
dependency-blocked|dependency-gate-unsatisfied|scheduler-paused|deferred|step-budget-exhausted-continuable|\
target-drift|target-drift-explained|target-drift-unclear|\
noncritical-artifact-cleanup|lifecycle-residue-cleanup-needed|critical-artifact-cleanup-required|artifact-cleanup-required|worktree-hygiene-blocked|artifact-ownership-unclear|\
recovery-budget-exhausted-alternate-route|recovery-budget-override-required|recovery-integrity-risk|\
recovery-route-unavailable|receipt-recovery-unavailable|finding-binding-unavailable|deferred-evidence-missing|aggregate-closeout-readiness-missing|\
authority-zone-denied|authority-zone-ambiguous|self-authorization-attempt|scope-expansion|protected-artifact-authority-ambiguity|\
unsafe-resume|authority-boundary-ambiguous)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

program_blocker_non_recoverable() {
  case "$1" in
    unsafe-resume|authority-boundary-ambiguous)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

program_blocker_unsafe() {
  case "$1" in
    unsupported-mode|unsupported-mode-authority|atomic-write-scope-conflict|recovery-integrity-risk|authority-zone-ambiguous|self-authorization-attempt|unsafe-resume|authority-boundary-ambiguous)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

program_blocker_human_required() {
  case "$1" in
    authority-ambiguity|authority-ambiguity|executor-preflight-blocked|unsupported-mode-config|target-drift|target-drift-unclear|\
critical-artifact-cleanup-required|artifact-cleanup-required|worktree-hygiene-blocked|artifact-ownership-unclear|\
recovery-budget-override-required|recovery-route-unavailable|receipt-recovery-unavailable|finding-binding-unavailable|\
deferred-evidence-missing|aggregate-closeout-readiness-missing|authority-zone-denied|scope-expansion|protected-artifact-authority-ambiguity)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

program_blocker_dependency_wait() {
  case "$1" in
    dependency-blocked|dependency-gate-unsatisfied|scheduler-paused|deferred|write-scope-serialization-required)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

program_blocker_runtime_child_route() {
  case "$1" in
    stale-receipt|missing-evidence|executor-failed|executor-timed-out)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_id() {
  [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]]
}

valid_program_recovery_idempotency_class() {
  case "$1" in
    inspect-only|idempotent|idempotent-rerun|bounded-retry|approval-gated-mutation|non-idempotent|unsafe|non-recoverable)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_safe_idempotency_class() {
  case "$1" in
    inspect-only|idempotent|idempotent-rerun|bounded-retry|no-op-safe)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_route_delegation_decision_class() {
  case "$1" in
    delegated-execution|new-governance-decision)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_route_replay_class() {
  case "$1" in
    inspect-only|idempotent|idempotent-rerun|bounded-retry|no-op-safe|non-replay-safe)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_route_write_scope_source() {
  case "$1" in
    target|route-completion-and-target|workflow-scope|program-child-registry|program-mutation-envelope|run-bound-artifacts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_human_only_boundary() {
  case "$1" in
    scope-expansion|policy-override|unresolved-risk-acceptance|governance-mutation|contradictory-evidence-resolution|stale-evidence-acceptance|authority-ambiguity|unsafe-resume|external-irreversible-effect)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_precondition() {
  case "$1" in
    live-state-readable|selected-route-present|receipt-stale|missing-evidence|target-path-unchanged|write-scope-unchanged|current-run-child-owned-drift-evidence|\
authority-zone-allowed|artifact-ownership-known|declared-write-scope-contained|run-bound-current|source-authority-digest-unchanged|generated-non-authority)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_dependent_handling() {
  case "$1" in
    continue-independent|block-dependents|pause-dependent|pause-phase|pause-barrier|fail-closed)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_post_attempt_validation() {
  case "$1" in
    replay-verify|replan-live-state|receipt-fresh|receipt-freshness|blocker-cleared|authority-boundary-check|aggregate-closeout-check|publication-freshness-cleared)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_replan_behavior() {
  case "$1" in
    none|after-attempt|always)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_program_recovery_action_id() {
  case "$1" in
    refresh-publication-projections|rebaseline-checkpoint|cleanup-current-run-artifacts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_authority_zone() {
  case "$1" in
    octon-run-bound|octon-generated-derived|octon-authored-governance|workspace-declared|current-run-agent-artifact|protected-or-external)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_authority_artifact_class() {
  case "$1" in
    run-control|run-evidence|generated-derived|authored-governance|workspace-source|current-run-generated|protected-human-or-external|unknown)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

valid_authority_operation_class() {
  case "$1" in
    inspect|append-run-evidence|update-run-control|refresh-generated-projection|cleanup-current-run-artifact|retry-child-route|execute-child-route|program-recovery-action|closeout-readiness|durable-authority-mutation|protected-artifact-mutation)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_recovery_object_keys() {
  local contract="$1" expr="$2" label="$3"
  local key
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    case "$key" in
      blocker_class|recovery_route_id|recovery_action_id|preconditions|idempotency_class|human_required|retry_budget|dependent_handling|post_attempt_validation|replan_behavior|max_attempts|replan_after_attempt|\
allowed_authority_zones|allowed_artifact_classes|operation_class|requires_run_binding|requires_declared_write_scope|requires_zone_evidence|human_required_for_zones)
        pass "program recovery field allowed: $label -> $key"
        ;;
      *)
        fail "program recovery field unsupported: $label -> $key"
        ;;
    esac
  done < <(yq -r "$expr | keys[]?" "$contract" 2>/dev/null || true)
}

validate_program_recovery_handler() {
  local contract="$1" lifecycle_id="$2" handler_key="$3"
  local handler_attempts handler_replan handler_approval recovery_route_id recipe_dispatch_count

  valid_program_blocker_class "$handler_key" \
    && pass "program recovery handler blocker valid: $lifecycle_id -> $handler_key" \
    || fail "program recovery handler blocker invalid: $lifecycle_id -> $handler_key"
  if program_blocker_non_recoverable "$handler_key"; then
    fail "program recovery handler cannot target non-recoverable blocker: $lifecycle_id -> $handler_key"
  fi

  validate_recovery_object_keys "$contract" ".program.recovery_policy.handlers.\"$handler_key\"" "$lifecycle_id handler $handler_key"

  recovery_route_id="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".recovery_route_id // \"\"" "$contract" 2>/dev/null || true)"
  if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]]; then
    valid_program_id "$recovery_route_id" \
      && pass "program recovery handler route id valid: $lifecycle_id $handler_key -> $recovery_route_id" \
      || fail "program recovery handler route id invalid: $lifecycle_id $handler_key -> $recovery_route_id"
  fi

  handler_attempts="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".max_attempts // \"\"" "$contract" 2>/dev/null || true)"
  if [[ -n "$handler_attempts" && "$handler_attempts" != "null" ]]; then
    [[ "$handler_attempts" =~ ^[0-9]+$ && "$handler_attempts" -le 10 ]] \
      && pass "program recovery handler attempts valid: $lifecycle_id -> $handler_key" \
      || fail "program recovery handler attempts invalid: $lifecycle_id -> $handler_key"
  fi

  if yq -e ".program.recovery_policy.handlers.\"$handler_key\" | has(\"replan_after_attempt\")" "$contract" >/dev/null 2>&1; then
    handler_replan="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".replan_after_attempt | tostring" "$contract" 2>/dev/null || true)"
    [[ "$handler_replan" == "true" || "$handler_replan" == "false" ]] \
      && pass "program recovery handler replan flag valid: $lifecycle_id -> $handler_key" \
      || fail "program recovery handler replan flag invalid: $lifecycle_id -> $handler_key"
  fi

  if yq -e ".program.recovery_policy.handlers.\"$handler_key\" | has(\"human_required\")" "$contract" >/dev/null 2>&1; then
    handler_approval="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".human_required | tostring" "$contract" 2>/dev/null || true)"
    [[ "$handler_approval" == "true" || "$handler_approval" == "false" ]] \
      && pass "program recovery handler approval flag valid: $lifecycle_id -> $handler_key" \
      || fail "program recovery handler approval flag invalid: $lifecycle_id -> $handler_key"
  fi

  recipe_dispatch_count="$(yq -r "[.program.recovery_policy.recipes[]? | select(.blocker_class == \"$handler_key\") | select(((.recovery_route_id // \"\") != \"\") or ((.recovery_action_id // \"\") != \"\"))] | length" "$contract" 2>/dev/null || echo 0)"
  if program_blocker_non_recoverable "$handler_key" \
    || program_blocker_unsafe "$handler_key" \
    || program_blocker_human_required "$handler_key" \
    || program_blocker_dependency_wait "$handler_key" \
    || program_blocker_runtime_child_route "$handler_key" \
    || [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]] \
    || [[ "$recipe_dispatch_count" =~ ^[0-9]+$ && "$recipe_dispatch_count" -gt 0 ]]; then
    pass "program recovery handler dispatchability modeled: $lifecycle_id -> $handler_key"
  else
    fail "program recovery handler lacks route/action/wait/runtime dispatch: $lifecycle_id -> $handler_key"
  fi
}

validate_program_recovery_recipe() {
  local contract="$1" lifecycle_id="$2" recipe_index="$3"
  local label blocker idempotency approval retry_budget dependent_handling replan_behavior recovery_route_id recovery_action_id
  local validation validation_count validation_index precondition_count unique_precondition_count unique_validation_count
  local zone_count zone_index zone artifact_count artifact_index artifact operation_class required_flag approval_zone_count approval_zone_index approval_zone

  label="$lifecycle_id recipe[$recipe_index]"
  yq -e ".program.recovery_policy.recipes[$recipe_index] | tag == \"!!map\"" "$contract" >/dev/null 2>&1 \
    && pass "program recovery recipe is map: $label" \
    || fail "program recovery recipe must be a map: $label"
  validate_recovery_object_keys "$contract" ".program.recovery_policy.recipes[$recipe_index]" "$label"

  for field in blocker_class idempotency_class human_required retry_budget dependent_handling post_attempt_validation replan_behavior; do
    yq -e ".program.recovery_policy.recipes[$recipe_index] | has(\"$field\")" "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipe field declared: $label -> $field" \
      || fail "program recovery recipe field missing: $label -> $field"
  done

  blocker="$(yq -r ".program.recovery_policy.recipes[$recipe_index].blocker_class // \"\"" "$contract" 2>/dev/null || true)"
  valid_program_blocker_class "$blocker" \
    && pass "program recovery recipe blocker valid: $label -> $blocker" \
    || fail "program recovery recipe blocker invalid: $label -> $blocker"

  recovery_route_id="$(yq -r ".program.recovery_policy.recipes[$recipe_index].recovery_route_id // \"\"" "$contract" 2>/dev/null || true)"
  if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]]; then
    valid_program_id "$recovery_route_id" \
      && pass "program recovery recipe route id valid: $label -> $recovery_route_id" \
      || fail "program recovery recipe route id invalid: $label -> $recovery_route_id"
  fi
  recovery_action_id="$(yq -r ".program.recovery_policy.recipes[$recipe_index].recovery_action_id // \"\"" "$contract" 2>/dev/null || true)"
  if [[ -n "$recovery_action_id" && "$recovery_action_id" != "null" ]]; then
    valid_program_recovery_action_id "$recovery_action_id" \
      && pass "program recovery recipe action id valid: $label -> $recovery_action_id" \
      || fail "program recovery recipe action id invalid: $label -> $recovery_action_id"
  fi
  if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" && -n "$recovery_action_id" && "$recovery_action_id" != "null" ]]; then
    fail "program recovery recipe must not declare both route and action: $label"
  else
    pass "program recovery recipe route/action exclusivity valid: $label"
  fi

  if yq -e ".program.recovery_policy.recipes[$recipe_index].preconditions" "$contract" >/dev/null 2>&1; then
    yq -e ".program.recovery_policy.recipes[$recipe_index].preconditions | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipe preconditions sequence valid: $label" \
      || fail "program recovery recipe preconditions must be a sequence: $label"
    precondition_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].preconditions // []) | length" "$contract" 2>/dev/null || echo 0)"
    unique_precondition_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].preconditions // [] | unique) | length" "$contract" 2>/dev/null || echo 0)"
    [[ "$precondition_count" == "$unique_precondition_count" ]] \
      && pass "program recovery recipe preconditions unique: $label" \
      || fail "program recovery recipe preconditions duplicate: $label"
    while IFS= read -r validation; do
      if [[ -z "$validation" ]]; then
        fail "program recovery recipe precondition empty: $label"
      elif valid_program_recovery_precondition "$validation"; then
        pass "program recovery recipe precondition valid: $label -> $validation"
      else
        fail "program recovery recipe precondition invalid: $label -> $validation"
      fi
    done < <(yq -r ".program.recovery_policy.recipes[$recipe_index].preconditions[]? // \"\"" "$contract" 2>/dev/null || true)
  fi

  idempotency="$(yq -r ".program.recovery_policy.recipes[$recipe_index].idempotency_class // \"\"" "$contract" 2>/dev/null || true)"
  valid_program_recovery_idempotency_class "$idempotency" \
    && pass "program recovery recipe idempotency valid: $label -> $idempotency" \
    || fail "program recovery recipe idempotency invalid: $label -> $idempotency"

  approval="$(yq -r ".program.recovery_policy.recipes[$recipe_index].human_required | tostring" "$contract" 2>/dev/null || true)"
  [[ "$approval" == "true" || "$approval" == "false" ]] \
    && pass "program recovery recipe approval flag valid: $label" \
    || fail "program recovery recipe approval flag invalid: $label"

  if yq -e ".program.recovery_policy.recipes[$recipe_index].allowed_authority_zones" "$contract" >/dev/null 2>&1; then
    yq -e ".program.recovery_policy.recipes[$recipe_index].allowed_authority_zones | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipe authority zones sequence valid: $label" \
      || fail "program recovery recipe authority zones must be a sequence: $label"
  fi
  zone_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].allowed_authority_zones // []) | length" "$contract" 2>/dev/null || echo 0)"
  for ((zone_index=0; zone_index<zone_count; zone_index++)); do
    zone="$(yq -r ".program.recovery_policy.recipes[$recipe_index].allowed_authority_zones[$zone_index] // \"\"" "$contract" 2>/dev/null || true)"
    valid_authority_zone "$zone" \
      && pass "program recovery recipe authority zone valid: $label -> $zone" \
      || fail "program recovery recipe authority zone invalid: $label -> $zone"
    if [[ "$approval" == "false" && ( "$zone" == "octon-authored-governance" || "$zone" == "protected-or-external" ) ]]; then
      fail "approval-free recovery recipe must not allow durable/protected authority zone: $label -> $zone"
    fi
  done

  if yq -e ".program.recovery_policy.recipes[$recipe_index].allowed_artifact_classes" "$contract" >/dev/null 2>&1; then
    yq -e ".program.recovery_policy.recipes[$recipe_index].allowed_artifact_classes | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipe artifact classes sequence valid: $label" \
      || fail "program recovery recipe artifact classes must be a sequence: $label"
  fi
  artifact_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].allowed_artifact_classes // []) | length" "$contract" 2>/dev/null || echo 0)"
  for ((artifact_index=0; artifact_index<artifact_count; artifact_index++)); do
    artifact="$(yq -r ".program.recovery_policy.recipes[$recipe_index].allowed_artifact_classes[$artifact_index] // \"\"" "$contract" 2>/dev/null || true)"
    valid_authority_artifact_class "$artifact" \
      && pass "program recovery recipe artifact class valid: $label -> $artifact" \
      || fail "program recovery recipe artifact class invalid: $label -> $artifact"
    if [[ "$approval" == "false" && ( "$artifact" == "authored-governance" || "$artifact" == "protected-human-or-external" || "$artifact" == "unknown" ) ]]; then
      fail "approval-free recovery recipe must not allow durable/protected artifact class: $label -> $artifact"
    fi
  done

  operation_class="$(yq -r ".program.recovery_policy.recipes[$recipe_index].operation_class // \"\"" "$contract" 2>/dev/null || true)"
  if [[ -n "$operation_class" && "$operation_class" != "null" ]]; then
    valid_authority_operation_class "$operation_class" \
      && pass "program recovery recipe operation class valid: $label -> $operation_class" \
      || fail "program recovery recipe operation class invalid: $label -> $operation_class"
    if [[ "$approval" == "false" && ( "$operation_class" == "durable-authority-mutation" || "$operation_class" == "protected-artifact-mutation" ) ]]; then
      fail "approval-free recovery recipe must not allow durable/protected operation class: $label -> $operation_class"
    fi
  fi

  for required_flag in requires_run_binding requires_declared_write_scope requires_zone_evidence; do
    if yq -e ".program.recovery_policy.recipes[$recipe_index] | has(\"$required_flag\")" "$contract" >/dev/null 2>&1; then
      local flag_value
      flag_value="$(yq -r ".program.recovery_policy.recipes[$recipe_index].$required_flag | tostring" "$contract" 2>/dev/null || true)"
      [[ "$flag_value" == "true" || "$flag_value" == "false" ]] \
        && pass "program recovery recipe authority flag valid: $label -> $required_flag" \
        || fail "program recovery recipe authority flag invalid: $label -> $required_flag"
    fi
  done

  if yq -e ".program.recovery_policy.recipes[$recipe_index].human_required_for_zones" "$contract" >/dev/null 2>&1; then
    yq -e ".program.recovery_policy.recipes[$recipe_index].human_required_for_zones | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipe authority-ambiguity zones sequence valid: $label" \
      || fail "program recovery recipe authority-ambiguity zones must be a sequence: $label"
  fi
  approval_zone_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].human_required_for_zones // []) | length" "$contract" 2>/dev/null || echo 0)"
  for ((approval_zone_index=0; approval_zone_index<approval_zone_count; approval_zone_index++)); do
    approval_zone="$(yq -r ".program.recovery_policy.recipes[$recipe_index].human_required_for_zones[$approval_zone_index] // \"\"" "$contract" 2>/dev/null || true)"
    valid_authority_zone "$approval_zone" \
      && pass "program recovery recipe authority-ambiguity zone valid: $label -> $approval_zone" \
      || fail "program recovery recipe authority-ambiguity zone invalid: $label -> $approval_zone"
  done

  if [[ "$approval" == "false" ]]; then
    [[ "$zone_count" =~ ^[0-9]+$ && "$zone_count" -gt 0 ]] \
      && pass "approval-free recovery recipe declares authority zones: $label" \
      || fail "approval-free recovery recipe must declare allowed_authority_zones: $label"
    [[ "$artifact_count" =~ ^[0-9]+$ && "$artifact_count" -gt 0 ]] \
      && pass "approval-free recovery recipe declares artifact classes: $label" \
      || fail "approval-free recovery recipe must declare allowed_artifact_classes: $label"
    [[ -n "$operation_class" && "$operation_class" != "null" ]] \
      && pass "approval-free recovery recipe declares operation class: $label" \
      || fail "approval-free recovery recipe must declare operation_class: $label"
  fi

  retry_budget="$(yq -r ".program.recovery_policy.recipes[$recipe_index].retry_budget // \"\"" "$contract" 2>/dev/null || true)"
  [[ "$retry_budget" =~ ^[0-9]+$ && "$retry_budget" -le 10 ]] \
    && pass "program recovery recipe retry budget valid: $label -> $retry_budget" \
    || fail "program recovery recipe retry budget invalid: $label -> $retry_budget"

  dependent_handling="$(yq -r ".program.recovery_policy.recipes[$recipe_index].dependent_handling // \"\"" "$contract" 2>/dev/null || true)"
  valid_program_recovery_dependent_handling "$dependent_handling" \
    && pass "program recovery recipe dependent handling valid: $label -> $dependent_handling" \
    || fail "program recovery recipe dependent handling invalid: $label -> $dependent_handling"

  yq -e ".program.recovery_policy.recipes[$recipe_index].post_attempt_validation | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
    && pass "program recovery recipe post-attempt validation sequence valid: $label" \
    || fail "program recovery recipe post-attempt validation must be a sequence: $label"
  validation_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].post_attempt_validation // []) | length" "$contract" 2>/dev/null || echo 0)"
  unique_validation_count="$(yq -r "(.program.recovery_policy.recipes[$recipe_index].post_attempt_validation // [] | unique) | length" "$contract" 2>/dev/null || echo 0)"
  [[ "$validation_count" == "$unique_validation_count" ]] \
    && pass "program recovery recipe post-attempt validations unique: $label" \
    || fail "program recovery recipe post-attempt validations duplicate: $label"
  for ((validation_index=0; validation_index<validation_count; validation_index++)); do
    validation="$(yq -r ".program.recovery_policy.recipes[$recipe_index].post_attempt_validation[$validation_index] // \"\"" "$contract" 2>/dev/null || true)"
    valid_program_recovery_post_attempt_validation "$validation" \
      && pass "program recovery recipe post-attempt validation valid: $label -> $validation" \
      || fail "program recovery recipe post-attempt validation invalid: $label -> $validation"
  done

  replan_behavior="$(yq -r ".program.recovery_policy.recipes[$recipe_index].replan_behavior // \"\"" "$contract" 2>/dev/null || true)"
  valid_program_recovery_replan_behavior "$replan_behavior" \
    && pass "program recovery recipe replan behavior valid: $label -> $replan_behavior" \
    || fail "program recovery recipe replan behavior invalid: $label -> $replan_behavior"

  if program_blocker_non_recoverable "$blocker"; then
    [[ "$idempotency" == "non-recoverable" ]] \
      && pass "non-recoverable recipe declares non-recoverable idempotency: $label" \
      || fail "non-recoverable recipe must declare non-recoverable idempotency: $label"
    [[ "$retry_budget" == "0" ]] \
      && pass "non-recoverable recipe retry budget is zero: $label" \
      || fail "non-recoverable recipe retry budget must be zero: $label"
    [[ "$dependent_handling" == "fail-closed" ]] \
      && pass "non-recoverable recipe dependent handling fail-closed: $label" \
      || fail "non-recoverable recipe dependent handling must be fail-closed: $label"
    [[ -z "$recovery_route_id" || "$recovery_route_id" == "null" ]] \
      && pass "non-recoverable recipe has no recovery route: $label" \
      || fail "non-recoverable recipe must not declare recovery_route_id: $label"
    [[ -z "$recovery_action_id" || "$recovery_action_id" == "null" ]] \
      && pass "non-recoverable recipe has no recovery action: $label" \
      || fail "non-recoverable recipe must not declare recovery_action_id: $label"
  elif program_blocker_unsafe "$blocker"; then
    valid_program_recovery_safe_idempotency_class "$idempotency" \
      && pass "unsafe repair recipe idempotency is safe-unattended: $label -> $idempotency" \
      || fail "unsafe repair recipe must declare safe-unattended idempotency: $label"
    [[ "$validation_count" =~ ^[0-9]+$ && "$validation_count" -gt 0 ]] \
      && pass "unsafe repair recipe declares post-attempt validation: $label" \
      || fail "unsafe repair recipe must declare post-attempt validation: $label"
  elif program_blocker_human_required "$blocker"; then
    [[ "$retry_budget" == "0" ]] \
      && pass "human-required recovery recipe retry budget is zero: $label" \
      || fail "human-required recovery recipe retry budget must be zero: $label"
    [[ -z "$recovery_route_id" || "$recovery_route_id" == "null" ]] \
      && pass "human-required recovery recipe has no recovery route: $label" \
      || fail "human-required recovery recipe must not declare recovery_route_id: $label"
    [[ -z "$recovery_action_id" || "$recovery_action_id" == "null" ]] \
      && pass "human-required recovery recipe has no recovery action: $label" \
      || fail "human-required recovery recipe must not declare recovery_action_id: $label"
    pass "human-required recovery recipe dispatchability is fail-closed: $label"
  elif program_blocker_dependency_wait "$blocker"; then
    pass "dependency-wait recovery recipe dispatchability modeled: $label"
  elif program_blocker_runtime_child_route "$blocker"; then
    yq -e ".program.recovery_policy.recipes[$recipe_index].preconditions[]? | select(. == \"selected-route-present\")" "$contract" >/dev/null 2>&1 \
      && pass "runtime child route recovery recipe requires selected route: $label" \
      || fail "runtime child route recovery recipe must require selected-route-present: $label"
  else
    if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]] || [[ -n "$recovery_action_id" && "$recovery_action_id" != "null" ]]; then
      pass "recoverable recovery recipe dispatchability modeled: $label"
    else
      fail "recoverable recovery recipe lacks route/action/wait/runtime dispatch: $label"
    fi
  fi
}

validate_program_recovery_policy() {
  local contract="$1" lifecycle_id="$2"
  local handler_key recipe_count recipe_index

  while IFS= read -r handler_key; do
    [[ -n "$handler_key" ]] || continue
    validate_program_recovery_handler "$contract" "$lifecycle_id" "$handler_key"
  done < <(yq -r '.program.recovery_policy.handlers // {} | keys[]?' "$contract" 2>/dev/null || true)

  recipe_count="$(yq -r '(.program.recovery_policy.recipes // []) | length' "$contract" 2>/dev/null || echo 0)"
  if yq -e '.program.recovery_policy.recipes' "$contract" >/dev/null 2>&1; then
    yq -e '.program.recovery_policy.recipes | tag == "!!seq"' "$contract" >/dev/null 2>&1 \
      && pass "program recovery recipes sequence valid: $lifecycle_id" \
      || fail "program recovery recipes must be a sequence: $lifecycle_id"
  fi
  for ((recipe_index=0; recipe_index<recipe_count; recipe_index++)); do
    validate_program_recovery_recipe "$contract" "$lifecycle_id" "$recipe_index"
  done
}

validate_program_closeout_policy() {
  local contract="$1" lifecycle_id="$2"
  local req_count req_index outcome receipt_count receipt_index receipt_id field_count field_index field_name field_value

  if ! yq -e '.program.closeout_policy' "$contract" >/dev/null 2>&1; then
    return 0
  fi
  if yq -e '.program.closeout_policy.terminal_child_receipt_requirements' "$contract" >/dev/null 2>&1; then
    yq -e '.program.closeout_policy.terminal_child_receipt_requirements | tag == "!!seq"' "$contract" >/dev/null 2>&1 \
      && pass "program closeout terminal child receipt requirements sequence valid: $lifecycle_id" \
      || fail "program closeout terminal child receipt requirements must be a sequence: $lifecycle_id"
  fi
  req_count="$(yq -r '(.program.closeout_policy.terminal_child_receipt_requirements // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((req_index=0; req_index<req_count; req_index++)); do
    outcome="$(yq -r ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].outcome_id // \"\"" "$contract" 2>/dev/null || true)"
    valid_program_id "$outcome" \
      && pass "program closeout terminal outcome requirement id valid: $lifecycle_id -> $outcome" \
      || fail "program closeout terminal outcome requirement id invalid: $lifecycle_id -> $outcome"
    yq -e ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipts | tag == \"!!seq\" and length > 0" "$contract" >/dev/null 2>&1 \
      && pass "program closeout required child receipts declared: $lifecycle_id -> $outcome" \
      || fail "program closeout required child receipts missing: $lifecycle_id -> $outcome"
    receipt_count="$(yq -r "(.program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipts // []) | length" "$contract" 2>/dev/null || echo 0)"
    for ((receipt_index=0; receipt_index<receipt_count; receipt_index++)); do
      receipt_id="$(yq -r ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipts[$receipt_index] // \"\"" "$contract" 2>/dev/null || true)"
      valid_program_id "$receipt_id" \
        && pass "program closeout child receipt id valid: $lifecycle_id $outcome -> $receipt_id" \
        || fail "program closeout child receipt id invalid: $lifecycle_id $outcome -> $receipt_id"
    done
    if yq -e ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals" "$contract" >/dev/null 2>&1; then
      yq -e ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals | tag == \"!!seq\"" "$contract" >/dev/null 2>&1 \
        && pass "program closeout child receipt field checks sequence valid: $lifecycle_id -> $outcome" \
        || fail "program closeout child receipt field checks must be a sequence: $lifecycle_id -> $outcome"
    fi
    field_count="$(yq -r "(.program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals // []) | length" "$contract" 2>/dev/null || echo 0)"
    for ((field_index=0; field_index<field_count; field_index++)); do
      receipt_id="$(yq -r ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals[$field_index].receipt_id // \"\"" "$contract" 2>/dev/null || true)"
      field_name="$(yq -r ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals[$field_index].field // \"\"" "$contract" 2>/dev/null || true)"
      field_value="$(yq -r ".program.closeout_policy.terminal_child_receipt_requirements[$req_index].required_receipt_field_equals[$field_index].value // \"\"" "$contract" 2>/dev/null || true)"
      valid_program_id "$receipt_id" \
        && pass "program closeout child receipt field check receipt valid: $lifecycle_id $outcome -> $receipt_id" \
        || fail "program closeout child receipt field check receipt invalid: $lifecycle_id $outcome -> $receipt_id"
      [[ "$field_name" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]] \
        && pass "program closeout child receipt field check field valid: $lifecycle_id $outcome -> $field_name" \
        || fail "program closeout child receipt field check field invalid: $lifecycle_id $outcome -> $field_name"
      [[ -n "$field_value" && "$field_value" != "null" ]] \
        && pass "program closeout child receipt field check value declared: $lifecycle_id $outcome -> $receipt_id.$field_name" \
        || fail "program closeout child receipt field check value missing: $lifecycle_id $outcome -> $receipt_id.$field_name"
    done
  done
}

validate_program_section() {
  local contract="$1" lifecycle_id="$2"
  local registry_path child_default mode max_attempts serialize_conflicts boundary_value key mode_count index atomic_seen

  if ! yq -e '.program' "$contract" >/dev/null 2>&1; then
    return 0
  fi

  registry_path="$(yq -r '.program.child_registry_path // ""' "$contract" 2>/dev/null || true)"
  valid_rel_path "$registry_path" \
    && pass "program child registry path valid: $lifecycle_id" \
    || fail "program child registry path invalid: $lifecycle_id"

  child_default="$(yq -r '.program.child_lifecycle_id_default // ""' "$contract" 2>/dev/null || true)"
  if [[ -n "$child_default" && "$child_default" != "null" ]]; then
    [[ "$child_default" =~ ^[a-z][a-z0-9-]*$ ]] \
      && pass "program child lifecycle default valid: $lifecycle_id -> $child_default" \
      || fail "program child lifecycle default invalid: $lifecycle_id -> $child_default"
  fi

  yq -e '.program.supported_execution_modes | tag == "!!seq" and length > 0' "$contract" >/dev/null 2>&1 \
    && pass "program supported execution modes declared: $lifecycle_id" \
    || fail "program supported execution modes missing: $lifecycle_id"
  mode_count="$(yq -r '(.program.supported_execution_modes // []) | length' "$contract" 2>/dev/null || echo 0)"
  atomic_seen=0
  for ((index=0; index<mode_count; index++)); do
    mode="$(yq -r ".program.supported_execution_modes[$index] // \"\"" "$contract" 2>/dev/null || true)"
    if valid_program_execution_mode "$mode"; then
      pass "program supported execution mode valid: $lifecycle_id -> $mode"
      [[ "$mode" == "program-atomic" ]] && atomic_seen=1
    else
      fail "program supported execution mode invalid: $lifecycle_id -> $mode"
    fi
  done
  if [[ "$atomic_seen" -eq 1 ]]; then
    [[ "$(yq -r '.program.atomic_policy.eligibility // ""' "$contract" 2>/dev/null || true)" == "explicit-route-opt-in" ]] \
      && pass "program atomic policy explicit opt-in: $lifecycle_id" \
      || fail "program-atomic requires atomic_policy.eligibility explicit-route-opt-in: $lifecycle_id"
  fi

  max_attempts="$(yq -r '.program.recovery_policy.max_recovery_attempts // ""' "$contract" 2>/dev/null || true)"
  [[ "$max_attempts" =~ ^[0-9]+$ && "$max_attempts" -le 10 ]] \
    && pass "program recovery attempt limit valid: $lifecycle_id" \
    || fail "program recovery attempt limit invalid: $lifecycle_id"
  serialize_conflicts="$(yq -r '.program.recovery_policy.serialize_write_scope_conflicts // ""' "$contract" 2>/dev/null || true)"
  [[ "$serialize_conflicts" == "true" || "$serialize_conflicts" == "false" ]] \
    && pass "program write-scope conflict policy valid: $lifecycle_id" \
    || fail "program write-scope conflict policy invalid: $lifecycle_id"
  validate_program_recovery_policy "$contract" "$lifecycle_id"
  validate_program_closeout_policy "$contract" "$lifecycle_id"

  for key in parent_coordinates_only child_receipts_remain_child_owned child_promotion_targets_remain_child_owned; do
    boundary_value="$(yq -r ".program.authority_boundaries.${key} // \"\"" "$contract" 2>/dev/null || true)"
    [[ "$boundary_value" == "true" ]] \
      && pass "program authority boundary declared: $lifecycle_id -> $key" \
      || fail "program authority boundary must be true: $lifecycle_id -> $key"
  done
}

validate_execution_strategy() {
  local contract="$1" lifecycle_id="$2"
  local declared has_program resolved

  declared="$(yq -r '.execution_strategy // ""' "$contract" 2>/dev/null || true)"
  has_program=0
  yq -e '.program' "$contract" >/dev/null 2>&1 && has_program=1

  if [[ -n "$declared" && "$declared" != "null" ]]; then
    if valid_lifecycle_execution_strategy "$declared"; then
      pass "lifecycle execution strategy valid: $lifecycle_id -> $declared"
    else
      fail "lifecycle execution strategy invalid: $lifecycle_id -> $declared"
      return
    fi
    resolved="$declared"
  elif [[ "$has_program" -eq 1 ]]; then
    resolved="orchestrated-replan-loop"
    pass "lifecycle execution strategy inferred: $lifecycle_id -> $resolved"
  else
    resolved="route-progression"
    pass "lifecycle execution strategy inferred: $lifecycle_id -> $resolved"
  fi

  if [[ "$has_program" -eq 1 && "$resolved" != "orchestrated-replan-loop" ]]; then
    fail "program lifecycle must use execution_strategy orchestrated-replan-loop: $lifecycle_id"
  elif [[ "$has_program" -eq 1 ]]; then
    pass "program lifecycle execution strategy compatible: $lifecycle_id"
  fi

  if [[ "$has_program" -eq 0 && "$resolved" == "orchestrated-replan-loop" ]]; then
    fail "orchestrated-replan-loop requires a program section: $lifecycle_id"
  elif [[ "$has_program" -eq 0 ]]; then
    pass "packet lifecycle execution strategy compatible: $lifecycle_id"
  fi
}

validate_program_route_references() {
  local contract="$1" lifecycle_id="$2" contract_route_ids="$3"
  local handler_key recovery_route_id
  while IFS= read -r handler_key; do
    [[ -n "$handler_key" ]] || continue
    recovery_route_id="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".recovery_route_id // \"\"" "$contract" 2>/dev/null || true)"
    if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]]; then
      id_list_contains "$recovery_route_id" "$contract_route_ids" \
        && pass "program recovery handler route exists: $lifecycle_id $handler_key -> $recovery_route_id" \
        || fail "program recovery handler route missing: $lifecycle_id $handler_key -> $recovery_route_id"
    fi
  done < <(yq -r '.program.recovery_policy.handlers // {} | keys[]?' "$contract" 2>/dev/null || true)
  local recipe_index recipe_count recipe_blocker
  recipe_count="$(yq -r '(.program.recovery_policy.recipes // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((recipe_index=0; recipe_index<recipe_count; recipe_index++)); do
    recipe_blocker="$(yq -r ".program.recovery_policy.recipes[$recipe_index].blocker_class // \"\"" "$contract" 2>/dev/null || true)"
    recovery_route_id="$(yq -r ".program.recovery_policy.recipes[$recipe_index].recovery_route_id // \"\"" "$contract" 2>/dev/null || true)"
    if [[ -n "$recovery_route_id" && "$recovery_route_id" != "null" ]]; then
      id_list_contains "$recovery_route_id" "$contract_route_ids" \
        && pass "program recovery recipe route exists: $lifecycle_id $recipe_blocker -> $recovery_route_id" \
        || fail "program recovery recipe route missing: $lifecycle_id $recipe_blocker -> $recovery_route_id"
    fi
  done
}

validate_contract() {
  local contract="$1" rel pack_id owner lifecycle_id routing_contract command_manifest skill_manifest skill_registry workflows_manifest
  local route_ids contract_route_ids command_ids skill_ids prompt_set_ids workflow_ids validator_ids gate_ids receipt_ids input_binding_ids
  local route_count index route_id route_type command_id skill_id prompt_set_id validator_id receipt_id loop_id max_iterations target_manifest allowed_statuses

  rel="$(rel_from_root "$contract")"
  pack_id="$(pack_id_for_contract "$rel")"
  if [[ -z "$pack_id" ]]; then
    fail "lifecycle contract must live under an extension context path: $rel"
    return
  fi

  [[ -f "$contract" ]] || {
    fail "lifecycle contract exists: $rel"
    return
  }
  yq -e '.' "$contract" >/dev/null 2>&1 && pass "lifecycle contract parses: $rel" || {
    fail "lifecycle contract parses: $rel"
    return
  }
  [[ "$(yq -r '.schema_version // ""' "$contract")" == "octon-extension-lifecycle-contract-v1" ]] \
    && pass "lifecycle schema version valid: $pack_id" \
    || fail "lifecycle schema version invalid: $pack_id"

  owner="$(yq -r '.owner_extension // ""' "$contract")"
  lifecycle_id="$(yq -r '.lifecycle_id // ""' "$contract")"
  [[ "$owner" == "$pack_id" ]] && pass "owner_extension matches pack id: $pack_id" || fail "owner_extension must match pack id: $pack_id"
  [[ "$lifecycle_id" =~ ^[a-z][a-z0-9-]*$ ]] && pass "lifecycle_id valid: $lifecycle_id" || fail "lifecycle_id invalid: $lifecycle_id"
  [[ "$(yq -r '.version // ""' "$contract")" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && pass "lifecycle version valid: $lifecycle_id" || fail "lifecycle version invalid: $lifecycle_id"
  validate_execution_strategy "$contract" "$lifecycle_id"
  validate_program_section "$contract" "$lifecycle_id"

  target_manifest="$(yq -r '.target.manifest_path // ""' "$contract")"
  allowed_statuses="$(load_ids "$contract" '.target.allowed_statuses[]?')"
  valid_rel_path "$target_manifest" && pass "target manifest path is relative: $lifecycle_id" || fail "target manifest path invalid: $lifecycle_id"
  yq -e '.target.allowed_statuses | tag == "!!seq" and length > 0' "$contract" >/dev/null 2>&1 \
    && pass "target allowed statuses declared: $lifecycle_id" \
    || fail "target allowed statuses missing: $lifecycle_id"

  yq -e '.states | tag == "!!seq" and length > 0' "$contract" >/dev/null 2>&1 && pass "states declared: $lifecycle_id" || fail "states missing: $lifecycle_id"
  yq -e '.routes | tag == "!!seq" and length > 0' "$contract" >/dev/null 2>&1 && pass "routes declared: $lifecycle_id" || fail "routes missing: $lifecycle_id"
  yq -e '.receipts | tag == "!!seq" and length > 0' "$contract" >/dev/null 2>&1 && pass "receipts declared: $lifecycle_id" || fail "receipts missing: $lifecycle_id"
  while IFS= read -r binding_source; do
    [[ -n "$binding_source" ]] || continue
    if [[ "$binding_source" == "lifecycle.target" \
      || "$binding_source" =~ ^run\.input\.[A-Za-z0-9_-]+$ \
      || "$binding_source" =~ ^receipt\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
      pass "input binding source valid: $binding_source"
    else
      fail "input binding source invalid: $binding_source"
    fi
  done < <(yq -r '.input_bindings // {} | to_entries[]?.value.source // ""' "$contract" 2>/dev/null || true)
  validate_unique_ids "$contract" '.states[]?.state_id' "state"
  validate_unique_ids "$contract" '.routes[]?.route_id' "route"
  validate_unique_ids "$contract" '.receipts[]?.receipt_id' "receipt"
  validate_unique_ids "$contract" '.validators[]?.validator_id' "validator"
  validate_validator_argv "$contract" "$owner"

  routing_contract="$OCTON_DIR/inputs/additive/extensions/$pack_id/context/routing.contract.yml"
  command_manifest="$OCTON_DIR/inputs/additive/extensions/$pack_id/commands/manifest.fragment.yml"
  skill_manifest="$OCTON_DIR/inputs/additive/extensions/$pack_id/skills/manifest.fragment.yml"
  skill_registry="$OCTON_DIR/inputs/additive/extensions/$pack_id/skills/registry.fragment.yml"
  workflows_manifest="$OCTON_DIR/framework/orchestration/runtime/workflows/manifest.yml"

  route_ids="$(load_ids "$routing_contract" '.dispatchers[]?.routes[]?.route_id')"
  command_ids="$(load_ids "$command_manifest" '.commands[]?.id')"
  skill_ids="$(printf '%s\n%s\n' "$(load_ids "$skill_manifest" '.skills[]?.id')" "$(load_ids "$skill_registry" '.skills[]?.id')" | awk 'NF' | LC_ALL=C sort -u)"
  prompt_set_ids="$(find "$OCTON_DIR/inputs/additive/extensions/$pack_id/prompts" -name manifest.yml -type f -print 2>/dev/null | while IFS= read -r prompt_manifest; do yq -r '.prompt_set_id // ""' "$prompt_manifest"; done | awk 'NF' | LC_ALL=C sort -u)"
  workflow_ids="$(load_ids "$workflows_manifest" '.workflows[]?.id')"
  validator_ids="$(load_ids "$contract" '.validators[]?.validator_id')"
  gate_ids="$(load_ids "$contract" '.gates[]?.gate_id')"
  receipt_ids="$(load_ids "$contract" '.receipts[]?.receipt_id')"
  contract_route_ids="$(load_ids "$contract" '.routes[]?.route_id')"
  input_binding_ids="$(load_ids "$contract" '.input_bindings // {} | keys[]?')"
  validate_program_route_references "$contract" "$lifecycle_id" "$contract_route_ids"

  local terminal_count outcome_id
  terminal_count="$(yq -r '(.terminal_outcomes // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<terminal_count; index++)); do
    outcome_id="$(yq -r ".terminal_outcomes[$index].outcome_id // \"\"" "$contract" 2>/dev/null || true)"
    if yq -e ".terminal_outcomes[$index].when" "$contract" >/dev/null 2>&1; then
      validate_condition_receipt_refs "$contract" ".terminal_outcomes[$index].when" "terminal $outcome_id when" "$receipt_ids"
      validate_condition_path_refs "$contract" ".terminal_outcomes[$index].when" "terminal $outcome_id when"
    fi
  done

  route_count="$(yq -r '.routes | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<route_count; index++)); do
    route_id="$(yq -r ".routes[$index].route_id // \"\"" "$contract")"
    route_type="$(yq -r ".routes[$index].route_type // \"\"" "$contract")"
    case "$route_type" in
      extension)
        id_list_contains "$route_id" "$route_ids" && pass "extension route exists: $route_id" || fail "extension route missing: $route_id"
        ;;
      workflow)
        id_list_contains "$route_id" "$workflow_ids" && pass "workflow route exists: $route_id" || fail "workflow route missing: $route_id"
        ;;
      *)
        fail "route_type invalid for $route_id"
        ;;
    esac
    command_id="$(yq -r ".routes[$index].command_id // \"\"" "$contract")"
    if [[ -n "$command_id" && "$command_id" != "null" ]]; then
      id_list_contains "$command_id" "$command_ids" && pass "route command exists: $route_id -> $command_id" || fail "route command missing: $route_id -> $command_id"
    fi
    skill_id="$(yq -r ".routes[$index].skill_id // \"\"" "$contract")"
    if [[ -n "$skill_id" && "$skill_id" != "null" ]]; then
      id_list_contains "$skill_id" "$skill_ids" && pass "route skill exists: $route_id -> $skill_id" || fail "route skill missing: $route_id -> $skill_id"
    fi
    prompt_set_id="$(yq -r ".routes[$index].prompt_set_id // \"\"" "$contract")"
    if [[ -n "$prompt_set_id" && "$prompt_set_id" != "null" ]]; then
      id_list_contains "$prompt_set_id" "$prompt_set_ids" && pass "route prompt set exists: $route_id -> $prompt_set_id" || fail "route prompt set missing: $route_id -> $prompt_set_id"
    fi
    if yq -e ".routes[$index].enter_when" "$contract" >/dev/null 2>&1; then
      validate_condition_receipt_refs "$contract" ".routes[$index].enter_when" "route $route_id enter_when" "$receipt_ids"
      validate_condition_path_refs "$contract" ".routes[$index].enter_when" "route $route_id enter_when"
    fi
    while IFS= read -r input_id; do
      [[ -n "$input_id" ]] || continue
      id_list_contains "$input_id" "$input_binding_ids" \
        && pass "route required input binding exists: $route_id -> $input_id" \
        || fail "route required input binding missing: $route_id -> $input_id"
    done < <(yq -r ".routes[$index].required_inputs[]? // \"\"" "$contract" 2>/dev/null || true)
    while IFS= read -r receipt_id; do
      [[ -n "$receipt_id" ]] || continue
      id_list_contains "$receipt_id" "$receipt_ids" \
        && pass "route completion expected receipt exists: $route_id -> $receipt_id" \
        || fail "route completion expected receipt missing: $route_id -> $receipt_id"
    done < <(yq -r ".routes[$index].completion.expected_receipts[]? // \"\"" "$contract" 2>/dev/null || true)
    local expected_path expected_status decision_class safe_delegation replay_class scope_source recovery_policy
    while IFS= read -r expected_path; do
      [[ -n "$expected_path" ]] || continue
      valid_rel_path "$expected_path" \
        && pass "route completion expected path is relative: $route_id -> $expected_path" \
        || fail "route completion expected path invalid: $route_id -> $expected_path"
    done < <(yq -r ".routes[$index].completion.expected_paths[]? // \"\"" "$contract" 2>/dev/null || true)
    expected_status="$(yq -r ".routes[$index].completion.expected_manifest_status // \"\"" "$contract" 2>/dev/null || true)"
    if [[ -n "$expected_status" && "$expected_status" != "null" ]]; then
      id_list_contains "$expected_status" "$allowed_statuses" \
        && pass "route completion expected manifest status allowed: $route_id -> $expected_status" \
        || fail "route completion expected manifest status invalid: $route_id -> $expected_status"
    fi
    if yq -e ".routes[$index] | has(\"approval\")" "$contract" >/dev/null 2>&1; then
      fail "route legacy approval primitive forbidden: $route_id"
    else
      pass "route legacy approval primitive absent: $route_id"
    fi
    if yq -e ".routes[$index] | has(\"idempotency\")" "$contract" >/dev/null 2>&1; then
      fail "route legacy idempotency primitive forbidden: $route_id"
    else
      pass "route legacy idempotency primitive absent: $route_id"
    fi
    if yq -e ".routes[$index].delegation_contract | tag == \"!!map\"" "$contract" >/dev/null 2>&1; then
      pass "route delegation contract declared: $route_id"
    else
      fail "route delegation contract missing: $route_id"
    fi
    for field in decision_class safe_delegation authority_zones_allowed declared_write_scope_source required_evidence_gates required_receipts_before_dispatch required_receipts_before_completion replay_class automated_recovery_policy human_only_boundaries; do
      yq -e ".routes[$index].delegation_contract | has(\"$field\")" "$contract" >/dev/null 2>&1 \
        && pass "route delegation contract field declared: $route_id -> $field" \
        || fail "route delegation contract field missing: $route_id -> $field"
    done
    decision_class="$(yq -r ".routes[$index].delegation_contract.decision_class // \"\"" "$contract" 2>/dev/null || true)"
    valid_route_delegation_decision_class "$decision_class" \
      && pass "route delegation decision class valid: $route_id -> $decision_class" \
      || fail "route delegation decision class invalid: $route_id -> $decision_class"
    safe_delegation="$(yq -r ".routes[$index].delegation_contract.safe_delegation | tostring" "$contract" 2>/dev/null || true)"
    [[ "$safe_delegation" == "true" || "$safe_delegation" == "false" ]] \
      && pass "route delegation safe flag valid: $route_id" \
      || fail "route delegation safe flag invalid: $route_id"
    scope_source="$(yq -r ".routes[$index].delegation_contract.declared_write_scope_source // \"\"" "$contract" 2>/dev/null || true)"
    valid_route_write_scope_source "$scope_source" \
      && pass "route delegation write scope source valid: $route_id -> $scope_source" \
      || fail "route delegation write scope source invalid: $route_id -> $scope_source"
    replay_class="$(yq -r ".routes[$index].delegation_contract.replay_class // \"\"" "$contract" 2>/dev/null || true)"
    valid_route_replay_class "$replay_class" \
      && pass "route delegation replay class valid: $route_id -> $replay_class" \
      || fail "route delegation replay class invalid: $route_id -> $replay_class"
    recovery_policy="$(yq -r ".routes[$index].delegation_contract.automated_recovery_policy // \"\"" "$contract" 2>/dev/null || true)"
    [[ -n "$recovery_policy" && "$recovery_policy" != "null" ]] \
      && pass "route delegation automated recovery policy declared: $route_id" \
      || fail "route delegation automated recovery policy missing: $route_id"
    local delegation_zone_count delegation_zone_index delegation_zone
    delegation_zone_count="$(yq -r "(.routes[$index].delegation_contract.authority_zones_allowed // []) | length" "$contract" 2>/dev/null || echo 0)"
    [[ "$delegation_zone_count" =~ ^[0-9]+$ && "$delegation_zone_count" -gt 0 ]] \
      && pass "route delegation authority zones declared: $route_id" \
      || fail "route delegation authority zones missing: $route_id"
    for ((delegation_zone_index=0; delegation_zone_index<delegation_zone_count; delegation_zone_index++)); do
      delegation_zone="$(yq -r ".routes[$index].delegation_contract.authority_zones_allowed[$delegation_zone_index] // \"\"" "$contract" 2>/dev/null || true)"
      valid_authority_zone "$delegation_zone" \
        && pass "route delegation authority zone valid: $route_id -> $delegation_zone" \
        || fail "route delegation authority zone invalid: $route_id -> $delegation_zone"
    done
    while IFS= read -r gate_id; do
      [[ -n "$gate_id" ]] || continue
      id_list_contains "$gate_id" "$gate_ids" \
        && pass "route delegation evidence gate exists: $route_id -> $gate_id" \
        || fail "route delegation evidence gate missing: $route_id -> $gate_id"
    done < <(yq -r ".routes[$index].delegation_contract.required_evidence_gates[]? // \"\"" "$contract" 2>/dev/null || true)
    while IFS= read -r receipt_id; do
      [[ -n "$receipt_id" ]] || continue
      id_list_contains "$receipt_id" "$receipt_ids" \
        && pass "route delegation dispatch receipt exists: $route_id -> $receipt_id" \
        || fail "route delegation dispatch receipt missing: $route_id -> $receipt_id"
    done < <(yq -r ".routes[$index].delegation_contract.required_receipts_before_dispatch[]? // \"\"" "$contract" 2>/dev/null || true)
    while IFS= read -r receipt_id; do
      [[ -n "$receipt_id" ]] || continue
      id_list_contains "$receipt_id" "$receipt_ids" \
        && pass "route delegation completion receipt exists: $route_id -> $receipt_id" \
        || fail "route delegation completion receipt missing: $route_id -> $receipt_id"
    done < <(yq -r ".routes[$index].delegation_contract.required_receipts_before_completion[]? // \"\"" "$contract" 2>/dev/null || true)
    local human_boundary_count human_boundary_index human_boundary
    human_boundary_count="$(yq -r "(.routes[$index].delegation_contract.human_only_boundaries // []) | length" "$contract" 2>/dev/null || echo 0)"
    [[ "$human_boundary_count" =~ ^[0-9]+$ && "$human_boundary_count" -gt 0 ]] \
      && pass "route delegation human-only boundaries declared: $route_id" \
      || fail "route delegation human-only boundaries missing: $route_id"
    for ((human_boundary_index=0; human_boundary_index<human_boundary_count; human_boundary_index++)); do
      human_boundary="$(yq -r ".routes[$index].delegation_contract.human_only_boundaries[$human_boundary_index] // \"\"" "$contract" 2>/dev/null || true)"
      valid_human_only_boundary "$human_boundary" \
        && pass "route delegation human-only boundary valid: $route_id -> $human_boundary" \
        || fail "route delegation human-only boundary invalid: $route_id -> $human_boundary"
    done
    if yq -e ".routes[$index].atomic" "$contract" >/dev/null 2>&1; then
      local atomic_ref atomic_label rollback_ref compensation_ref
      for atomic_label in stage_route_id commit_route_id; do
        atomic_ref="$(yq -r ".routes[$index].atomic.${atomic_label} // \"\"" "$contract" 2>/dev/null || true)"
        if [[ -z "$atomic_ref" || "$atomic_ref" == "null" ]]; then
          fail "route atomic $atomic_label missing: $route_id"
        elif [[ "$atomic_ref" == "$route_id" ]]; then
          fail "route atomic $atomic_label self-reference invalid: $route_id"
        elif id_list_contains "$atomic_ref" "$contract_route_ids"; then
          pass "route atomic $atomic_label exists: $route_id -> $atomic_ref"
        else
          fail "route atomic $atomic_label missing route: $route_id -> $atomic_ref"
        fi
      done
      rollback_ref="$(yq -r ".routes[$index].atomic.rollback_route_id // \"\"" "$contract" 2>/dev/null || true)"
      compensation_ref="$(yq -r ".routes[$index].atomic.compensation_route_id // \"\"" "$contract" 2>/dev/null || true)"
      if [[ -z "$rollback_ref" || "$rollback_ref" == "null" ]] && [[ -z "$compensation_ref" || "$compensation_ref" == "null" ]]; then
        fail "route atomic rollback or compensation route missing: $route_id"
      fi
      for atomic_label in rollback_route_id compensation_route_id; do
        atomic_ref="$(yq -r ".routes[$index].atomic.${atomic_label} // \"\"" "$contract" 2>/dev/null || true)"
        [[ -n "$atomic_ref" && "$atomic_ref" != "null" ]] || continue
        if [[ "$atomic_ref" == "$route_id" ]]; then
          fail "route atomic $atomic_label self-reference invalid: $route_id"
        elif id_list_contains "$atomic_ref" "$contract_route_ids"; then
          pass "route atomic $atomic_label exists: $route_id -> $atomic_ref"
        else
          fail "route atomic $atomic_label missing route: $route_id -> $atomic_ref"
        fi
      done
    fi
  done

  local gate_count
  gate_count="$(yq -r '(.gates // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<gate_count; index++)); do
    validator_id="$(yq -r ".gates[$index].validator_id // \"\"" "$contract")"
    id_list_contains "$validator_id" "$validator_ids" && pass "gate validator exists: $validator_id" || fail "gate validator missing: $validator_id"
    while IFS= read -r route_id; do
      [[ -n "$route_id" ]] || continue
      id_list_contains "$route_id" "$contract_route_ids" && pass "gate required route exists: $route_id" || fail "gate required route missing: $route_id"
    done < <(yq -r ".gates[$index].required_before_routes[]? // \"\"" "$contract")
    local on_fail_route_id
    on_fail_route_id="$(yq -r ".gates[$index].on_fail_route_id // \"\"" "$contract")"
    if [[ -n "$on_fail_route_id" && "$on_fail_route_id" != "null" ]]; then
      id_list_contains "$on_fail_route_id" "$contract_route_ids" && pass "gate fallback route exists: $on_fail_route_id" || fail "gate fallback route missing: $on_fail_route_id"
    fi
  done

  local receipt_count receipt_path
  receipt_count="$(yq -r '.receipts | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<receipt_count; index++)); do
    receipt_id="$(yq -r ".receipts[$index].receipt_id // \"\"" "$contract")"
    receipt_path="$(yq -r ".receipts[$index].path // \"\"" "$contract")"
    valid_rel_path "$receipt_path" && pass "receipt path valid: $receipt_id" || fail "receipt path invalid: $receipt_id"
    if yq -e ".receipts[$index].freshness" "$contract" >/dev/null 2>&1; then
      yq -e ".receipts[$index].freshness.digest_command | tag == \"!!seq\" and length > 0" "$contract" >/dev/null 2>&1 \
        && pass "receipt freshness digest command declared: $receipt_id" \
        || fail "receipt freshness digest command invalid: $receipt_id"
      local digest_first digest_second digest_script digest_script_abs
      digest_first="$(yq -r ".receipts[$index].freshness.digest_command[0] // \"\"" "$contract" 2>/dev/null || true)"
      digest_second="$(yq -r ".receipts[$index].freshness.digest_command[1] // \"\"" "$contract" 2>/dev/null || true)"
      case "$digest_first" in
        bash|sh)
          digest_script="$digest_second"
          ;;
        *)
          digest_script="$digest_first"
          ;;
      esac
      if [[ -z "$digest_script" ]]; then
        fail "receipt freshness digest script missing: $receipt_id"
      elif ! valid_rel_path "$digest_script"; then
        fail "receipt freshness digest script path is not repo-relative: $receipt_id"
      else
        case "$digest_script" in
          .octon/framework/assurance/runtime/_ops/scripts/*|.octon/inputs/additive/extensions/"$owner"/validation/*)
            digest_script_abs="$ROOT_DIR/$digest_script"
            [[ -f "$digest_script_abs" ]] && pass "receipt freshness digest script exists: $receipt_id" || fail "receipt freshness digest script missing on disk: $digest_script"
            ;;
          *)
            fail "receipt freshness digest script outside allowed roots: $receipt_id"
            ;;
        esac
      fi
      [[ -n "$(yq -r ".receipts[$index].freshness.digest_field // \"\"" "$contract")" ]] \
        && pass "receipt freshness digest field declared: $receipt_id" \
        || fail "receipt freshness digest field missing: $receipt_id"
    fi
  done

  local loop_count repeat_route_id
  loop_count="$(yq -r '(.loops // []) | length' "$contract" 2>/dev/null || echo 0)"
  for ((index=0; index<loop_count; index++)); do
    loop_id="$(yq -r ".loops[$index].loop_id // \"\"" "$contract")"
    receipt_id="$(yq -r ".loops[$index].receipt_id // \"\"" "$contract")"
    repeat_route_id="$(yq -r ".loops[$index].repeat_route_id // \"\"" "$contract")"
    max_iterations="$(yq -r ".loops[$index].max_iterations // \"\"" "$contract")"
    id_list_contains "$receipt_id" "$receipt_ids" && pass "loop receipt exists: $loop_id" || fail "loop receipt missing: $loop_id"
    id_list_contains "$repeat_route_id" "$(load_ids "$contract" '.routes[]?.route_id')" && pass "loop repeat route exists: $loop_id" || fail "loop repeat route missing: $loop_id"
    [[ "$max_iterations" =~ ^[1-9][0-9]*$ ]] && pass "loop max_iterations bounded: $loop_id" || fail "loop max_iterations invalid: $loop_id"
  done
}

main() {
  local found=0 contract
  while IFS= read -r contract; do
    [[ -n "$contract" ]] || continue
    found=1
    validate_contract "$contract"
  done < <(contract_files)

  if [[ "$found" -eq 0 ]]; then
    warn "no extension lifecycle contracts found"
  fi

  echo "Validation summary: errors=$errors warnings=$warnings"
  [[ "$errors" -eq 0 ]]
}

main "$@"
