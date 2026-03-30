#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ARCH_WORKFLOW="$ROOT_DIR/.github/workflows/architecture-conformance.yml"
PHASE7_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization/plan.md"
PHASE7_ADR="$OCTON_DIR/instance/cognition/decisions/083-unified-execution-constitution-phase7-build-to-delete-institutionalization.md"
PHASE7_EVIDENCE_DIR="$OCTON_DIR/state/evidence/migration/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization"
GOVERNANCE_CONTRACTS="$OCTON_DIR/instance/governance/contracts"
BUILD_TO_DELETE_ROOT="$(yq -r '.latest_review_packet // ""' "$GOVERNANCE_CONTRACTS/closeout-reviews.yml" 2>/dev/null || true)"
PHASE6_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-phase6-simplification-deletion.sh"
CLOSEOUT_VALIDATOR="$OCTON_DIR/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh"

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

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
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
  echo "== Unified Execution Constitution Phase 7 Validation =="

  require_file "$PHASE7_PLAN"
  require_file "$PHASE7_ADR"
  require_dir "$PHASE7_EVIDENCE_DIR"
  require_file "$PHASE7_EVIDENCE_DIR/bundle.yml"
  require_file "$PHASE7_EVIDENCE_DIR/evidence.md"
  require_file "$PHASE7_EVIDENCE_DIR/validation.md"
  require_file "$PHASE7_EVIDENCE_DIR/commands.md"
  require_file "$PHASE7_EVIDENCE_DIR/inventory.md"
  require_file "$ARCH_WORKFLOW"
  require_file "$GOVERNANCE_CONTRACTS/README.md"
  require_file "$GOVERNANCE_CONTRACTS/retirement-policy.yml"
  require_file "$GOVERNANCE_CONTRACTS/retirement-registry.yml"
  require_file "$GOVERNANCE_CONTRACTS/drift-review.yml"
  require_file "$GOVERNANCE_CONTRACTS/support-target-review.yml"
  require_file "$GOVERNANCE_CONTRACTS/adapter-review.yml"
  require_file "$GOVERNANCE_CONTRACTS/retirement-review.yml"
  require_file "$GOVERNANCE_CONTRACTS/ablation-deletion-workflow.yml"
  require_file "$GOVERNANCE_CONTRACTS/closeout-reviews.yml"
  if [[ -z "$BUILD_TO_DELETE_ROOT" ]]; then
    fail "closeout reviews contract does not publish latest_review_packet"
  elif [[ "$BUILD_TO_DELETE_ROOT" == .octon/* ]]; then
    BUILD_TO_DELETE_ROOT="$ROOT_DIR/${BUILD_TO_DELETE_ROOT#./}"
  fi
  require_dir "$BUILD_TO_DELETE_ROOT"
  require_file "$BUILD_TO_DELETE_ROOT/drift-review.yml"
  require_file "$BUILD_TO_DELETE_ROOT/support-target-review.yml"
  require_file "$BUILD_TO_DELETE_ROOT/adapter-review.yml"
  require_file "$BUILD_TO_DELETE_ROOT/retirement-review.yml"
  require_file "$BUILD_TO_DELETE_ROOT/ablation-deletion-receipt.yml"
  require_file "$PHASE6_VALIDATOR"
  require_file "$CLOSEOUT_VALIDATOR"

  require_text 'retirement-registry.yml' "$GOVERNANCE_CONTRACTS/README.md" "governance contracts README publishes retirement registry"
  require_text 'ablation-deletion-workflow.yml' "$GOVERNANCE_CONTRACTS/README.md" "governance contracts README publishes ablation workflow"
  require_text '.octon/instance/governance/contracts/**' "$ARCH_WORKFLOW" "architecture workflow triggers on governance contract changes"
  require_text '.octon/state/evidence/validation/publication/**' "$ARCH_WORKFLOW" "architecture workflow triggers on publication review evidence changes"
  require_text 'validate-phase7-build-to-delete-institutionalization.sh' "$ARCH_WORKFLOW" "architecture workflow enforces Phase 7 validator"
  require_text 'assert-unified-execution-closure.sh' "$ARCH_WORKFLOW" "architecture workflow enforces closeout validator"

  require_yq '.schema_version == "repo-retirement-policy-v2"' "$GOVERNANCE_CONTRACTS/retirement-policy.yml" "retirement policy uses Phase 7 schema"
  require_yq '.entries[] | select(.target_id == "workspace-objective-compatibility-shims" and .review_contract_ref == ".octon/instance/governance/contracts/drift-review.yml")' "$GOVERNANCE_CONTRACTS/retirement-registry.yml" "retirement registry binds workspace shims to drift review"
  require_yq '.entries[] | select(.target_id == "helper-authored-run-projections" and .required_ablation_suite[] == ".octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh")' "$GOVERNANCE_CONTRACTS/retirement-registry.yml" "retirement registry ties helper projections to closeout ablation"
  require_yq '.review_id == "drift-review"' "$GOVERNANCE_CONTRACTS/drift-review.yml" "drift review contract publishes review id"
  require_yq '.review_id == "support-target-review"' "$GOVERNANCE_CONTRACTS/support-target-review.yml" "support-target review contract publishes review id"
  require_yq '.review_id == "adapter-review"' "$GOVERNANCE_CONTRACTS/adapter-review.yml" "adapter review contract publishes review id"
  require_yq '.review_id == "retirement-review"' "$GOVERNANCE_CONTRACTS/retirement-review.yml" "retirement review contract publishes review id"
  require_yq '.workflow_id == "ablation-driven-deletion"' "$GOVERNANCE_CONTRACTS/ablation-deletion-workflow.yml" "ablation workflow contract publishes workflow id"
  require_yq '.review_set_id == "execution-constitution-build-to-delete"' "$GOVERNANCE_CONTRACTS/closeout-reviews.yml" "closeout review set points at build-to-delete packet"
  require_yq '.latest_review_packet | test("^\\.octon/state/evidence/validation/publication/build-to-delete/[0-9]{4}-[0-9]{2}-[0-9]{2}$")' "$GOVERNANCE_CONTRACTS/closeout-reviews.yml" "closeout reviews publish a canonical latest review packet path"
  require_yq '.status == "approved"' "$BUILD_TO_DELETE_ROOT/retirement-review.yml" "retirement review receipt approved"
  require_yq '.status == "completed"' "$BUILD_TO_DELETE_ROOT/ablation-deletion-receipt.yml" "ablation receipt completed"

  run_test \
    "Phase 6 validator still passes under Phase 7 governance" \
    bash "$PHASE6_VALIDATOR"
  run_test \
    "architecture conformance workflow remains valid YAML" \
    yq -e '.' "$ARCH_WORKFLOW"
  run_test \
    "Phase 7 validator script parses" \
    bash -n "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-phase7-build-to-delete-institutionalization.sh"
  run_test \
    "closeout validator script parses" \
    bash -n "$CLOSEOUT_VALIDATOR"
  run_test \
    "git diff check is clean" \
    git diff --check

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
