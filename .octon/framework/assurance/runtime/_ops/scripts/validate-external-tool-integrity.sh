#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

POLICY="$OCTON_DIR/instance/governance/policies/external-tool-integrity.yml"
CHARTER_MD="$OCTON_DIR/framework/constitution/CHARTER.md"
CHARTER_YML="$OCTON_DIR/framework/constitution/charter.yml"
FAIL_CLOSED="$OCTON_DIR/framework/constitution/obligations/fail-closed.yml"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
WORKSPACE_MD="$OCTON_DIR/instance/charter/workspace.md"
WORKSPACE_YML="$OCTON_DIR/instance/charter/workspace.yml"
INGRESS="$OCTON_DIR/instance/ingress/AGENTS.md"
INGRESS_MANIFEST="$OCTON_DIR/instance/ingress/manifest.yml"
SHARED_CONSTRAINTS="$OCTON_DIR/instance/cognition/context/shared/constraints.md"
ORCHESTRATOR_ROLE="$OCTON_DIR/framework/execution-roles/runtime/orchestrator/ROLE.md"
PRACTICE="$OCTON_DIR/framework/execution-roles/practices/standards/external-tool-integrity.md"
AI_PRACTICE="$OCTON_DIR/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md"
DEPENDENCY_PRACTICE="$OCTON_DIR/framework/execution-roles/practices/standards/dependency-discipline.md"
PROPOSAL_STANDARD="$OCTON_DIR/framework/scaffolding/governance/patterns/proposal-standard.md"
ARCHITECTURE_STANDARD="$OCTON_DIR/framework/scaffolding/governance/patterns/architecture-proposal-standard.md"
BALANCED_METHOD="$OCTON_DIR/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md"
RECEIPT_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"
ALIGNMENT_CHECK="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/alignment-check.sh"

errors=0

pass() {
  printf '[OK] %s\n' "$1"
}

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  errors=$((errors + 1))
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    pass "yq is available"
  else
    printf '[ERROR] yq is required\n' >&2
    exit 1
  fi
}

require_file() {
  local file="$1" label="$2"
  if [[ -f "$file" ]]; then
    pass "$label exists"
  else
    fail "$label exists: $file"
  fi
}

