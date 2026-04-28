#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-work-package-compiler.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/engagement-work-package-compiler-v1/valid"
TMP_ROOT="${TMPDIR:-/tmp}/engagement-compiler-tests"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" && -e "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

new_case() {
  mkdir -p "$TMP_ROOT"
  local case_root
  case_root="$(mktemp -d "$TMP_ROOT/case.XXXXXX")"
  CLEANUP_DIRS+=("$case_root")
  if [[ "${OCTON_USE_STATIC_ENGAGEMENT_FIXTURE:-0}" == "1" && -d "$FIXTURE_ROOT" ]]; then
    cp -R "$FIXTURE_ROOT/." "$case_root/"
  fi
  build_generated_fixture "$case_root"
  printf '%s\n' "$case_root"
}

build_generated_fixture() {
  local case_root="$1"
  mkdir -p \
    "$case_root/.octon/instance" \
    "$case_root/.octon/instance/capabilities/runtime" \
    "$case_root/.octon/framework/cognition/_meta/architecture" \
    "$case_root/.octon/framework/engine/runtime/spec" \
    "$case_root/.octon/framework/constitution" \
    "$case_root/.octon/state/control/engagements/eng-001/objective" \
    "$case_root/.octon/state/control/engagements/eng-001/decisions" \
    "$case_root/.octon/state/control/engagements/eng-001/run-candidates/run-001" \
    "$case_root/.octon/state/evidence/engagements/eng-001/objective" \
    "$case_root/.octon/state/evidence/engagements/eng-001/run-contract-readiness" \
    "$case_root/.octon/state/evidence/engagements/eng-001/cli"

  rm -r -f \
    "$case_root/.octon/framework/engine/runtime/spec" \
    "$case_root/.octon/framework/cognition/_meta/architecture/contract-registry.yml" \
    "$case_root/.octon/framework/constitution/contracts" \
    "$case_root/.octon/instance/governance" \
    "$case_root/.octon/instance/capabilities/runtime/packs"
  cp -R "$ROOT_DIR/.octon/instance/governance" "$case_root/.octon/instance/governance"
  cp -R "$ROOT_DIR/.octon/instance/capabilities/runtime/packs" "$case_root/.octon/instance/capabilities/runtime/packs"
  cp -R "$ROOT_DIR/.octon/framework/engine/runtime/spec" "$case_root/.octon/framework/engine/runtime/spec"
  cp "$ROOT_DIR/.octon/framework/cognition/_meta/architecture/contract-registry.yml" "$case_root/.octon/framework/cognition/_meta/architecture/contract-registry.yml"
  cp -R "$ROOT_DIR/.octon/framework/constitution/contracts" "$case_root/.octon/framework/constitution/contracts"

  cat >"$case_root/.octon/state/control/engagements/eng-001/work-package.yml" <<'YAML'
schema_version: "work-package-v1"
work_package_id: "wp-001"
engagement_ref: ".octon/state/control/engagements/eng-001/engagement.yml"
project_profile_ref: ".octon/instance/locality/project-profile.yml"
objective_brief_schema_ref: ".octon/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json"
objective_control_root: ".octon/state/control/engagements/eng-001/objective"
objective_brief_ref: ".octon/state/control/engagements/eng-001/objective/objective-brief.yml"
objective_brief_evidence_refs:
  - ".octon/state/evidence/engagements/eng-001/objective/receipt.yml"
objective_brief_authority_boundary:
  objective_brief_is_workspace_charter_authority: false
  material_execution_authorized_by_objective_brief: false
authority_binding:
  authority_ref: ".octon/state/control/execution/approvals/grants/grant-fixture.yml"
  grant_bundle_ref: ".octon/state/evidence/control/execution/grant-fixture.yml"
implementation_plan_summary: "Fixture Work Package for validator coverage."
impact_map: {}
risk_materiality:
  materiality: "moderate"
  risk_class: "ACP-2"
  reversibility_class: "reversible"
validation:
  commands: []
rollback:
  plan_ref: ".octon/state/control/engagements/eng-001/rollback.yml"
support_posture:
  tuple_id: "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/repo-shell"
  claim_effect: "admitted-live-claim"
capability_posture:
  pack_ids:
    - "repo"
connector_posture:
  connector_posture_schema_ref: ".octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json"
  connector_policy_schema_ref: ".octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json"
  connector_registry_schema_ref: ".octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json"
  connector_policy_ref: ".octon/instance/governance/connectors/posture.yml"
  connector_registry_ref: ".octon/instance/governance/connectors/registry.yml"
  readme_authority_allowed: false
  requested_connectors: []
evidence_profile:
  selected_profile: "repo-consequential"
  policy_ref: ".octon/instance/governance/policies/evidence-profiles.yml"
  required_evidence:
    - "context-pack-receipt"
context_pack:
  request_ref: ".octon/state/control/engagements/eng-001/context/context-pack-request.yml"
  receipt_ref: ".octon/state/evidence/runs/run-001/context/receipt.yml"
decision_requests:
  - decision_ref: ".octon/state/control/engagements/eng-001/decisions/decision-001.yml"
run_contract_candidate:
  ref: ".octon/state/control/engagements/eng-001/run-candidates/run-001/run-contract.candidate.yml"
run_contract_readiness_evidence_refs:
  - ".octon/state/evidence/engagements/eng-001/run-contract-readiness/receipt.yml"
autonomy_envelope:
  mission_required: false
  mode: "run-only"
placement:
  path_family_registry_ref: ".octon/instance/governance/engagements/path-families.yml"
  runtime_write_family_refs:
    - "engagement-control"
    - "work-package-control"
    - "objective-brief-control"
    - "decision-request-control"
    - "engagement-evidence"
    - "objective-brief-evidence"
    - "orientation-evidence"
    - "project-profile-evidence"
    - "project-profile-source-fact-evidence"
    - "work-package-compilation-evidence"
    - "decision-evidence"
    - "run-contract-readiness-evidence"
    - "engagement-continuity"
    - "project-profile-authority"
runtime_authorization:
  grant_bundle_ref: ".octon/state/evidence/control/execution/grant-fixture.yml"
outcome:
  status: "ready_for_authorization"
  blockers: []
  reason_refs: []
created_at: "2026-04-28T00:00:00Z"
updated_at: "2026-04-28T00:00:00Z"
YAML

  cat >"$case_root/.octon/state/control/engagements/eng-001/objective/objective-brief.yml" <<'YAML'
schema_version: "engagement-objective-brief-v1"
objective_brief_id: "obj-001"
engagement_id: "eng-001"
status: "candidate"
objective_layer: "engagement-control-candidate"
authority_status: "candidate-control-not-workspace-authority"
workspace_charter_substitution_allowed: false
control_binding:
  objective_control_root: ".octon/state/control/engagements/eng-001/objective"
  objective_control_ref: ".octon/state/control/engagements/eng-001/objective/objective-brief.yml"
  engagement_control_ref: ".octon/state/control/engagements/eng-001/engagement.yml"
objective_summary: "Fixture objective."
scope_in:
  - ".octon/instance/locality/project-profile.yml"
scope_out:
  - ".octon/state/control/engagements/eng-001/work-package.yml"
done_when:
  - "Fixture Work Package is validated."
acceptance_criteria:
  - "Objective Brief remains per-engagement candidate control state."
workspace_charter_refs:
  workspace_charter_ref: ".octon/instance/charter/workspace.md"
  workspace_machine_charter_ref: ".octon/instance/charter/workspace.yml"
backing_evidence_refs:
  - ".octon/state/evidence/engagements/eng-001/objective/receipt.yml"
authority_boundary:
  objective_brief_is_workspace_charter_authority: false
  may_rewrite_workspace_charter: false
  material_execution_authorized_by_objective_brief: false
created_at: "2026-04-28T00:00:00Z"
updated_at: "2026-04-28T00:00:00Z"
YAML

  cat >"$case_root/.octon/state/evidence/engagements/eng-001/objective/receipt.yml" <<'YAML'
schema_version: "objective-brief-source-evidence-v1"
engagement_id: "eng-001"
objective_brief_ref: ".octon/state/control/engagements/eng-001/objective/objective-brief.yml"
authority_boundary:
  objective_brief_is_workspace_charter_authority: false
  may_rewrite_workspace_charter: false
  material_execution_authorized_by_objective_brief: false
recorded_at: "2026-04-28T00:00:00Z"
YAML

  cat >"$case_root/.octon/state/evidence/engagements/eng-001/run-contract-readiness/receipt.yml" <<'YAML'
schema_version: "run-contract-readiness-evidence-v1"
engagement_id: "eng-001"
run_id: "run-001"
candidate_ref: ".octon/state/control/engagements/eng-001/run-candidates/run-001/run-contract.candidate.yml"
material_execution_entrypoint: "octon run start --contract"
direct_execution_allowed: false
recorded_at: "2026-04-28T00:00:00Z"
YAML

  cat >"$case_root/.octon/state/control/engagements/eng-001/decisions/decision-001.yml" <<'YAML'
schema_version: "decision-request-v1"
decision_request_id: "decision-001"
engagement_id: "eng-001"
status: "resolved"
decision_type: "approval"
question: "Approve fixture run-contract handoff?"
allowed_resolutions:
  - "approval"
subject_refs:
  work_package_ref: ".octon/state/control/engagements/eng-001/work-package.yml"
canonical_resolution_targets:
  approval_request_ref: ".octon/state/control/execution/approvals/requests/decision-001.yml"
  approval_grant_ref: ".octon/state/control/execution/approvals/grants/grant-decision-001.yml"
  exception_lease_root: ".octon/state/control/execution/exceptions/leases"
  revocation_root: ".octon/state/control/execution/revocations"
evidence_root: ".octon/state/evidence/decisions/decision-001"
created_at: "2026-04-28T00:00:00Z"
YAML

  cat >"$case_root/.octon/state/control/engagements/eng-001/run-candidates/run-001/run-contract.candidate.yml" <<'YAML'
schema_version: "run-contract-v3"
required_evidence:
  - ".octon/state/evidence/engagements/eng-001/run-contract-readiness/receipt.yml"
handoff:
  bypass_run_start: false
direct_execution_allowed: false
YAML

  cat >"$case_root/.octon/state/evidence/engagements/eng-001/cli/octon-help.txt" <<'EOF'
octon start
octon profile
octon plan
octon arm --prepare-only
octon run start --contract .octon/state/control/execution/runs/<run-id>/run-contract.yml
EOF
}

