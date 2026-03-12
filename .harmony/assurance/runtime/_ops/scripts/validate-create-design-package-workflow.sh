#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/meta/create-design-package"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
WORKFLOWS_README="$HARMONY_DIR/orchestration/runtime/workflows/README.md"

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

check_required_files() {
  local required_files=(
    "$WORKFLOW_DIR/workflow.yml"
    "$WORKFLOW_DIR/stages/01-validate-request.md"
    "$WORKFLOW_DIR/stages/02-select-bundles.md"
    "$WORKFLOW_DIR/stages/03-scaffold-package.md"
    "$WORKFLOW_DIR/stages/04-validate-package.md"
    "$WORKFLOW_DIR/stages/05-report.md"
    "$WORKFLOW_DIR/README.md"
    "$WORKFLOW_MANIFEST"
    "$WORKFLOW_REGISTRY"
    "$WORKFLOWS_README"
  )

  local file
  for file in "${required_files[@]}"; do
    require_file "$file"
  done
}

check_workflow_contract() {
  require_fixed 'schema_version: "workflow-contract-v1"' "$WORKFLOW_DIR/workflow.yml" "workflow contract schema version matches"
  require_fixed 'name: "create-design-package"' "$WORKFLOW_DIR/workflow.yml" "workflow contract name matches id"
  require_fixed 'forbid_design_packages: false' "$WORKFLOW_DIR/workflow.yml" "workflow contract allows design-package writes"
  require_fixed '../../../../../.harmony/output/reports/{{date}}-create-design-package.md' "$WORKFLOW_DIR/workflow.yml" "workflow contract declares top-level summary output"
  require_fixed '../../../../../.harmony/output/reports/workflows/{{date}}-create-design-package-{{package_id}}/' "$WORKFLOW_DIR/workflow.yml" "workflow contract declares workflow bundle output"
  require_fixed 'standard-validator.log' "$WORKFLOW_DIR/workflow.yml" "workflow contract declares validator log output"
  require_fixed '`bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md` exist' "$WORKFLOW_DIR/workflow.yml" "workflow contract records workflow bundle done-gate files"
}

check_stage_contracts() {
  require_fixed '.design-packages/registry.yml' "$WORKFLOW_DIR/stages/03-scaffold-package.md" "scaffold stage guarantees registry update"
  require_fixed 'validate-design-package-standard.sh' "$WORKFLOW_DIR/stages/04-validate-package.md" "validate stage runs the standard package validator"
  require_fixed 'standard-validator.log' "$WORKFLOW_DIR/stages/04-validate-package.md" "validate stage records validator log"
  require_fixed 'bundle.yml' "$WORKFLOW_DIR/stages/05-report.md" "report stage writes bundle metadata"
  require_fixed 'summary.md' "$WORKFLOW_DIR/stages/05-report.md" "report stage writes bundle summary"
  require_fixed '.harmony/output/reports/' "$WORKFLOW_DIR/stages/05-report.md" "report stage writes top-level summary"
}

check_registration() {
  if yq -e '.workflows[] | select(.id == "create-design-package" and .path == "meta/create-design-package/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1; then
    pass "workflow manifest includes create-design-package"
  else
    fail "workflow manifest includes create-design-package"
  fi

  require_fixed 'create-design-package:' "$WORKFLOW_REGISTRY" "workflow registry includes create-design-package"
  require_fixed 'commands: ["/create-design-package"]' "$WORKFLOW_REGISTRY" "workflow registry exposes create-design-package slash command"
}

check_output_alignment() {
  local workflow_paths registry_paths
  workflow_paths="$(yq -r '.artifacts[]?.path' "$WORKFLOW_DIR/workflow.yml" | sort)"
  registry_paths="$(yq -r '.workflows."create-design-package".io.outputs[]?.path' "$WORKFLOW_REGISTRY" | sort)"

  if [[ "$workflow_paths" == "$registry_paths" ]]; then
    pass "workflow contract and registry output paths agree"
  else
    fail "workflow contract and registry output paths agree"
  fi
}

check_surface_docs() {
  require_fixed '`workflow.yml` as the canonical machine-readable contract' "$WORKFLOWS_README" "workflow README describes canonical contract role"
  require_fixed '`README.md` as the generated human-readable and slash-facing facet' "$WORKFLOWS_README" "workflow README describes README facet"
}

main() {
  echo "== Create Design Package Workflow Validation =="

  check_required_files
  check_workflow_contract
  check_stage_contracts
  check_registration
  check_output_alignment
  check_surface_docs

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
