#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

STATE_MACHINE_YML="${CHANGE_CLOSEOUT_STATE_MACHINE_YML:-$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.yml}"
STATE_MACHINE_MD="$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.md"
DEFAULT_WORK_UNIT_YML="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
DEFAULT_WORK_UNIT_MD="$OCTON_DIR/framework/product/contracts/default-work-unit.md"
RECEIPT_SCHEMA="$OCTON_DIR/framework/product/contracts/change-receipt-v1.schema.json"
AUTHORIZATION_SCHEMA="$OCTON_DIR/framework/product/contracts/branch-landing-authorization-v1.schema.json"
TERMINAL_LOCAL_EVIDENCE_SCHEMA="$OCTON_DIR/framework/product/contracts/terminal-closeout-local-evidence-v1.schema.json"
TERMINAL_LOCAL_EVIDENCE_WRITER="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh"
TERMINAL_LOCAL_EVIDENCE_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-terminal-closeout-local-evidence.sh"
WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"
WORKFLOW_STAGE_EVALUATE="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md"
WORKFLOW_STAGE_REPORT="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
CLOSEOUT_CHANGE_PHASES="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/references/phases.md"
CLOSEOUT_CHANGE_VALIDATION="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md"
CLOSEOUT_WORKTREE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
CLOSEOUT_WORKTREE_PHASES="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/phases.md"
CLOSEOUT_WORKTREE_VALIDATION="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/validation.md"
WRAPPER_REPORT_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh"
CLOSEOUT_PR="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
CLOSEOUT_PR_PHASES="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/references/phases.md"
WORKTREE_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
RESIDUE_CLASSIFIER="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh"

RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-change-closeout-state-machine.sh [--receipt <path>]

Without --receipt, validates static Change Closeout State Machine contract
alignment. With --receipt, also validates stateful_closeout evidence for
completed or cleaned closeout claims.
USAGE
}

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  grep -Fq -- "$needle" "$file" && pass "$ok_msg" || fail "$fail_msg"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

json_value() {
  local expr="$1"
  jq -r "$expr // \"\"" "$RECEIPT_PATH"
}

json_array_nonempty() {
  local expr="$1"
  jq -e "$expr | type == \"array\" and length > 0" "$RECEIPT_PATH" >/dev/null 2>&1
}

json_has_nonempty() {
  local expr="$1"
  jq -e "$expr | type == \"string\" and length > 0" "$RECEIPT_PATH" >/dev/null 2>&1
}

json_bool_true() {
  local expr="$1"
  jq -e "$expr == true" "$RECEIPT_PATH" >/dev/null 2>&1
}