run_validator() {
  local case_root="$1"
  local log="$case_root/validator.log"
  if bash "$VALIDATOR" \
    --root "$case_root" \
    --work-package ".octon/state/control/engagements/eng-001/work-package.yml" \
    --cli-help ".octon/state/evidence/engagements/eng-001/cli/octon-help.txt" >"$log" 2>&1; then
    return 0
  fi
  return 1
}

case_valid_fixture_passes() {
  local case_root
  case_root="$(new_case)"
  if ! run_validator "$case_root"; then
    cat "$case_root/validator.log" >&2
    return 1
  fi
}

case_schema_metadata_missing_fails() {
  local case_root schema
  case_root="$(new_case)"
  schema="$case_root/.octon/framework/engine/runtime/spec/work-package-v1.schema.json"
  jq 'del(."$schema")' "$schema" >"$schema.tmp"
  mv "$schema.tmp" "$schema"
  ! run_validator "$case_root"
}

case_objective_brief_wrong_root_fails() {
  local case_root
  case_root="$(new_case)"
  yq -i '.objective_brief_ref = ".octon/instance/charter/workspace.md"' \
    "$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  ! run_validator "$case_root"
}

case_objective_brief_workspace_authority_fails() {
  local case_root work_package objective
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  objective="$case_root/.octon/state/control/engagements/eng-001/objective/objective-brief.yml"
  yq -i '.objective_brief_authority_boundary.objective_brief_is_workspace_charter_authority = true' "$work_package"
  yq -i '.authority_boundary.objective_brief_is_workspace_charter_authority = true' "$objective"
  ! run_validator "$case_root"
}

