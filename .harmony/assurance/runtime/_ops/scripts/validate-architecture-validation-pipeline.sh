#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

DESIGN_PACKAGES_README="$ROOT_DIR/.design-packages/README.md"
PIPELINE_DIR="$HARMONY_DIR/orchestration/runtime/pipelines/audit/audit-design-package-workflow"
PIPELINE_MANIFEST="$HARMONY_DIR/orchestration/runtime/pipelines/manifest.yml"
PIPELINE_REGISTRY="$HARMONY_DIR/orchestration/runtime/pipelines/registry.yml"
WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/audit/audit-design-package-workflow"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
CAPABILITY_MAP="$HARMONY_DIR/orchestration/governance/capability-map-v1.yml"
WORKFLOWS_README="$HARMONY_DIR/orchestration/runtime/workflows/README.md"
PIPELINES_README="$HARMONY_DIR/orchestration/runtime/pipelines/README.md"

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
  local file
  local required_files=(
    "$DESIGN_PACKAGES_README"
    "$PIPELINE_DIR/pipeline.yml"
    "$PIPELINE_DIR/stages/01-configure.md"
    "$PIPELINE_DIR/stages/02-design-audit.md"
    "$PIPELINE_DIR/stages/03-remediation-track.md"
    "$PIPELINE_DIR/stages/04-implementation-simulation.md"
    "$PIPELINE_DIR/stages/05-specification-closure.md"
    "$PIPELINE_DIR/stages/06-extract-blueprint.md"
    "$PIPELINE_DIR/stages/07-first-implementation-plan.md"
    "$PIPELINE_DIR/stages/08-report.md"
    "$PIPELINE_DIR/stages/09-verify.md"
    "$PIPELINE_MANIFEST"
    "$PIPELINE_REGISTRY"
    "$WORKFLOW_MANIFEST"
    "$WORKFLOW_REGISTRY"
    "$WORKFLOW_DIR/WORKFLOW.md"
    "$CAPABILITY_MAP"
    "$WORKFLOWS_README"
    "$PIPELINES_README"
  )

  for file in "${required_files[@]}"; do
    require_file "$file"
  done
}

check_pipeline_contract() {
  require_fixed 'name: "audit-design-package-workflow"' "$PIPELINE_DIR/pipeline.yml" "pipeline contract name matches id"
  require_fixed 'projection:' "$PIPELINE_DIR/pipeline.yml" "pipeline contract declares workflow projection"
  require_fixed 'projection_format: "directory"' "$PIPELINE_DIR/pipeline.yml" "pipeline contract declares directory projection"
  require_fixed 'forbid_design_packages: true' "$PIPELINE_DIR/pipeline.yml" "pipeline contract forbids design-package dependencies"
  require_fixed "temporary workspace for implementation-oriented design" "$DESIGN_PACKAGES_README" ".design-packages README describes temporary purpose"
  require_fixed "They are not canonical runtime" "$DESIGN_PACKAGES_README" ".design-packages README forbids canonical treatment"
  require_absent_fixed ".design-packages/architecture-validation-pipeline-package" "$PIPELINE_DIR/pipeline.yml" "pipeline contract avoids temporary package path references"
}

check_stage_contracts() {
  require_fixed "CHANGE MANIFEST" "$PIPELINE_DIR/stages/03-remediation-track.md" "remediation track requires change manifest"
  require_fixed "zero-change receipt" "$PIPELINE_DIR/stages/03-remediation-track.md" "remediation track permits explicit zero-change receipt"
  require_fixed "zero-change receipt" "$PIPELINE_DIR/stages/05-specification-closure.md" "specification closure permits explicit zero-change receipt"
  require_fixed "canonical" "$PIPELINE_DIR/stages/01-configure.md" "configure stage uses canonical pipeline framing"
  require_absent_fixed "./prompts/" "$PIPELINE_DIR/stages/01-configure.md" "configure stage avoids workflow-local prompt references"
  require_absent_fixed "./references/" "$PIPELINE_DIR/stages/01-configure.md" "configure stage avoids workflow-local reference paths"
  require_absent_fixed ".design-packages/architecture-validation-pipeline-package" "$PIPELINE_DIR/stages/02-design-audit.md" "design audit stage avoids temporary package path references"
}

check_registration() {
  if yq -e '.pipelines[] | select(.id == "audit-design-package-workflow")' "$PIPELINE_MANIFEST" >/dev/null 2>&1; then
    pass "pipeline manifest includes audit-design-package-workflow"
  else
    fail "pipeline manifest includes audit-design-package-workflow"
  fi
  if yq -e '.pipelines[] | select(.id == "audit-design-package-workflow" and .path == "audit/audit-design-package-workflow/")' "$PIPELINE_MANIFEST" >/dev/null 2>&1; then
    pass "pipeline manifest path matches pipeline directory"
  else
    fail "pipeline manifest path matches pipeline directory"
  fi
  require_fixed "audit-design-package-workflow" "$PIPELINE_REGISTRY" "pipeline registry includes audit-design-package-workflow"
  require_fixed 'workflow_path: ".harmony/orchestration/runtime/workflows/audit/audit-design-package-workflow/"' "$PIPELINE_REGISTRY" "pipeline registry points at workflow projection"

  require_fixed "- id: audit-design-package-workflow" "$WORKFLOW_MANIFEST" "workflow manifest includes projected workflow"
  require_fixed "audit-design-package-workflow" "$WORKFLOW_REGISTRY" "workflow registry includes projected workflow"
  require_fixed "pipeline_path: .harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow/" "$WORKFLOW_REGISTRY" "workflow registry points back to canonical pipeline"
  require_fixed 'workflow_id: "audit-design-package-workflow"' "$CAPABILITY_MAP" "capability map classifies workflow"
}

check_surface_docs() {
  require_fixed "generated projection/readability surfaces" "$WORKFLOWS_README" "workflow README describes projection role"
  require_fixed "canonical autonomous orchestration surface" "$PIPELINES_README" "pipelines README describes canonical role"
}

main() {
  echo "== Architecture Validation Pipeline Validation =="

  check_required_files
  check_pipeline_contract
  check_stage_contracts
  check_registration
  check_surface_docs

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
