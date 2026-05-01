#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY_MD="$OCTON_DIR/framework/product/contracts/default-work-unit.md"
POLICY_YML="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
RECEIPT_SCHEMA="$OCTON_DIR/framework/product/contracts/change-receipt-v1.schema.json"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
ARCH_REGISTRY="$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"
NORMATIVE="$OCTON_DIR/framework/constitution/precedence/normative.yml"
WORKTREE_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"
SKILL_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
SKILL_REGISTRY="$OCTON_DIR/framework/capabilities/runtime/skills/registry.yml"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
CLOSEOUT_PR="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
LIFECYCLE_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
HOSTED_NO_PR_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
GITHUB_RULESET_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"
CHANGE_PACKAGE_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/change-package-v1.schema.json"
CHANGE_PACKAGE_CONSTITUTIONAL_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/change-package-v1.schema.json"
CHANGE_PACKAGE_COMPILER="$OCTON_DIR/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md"
COMMIT_PR_STANDARDS="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"
GITHUB_CONTROL_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"
AI_GATE_POLICY="$OCTON_DIR/framework/execution-roles/practices/standards/ai-gate-policy.json"
REVIEW_ROUTING="$OCTON_DIR/framework/assurance/evaluators/review-routing.yml"

errors=0

pass() {
  echo "[OK] $1"
}

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

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

require_absent_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Fq -- "$needle" "$file"; then
    fail "$fail_msg"
  else
    pass "$ok_msg"
  fi
}

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if jq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