case_missing_run_readiness_evidence_fails() {
  local case_root work_package
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  yq -i 'del(.run_contract_readiness_evidence_refs)' "$work_package"
  ! run_validator "$case_root"
}

case_raw_input_candidate_dependency_fails() {
  local case_root candidate
  case_root="$(new_case)"
  candidate="$case_root/.octon/state/control/engagements/eng-001/run-candidates/run-001/run-contract.candidate.yml"
  yq -i '.required_evidence += [".octon/inputs/exploratory/proposals/architecture/engagement-project-profile-work-package-compiler-v1/architecture/validation-plan.md"]' "$candidate"
  ! run_validator "$case_root"
}

case_generated_authority_ref_fails() {
  local case_root work_package
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  yq -i '.authority_binding.authority_ref = ".octon/generated/cognition/projections/materialized/work-packages/wp-001.yml"' "$work_package"
  ! run_validator "$case_root"
}

case_ready_with_unresolved_decision_fails() {
  local case_root decision
  case_root="$(new_case)"
  decision="$case_root/.octon/state/control/engagements/eng-001/decisions/decision-001.yml"
  yq -i '.status = "open"' "$decision"
  ! run_validator "$case_root"
}

case_ready_with_stage_only_profile_fails() {
  local case_root work_package
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  yq -i '.evidence_profile.selected_profile = "stage-only"' "$work_package"
  ! run_validator "$case_root"
}

