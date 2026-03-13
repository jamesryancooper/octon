#!/usr/bin/env bash
# test-workflow-system-audit.sh - Regression tests for the workflow-system audit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOWS_DIR="$(cd "$OPS_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$WORKFLOWS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
AUDIT_SCRIPT=".octon/orchestration/runtime/workflows/_ops/scripts/audit-workflow-system.sh"
VALIDATE_SCRIPT=".octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh"

pass_count=0
fail_count=0

declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
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
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi

  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/workflow-system-audit.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p "$fixture_root/.octon"
  cp -R "$REPO_ROOT/.octon/orchestration" "$fixture_root/.octon/"
  mkdir -p "$fixture_root/.octon/cognition/runtime"
  cp -R "$REPO_ROOT/.octon/cognition/runtime/context" "$fixture_root/.octon/cognition/runtime/"
  cp -R "$REPO_ROOT/.octon/cognition/runtime/audits" "$fixture_root/.octon/cognition/runtime/"
  mkdir -p "$fixture_root/.octon/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/.octon/assurance/runtime/_ops/scripts/alignment-check.sh" \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts/alignment-check.sh"
  mkdir -p "$fixture_root/.octon/output/reports/audits" "$fixture_root/.octon/output/.tmp"
  cp "$REPO_ROOT/.octon/output/reports/audits/README.md" \
    "$fixture_root/.octon/output/reports/audits/README.md"

  (
    cd "$fixture_root"
    git init -q
    git config user.email "workflow-audit-test@example.local"
    git config user.name "Workflow Audit Test"
    git add .
    git commit -qm "fixture"
  )

  printf '%s\n' "$fixture_root"
}

run_audit_in_fixture() {
  local fixture_root="$1"
  shift
  (
    cd "$fixture_root"
    bash "$AUDIT_SCRIPT" "$@"
  )
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_score_directory_workflow() {
  (
    cd "$REPO_ROOT"
    bash "$AUDIT_SCRIPT" --mode score-workflow --target ".octon/orchestration/runtime/workflows/refactor/refactor/" \
      | grep -F "Workflow Assessment: refactor"
  )
}

case_score_single_file_workflow() {
  (
    cd "$REPO_ROOT"
    bash "$AUDIT_SCRIPT" --mode score-workflow --target ".octon/orchestration/runtime/workflows/tasks/onboard-new-developer.md" \
      | grep -F "Workflow Assessment: onboard-new-developer"
  )
}

case_duplicate_trigger_fails_validator() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local manifest="$fixture_root/.octon/orchestration/runtime/workflows/manifest.yml"
  local tmp_file
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/workflow-trigger.XXXXXX")"
  awk '
    $0 == "  - id: create-workflow" { in_block=1 }
    in_block && $0 == "      - \"create a workflow\"" {
      print "      - \"evaluate workflow\""
      next
    }
    in_block && $0 == "  - id: evaluate-workflow" { in_block=0 }
    { print }
  ' "$manifest" >"$tmp_file"
  mv "$tmp_file" "$manifest"
  run_validator_in_fixture "$fixture_root"
}

case_missing_required_outcome_fails_scenario_pack() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local workflow_file="$fixture_root/.octon/orchestration/runtime/workflows/projects/create-project/README.md"
  local tmp_file
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/workflow-required-outcome.XXXXXX")"
  awk '
    /^## Verification Gate$/ { skip=1; next }
    skip && /^## / { skip=0 }
    !skip { print }
  ' "$workflow_file" >"$tmp_file"
  mv "$tmp_file" "$workflow_file"
  run_audit_in_fixture "$fixture_root" --mode ci-static
}

case_dependency_cycle_fails_validator() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local registry="$fixture_root/.octon/orchestration/runtime/workflows/registry.yml"
  yq -i '
    .workflows."create-workflow".depends_on = [{"workflow":"evaluate-workflow","condition":"fixture cycle"}] |
    .workflows."evaluate-workflow".depends_on = [{"workflow":"create-workflow","condition":"fixture cycle"}]
  ' "$registry"
  run_validator_in_fixture "$fixture_root"
}

case_external_profile_mismatch_fails_validator() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local manifest="$fixture_root/.octon/orchestration/runtime/workflows/manifest.yml"
  yq -i '
    (.workflows[] | select(.id == "python-api-foundation") | .execution_profile) = "core"
  ' "$manifest"
  run_validator_in_fixture "$fixture_root"
}

case_execution_controls_boolean_is_allowed() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local workflow="$fixture_root/.octon/orchestration/runtime/workflows/meta/create-workflow/workflow.yml"
  yq -i '
    .execution_controls.cancel_safe = true
  ' "$workflow"
  run_validator_in_fixture "$fixture_root"
}