check_core_contracts() {
  require_file "$POLICY_MD"
  require_file "$POLICY_YML"
  require_file "$RECEIPT_SCHEMA"
  require_file "$CHANGE_PACKAGE_SCHEMA"
  require_file "$CHANGE_PACKAGE_CONSTITUTIONAL_SCHEMA"
  require_file "$CHANGE_PACKAGE_COMPILER"
  require_file "$LIFECYCLE_VALIDATOR"
  require_file "$COMMIT_PR_STANDARDS"
  require_file "$GITHUB_CONTROL_CONTRACT"
  require_file "$AI_GATE_POLICY"
  require_file "$HOSTED_NO_PR_VALIDATOR"
  require_file "$GITHUB_RULESET_VALIDATOR"

  require_yq "$POLICY_YML" '.default_work_unit == "change"' "machine policy declares Change as default work unit" "machine policy must declare Change as default work unit"
  require_yq "$POLICY_YML" '.internal_execution_bundle == "change-package"' "machine policy declares Change Package as internal bundle" "machine policy must declare Change Package as internal bundle"
  for route in direct-main branch-no-pr branch-pr stage-only-escalate; do
    require_yq "$POLICY_YML" ".routes[]? | select(.route_id == \"$route\")" "machine policy exposes route $route" "machine policy missing route $route"
    require_jq "$RECEIPT_SCHEMA" ".properties.selected_route.enum[] | select(. == \"$route\")" "receipt schema accepts route $route" "receipt schema missing route $route"
  done
  require_jq "$RECEIPT_SCHEMA" '.required[] | select(. == "rollback_handle")' "receipt schema requires rollback handle" "receipt schema must require rollback_handle"
  for field in lifecycle_outcome integration_status publication_status cleanup_status; do
    require_jq "$RECEIPT_SCHEMA" ".required[] | select(. == \"$field\")" "receipt schema requires $field" "receipt schema must require $field"
  done
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "provider_ruleset_ref")' "receipt schema requires hosted landing provider evidence" "receipt schema must require hosted landing provider evidence"
  require_jq "$RECEIPT_SCHEMA" '.properties.publication_status.enum[] | select(. == "hosted-main-updated")' "receipt schema models hosted main update status" "receipt schema must model hosted main update status"
  for outcome in preserved branch-local-complete published-branch published ready landed cleaned blocked escalated denied; do
    require_jq "$RECEIPT_SCHEMA" ".properties.lifecycle_outcome.enum[] | select(. == \"$outcome\")" "receipt schema accepts lifecycle outcome $outcome" "receipt schema missing lifecycle outcome $outcome"
  done
  require_yq "$POLICY_YML" '.route_lifecycle_outcomes."branch-no-pr".allowed_outcomes[]? | select(. == "landed")' "machine policy allows no-PR branch landing outcome" "machine policy must model no-PR branch landing as branch-no-pr outcome"
  require_yq "$POLICY_YML" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "origin_main_equals_landed_ref_after_push")' "machine policy requires origin/main equality for no-PR landing" "machine policy must require origin/main equality for no-PR landing"
  require_yq "$POLICY_YML" '.fail_closed_conditions[]? | select(. == "provider_ruleset_blocks_requested_hosted_no_pr_landing")' "machine policy fails closed when ruleset blocks no-PR landing" "machine policy must fail closed when ruleset blocks no-PR landing"
  require_yq "$POLICY_YML" '.hosted_provider_ruleset.target_model == "route-neutral protected main"' "machine policy defines route-neutral hosted ruleset target" "machine policy must define route-neutral hosted ruleset target"
  require_yq "$POLICY_YML" '.hosted_provider_ruleset.pr_specific_checks[]? | select(. == "AI Review Gate / decision")' "machine policy keeps AI review gate PR-specific" "machine policy must keep AI review gate PR-specific"
  require_yq "$POLICY_YML" '.route_lifecycle_outcomes."branch-pr".allowed_outcomes[]? | select(. == "ready")' "machine policy distinguishes PR ready outcome" "machine policy must distinguish PR ready outcome"
  if yq -e '.routes[]? | select(.route_id == "branch-land-no-pr")' "$POLICY_YML" >/dev/null 2>&1; then
    fail "machine policy must not add branch-land-no-pr top-level route"
  else
    pass "machine policy keeps no-PR branch landing as lifecycle outcome, not top-level route"
  fi
  require_jq "$CHANGE_PACKAGE_SCHEMA" '.properties.schema_version.const == "change-package-v1"' "runtime Change Package schema has target schema version" "runtime Change Package schema must use change-package-v1"
  require_jq "$COMMIT_PR_STANDARDS" '.change.default_work_unit == "change" and (.change.pr_required_routes[]? == "branch-pr")' "commit/PR standards bind to Change routes" "commit/PR standards must bind to Change routes"
  require_jq "$GITHUB_CONTROL_CONTRACT" '.scope.projection_host_for == "PR-backed Changes" and .direct_main_projection.github_pr_metadata_required == false' "GitHub control contract is projection-only for PR-backed Changes" "GitHub control contract must stay projection-only"
  require_jq "$AI_GATE_POLICY" '.route_scope.hosted_gate_route == "branch-pr" and .route_scope.no_pr_change_gate_required == false' "AI gate policy is scoped to hosted PR route" "AI gate policy must be scoped to hosted PR route"
  require_yq "$REVIEW_ROUTING" '.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "review routing references default work unit policy" "review routing must reference default work unit policy"
}

