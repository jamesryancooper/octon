#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SPEC_DIR="$OCTON_DIR/framework/engine/runtime/spec"
CONFIG_FILE="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"
CARGO_MANIFEST="$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}
run_test() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Mission Runtime Contracts Validation =="

  for file in \
    mission-charter-v2.schema.json \
    mission-autonomy-policy-v1.schema.json \
    ownership-registry-v1.schema.json \
    mission-control-lease-v1.schema.json \
    action-slice-v1.schema.json \
    intent-register-v1.schema.json \
    mission-classification-v1.schema.json \
    mode-state-v1.schema.json \
    control-directive-v1.schema.json \
    authorize-update-v1.schema.json \
    schedule-control-v1.schema.json \
    autonomy-budget-v1.schema.json \
    circuit-breaker-v1.schema.json \
    subscriptions-v1.schema.json \
    execution-request-v2.schema.json \
    execution-receipt-v2.schema.json \
    policy-receipt-v2.schema.json \
    policy-digest-v2.md \
    control-receipt-v1.schema.json \
    scenario-resolution-v1.schema.json \
    mission-view-v1.schema.json \
    ../../../constitution/contracts/authority/approval-request-v1.schema.json \
    ../../../constitution/contracts/authority/approval-grant-v1.schema.json \
    ../../../constitution/contracts/authority/exception-lease-v1.schema.json \
    ../../../constitution/contracts/authority/revocation-v1.schema.json \
    ../../../constitution/contracts/authority/decision-artifact-v1.schema.json \
    ../../../constitution/contracts/authority/grant-bundle-v1.schema.json
  do
    [[ -f "$SPEC_DIR/$file" ]] && pass "found spec $file" || fail "missing spec $file"
  done

  has_pattern 'mission_autonomy_policy' "$CONFIG_FILE" && pass "policy interface exposes mission autonomy policy" || fail "policy interface missing mission_autonomy_policy path"
  has_pattern 'mission_control_root' "$CONFIG_FILE" && pass "policy interface exposes mission control root" || fail "policy interface missing mission_control_root path"
  has_pattern 'control_receipt_root' "$CONFIG_FILE" && pass "policy interface exposes control receipt root" || fail "policy interface missing control_receipt_root path"
  has_pattern 'support_targets' "$CONFIG_FILE" && pass "policy interface exposes support-target declarations" || fail "policy interface missing support_targets path"
  has_pattern 'approval_request_root' "$CONFIG_FILE" && pass "policy interface exposes approval request root" || fail "policy interface missing approval_request_root path"
  has_pattern 'approval_grant_root' "$CONFIG_FILE" && pass "policy interface exposes approval grant root" || fail "policy interface missing approval_grant_root path"
  has_pattern 'execution_revocations' "$CONFIG_FILE" && pass "policy interface exposes revocation root" || fail "policy interface missing execution_revocations path"
  has_pattern 'mission_effective_route_root' "$CONFIG_FILE" && pass "policy interface exposes mission effective route root" || fail "policy interface missing mission_effective_route_root path"
  has_pattern 'mission_summary_root' "$CONFIG_FILE" && pass "policy interface exposes mission summary root" || fail "policy interface missing mission_summary_root path"
  has_pattern 'operator_digest_root' "$CONFIG_FILE" && pass "policy interface exposes operator digest root" || fail "policy interface missing operator_digest_root path"
  has_pattern 'mission_projection_root' "$CONFIG_FILE" && pass "policy interface exposes mission projection root" || fail "policy interface missing mission_projection_root path"
  has_pattern 'policy-receipt-v2' "$OCTON_DIR/framework/capabilities/_ops/scripts/policy-receipt-write.sh" && pass "shared policy receipt writer emits v2 schema" || fail "shared policy receipt writer still emits v1 schema"
  has_pattern 'policy-digest-v2' "$OCTON_DIR/framework/capabilities/_ops/scripts/policy-receipt-write.sh" && pass "shared policy receipt writer emits v2 digest format" || fail "shared policy receipt writer still emits v1 digest format"
  has_pattern 'autonomy_context' "$OCTON_DIR/framework/engine/runtime/crates/authority_engine/src/implementation.rs" && pass "kernel authorization uses autonomy_context" || fail "kernel authorization missing autonomy_context"
  has_pattern 'workflow_mode' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/pipeline.rs" && pass "pipeline emits workflow_mode" || fail "pipeline missing workflow_mode"
  has_pattern 'effective_scenario_resolution_ref' "$OCTON_DIR/framework/engine/runtime/crates/authority_engine/src/implementation.rs" && pass "kernel authorization reads route linkage" || fail "kernel authorization missing route linkage handling"
  has_pattern 'mission-classification.yml' "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh" && pass "mission seed helper writes mission classification" || fail "mission seed helper missing mission classification"
  has_pattern 'MISSION_PROPOSAL_REF_REQUIRED' "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh" && pass "route publisher marks missing required proposal refs" || fail "route publisher missing required proposal-ref signal"
  has_pattern 'proposal_refs_required' "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh" && pass "mission evaluator fails closed on missing proposal refs" || fail "mission evaluator missing proposal-ref fail-closed reason"

  while IFS= read -r run_contract; do
    [[ -n "$run_contract" ]] || continue

    local run_id mission_mode requires_mission mission_id stage_root_rel stage_root
    run_id="$(basename "$(dirname "$run_contract")")"
    mission_mode="$(yq -r '.mission_mode // ""' "$run_contract")"
    requires_mission="$(yq -r '.requires_mission // false' "$run_contract")"
    mission_id="$(yq -r '.mission_id // ""' "$run_contract")"

    [[ "$mission_mode" == "mission-bound" && "$requires_mission" == "true" && -n "$mission_id" ]] || continue

    stage_root_rel="$(yq -r '.stage_attempt_root // ""' "$run_contract")"
    [[ -n "$stage_root_rel" ]] || {
      fail "$run_id is mission-bound but missing stage_attempt_root"
      continue
    }
    stage_root="$ROOT_DIR/$stage_root_rel"
    [[ -d "$stage_root" ]] && pass "$run_id publishes a stage-attempt root for mission-bound execution" || {
      fail "$run_id is mission-bound but missing a stage-attempt root"
      continue
    }

    while IFS= read -r stage_file; do
      [[ -n "$stage_file" ]] || continue

      local stage_schema receipt_path receipt_rel action_slice_ref action_slice_path expected_stage_ref
      stage_schema="$(yq -r '.schema_version // ""' "$stage_file")"
      if [[ "$stage_schema" != "stage-attempt-v2" ]]; then
        pass "$run_id $(basename "$stage_file") remains outside stage-attempt-v2 action-slice enforcement"
        continue
      fi

      action_slice_ref="$(yq -r '.action_slice_ref // ""' "$stage_file")"
      [[ -n "$action_slice_ref" ]] && pass "$run_id stage-attempt-v2 carries action_slice_ref" || {
        fail "$run_id stage-attempt-v2 is missing action_slice_ref"
        continue
      }

      action_slice_path="$ROOT_DIR/$action_slice_ref"
      [[ -f "$action_slice_path" ]] && pass "$run_id action_slice_ref resolves to a declared mission action slice" || {
        fail "$run_id action_slice_ref does not resolve: $action_slice_ref"
        continue
      }

      [[ "$(yq -r '.mission_id // ""' "$action_slice_path")" == "$mission_id" ]] \
        && pass "$run_id action_slice_ref remains mission-aligned" \
        || fail "$run_id action_slice_ref must stay aligned to mission $mission_id"

      receipt_path="$OCTON_DIR/state/evidence/runs/$run_id/receipts/stage-action-slice-binding.yml"
      receipt_rel=".octon/state/evidence/runs/$run_id/receipts/stage-action-slice-binding.yml"
      [[ -f "$receipt_path" ]] && pass "$run_id retains a stage-action-slice binding receipt" || {
        fail "$run_id is missing retained stage-action-slice binding receipt"
        continue
      }

      expected_stage_ref=".octon/state/control/execution/runs/$run_id/stage-attempts/$(basename "$stage_file")"
      yq -e ".run_id == \"$run_id\" and .mission_id == \"$mission_id\" and .action_slice_ref == \"$action_slice_ref\" and .stage_attempt_ref == \"$expected_stage_ref\" and .status == \"verified\"" "$receipt_path" >/dev/null 2>&1 \
        && pass "$run_id binding receipt matches the mission-bound stage attempt" \
        || fail "$run_id binding receipt must match the mission-bound stage attempt"

      has_pattern "$receipt_rel" "$stage_file" \
        && pass "$run_id stage-attempt evidence references the retained binding receipt" \
        || fail "$run_id stage-attempt evidence must reference the retained binding receipt"
    done < <(find "$stage_root" -maxdepth 1 -name '*.yml' -print | sort)
  done < <(find "$OCTON_DIR/state/control/execution/runs" -name run-contract.yml -print | sort)

  run_test \
    "authorization denies autonomous execution without mission context" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_requires_mission_context
  run_test \
    "authorization accepts seeded autonomous mission context" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel autonomous_request_allows_seeded_mission_context
  run_test \
    "approval-required autonomous execution returns stage-only without a canonical grant" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel approval_required_autonomous_request_returns_stage_only_without_human_approval
  run_test \
    "proceed-on-silence blocks when autonomy budget is not healthy" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel proceed_on_silence_blocks_when_autonomy_budget_not_healthy
  run_test \
    "unsupported support tier denies execution" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel unsupported_support_tier_denies_execution
  run_test \
    "authorization stage-onlys when mission scenario resolution is missing" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel missing_scenario_resolution_returns_stage_only
  run_test \
    "authorization stage-onlys when mission scenario resolution is stale" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel stale_scenario_resolution_returns_stage_only
  run_test \
    "authorization stage-onlys when mission scenario resolution omits action class" \
    cargo test --manifest-path "$CARGO_MANIFEST" -p octon_kernel missing_scenario_action_class_returns_stage_only

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