case_execution_controls_non_boolean_fails_validator() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local workflow="$fixture_root/.octon/orchestration/runtime/workflows/meta/create-workflow/workflow.yml"
  yq -i '
    .execution_controls.cancel_safe = "sometimes"
  ' "$workflow"
  run_validator_in_fixture "$fixture_root"
}

case_legacy_authoring_guide_ref_fails_validator() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local stage_file="$fixture_root/.octon/orchestration/runtime/workflows/meta/create-workflow/stages/03-select-template.md"
  printf '\nLegacy scaffold note: `guide/NN-*.md`\n' >>"$stage_file"
  run_validator_in_fixture "$fixture_root"
}

case_capability_map_gap_is_reported() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local capability_map="$fixture_root/.octon/orchestration/governance/capability-map-v1.yml"
  yq -i 'del(.workflows[] | select(.workflow_id == "create-workflow"))' "$capability_map"
  run_audit_in_fixture "$fixture_root" --mode ci-static >/dev/null
  grep -F "capability map is missing classification for 'create-workflow'" \
    "$fixture_root/.octon/output/.tmp/workflow-system-audit/findings.yml"
}

case_parameter_drift_is_reported() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local registry="$fixture_root/.octon/orchestration/runtime/workflows/registry.yml"
  yq -i '
    .workflows."create-project".parameters = [{"name":"mystery_param","type":"text","required":true,"description":"fixture drift"}]
  ' "$registry"
  run_audit_in_fixture "$fixture_root" --mode ci-static >/dev/null
  grep -F "registry parameter 'mystery_param' is undocumented in workflow content" \
    "$fixture_root/.octon/output/.tmp/workflow-system-audit/findings.yml"
}

case_missing_terminal_verification_is_reported() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  local workflow="$fixture_root/.octon/orchestration/runtime/workflows/meta/create-workflow/workflow.yml"
  yq -i '(.stages[-1].kind) = "analysis"' "$workflow"
  run_audit_in_fixture "$fixture_root" --mode ci-static >/dev/null
  grep -F "side-effectful workflow does not terminate in a verification stage" \
    "$fixture_root/.octon/output/.tmp/workflow-system-audit/findings.yml"
}

case_full_mode_emits_bundle() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_audit_in_fixture "$fixture_root" --mode full >/dev/null
  local run_id
  run_id="$(date +%F)-workflow-system-audit"
  [[ -f "$fixture_root/.octon/output/reports/audits/$run_id/bundle.yml" ]]
  [[ -f "$fixture_root/.octon/output/reports/audits/$run_id/findings.yml" ]]
  [[ -f "$fixture_root/.octon/output/reports/audits/$run_id/scores.yml" ]]
  [[ -f "$fixture_root/.octon/output/reports/audits/$run_id/scenarios.yml" ]]
  [[ -f "$fixture_root/.octon/cognition/runtime/audits/$run_id/plan.md" ]]
  [[ -f "$fixture_root/.octon/cognition/runtime/audits/$run_id/evidence.md" ]]
}

main() {
  assert_success \
    "shared scorer handles directory workflows" \
    case_score_directory_workflow

  assert_success \
    "shared scorer handles single-file workflows" \
    case_score_single_file_workflow

  assert_failure_contains \
    "validator rejects duplicate triggers through workflow-system audit" \
    "duplicate trigger" \
    case_duplicate_trigger_fails_validator

  assert_failure_contains \
    "scenario pack fails when representative verification is removed" \
    "representative full rehearsal lacks verification gate" \
    case_missing_required_outcome_fails_scenario_pack

  assert_failure_contains \
    "validator rejects workflow dependency cycles" \
    "workflow dependency cycle detected" \
    case_dependency_cycle_fails_validator

  assert_failure_contains \
    "validator rejects external profile drift" \
    "execution_profile='core'" \
    case_external_profile_mismatch_fails_validator

  assert_success \
    "validator accepts boolean execution_controls.cancel_safe metadata" \
    case_execution_controls_boolean_is_allowed

  assert_failure_contains \
    "validator rejects non-boolean execution_controls.cancel_safe metadata" \
    "must declare execution_controls.cancel_safe as boolean" \
    case_execution_controls_non_boolean_fails_validator

  assert_failure_contains \
    "validator rejects deprecated guide layout in workflow authoring surfaces" \
    "deprecated guide/NN-* authoring layout" \
    case_legacy_authoring_guide_ref_fails_validator

  assert_success \
    "capability map drift is reported by the workflow-system audit" \
    case_capability_map_gap_is_reported

  assert_success \
    "parameter contract drift is reported by the workflow-system audit" \
    case_parameter_drift_is_reported

  assert_success \
    "terminal verification gaps are reported for side-effectful workflows" \
    case_missing_terminal_verification_is_reported

  assert_success \
    "full mode emits bundle and runtime audit artifacts" \
    case_full_mode_emits_bundle

  echo ""
  echo "Workflow-system audit tests complete: $pass_count passed, $fail_count failed"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main "$@"