check_discovery_and_routing() {
  require_yq "$CONTRACT_REGISTRY" '.integration_surfaces.default_work_unit_policy.machine_contract == ".octon/framework/product/contracts/default-work-unit.yml"' "constitutional registry exposes default work unit policy" "constitutional registry missing default work unit policy"
  require_yq "$ARCH_REGISTRY" '.path_families.default_work_unit_policy.canonical_paths[]? | select(. == ".octon/framework/product/contracts/default-work-unit.yml")' "architecture registry exposes machine policy contract" "architecture registry missing default work unit policy"
  require_yq "$NORMATIVE" '.layers[]? | select(.authority == "product-and-repo-governance-declarations") | .surfaces[]? | select(. == ".octon/framework/product/contracts/default-work-unit.yml")' "normative precedence includes default work unit policy" "normative precedence missing default work unit policy"
  require_yq "$WORKTREE_CONTRACT" '.policy_refs.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "Git/worktree contract defers to default work unit policy" "Git/worktree contract must defer to default work unit policy"
  require_yq "$WORKFLOW" '.policy_refs.owner_surface_ref == ".octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"' "closeout workflow owner is closeout-change" "closeout workflow must use closeout-change as owner"
  require_yq "$SKILL_MANIFEST" '.skills[]? | select(.id == "closeout-change")' "skill manifest exposes closeout-change" "skill manifest missing closeout-change"
  require_yq "$SKILL_REGISTRY" '.skills | has("closeout-change")' "skill registry exposes closeout-change" "skill registry missing closeout-change"
  require_literal "$CLOSEOUT_CHANGE" 'Do not open a PR unless route selection returns `branch-pr`.' "closeout-change forbids PR before branch-pr route" "closeout-change must forbid PR before branch-pr route"
  require_literal "$CLOSEOUT_CHANGE" 'Select Outcome' "closeout-change resolves lifecycle outcome" "closeout-change must resolve lifecycle outcome separately"
  require_literal "$CLOSEOUT_PR" 'selected route `branch-pr`' "closeout-pr requires branch-pr route" "closeout-pr must require upstream branch-pr route"
  require_literal "$CLOSEOUT_PR" 'Draft/open PR state is `published`, not full closeout' "closeout-pr distinguishes published from full closeout" "closeout-pr must not treat draft/open PR as full closeout"
}

check_no_active_legacy_or_default_drift() {
  local drift
  drift="$(
    cd "$OCTON_DIR"
    rg -n "Work Package|WorkPackage|work package|work-package|work_package|WORK_PACKAGE" framework instance \
      -g '!framework/product/contracts/default-work-unit.*' \
      -g '!framework/scaffolding/practices/prompts/**' \
      -g '!framework/scaffolding/governance/patterns/proposal-standard.md' \
      -g '!framework/orchestration/runtime/workflows/meta/audit-post-implementation-drift/**' \
      -g '!framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh' \
      -g '!framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh' \
      -g '!framework/assurance/runtime/_ops/tests/test-validate-proposal-post-implementation-drift.sh' \
      -g '!instance/cognition/decisions/**' 2>/dev/null || true
  )"
  if [[ -n "$drift" ]]; then
    printf '%s\n' "$drift"
    fail "active framework/instance surfaces must not retain legacy Change Package predecessor terminology"
  else
    pass "active framework/instance surfaces avoid legacy Change Package predecessor terminology"
  fi

  local legacy_paths
  legacy_paths="$(find "$OCTON_DIR/framework" "$OCTON_DIR/instance" \( -iname '*work-package*' -o -iname '*work_package*' \) -print 2>/dev/null || true)"
  if [[ -n "$legacy_paths" ]]; then
    printf '%s\n' "$legacy_paths"
    fail "active framework/instance paths must not retain legacy Change Package predecessor filenames"
  else
    pass "active framework/instance paths avoid legacy Change Package predecessor filenames"
  fi

  local default_drift
  default_drift="$(
    cd "$OCTON_DIR"
    rg -n "PR-first|main remains PR-first|default execution unit is one branch|one branch worktree per task or PR|Stage, commit, push, and open a draft PR" framework instance \
      -g '!framework/scaffolding/practices/prompts/**' \
      -g '!framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh' \
      -g '!instance/cognition/decisions/**' 2>/dev/null || true
  )"
  if [[ -n "$default_drift" ]]; then
    printf '%s\n' "$default_drift"
    fail "active surfaces must not reintroduce PR or branch as the default work unit"
  else
    pass "active surfaces avoid PR/branch default-work-unit drift"
  fi
}

main() {
  echo "== Default Work Unit Alignment Validation =="
  command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }
  command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }

  check_core_contracts
  check_discovery_and_routing
  check_no_active_legacy_or_default_drift

  echo
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"
