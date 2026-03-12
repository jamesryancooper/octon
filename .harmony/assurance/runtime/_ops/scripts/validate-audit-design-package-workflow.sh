#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

DESIGN_PACKAGES_README="$ROOT_DIR/.design-packages/README.md"
WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/audit/audit-design-package"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
CAPABILITY_MAP="$HARMONY_DIR/orchestration/governance/capability-map-v1.yml"
WORKFLOWS_README="$HARMONY_DIR/orchestration/runtime/workflows/README.md"
LEGACY_PACKAGE_PATH=".design-packages/architecture-validation-pipeline-package"
WORKFLOW_PACKAGE_ID="design-package-audit-workflow-package"
WORKFLOW_PACKAGE_ACTIVE_PATH=".design-packages/${WORKFLOW_PACKAGE_ID}"
WORKFLOW_PACKAGE_ARCHIVE_PATH=".design-packages/.archive/${WORKFLOW_PACKAGE_ID}"
EXPECTED_BUNDLE_ROOT=".harmony/output/reports/workflows"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
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

require_fixed() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_absent_fixed() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

check_required_files() {
  local required_files=(
    "$DESIGN_PACKAGES_README"
    "$WORKFLOW_DIR/workflow.yml"
    "$WORKFLOW_DIR/stages/01-configure.md"
    "$WORKFLOW_DIR/stages/02-design-audit.md"
    "$WORKFLOW_DIR/stages/03-design-package-remediation.md"
    "$WORKFLOW_DIR/stages/04-design-red-team.md"
    "$WORKFLOW_DIR/stages/05-design-hardening.md"
    "$WORKFLOW_DIR/stages/06-design-integration.md"
    "$WORKFLOW_DIR/stages/07-implementation-simulation.md"
    "$WORKFLOW_DIR/stages/08-specification-closure.md"
    "$WORKFLOW_DIR/stages/09-extract-blueprint.md"
    "$WORKFLOW_DIR/stages/10-first-implementation-plan.md"
    "$WORKFLOW_DIR/stages/11-report.md"
    "$WORKFLOW_DIR/stages/12-verify.md"
    "$WORKFLOW_DIR/README.md"
    "$WORKFLOW_MANIFEST"
    "$WORKFLOW_REGISTRY"
    "$CAPABILITY_MAP"
    "$WORKFLOWS_README"
  )

  local file
  for file in "${required_files[@]}"; do
    require_file "$file"
  done
}

check_workflow_contract() {
  require_fixed 'schema_version: "workflow-contract-v1"' "$WORKFLOW_DIR/workflow.yml" "workflow contract schema version matches"
  require_fixed 'name: "audit-design-package"' "$WORKFLOW_DIR/workflow.yml" "workflow contract name matches id"
  require_fixed 'forbid_design_packages: true' "$WORKFLOW_DIR/workflow.yml" "workflow contract forbids design-package dependencies"
  require_fixed 'default: ".harmony/output/reports/workflows"' "$WORKFLOW_DIR/workflow.yml" "workflow contract bundle root default uses reports/workflows"
  require_fixed 'validate-design-package-standard.sh --package <target>' "$WORKFLOW_DIR/workflow.yml" "workflow contract records standard-validator done gate"
  require_absent_fixed 'projection:' "$WORKFLOW_DIR/workflow.yml" "workflow contract omits deprecated projection block"
  require_absent_fixed "$LEGACY_PACKAGE_PATH" "$WORKFLOW_DIR/workflow.yml" "workflow contract avoids legacy temporary package path references"
  require_absent_fixed "$WORKFLOW_PACKAGE_ACTIVE_PATH" "$WORKFLOW_DIR/workflow.yml" "workflow contract avoids active temporary package path references"
  require_absent_fixed "$WORKFLOW_PACKAGE_ARCHIVE_PATH" "$WORKFLOW_DIR/workflow.yml" "workflow contract avoids archived temporary package path references"
  require_fixed "temporary workspace for implementation-oriented design" "$DESIGN_PACKAGES_README" ".design-packages README describes temporary purpose"
  require_fixed "They are not canonical runtime" "$DESIGN_PACKAGES_README" ".design-packages README forbids canonical treatment"
}