yaml_assert() {
  local file="$1" expression="$2" label="$3"
  if [[ -f "$file" ]] && yq -e "$expression" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

text_assert() {
  local file="$1" needle="$2" label="$3"
  if [[ -f "$file" ]] && rg -Fqi -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  require_yq

  local required_files=(
    "$POLICY"
    "$CHARTER_MD"
    "$CHARTER_YML"
    "$FAIL_CLOSED"
    "$CONTRACT_REGISTRY"
    "$WORKSPACE_MD"
    "$WORKSPACE_YML"
    "$INGRESS"
    "$INGRESS_MANIFEST"
    "$SHARED_CONSTRAINTS"
    "$ORCHESTRATOR_ROLE"
    "$PRACTICE"
    "$AI_PRACTICE"
    "$DEPENDENCY_PRACTICE"
    "$PROPOSAL_STANDARD"
    "$ARCHITECTURE_STANDARD"
    "$BALANCED_METHOD"
    "$RECEIPT_VALIDATOR"
    "$ALIGNMENT_CHECK"
  )
  local file
  for file in "${required_files[@]}"; do
    require_file "$file" "external-tool integrity control surface"
  done

  yaml_assert "$POLICY" \
    '.schema_version == "external-tool-integrity-policy-v1" and .status == "active" and .effective_at == "2026-07-16T14:24:00Z"' \
    "external-tool integrity policy identity and effective time are fixed"
  yaml_assert "$POLICY" \
    '.rules.external_tools_are_immutable_dependencies == true and .rules.octon_owns_all_required_solution_changes == true and .rules.supported_interfaces_only == true' \
    "policy requires immutable external tools and Octon-owned solutions"
  yaml_assert "$POLICY" \
    '.rules.prohibited_strategies[] | select(. == "fork-external-tool")' \
    "policy prohibits external-tool forks"
  yaml_assert "$POLICY" \
    '.rules.prohibited_strategies[] | select(. == "patch-external-tool")' \
    "policy prohibits external-tool patches"
  yaml_assert "$POLICY" \
    '.rules.prohibited_strategies[] | select(. == "reengineer-external-tool")' \
    "policy prohibits external-tool reengineering"
  yaml_assert "$POLICY" \
    '.rules.prohibited_strategies[] | select(. == "depend-on-upstream-change-for-octon-acceptance")' \
    "policy prohibits upstream changes as Octon acceptance dependencies"
  yaml_assert "$POLICY" \
    '.enforcement.review_receipt_coverage_key == "external_tool_integrity" and .enforcement.receipt_requirement_effective_at == "2026-07-16T14:24:00Z" and .enforcement.fail_closed_reason_ref == "FCR-039"' \
    "policy binds review coverage and fail-closed reason"

  yaml_assert "$CHARTER_YML" \
    '.non_negotiables[] | select(.id == "NK-016" and (.rule | test("external tools as immutable dependencies")))' \
    "constitutional charter declares NK-016"
  yaml_assert "$FAIL_CLOSED" \
    '.rules[] | select(.id == "FCR-039" and .route == "DENY" and .adoption_status == "active")' \
    "fail-closed registry declares active DENY rule FCR-039"
  yaml_assert "$WORKSPACE_YML" \
    '.hard_boundaries[] | select(.boundary_id == "external-tool-integrity" and .on_violation == "deny")' \
    "workspace hard boundary denies external-tool modification"
  yaml_assert "$CONTRACT_REGISTRY" \
    '.integration_surfaces.external_tool_integrity_policy.validator_ref == ".octon/framework/assurance/runtime/_ops/scripts/validate-external-tool-integrity.sh"' \
    "constitutional contract registry binds the validator"
  yaml_assert "$INGRESS_MANIFEST" \
    '.conditional_orientation.ai_assisted_development_discipline[] | select(. == ".octon/framework/execution-roles/practices/standards/external-tool-integrity.md")' \
    "ingress manifest requires the external-tool integrity standard for non-trivial AI-assisted work"

  text_assert "$CHARTER_MD" "treat external tools as immutable dependencies" \
    "human-readable charter states the immutable-dependency rule"
  text_assert "$WORKSPACE_MD" "forking, patching, modifying, or reengineering an external tool" \
    "workspace charter excludes external-tool modification"
  text_assert "$INGRESS" "external-tool integrity" \
    "canonical ingress exposes the external-tool integrity boundary"
  text_assert "$SHARED_CONSTRAINTS" "External-tool integrity" \
    "shared prompt context exposes the external-tool integrity constraint"
  text_assert "$ORCHESTRATOR_ROLE" "must never recommend, propose, require, or route work through" \
    "orchestrator role rejects external-tool modification recommendations"
  text_assert "$PRACTICE" "Every required behavior must be implemented inside Octon's own architecture" \
    "dedicated practice requires Octon-owned implementation"
  text_assert "$AI_PRACTICE" "forking, patching, modifying, reengineering" \
    "AI-assisted development discipline forbids external-tool modification strategies"
  text_assert "$DEPENDENCY_PRACTICE" "External tools remain unmodified dependencies" \
    "dependency discipline preserves external tools unmodified"
  text_assert "$PROPOSAL_STANDARD" "External tools may be used only through supported interfaces" \
    "generic proposal standard requires supported interfaces"
  text_assert "$ARCHITECTURE_STANDARD" "invalid target architecture" \
    "architecture proposal standard rejects external-tool modification targets"
  text_assert "$BALANCED_METHOD" "External-tool integrity gate" \
    "Balanced Architecture Review Method includes the external-tool integrity gate"

  local template_root="$OCTON_DIR/framework/scaffolding/runtime/templates/proposal-architecture-core"
  text_assert "$template_root/architecture/target-architecture.md" "External Tool Boundary" \
    "target-architecture template captures the external-tool boundary"
  text_assert "$template_root/architecture/implementation-plan.md" "External Tool Integrity" \
    "implementation-plan template captures external-tool integrity"
  text_assert "$template_root/architecture/acceptance-criteria.md" "Every external tool remains an unmodified supported release" \
    "acceptance template requires unmodified external tools"
  text_assert "$template_root/navigation/source-of-truth-map.md" "External tools are non-authoritative, unmodified dependencies" \
    "source-of-truth template keeps external tools non-authoritative"

  local workflow_root="$OCTON_DIR/framework/orchestration/runtime/workflows/audit"
  local occasion
  for occasion in \
    pre-integration-architecture-review \
    post-integration-architecture-review \
    current-state-mechanism-architecture-review \
    architecture-readiness-audit; do
    text_assert "$workflow_root/$occasion/stages/01-configure.md" \
      ".octon/instance/governance/policies/external-tool-integrity.yml" \
      "$occasion loads the external-tool integrity policy"
  done

  text_assert "$RECEIPT_VALIDATOR" "EXTERNAL_TOOL_INTEGRITY_COVERAGE_KEY" \
    "architectural-review receipt validator enforces external-tool integrity coverage"
  text_assert "$ALIGNMENT_CHECK" "validate-external-tool-integrity.sh" \
    "harness alignment invokes the external-tool integrity validator"

  printf 'Validation summary: errors=%s\n' "$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"
