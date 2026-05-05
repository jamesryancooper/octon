#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

POLICY="$OCTON_DIR/instance/governance/policies/repo-hygiene.yml"
HOST_TOOL_REQUIREMENTS="$OCTON_DIR/instance/capabilities/runtime/host-tools/requirements.yml"
HOST_TOOL_POLICY="$OCTON_DIR/instance/governance/policies/host-tool-resolution.yml"
PROVISION_HOST_TOOLS_DOC="$OCTON_DIR/framework/capabilities/runtime/commands/provision-host-tools.md"
PROVISION_HOST_TOOLS_SCRIPT="$OCTON_DIR/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh"
COMMAND_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
COMMAND_README="$OCTON_DIR/instance/capabilities/runtime/commands/repo-hygiene/README.md"
COMMAND_SCRIPT="$OCTON_DIR/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh"
COMMAND_COMMON="$OCTON_DIR/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene-common.sh"
LOCAL_ARTIFACT_CLEANUP_SCRIPT="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"
LOCAL_ARTIFACT_CLEANUP_TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh"
LEGACY_PUBLICATION_CLEANUP_SCRIPT="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh"
EVIDENCE_STORE_SPEC="$OCTON_DIR/framework/engine/runtime/spec/evidence-store-v1.md"
CLEANUP_PASS_STANDARD="$OCTON_DIR/framework/execution-roles/practices/standards/cleanup-pass.md"
CLOSEOUT_REQUEST_STAGE="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md"
RETIREMENT_POLICY="$OCTON_DIR/instance/governance/contracts/retirement-policy.yml"
RETIREMENT_REVIEW="$OCTON_DIR/instance/governance/contracts/retirement-review.yml"
DRIFT_REVIEW="$OCTON_DIR/instance/governance/contracts/drift-review.yml"
ABLATION_WORKFLOW="$OCTON_DIR/instance/governance/contracts/ablation-deletion-workflow.yml"
ARCH_WORKFLOW="$ROOT_DIR/.github/workflows/architecture-conformance.yml"
CLOSURE_WORKFLOW="$ROOT_DIR/.github/workflows/closure-certification.yml"
REPO_HYGIENE_WORKFLOW="$ROOT_DIR/.github/workflows/repo-hygiene.yml"
LATEST_PACKET_REL="$(yq -r '.latest_review_packet // ""' "$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml" 2>/dev/null || true)"
LATEST_PACKET_ATTACHMENT=""
if [[ -n "$LATEST_PACKET_REL" && "$LATEST_PACKET_REL" != "null" ]]; then
  LATEST_PACKET_ATTACHMENT="$ROOT_DIR/${LATEST_PACKET_REL#./}/repo-hygiene-findings.yml"