check_stage_contracts() {
  require_fixed "CHANGE MANIFEST" "$WORKFLOW_DIR/stages/03-design-package-remediation.md" "short remediation requires change manifest"
  require_fixed "zero-change receipt" "$WORKFLOW_DIR/stages/03-design-package-remediation.md" "short remediation permits explicit zero-change receipt"
  require_fixed "CHANGE MANIFEST" "$WORKFLOW_DIR/stages/05-design-hardening.md" "design hardening requires change manifest"
  require_fixed "zero-change receipt" "$WORKFLOW_DIR/stages/05-design-hardening.md" "design hardening permits explicit zero-change receipt"
  require_fixed "CHANGE MANIFEST" "$WORKFLOW_DIR/stages/06-design-integration.md" "design integration requires change manifest"
  require_fixed "zero-change receipt" "$WORKFLOW_DIR/stages/06-design-integration.md" "design integration permits explicit zero-change receipt"
  require_fixed "zero-change receipt" "$WORKFLOW_DIR/stages/08-specification-closure.md" "specification closure permits explicit zero-change receipt"
  require_fixed "validate-design-package-standard.sh" "$WORKFLOW_DIR/stages/12-verify.md" "verify stage runs the standard validator for manifest-bearing packages"
  require_fixed "canonical workflow" "$WORKFLOW_DIR/stages/01-configure.md" "configure stage uses canonical workflow framing"
  require_absent_fixed "./prompts/" "$WORKFLOW_DIR/stages/01-configure.md" "configure stage avoids workflow-local prompt references"
  require_absent_fixed "./references/" "$WORKFLOW_DIR/stages/01-configure.md" "configure stage avoids workflow-local reference paths"
  require_absent_fixed "$LEGACY_PACKAGE_PATH" "$WORKFLOW_DIR/stages/02-design-audit.md" "design audit stage avoids legacy temporary package path references"
  require_absent_fixed "$WORKFLOW_PACKAGE_ACTIVE_PATH" "$WORKFLOW_DIR/stages/02-design-audit.md" "design audit stage avoids active temporary package path references"
  require_absent_fixed "$WORKFLOW_PACKAGE_ARCHIVE_PATH" "$WORKFLOW_DIR/stages/02-design-audit.md" "design audit stage avoids archived temporary package path references"
}

check_registration() {
  if yq -e '.workflows[] | select(.id == "audit-design-package" and .path == "audit/audit-design-package/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1; then
    pass "workflow manifest includes audit-design-package"
  else
    fail "workflow manifest includes audit-design-package"
  fi

  require_fixed 'audit-design-package:' "$WORKFLOW_REGISTRY" "workflow registry includes audit-design-package"
  require_fixed 'commands: ["/audit-design-package"]' "$WORKFLOW_REGISTRY" "workflow registry exposes renamed slash command"
  require_fixed 'workflow_id: "audit-design-package"' "$CAPABILITY_MAP" "capability map classifies workflow"
}

check_output_root_alignment() {
  local workflow_bundle_root registry_bundle_root workflow_paths registry_paths
  workflow_bundle_root="$(yq -r '.inputs[] | select(.name == "bundle_root") | .default' "$WORKFLOW_DIR/workflow.yml")"
  registry_bundle_root="$(yq -r '.workflows."audit-design-package".parameters[] | select(.name == "bundle_root") | .default' "$WORKFLOW_REGISTRY")"

  if [[ "$workflow_bundle_root" == "$EXPECTED_BUNDLE_ROOT" ]]; then
    pass "workflow contract bundle_root default matches expected output root"
  else
    fail "workflow contract bundle_root default matches expected output root"
  fi

  if [[ "$registry_bundle_root" == "$EXPECTED_BUNDLE_ROOT" ]]; then
    pass "workflow registry bundle_root default matches expected output root"
  else
    fail "workflow registry bundle_root default matches expected output root"
  fi

  workflow_paths="$(yq -r '.artifacts[]?.path' "$WORKFLOW_DIR/workflow.yml" | sort)"
  registry_paths="$(yq -r '.workflows."audit-design-package".io.outputs[]?.path' "$WORKFLOW_REGISTRY" | sort)"
  if [[ "$workflow_paths" == "$registry_paths" ]]; then
    pass "workflow contract and registry output paths agree"
  else
    fail "workflow contract and registry output paths agree"
  fi

  if yq -r '.workflows."audit-design-package".io.outputs[]?.path' "$WORKFLOW_REGISTRY" | grep -Fq 'reports/audits/'; then
    fail "workflow registry avoids bounded-audit output paths"
  else
    pass "workflow registry avoids bounded-audit output paths"
  fi
}

check_surface_docs() {
  require_fixed '`workflow.yml` as the canonical machine-readable contract' "$WORKFLOWS_README" "workflow README describes canonical contract role"
  require_fixed '`README.md` as the generated human-readable and slash-facing facet' "$WORKFLOWS_README" "workflow README describes README facet"
}

main() {
  echo "== Audit Design Package Workflow Validation =="

  check_required_files
  check_workflow_contract
  check_stage_contracts
  check_registration
  check_output_root_alignment
  check_surface_docs

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