resolve_ref_path() {
  local ref="$1"
  case "$ref" in
    "")
      return 1
      ;;
    /*)
      printf '%s\n' "$ref"
      ;;
    evidence://*)
      printf '%s/.octon/state/evidence/%s\n' "$ROOT_DIR" "${ref#evidence://}"
      ;;
    *)
      printf '%s/%s\n' "$ROOT_DIR" "$ref"
      ;;
  esac
}

digest_file() {
  local file="$1"
  local digest
  digest="$(shasum -a 256 "$file" | awk '{print $1}')"
  printf 'sha256:%s\n' "$digest"
}

is_terminal_local_ref() {
  local ref="$1"
  [[ "$ref" == .octon/state/evidence/local/terminal-closeout/* ]]
}

validate_terminal_local_proof_ref() {
  local ref expected_digest proof_path manifest_path change_id landed_ref actual_digest sink_dir final_verification_ref
  ref="$(json_value '.terminal_current_state_proof_ref')"
  [[ -n "$ref" ]] || return 0

  if ! is_terminal_local_ref "$ref"; then
    return 0
  fi

  expected_digest="$(json_value '.terminal_current_state_proof_digest')"
  if [[ -z "$expected_digest" ]]; then
    fail "local terminal proof ref requires terminal_current_state_proof_digest"
    return
  fi
  if [[ ! "$expected_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    fail "terminal_current_state_proof_digest must be sha256:<64 hex>"
    return
  fi

  proof_path="$(resolve_ref_path "$ref")" || { fail "terminal_current_state_proof_ref cannot be resolved"; return; }
  [[ -f "$proof_path" ]] || { fail "local terminal proof ref resolves to an existing file"; return; }
  actual_digest="$(digest_file "$proof_path")"
  [[ "$actual_digest" == "$expected_digest" ]] && pass "local terminal proof digest matches" || fail "local terminal proof digest must match terminal_current_state_proof_digest"

  sink_dir="$(dirname -- "$proof_path")"
  manifest_path="$sink_dir/manifest.json"
  [[ -f "$manifest_path" ]] || { fail "local terminal evidence manifest exists beside proof"; return; }
  change_id="$(json_value '.change_id')"
  landed_ref="$(json_value '.landed_ref')"
  if "$TERMINAL_LOCAL_EVIDENCE_VALIDATOR" --manifest "$manifest_path" --change-id "$change_id" --landed-ref "$landed_ref" >/dev/null; then
    pass "local terminal evidence manifest validates"
  else
    fail "local terminal evidence manifest must validate"
  fi

  final_verification_ref="$(json_value '.stateful_closeout.final_verification_ref')"
  if is_terminal_local_ref "$final_verification_ref"; then
    fail "stateful_closeout.final_verification_ref must not point at local terminal evidence sink"
  else
    pass "stateful final verification does not use local terminal sink"
  fi
}

validate_static() {
  for file in "$STATE_MACHINE_YML" "$STATE_MACHINE_MD" "$DEFAULT_WORK_UNIT_YML" "$DEFAULT_WORK_UNIT_MD" "$RECEIPT_SCHEMA" "$AUTHORIZATION_SCHEMA" "$TERMINAL_LOCAL_EVIDENCE_SCHEMA" "$TERMINAL_LOCAL_EVIDENCE_WRITER" "$TERMINAL_LOCAL_EVIDENCE_VALIDATOR" "$WORKFLOW" "$WORKFLOW_STAGE_EVALUATE" "$WORKFLOW_STAGE_REPORT" "$CLOSEOUT_CHANGE" "$CLOSEOUT_CHANGE_PHASES" "$CLOSEOUT_CHANGE_VALIDATION" "$CLOSEOUT_WORKTREE" "$CLOSEOUT_WORKTREE_PHASES" "$CLOSEOUT_WORKTREE_VALIDATION" "$WRAPPER_REPORT_VALIDATOR" "$CLOSEOUT_PR" "$CLOSEOUT_PR_PHASES" "$WORKTREE_CONTRACT" "$RESIDUE_CLASSIFIER"; do
    require_file "$file"
  done

  require_yq "$STATE_MACHINE_YML" '.schema_version == "change-closeout-state-machine-v1"' "state machine schema version is v1" "state machine schema version must be v1"
  require_yq "$STATE_MACHINE_YML" '.schema_version != "octon-extension-lifecycle-contract-v2"' "state machine is not an extension lifecycle contract" "state machine must not be declared as an extension lifecycle contract"
  require_yq "$STATE_MACHINE_YML" '.state_machine_id == "change-closeout-state-machine"' "state machine id is stable" "state machine id must be stable"
  require_yq "$STATE_MACHINE_YML" 'has("lifecycle_id") | not' "state machine does not declare lifecycle_id" "state machine must not declare lifecycle_id"
  require_yq "$STATE_MACHINE_YML" 'has("phase_loop") | not' "state machine does not declare generic phase_loop" "state machine must not be expressed as generic phase_loop"
  require_yq "$STATE_MACHINE_YML" '.default_work_unit == "change"' "state machine binds to Change" "state machine must bind to Change"
  require_yq "$STATE_MACHINE_YML" '.relationship_to_default_work_unit.route_authority == ".octon/framework/product/contracts/default-work-unit.yml"' "state machine preserves default-work-unit route authority" "state machine must preserve default-work-unit route authority"
  require_yq "$STATE_MACHINE_YML" '.policy_refs.closeout_worktree_wrapper_ref == ".octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"' "state machine references closeout-worktree wrapper" "state machine must reference closeout-worktree wrapper"
  require_yq "$STATE_MACHINE_YML" '.policy_refs.branch_landing_authorization_schema_ref == ".octon/framework/product/contracts/branch-landing-authorization-v1.schema.json"' "state machine references branch landing authorization schema" "state machine must reference branch landing authorization schema"
  require_yq "$STATE_MACHINE_YML" '.policy_refs.terminal_local_evidence_schema_ref == ".octon/framework/product/contracts/terminal-closeout-local-evidence-v1.schema.json"' "state machine references terminal local evidence schema" "state machine must reference terminal local evidence schema"
  require_yq "$STATE_MACHINE_YML" '.policy_refs.terminal_local_evidence_helper_ref == ".octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh"' "state machine references terminal local evidence helper" "state machine must reference terminal local evidence helper"
  require_yq "$STATE_MACHINE_YML" '.policy_refs.terminal_local_evidence_validator_ref == ".octon/framework/assurance/runtime/_ops/scripts/validate-terminal-closeout-local-evidence.sh"' "state machine references terminal local evidence validator" "state machine must reference terminal local evidence validator"
  require_yq "$STATE_MACHINE_YML" '.relationship_to_default_work_unit.dirty_worktree_wrapper.canonical_name == "Closeout Worktree"' "state machine names Closeout Worktree wrapper" "state machine must name Closeout Worktree wrapper"
  require_yq "$STATE_MACHINE_YML" '.relationship_to_default_work_unit.dirty_worktree_wrapper.default_work_unit_replacement == false' "Closeout Worktree does not replace default work unit" "Closeout Worktree must not replace default work unit"
  require_yq "$STATE_MACHINE_YML" '.relationship_to_default_work_unit.dirty_worktree_wrapper.decomposition_rule == "partition residue into singular Change closeouts and delegate each coherent unit to closeout-change"' "Closeout Worktree decomposes into closeout-change" "Closeout Worktree must decompose into closeout-change"
  for route in direct-main branch-no-pr branch-pr stage-only-escalate; do
    require_yq "$STATE_MACHINE_YML" ".routes[]? | select(. == \"$route\")" "state machine covers route $route" "state machine missing route $route"
  done
  if yq -e '.routes[]? | select(. == "branch-land-no-pr")' "$STATE_MACHINE_YML" >/dev/null 2>&1; then
    fail "state machine must not add branch-land-no-pr route"
  else
    pass "state machine does not add branch-land-no-pr route"
  fi
  for phase in read-in-and-constraints inventory residue-classification route-and-target-lifecycle-resolution safe-cleanup change-set-preparation validation hosted-no-pr-checks-and-landing pr-backed-subflow branch-cleanup receipt-and-evidence final-verification final-report; do
    require_yq "$STATE_MACHINE_YML" ".phases[]? | select(.phase_id == \"$phase\")" "state machine defines phase $phase" "state machine missing phase $phase"
  done
  require_yq "$STATE_MACHINE_YML" '.cleanup_safety.allowed_evidence_classes[]? | select(. == "origin-main-containment")' "state machine cleanup allows origin/main containment evidence" "state machine must require containment evidence"
  require_yq "$STATE_MACHINE_YML" '.cleanup_safety.denied_classes[]? | select(. == "detection-only")' "state machine denies detection-only cleanup" "state machine must deny detection-only cleanup"
  require_yq "$STATE_MACHINE_YML" '.stateful_receipt_object == "stateful_closeout"' "state machine declares stateful_closeout object" "state machine must declare stateful_closeout"
  require_yq "$STATE_MACHINE_YML" '.non_authority_boundaries[]? | select(. == ".octon/inputs/**")' "state machine marks inputs non-authoritative" "state machine must mark inputs non-authoritative"
  require_literal "$STATE_MACHINE_MD" "Detection alone is not deletion authority." "state machine docs deny detection-only deletion" "state machine docs must deny detection-only deletion"
  require_literal "$STATE_MACHINE_MD" 'Completed or cleaned closeout claims must include a `stateful_closeout` object' "state machine docs require stateful receipt evidence" "state machine docs must require stateful receipt evidence"
  require_literal "$STATE_MACHINE_MD" "write-terminal-closeout-local-evidence.sh" "state machine docs describe terminal local evidence helper" "state machine docs must describe terminal local evidence helper"
  require_literal "$STATE_MACHINE_MD" 'the state machine resolves' "state machine docs define default target resolution" "state machine docs must define default target resolution"
  require_yq "$STATE_MACHINE_YML" '.target_lifecycle_defaults.unspecified_closeout_request == "cleaned"' "state machine defaults unspecified target to cleaned" "state machine must default unspecified target to cleaned"
  require_yq "$STATE_MACHINE_YML" '.target_lifecycle_defaults.explicit_narrower_lifecycle_targets[]? | select(. == "published-branch")' "state machine models explicit narrower lifecycle targets" "state machine must model explicit narrower lifecycle targets separately from routes"
  require_yq "$STATE_MACHINE_YML" '.target_lifecycle_defaults.explicit_narrower_route_requests[]? | select(. == "stage-only-escalate")' "state machine models explicit stage-only route request separately" "state machine must model stage-only-escalate as an explicit route request"
  require_literal "$STATE_MACHINE_MD" '`Closeout Worktree` is the optional dirty-worktree wrapper.' "state machine docs describe Closeout Worktree wrapper" "state machine docs must describe Closeout Worktree wrapper"
  require_literal "$STATE_MACHINE_MD" "each coherent unit must be" "state machine docs require singular unit closeout" "state machine docs must require singular unit closeout"

  require_yq "$DEFAULT_WORK_UNIT_YML" '.state_machine_ref == ".octon/framework/product/contracts/change-closeout-state-machine.yml"' "default work unit references state machine" "default work unit must reference state machine"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.fail_closed_conditions[]? | select(. == "completed_or_cleaned_closeout_missing_state_machine_evidence")' "default work unit fails closed on missing state-machine evidence" "default work unit must fail closed on missing state-machine evidence"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.fail_closed_conditions[]? | select(. == "hosted_no_pr_landing_without_valid_governed_authorization")' "default work unit fails closed without governed landing authorization" "default work unit must fail closed without governed landing authorization"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.fail_closed_conditions[]? | select(. == "hosted_no_pr_landing_with_stale_or_denied_authorization")' "default work unit fails closed on stale or denied authorization" "default work unit must fail closed on stale or denied landing authorization"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "governed_landing_authorization_receipt")' "default work unit requires governed no-PR landing authorization" "default work unit must require governed no-PR landing authorization"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "landing_authorization_matches_source_ref_and_origin_main_pre_ref")' "default work unit requires current authorization refs" "default work unit must require authorization to match source and origin/main pre-ref"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.terminal_local_evidence_schema_ref == ".octon/framework/product/contracts/terminal-closeout-local-evidence-v1.schema.json"' "default work unit references terminal local evidence schema" "default work unit must reference terminal local evidence schema"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.closeout_evidence_boundaries.terminal_local_evidence_sink | test("terminal_current_state_proof_digest")' "default work unit requires digest-backed local terminal sink refs" "default work unit must require digest-backed local terminal sink refs"
  require_yq "$DEFAULT_WORK_UNIT_YML" '.fail_closed_conditions[]? | select(. == "local_terminal_current_state_proof_ref_missing_digest")' "default work unit fails closed on missing terminal local digest" "default work unit must fail closed on missing terminal local digest"
  require_literal "$DEFAULT_WORK_UNIT_MD" "Change Closeout State Machine" "default work unit docs reference state machine" "default work unit docs must reference state machine"
  require_literal "$DEFAULT_WORK_UNIT_MD" "Stateful closeout evidence for completed or cleaned claims." "default work unit durable history includes stateful evidence" "default work unit durable history must include stateful evidence"
  require_literal "$DEFAULT_WORK_UNIT_MD" "terminal_current_state_proof_digest" "default work unit docs describe digest-backed terminal sink refs" "default work unit docs must describe digest-backed terminal sink refs"

  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "state_machine_version")' "receipt schema requires state_machine_version" "receipt schema must require state_machine_version"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "initial_inventory_ref")' "receipt schema requires inventory ref" "receipt schema must require inventory ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "residue_classification_ref")' "receipt schema requires residue classification ref" "receipt schema must require residue classification ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "phase_exit_refs")' "receipt schema requires phase exit refs" "receipt schema must require phase exit refs"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "cleanup_decision_refs")' "receipt schema requires cleanup decision refs" "receipt schema must require cleanup decision refs"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "safe_cleanup_evidence_class")' "receipt schema requires cleanup safety class" "receipt schema must require cleanup safety class"
  require_jq "$RECEIPT_SCHEMA" '.properties.stateful_closeout.required[] | select(. == "final_verification_ref")' "receipt schema requires final verification ref" "receipt schema must require final verification ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.landing_authorization_ref' "receipt schema models governed landing authorization" "receipt schema must model landing_authorization_ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.terminal_current_state_proof_digest."$ref" == "#/$defs/sha256Digest"' "receipt schema models terminal proof digest" "receipt schema must model terminal_current_state_proof_digest"
  require_jq "$TERMINAL_LOCAL_EVIDENCE_SCHEMA" '.properties.schema_version.const == "terminal-closeout-local-evidence-v1"' "terminal local evidence schema version is stable" "terminal local evidence schema must define terminal-closeout-local-evidence-v1"
  require_jq "$RECEIPT_SCHEMA" '.allOf[]? | select(.then.required[]? == "landing_authorization_ref")' "receipt schema requires governed authorization for no-PR landing" "receipt schema must require landing_authorization_ref for branch-no-pr landed/cleaned claims"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.schema_version.const == "branch-landing-authorization-v1"' "authorization schema has stable version" "authorization schema must define branch-landing-authorization-v1"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.no_pr_required.const == true' "authorization schema requires no-PR proof" "authorization schema must require no_pr_required true"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.host_controls_not_bypassed.const == true' "authorization schema preserves host controls" "authorization schema must preserve host controls"
  require_jq "$RECEIPT_SCHEMA" '[.allOf[]? | select(.if.properties.closeout_outcome.const == "completed") | select((.then.required // []) | index("stateful_closeout"))] | length == 1' "receipt schema requires stateful_closeout for completed closeout" "receipt schema must require stateful_closeout for completed closeout"
  require_jq "$RECEIPT_SCHEMA" '[.allOf[]? | select(.if.properties.lifecycle_outcome.const == "cleaned") | select((.then.required // []) | index("stateful_closeout"))] | length == 1' "receipt schema requires stateful_closeout for cleaned outcome" "receipt schema must require stateful_closeout for cleaned outcome"

  require_yq "$WORKFLOW" '.policy_refs.state_machine_ref == ".octon/framework/product/contracts/change-closeout-state-machine.yml"' "closeout workflow references state machine" "closeout workflow must reference state machine"
  require_literal "$WORKFLOW_STAGE_EVALUATE" "stateful_closeout" "evaluate stage requires stateful closeout evidence" "evaluate stage must require stateful closeout evidence"
  require_literal "$WORKFLOW_STAGE_REPORT" 'Never claim completed or cleaned closeout without `stateful_closeout`' "report stage blocks missing stateful evidence" "report stage must block missing stateful evidence"
  require_literal "$CLOSEOUT_CHANGE" "Execute the Change Closeout State Machine phase loop" "closeout-change follows state-machine loop" "closeout-change must follow state-machine loop"
  require_literal "$CLOSEOUT_CHANGE" 'Use `closeout-worktree` when the operator asks to close out a dirty worktree' "closeout-change routes dirty worktrees to wrapper" "closeout-change must route dirty worktrees to wrapper"
  require_literal "$CLOSEOUT_CHANGE_PHASES" "Detection alone is not deletion authority." "closeout-change phases deny deletion by detection" "closeout-change phases must deny deletion by detection"
  require_literal "$CLOSEOUT_CHANGE_VALIDATION" 'Completed or cleaned closeout also requires `stateful_closeout`' "closeout-change validation requires stateful evidence" "closeout-change validation must require stateful evidence"
  require_literal "$CLOSEOUT_CHANGE" "branch-landing-authorization-v1" "closeout-change requires governed landing authorization" "closeout-change must require governed landing authorization"
  require_literal "$CLOSEOUT_CHANGE_VALIDATION" "landing_authorization_ref" "closeout-change validation requires landing authorization ref" "closeout-change validation must require landing authorization ref"
  require_literal "$CLOSEOUT_WORKTREE" "Dirty-worktree wrapper for decomposing multiple local change sets into" "closeout-worktree is dirty-worktree wrapper" "closeout-worktree must be dirty-worktree wrapper"
  require_literal "$CLOSEOUT_WORKTREE" "Route the selected candidate through" "closeout-worktree delegates selected candidate" "closeout-worktree must delegate selected candidate"
  require_literal "$CLOSEOUT_WORKTREE" "schema_version: closeout-worktree-report-v1" "closeout-worktree documents report evidence schema" "closeout-worktree must document report evidence schema"
  require_literal "$CLOSEOUT_WORKTREE_PHASES" "partition residue into singular Change closeouts" "closeout-worktree phases decompose into singular closeouts" "closeout-worktree phases must decompose into singular closeouts"
  require_literal "$CLOSEOUT_WORKTREE_VALIDATION" 'each delegated unit routed through `closeout-change`' "closeout-worktree validation requires closeout-change delegation" "closeout-worktree validation must require closeout-change delegation"
  require_literal "$WRAPPER_REPORT_VALIDATOR" "observed_change_set_count" "closeout-worktree wrapper report validator checks candidate count" "closeout-worktree wrapper report validator must check candidate count"
  require_literal "$CLOSEOUT_PR" "Closeout PR-Backed Change" "closeout-pr has PR-backed human-facing name" "closeout-pr must have PR-backed human-facing name"
  require_literal "$CLOSEOUT_PR_PHASES" 'Include `stateful_closeout` receipt evidence' "closeout-pr phases require stateful evidence" "closeout-pr phases must require stateful evidence"
  require_yq "$WORKTREE_CONTRACT" '.policy_refs.change_closeout_state_machine_ref == ".octon/framework/product/contracts/change-closeout-state-machine.yml"' "git/worktree contract references state machine" "git/worktree contract must reference state machine"
  require_yq "$WORKTREE_CONTRACT" '.policy_refs.worktree_wrapper_skill_ref == ".octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"' "git/worktree contract references closeout-worktree wrapper" "git/worktree contract must reference closeout-worktree wrapper"
  require_yq "$WORKTREE_CONTRACT" '.closeout.worktree_wrapper == "/closeout-worktree"' "git/worktree contract exposes closeout-worktree wrapper" "git/worktree contract must expose closeout-worktree wrapper"
  require_yq "$WORKTREE_CONTRACT" '.closeout.residue_classification.read_only == true' "residue classifier is read-only" "residue classifier must be read-only"
  require_yq "$WORKTREE_CONTRACT" '.closeout.residue_classification.detection_is_deletion_authority == false' "residue detection is not deletion authority" "residue detection must not authorize deletion"
  require_literal "$RESIDUE_CLASSIFIER" "read_only: true" "residue classifier emits read-only posture" "residue classifier must emit read-only posture"
  require_literal "$RESIDUE_CLASSIFIER" "detection_is_deletion_authority: false" "residue classifier denies deletion authority" "residue classifier must deny deletion authority"
}

validate_receipt() {
  [[ -f "$RECEIPT_PATH" ]] || { fail "receipt exists: $RECEIPT_PATH"; return; }
  jq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt parses as JSON" || { fail "receipt parses as JSON"; return; }

  local closeout outcome route cleanup integration safety_class
  closeout="$(json_value '.closeout_outcome')"
  outcome="$(json_value '.lifecycle_outcome')"
  route="$(json_value '.selected_route')"
  cleanup="$(json_value '.cleanup_status')"
  integration="$(json_value '.integration_status')"
  safety_class="$(json_value '.stateful_closeout.safe_cleanup_evidence_class')"

  if [[ "$closeout" == "completed" || "$outcome" == "cleaned" ]]; then
    jq -e '.stateful_closeout | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "terminal closeout has stateful_closeout" || fail "completed or cleaned closeout requires stateful_closeout"
    json_has_nonempty '.stateful_closeout.initial_inventory_ref' && pass "stateful closeout has initial inventory ref" || fail "stateful_closeout requires initial_inventory_ref"
    json_has_nonempty '.stateful_closeout.residue_classification_ref' && pass "stateful closeout has residue classification ref" || fail "stateful_closeout requires residue_classification_ref"
    json_array_nonempty '.stateful_closeout.phase_exit_refs' && pass "stateful closeout has phase exit refs" || fail "stateful_closeout requires phase_exit_refs"
    json_array_nonempty '.stateful_closeout.cleanup_decision_refs' && pass "stateful closeout has cleanup decision refs" || fail "stateful_closeout requires cleanup_decision_refs"
    json_has_nonempty '.stateful_closeout.final_verification_ref' && pass "stateful closeout has final verification ref" || fail "stateful_closeout requires final_verification_ref"
    [[ "$(json_value '.stateful_closeout.state_machine_version')" == "change-closeout-state-machine-v1" ]] && pass "stateful closeout names current state machine version" || fail "stateful_closeout must name change-closeout-state-machine-v1"
  fi

  case "$outcome" in
    published-branch|published|ready|deferred)
      if [[ "$closeout" == "completed" ]]; then
        fail "$outcome must not be completed closeout"
      else
        pass "$outcome is not completed closeout"
      fi
      ;;
  esac

  if [[ "$closeout" == "completed" && "$safety_class" == "detection-only" ]]; then
    fail "detection-only cleanup evidence cannot support completed closeout"
  elif [[ "$closeout" == "completed" ]]; then
    pass "completed closeout does not use detection-only cleanup evidence"
  fi

  if jq -e '.force_push_claimed == true or .stateful_closeout.force_push_claimed == true' "$RECEIPT_PATH" >/dev/null 2>&1; then
    fail "force-push cannot be claimed as allowed closeout"
  else
    pass "receipt does not claim force-push closeout"
  fi

  validate_terminal_local_proof_ref

  if [[ "$route" == "branch-no-pr" && ( "$outcome" == "landed" || "$outcome" == "cleaned" ) ]]; then
    json_array_nonempty '.stateful_closeout.hosted_landing_refs' && pass "hosted no-PR terminal claim has hosted landing refs" || fail "hosted no-PR terminal claim requires hosted_landing_refs"
    json_has_nonempty '.landing_authorization_ref' && pass "hosted no-PR terminal claim has landing authorization ref" || fail "hosted no-PR terminal claim requires landing_authorization_ref"
  fi

  if [[ ( "$route" == "branch-no-pr" || "$route" == "branch-pr" ) && "$integration" == "landed" && "$closeout" == "completed" ]]; then
    json_array_nonempty '.stateful_closeout.branch_cleanup_refs' && pass "completed landed branch closeout has branch cleanup refs" || fail "completed landed branch closeout requires branch_cleanup_refs"
    jq -e '.source_branch_integration | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "completed landed branch closeout has source branch integration evidence" || fail "completed landed branch closeout requires source_branch_integration"
    json_bool_true '.source_branch_integration.integrated' && pass "source branch integration is affirmed" || fail "source_branch_integration.integrated must be true"
    json_array_nonempty '.source_branch_integration.evidence_refs' && pass "source branch integration has evidence refs" || fail "source_branch_integration requires evidence_refs"
    json_has_nonempty '.main_alignment.origin_fetch_evidence_ref' && pass "completed landed branch closeout has post-landing fetch evidence" || fail "completed landed branch closeout requires origin_fetch_evidence_ref"
    json_has_nonempty '.main_alignment.local_main_sync_evidence_ref' && pass "completed landed branch closeout has local main sync evidence" || fail "completed landed branch closeout requires local_main_sync_evidence_ref"
    json_bool_true '.main_alignment.origin_main_contains_landed_ref' && pass "origin/main contains landed ref" || fail "completed landed branch closeout requires origin_main_contains_landed_ref true"
    json_bool_true '.main_alignment.local_main_contains_landed_ref' && pass "local main contains landed ref" || fail "completed landed branch closeout requires local_main_contains_landed_ref true"
  fi

  if [[ "$cleanup" == "completed" && "$safety_class" == "not-applicable" ]]; then
    fail "completed cleanup requires a concrete safety evidence class"
  elif [[ "$cleanup" == "completed" ]]; then
    pass "completed cleanup has concrete safety evidence class"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ -n "$RECEIPT_PATH" && "$RECEIPT_PATH" != /* ]]; then
  RECEIPT_PATH="$ROOT_DIR/$RECEIPT_PATH"
fi

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

echo "== Change Closeout State Machine Validation =="
validate_static
[[ -z "$RECEIPT_PATH" ]] || validate_receipt

echo
echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