fi

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq -- "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  elif grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_yq() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
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
  echo "== Repo Hygiene Governance Validation =="

  require_file "$POLICY"
  require_file "$HOST_TOOL_REQUIREMENTS"
  require_file "$HOST_TOOL_POLICY"
  require_file "$PROVISION_HOST_TOOLS_DOC"
  require_file "$PROVISION_HOST_TOOLS_SCRIPT"
  require_file "$COMMAND_MANIFEST"
  require_file "$COMMAND_README"
  require_file "$COMMAND_SCRIPT"
  require_file "$COMMAND_COMMON"
  require_file "$LOCAL_ARTIFACT_CLEANUP_SCRIPT"
  require_file "$LOCAL_ARTIFACT_CLEANUP_TEST"
  require_file "$LEGACY_PUBLICATION_CLEANUP_SCRIPT"
  require_file "$EVIDENCE_STORE_SPEC"
  require_file "$CLEANUP_PASS_STANDARD"
  require_file "$CLOSEOUT_REQUEST_STAGE"
  require_file "$RETIREMENT_POLICY"
  require_file "$RETIREMENT_REVIEW"
  require_file "$DRIFT_REVIEW"
  require_file "$ABLATION_WORKFLOW"
  require_file "$ARCH_WORKFLOW"
  require_file "$CLOSURE_WORKFLOW"
  require_file "$REPO_HYGIENE_WORKFLOW"
  if [[ -n "$LATEST_PACKET_ATTACHMENT" ]]; then
    require_file "$LATEST_PACKET_ATTACHMENT"
  else
    fail "closeout reviews do not publish a latest review packet for repo-hygiene attachment validation"
  fi

  require_yq '.schema_version == "repo-hygiene-policy-v1"' "$POLICY" "repo-hygiene policy schema is correct"
  require_yq '(.decision_grammar.allowed_actions | length) == 6 and (.decision_grammar.allowed_actions[] | select(. == "safe-to-delete")) and (.decision_grammar.allowed_actions[] | select(. == "needs-ablation-before-delete")) and (.decision_grammar.allowed_actions[] | select(. == "retain-with-rationale")) and (.decision_grammar.allowed_actions[] | select(. == "demote-to-historical")) and (.decision_grammar.allowed_actions[] | select(. == "register-for-future-retirement")) and (.decision_grammar.allowed_actions[] | select(. == "never-delete"))' "$POLICY" "repo-hygiene policy publishes the exact decision grammar"
  require_yq '.decision_grammar.invariants.unused_not_equivalent_to_safe_to_delete == true' "$POLICY" "repo-hygiene policy forbids unused == safe-to-delete"
  require_yq '.dynamic_inputs.release_lineage_ref == ".octon/instance/governance/disclosure/release-lineage.yml"' "$POLICY" "repo-hygiene policy binds release lineage"
  require_yq '.dynamic_inputs.closeout_reviews_ref == ".octon/instance/governance/contracts/closeout-reviews.yml"' "$POLICY" "repo-hygiene policy binds closeout reviews"
  require_yq '.dynamic_inputs.claim_gate_ref == ".octon/instance/governance/retirement/claim-gate.yml"' "$POLICY" "repo-hygiene policy binds claim gate"
  require_yq '.ai_assisted_cleanup_refs.local_run_artifact_cleanup_helper_ref == ".octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"' "$POLICY" "repo-hygiene policy references local run artifact cleanup helper"
  require_yq '.finding_classes[] | select(.id == "local-run-control-evidence-residue") | .allowed_actions[] | select(. == "safe-to-delete")' "$POLICY" "repo-hygiene policy classifies local run/control/evidence residue"
  require_yq '.detectors[] | select(.id == "local-run-artifact-classifier" and .command == "bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --summary-only")' "$POLICY" "repo-hygiene policy declares local run artifact classifier detector"
  require_yq '.local_artifact_hygiene.default_mode == "dry-run"' "$POLICY" "local artifact hygiene defaults to dry-run"
  require_yq '.local_artifact_hygiene.deletion_requires[] | select(. == "explicit --confirm operator action")' "$POLICY" "local artifact hygiene requires explicit confirmation before deletion"
  require_yq '.same_change_requirements[] | select(.id == "RH-005")' "$POLICY" "repo-hygiene policy gates untracked local state residue classification"
  require_yq '.consumers."repo-hygiene".mode_requirements.audit.mandatory_tools."cargo-udeps".version == "0.1.60"' "$HOST_TOOL_REQUIREMENTS" "repo-hygiene host-tool requirements declare cargo-udeps"
  require_yq '.installer_posture.init_must_not_install == true' "$HOST_TOOL_POLICY" "host-tool policy preserves /init boundary"
  require_yq '.commands[] | select(.id == "repo-hygiene" and .path == "repo-hygiene/README.md" and .access == "agent")' "$COMMAND_MANIFEST" "instance command manifest registers repo-hygiene"
  require_text 'scan' "$COMMAND_README" "repo-hygiene README documents scan mode"
  require_text 'enforce' "$COMMAND_README" "repo-hygiene README documents enforce mode"
  require_text 'audit' "$COMMAND_README" "repo-hygiene README documents audit mode"
  require_text 'packetize' "$COMMAND_README" "repo-hygiene README documents packetize mode"
  require_text 'cleanup-local-run-artifacts.sh' "$COMMAND_README" "repo-hygiene README documents local run artifact helper"
  require_text 'host-tools/requirements.yml' "$COMMAND_README" "repo-hygiene README points at host-tool requirements"
  require_text 'provision-host-tools' "$COMMAND_README" "repo-hygiene README points at provisioning command"
  require_text 'provision-host-tools.sh' "$COMMAND_COMMON" "repo-hygiene implementation resolves tools through provisioning runtime"
  require_text 'cleanup-local-run-artifacts.sh' "$EVIDENCE_STORE_SPEC" "evidence store specifies local run residue classifier"
  require_text 'stale unreferenced publication attempt' "$EVIDENCE_STORE_SPEC" "evidence store defines stale publication attempt classification"
  require_text 'cleanup-local-run-artifacts.sh' "$CLEANUP_PASS_STANDARD" "cleanup pass routes local run artifacts through helper"
  require_text 'cleanup-local-run-artifacts.sh' "$CLOSEOUT_REQUEST_STAGE" "closeout workflow classifies local state residue before cleaned outcome"
  require_text 'cleanup-local-run-artifacts.sh' "$LEGACY_PUBLICATION_CLEANUP_SCRIPT" "legacy publication cleanup delegates to local artifact helper"
  require_text 'repo-hygiene.yml' "$RETIREMENT_POLICY" "retirement policy references repo-hygiene policy"
  require_text 'repo-hygiene-findings.yml' "$RETIREMENT_REVIEW" "retirement review requires repo-hygiene attachment"
  require_text 'repo-hygiene-findings.yml' "$DRIFT_REVIEW" "drift review requires repo-hygiene attachment"
  require_text 'repo-hygiene-findings-attachment' "$ABLATION_WORKFLOW" "ablation workflow requires repo-hygiene attachment evidence"
  require_text '.octon/instance/capabilities/runtime/commands/**' "$ARCH_WORKFLOW" "architecture workflow triggers on repo-native command lane"
  require_text 'validate-repo-hygiene-governance.sh' "$ARCH_WORKFLOW" "architecture workflow runs repo-hygiene governance validator"
  require_text 'validate-global-retirement-closure.sh' "$CLOSURE_WORKFLOW" "closure workflow runs global retirement closure validator"
  require_text 'repo-hygiene.sh enforce' "$REPO_HYGIENE_WORKFLOW" "repo-hygiene workflow runs enforce mode"
  require_text 'repo-hygiene.sh audit' "$REPO_HYGIENE_WORKFLOW" "repo-hygiene workflow runs audit mode"
  require_yq '.summary.packetization_ready == true' "$LATEST_PACKET_ATTACHMENT" "latest repo-hygiene packet attachment is closure-ready"

  run_test "repo-hygiene policy parses" yq -e '.' "$POLICY"
  run_test "host-tool requirements parse" yq -e '.' "$HOST_TOOL_REQUIREMENTS"
  run_test "host-tool resolution policy parses" yq -e '.' "$HOST_TOOL_POLICY"
  run_test "instance command manifest parses" yq -e '.' "$COMMAND_MANIFEST"
  run_test "repo-hygiene workflow parses" yq -e '.' "$REPO_HYGIENE_WORKFLOW"
  run_test "architecture workflow parses" yq -e '.' "$ARCH_WORKFLOW"
  run_test "closure workflow parses" yq -e '.' "$CLOSURE_WORKFLOW"
  run_test "repo-hygiene main script parses" bash -n "$COMMAND_SCRIPT"
  run_test "repo-hygiene common script parses" bash -n "$COMMAND_COMMON"
  run_test "local run artifact cleanup script parses" bash -n "$LOCAL_ARTIFACT_CLEANUP_SCRIPT"
  run_test "legacy publication cleanup wrapper parses" bash -n "$LEGACY_PUBLICATION_CLEANUP_SCRIPT"
  run_test "local run artifact cleanup helper tests pass" bash "$LOCAL_ARTIFACT_CLEANUP_TEST"
  run_test "repo-hygiene validator parses" bash -n "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh"
  run_test "git diff check is clean" git diff --check

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