case_non_admitted_connector_ready_fails() {
  local case_root work_package
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  yq -i '.outcome.status = "ready_for_authorization" | .outcome.blockers = [] | .connector_posture.requested_connectors += [{"connector_class_id": "api", "requested_live_effect": false, "operation": "inventory"}]' "$work_package"
  ! run_validator "$case_root"
}

case_connector_live_route_allow_fails() {
  local case_root posture
  case_root="$(new_case)"
  posture="$case_root/.octon/instance/governance/connectors/posture.yml"
  yq -i '(.connector_classes[] | select(.connector_class_id == "api") | .live_effect_route) = "allow"' "$posture"
  ! run_validator "$case_root"
}

case_cli_help_missing_handoff_fails() {
  local case_root help_file
  case_root="$(new_case)"
  help_file="$case_root/.octon/state/evidence/engagements/eng-001/cli/octon-help.txt"
  perl -0pi -e 's/octon run start --contract/run contract handoff/g' "$help_file"
  ! run_validator "$case_root"
}

case_run_contract_candidate_bypass_fails() {
  local case_root candidate
  case_root="$(new_case)"
  candidate="$case_root/.octon/state/control/engagements/eng-001/run-candidates/run-001/run-contract.candidate.yml"
  yq -i '.handoff.bypass_run_start = true | .direct_execution_allowed = true' "$candidate"
  ! run_validator "$case_root"
}

case_stage_only_without_reason_fails() {
  local case_root work_package
  case_root="$(new_case)"
  work_package="$case_root/.octon/state/control/engagements/eng-001/work-package.yml"
  yq -i '.outcome.status = "stage_only" | .outcome.blockers = [] | .outcome.reason_refs = []' "$work_package"
  ! run_validator "$case_root"
}

main() {
  assert_success "valid fixture passes compiler validation" case_valid_fixture_passes
  assert_success "schema metadata omissions fail closed" case_schema_metadata_missing_fails
  assert_success "Objective Brief outside engagement control fails" case_objective_brief_wrong_root_fails
  assert_success "Objective Brief workspace authority claim fails" case_objective_brief_workspace_authority_fails
  assert_success "missing run-contract readiness evidence fails" case_missing_run_readiness_evidence_fails
  assert_success "proposal-local candidate dependency fails" case_raw_input_candidate_dependency_fails
  assert_success "generated authority dependency fails" case_generated_authority_ref_fails
  assert_success "ready outcome with unresolved Decision Request fails" case_ready_with_unresolved_decision_fails
  assert_success "ready outcome with stage-only evidence profile fails" case_ready_with_stage_only_profile_fails
  assert_success "ready outcome with non-admitted connector fails" case_non_admitted_connector_ready_fails
  assert_success "connector live allow route fails" case_connector_live_route_allow_fails
  assert_success "CLI help missing run-start handoff fails" case_cli_help_missing_handoff_fails
  assert_success "run-contract candidate bypass fails" case_run_contract_candidate_bypass_fails
  assert_success "stage-only outcome without reason fails" case_stage_only_without_reason_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

if [[ "${OCTON_ENGAGEMENT_COMPILER_TEST_LIB_ONLY:-0}" != "1" ]]; then
  main "$@"
fi
