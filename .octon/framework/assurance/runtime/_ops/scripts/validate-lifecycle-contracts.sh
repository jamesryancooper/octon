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
    find "$OCTON_DIR/inputs/additive/extensions" -path '*/context/lifecycle.contract.yml' -type f | sort
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

validate_unique_ids() {
  local contract="$1" query="$2" label="$3"
  local ids duplicates
  ids="$(load_ids "$contract" "$query")"
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
