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

valid_program_blocker_class() {
  case "$1" in
    approval-required|stale-receipt|target-drift|validation-failed|dependency-blocked|missing-evidence|executor-failed|write-scope-conflict|unsafe-resume|unsupported-mode|authority-boundary-ambiguous)
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
    replay-verify|replan-live-state|receipt-fresh|receipt-freshness|blocker-cleared|authority-boundary-check|aggregate-closeout-check)
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

validate_recovery_object_keys() {
  local contract="$1" expr="$2" label="$3"
  local key
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    case "$key" in
      blocker_class|recovery_route_id|preconditions|idempotency_class|approval_required|retry_budget|dependent_handling|post_attempt_validation|replan_behavior|max_attempts|replan_after_attempt)
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
  local handler_attempts handler_replan handler_approval recovery_route_id

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

  if yq -e ".program.recovery_policy.handlers.\"$handler_key\" | has(\"approval_required\")" "$contract" >/dev/null 2>&1; then
    handler_approval="$(yq -r ".program.recovery_policy.handlers.\"$handler_key\".approval_required | tostring" "$contract" 2>/dev/null || true)"
    [[ "$handler_approval" == "true" || "$handler_approval" == "false" ]] \
      && pass "program recovery handler approval flag valid: $lifecycle_id -> $handler_key" \
      || fail "program recovery handler approval flag invalid: $lifecycle_id -> $handler_key"
  fi
}

validate_program_recovery_recipe() {
  local contract="$1" lifecycle_id="$2" recipe_index="$3"
  local label blocker idempotency approval retry_budget dependent_handling replan_behavior recovery_route_id
  local validation validation_count validation_index precondition_count unique_precondition_count unique_validation_count

  label="$lifecycle_id recipe[$recipe_index]"
  yq -e ".program.recovery_policy.recipes[$recipe_index] | tag == \"!!map\"" "$contract" >/dev/null 2>&1 \
    && pass "program recovery recipe is map: $label" \
    || fail "program recovery recipe must be a map: $label"
  validate_recovery_object_keys "$contract" ".program.recovery_policy.recipes[$recipe_index]" "$label"

  for field in blocker_class idempotency_class approval_required retry_budget dependent_handling post_attempt_validation replan_behavior; do
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
      [[ -n "$validation" ]] \
        && pass "program recovery recipe precondition declared: $label -> $validation" \
        || fail "program recovery recipe precondition empty: $label"
    done < <(yq -r ".program.recovery_policy.recipes[$recipe_index].preconditions[]? // \"\"" "$contract" 2>/dev/null || true)
  fi

  idempotency="$(yq -r ".program.recovery_policy.recipes[$recipe_index].idempotency_class // \"\"" "$contract" 2>/dev/null || true)"
  valid_program_recovery_idempotency_class "$idempotency" \
    && pass "program recovery recipe idempotency valid: $label -> $idempotency" \
    || fail "program recovery recipe idempotency invalid: $label -> $idempotency"

  approval="$(yq -r ".program.recovery_policy.recipes[$recipe_index].approval_required | tostring" "$contract" 2>/dev/null || true)"
  [[ "$approval" == "true" || "$approval" == "false" ]] \
    && pass "program recovery recipe approval flag valid: $label" \
    || fail "program recovery recipe approval flag invalid: $label"

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

  for key in parent_coordinates_only child_receipts_remain_child_owned child_promotion_targets_remain_child_owned; do
    boundary_value="$(yq -r ".program.authority_boundaries.${key} // \"\"" "$contract" 2>/dev/null || true)"
    [[ "$boundary_value" == "true" ]] \
      && pass "program authority boundary declared: $lifecycle_id -> $key" \
      || fail "program authority boundary must be true: $lifecycle_id -> $key"
  done
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
  local route_ids contract_route_ids command_ids skill_ids prompt_set_ids workflow_ids validator_ids receipt_ids input_binding_ids
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
    if [[ "$binding_source" == "lifecycle.target" || "$binding_source" =~ ^run\.input\.[A-Za-z0-9_-]+$ ]]; then
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
    local expected_path expected_status approval_required approval_reason
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
    approval_required="$(yq -r ".routes[$index].approval.required_by_default // \"\"" "$contract" 2>/dev/null || true)"
    approval_reason="$(yq -r ".routes[$index].approval.reason // \"\"" "$contract" 2>/dev/null || true)"
    if [[ "$approval_required" == "true" ]]; then
      [[ -n "$approval_reason" && "$approval_reason" != "null" ]] \
        && pass "route approval reason declared: $route_id" \
        || fail "route approval reason missing: $route_id"
    fi
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
