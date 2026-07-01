#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
WORKFLOW_DIR="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery"
WORKFLOW_PATH="$WORKFLOW_DIR/workflow.yml"
README_PATH="$WORKFLOW_DIR/README.md"
COMMAND_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_COMMAND_PATH:-$ROOT_DIR/.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md}"
NATIVE_ALIAS_COMMAND_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_NATIVE_ALIAS_COMMAND_PATH:-$ROOT_DIR/.octon/framework/capabilities/runtime/commands/octon-proposal-run-program-delivery.md}"
COMMAND_MANIFEST_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_COMMAND_MANIFEST_PATH:-$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml}"
SKILL_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_SKILL_PATH:-$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md}"
LIFECYCLE_CONTRACT_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_LIFECYCLE_CONTRACT_PATH:-$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml}"
BUNDLE_MATRIX_PATH="${OCTON_PROPOSAL_LIFECYCLE_BUNDLE_MATRIX_PATH:-$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md}"
EXTENSION_COMMAND_MANIFEST_PATH="${OCTON_PROPOSAL_LIFECYCLE_COMMAND_MANIFEST_PATH:-$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml}"
ALIAS_COMMAND_PATH="${OCTON_PROPOSAL_PROGRAM_DELIVERY_ALIAS_COMMAND_PATH:-$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-delivery.md}"
MANIFEST_PATH="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/manifest.yml"
REGISTRY_PATH="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/registry.yml"
errors=0

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

require_file() {
  local path="$1" label="$2"
  [[ -f "$path" ]] && pass "$label exists" || fail "$label missing: $path"
}

reject_path() {
  local path="$1" label="$2"
  [[ -e "$path" ]] && fail "$label must not exist: $path" || pass "$label absent"
}

require_token() {
  local path="$1" token="$2" label="$3"
  if [[ -f "$path" ]] && grep -Fq "$token" "$path"; then
    pass "$label"
  else
    fail "$label missing token: $token"
  fi
}

reject_token() {
  local path="$1" token="$2" label="$3"
  if [[ -f "$path" ]] && grep -Fq "$token" "$path"; then
    fail "$label contains forbidden token: $token"
  else
    pass "$label"
  fi
}

reject_yaml_match() {
  local path="$1" expression="$2" label="$3"
  if [[ -f "$path" ]] && yq -e "$expression" "$path" >/dev/null 2>&1; then
    fail "$label"
  else
    pass "$label"
  fi
}

require_yaml_value() {
  local path="$1" expression="$2" expected="$3" label="$4" value
  value="$(yq -r "$expression" "$path" 2>/dev/null || true)"
  [[ "$value" == "$expected" ]] && pass "$label" || fail "$label must be $expected"
}

need_tool yq

echo "== Proposal Program Delivery Workflow Validation =="

require_file "$WORKFLOW_PATH" "workflow contract"
require_file "$README_PATH" "workflow README"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json" "profile schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json" "receipt schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/feature-catalog-drift-receipt-v1.schema.json" "feature catalog drift receipt schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json" "order override receipt schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-evidence-index-v1.schema.json" "delivery evidence index schema"
require_file "$ALIAS_COMMAND_PATH" "additive program delivery alias command"
reject_path "$NATIVE_ALIAS_COMMAND_PATH" "native program delivery alias command"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh" "profile validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh" "receipt validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh" "feature catalog drift validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh" "delivery evidence index generator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh" "delivery evidence index validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh" "validator test"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-proposal-program-delivery-evidence-index.sh" "delivery evidence index test"

if [[ -f "$WORKFLOW_PATH" ]] && yq -e '.' "$WORKFLOW_PATH" >/dev/null 2>&1; then
  pass "workflow YAML parses"
  require_yaml_value "$WORKFLOW_PATH" '.schema_version' 'workflow-contract-v2' "workflow schema version"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.id' 'proposal-program-delivery' "workflow id"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.aggregate_receipt_only' 'true' "aggregate receipt only authority"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.child_receipts_remain_target_owned' 'true' "child receipts remain target-owned"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.git_mutation_owner' 'closeout-change' "Git mutation owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.outputs[] | select(.name == "delivery_evidence_index") | .schema_ref' '.octon/framework/product/contracts/proposal-program-delivery-evidence-index-v1.schema.json' "delivery evidence index output schema"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.validators.evidence_index' '.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh' "delivery evidence index validator"
  require_yaml_value "$WORKFLOW_PATH" '.inputs[] | select(.name == "profile_path") | .required' 'true' "top-level profile_path is required"
  require_yaml_value "$WORKFLOW_PATH" '.inputs[] | select(.name == "delivery_run_id") | .required' 'true' "top-level delivery_run_id is required"
  require_yaml_value "$WORKFLOW_PATH" '.inputs[] | select(.name == "target_outcome") | .required' 'true' "top-level target_outcome is required"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.inputs[] | select(.name == "profile_path") | .required' 'true' "workflow profile_path is required"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.inputs[] | select(.name == "delivery_run_id") | .required' 'true' "workflow delivery_run_id is required"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.inputs[] | select(.name == "target_outcome") | .required' 'true' "workflow target_outcome is required"
  stage_count="$(yq -r '(.workflow.stages // []) | length' "$WORKFLOW_PATH" 2>/dev/null || echo 0)"
  [[ "$stage_count" -ge 10 ]] && pass "workflow has at least ten stages" || fail "workflow must have at least ten stages"
  require_yaml_value "$WORKFLOW_PATH" '.stages[1].id' 'delivery-readiness-preflight' "top-level delivery readiness preflight placement"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.stages[1].id' 'delivery-readiness-preflight' "workflow delivery readiness preflight placement"
  for stage_id in \
    bind-profile \
    delivery-readiness-preflight \
    validate-program-state \
    run-or-resume-child-lifecycles \
    validate-child-receipts \
    validate-feature-catalog-drift \
    route-closeout-and-archive \
    route-change-closeout \
    validate-cleanup-sync-proof \
    emit-delivery-receipt; do
    yq -e ".workflow.stages[]? | select(.id == \"$stage_id\")" "$WORKFLOW_PATH" >/dev/null 2>&1 \
      && pass "workflow stage declared: $stage_id" \
      || fail "workflow stage missing: $stage_id"
  done
else
  fail "workflow YAML does not parse"
fi

for stage_file in "$WORKFLOW_DIR"/stages/*.md; do
  require_token "$stage_file" "Required checks" "stage required checks in $(basename "$stage_file")"
done

for token in \
  "proposal-program-delivery-receipt" \
  "proposal-program-delivery-order-override-receipt-v1" \
  "proposal-program-delivery-evidence-index" \
  "execution_order_policy" \
  "delivery-readiness-preflight" \
  "order override receipt" \
  "validate-proposal-program-delivery-profile.sh" \
  "validate-proposal-program-delivery-receipt.sh" \
  "feature-catalog-drift" \
  "feature-catalog-drift-receipt-v1" \
  "validate-feature-catalog-drift-closeout.sh" \
  "unresolved child or parent feature-catalog drift blocks completed delivery" \
  "validate-proposal-program-delivery-evidence-index.sh" \
  "closeout-change" \
  "closeout-worktree" \
  "repo-hygiene-cleanup" \
  "branch landing authorization" \
  "branch cleanup authorization" \
  "route-owned clean worktree" \
  "include-path classification" \
  "retained readiness receipt" \
  "lifecycle postmortem threshold" \
  "terminal current-state proof" \
  "parent summary" \
  "target-owned"; do
  require_token "$README_PATH" "$token" "workflow README token: $token"
done

require_token "$MANIFEST_PATH" "proposal-program-delivery" "workflow manifest registration"
require_token "$REGISTRY_PATH" "proposal-program-delivery" "workflow registry registration"
require_token "$COMMAND_PATH" "proposal-program-delivery" "command file registration"
require_token "$COMMAND_PATH" "/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "command usage requires profile and run-id"
reject_token "$COMMAND_PATH" "[profile=<profile-path>]" "command does not mark profile optional"
reject_token "$COMMAND_PATH" "[run-id=<id>]" "command does not mark run-id optional"
require_token "$COMMAND_PATH" 'Resume may satisfy `profile` or `run-id` only through fresh, target-bound' "command documents resume evidence for required inputs"
require_token "$ALIAS_COMMAND_PATH" "Run Program to Clean Delivery" "additive alias display label"
require_token "$ALIAS_COMMAND_PATH" "/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "additive alias usage requires profile and run-id"
require_token "$ALIAS_COMMAND_PATH" "/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "additive alias delegates to canonical command"
require_token "$ALIAS_COMMAND_PATH" 'delegates to `proposal-program-delivery`' "additive alias names canonical wrapper"
require_token "$ALIAS_COMMAND_PATH" ".octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml" "additive alias names canonical workflow"
require_token "$ALIAS_COMMAND_PATH" 'Missing `profile` or `run-id` fails closed before mutation' "additive alias fails closed on missing inputs"
require_token "$ALIAS_COMMAND_PATH" "does not create an independent lifecycle contract, workflow id" "additive alias denies independent authority"
reject_token "$ALIAS_COMMAND_PATH" "[profile=<profile-path>]" "additive alias does not mark profile optional"
reject_token "$ALIAS_COMMAND_PATH" "[run-id=<id>]" "additive alias does not mark run-id optional"
require_yaml_value "$EXTENSION_COMMAND_MANIFEST_PATH" '.commands[] | select(.id == "octon-proposal-run-program-delivery") | .display_name' 'Run Program to Clean Delivery' "additive command manifest alias display label"
require_yaml_value "$EXTENSION_COMMAND_MANIFEST_PATH" '.commands[] | select(.id == "octon-proposal-run-program-delivery") | .path' 'octon-proposal-run-program-delivery.md' "additive command manifest alias path"
require_yaml_value "$EXTENSION_COMMAND_MANIFEST_PATH" '.commands[] | select(.id == "octon-proposal-run-program-delivery") | .argument_hint' 'target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>' "additive command manifest alias requires profile and run-id"
require_token "$COMMAND_MANIFEST_PATH" "proposal-program-delivery" "command manifest registration"
require_token "$COMMAND_MANIFEST_PATH" "target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "command manifest requires profile and run-id"
reject_yaml_match "$COMMAND_MANIFEST_PATH" '.commands[]? | select(.id == "octon-proposal-run-program-delivery")' "native command manifest has no extension alias"
reject_token "$COMMAND_MANIFEST_PATH" "target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]" "command manifest does not mark delivery inputs optional"
require_token "$SKILL_PATH" "proposal-program-delivery" "skill file registration"
require_token "$SKILL_PATH" "/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "skill usage requires profile and run-id"
require_token "$SKILL_PATH" "/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "skill documents alias usage"
require_token "$SKILL_PATH" 'The alias delegates to `proposal-program-delivery`' "skill documents alias delegation"
require_token "$SKILL_PATH" "does not create an independent lifecycle contract" "skill denies alias authority widening"
reject_token "$SKILL_PATH" "[profile=<profile-path>]" "skill does not mark profile optional"
reject_token "$SKILL_PATH" "[run-id=<id>]" "skill does not mark run-id optional"
require_token "$SKILL_PATH" "profile_path" "skill names workflow profile_path input"
require_token "$SKILL_PATH" "delivery_run_id" "skill names workflow delivery_run_id input"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml" "proposal-program-delivery" "skill manifest registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml" "proposal-program-delivery" "skill registry registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/capabilities.yml" "proposal-program-delivery" "skill capability registration"
require_token "$ROOT_DIR/.octon/framework/product/features/catalog.yml" "governed-proposal-delivery" "product feature catalog registration"
require_token "$ROOT_DIR/.octon/framework/product/features/governed-proposal-delivery.md" "Proposal Program Delivery" "product feature doc"
require_token "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json" '"feature_catalog_drift"' "receipt schema declares feature catalog drift gate"
require_token "$ROOT_DIR/.octon/framework/product/contracts/feature-catalog-drift-receipt-v1.schema.json" '"feature-catalog-drift-receipt-v1"' "feature catalog drift receipt schema declares version"
require_token "$BUNDLE_MATRIX_PATH" "proposal-program-delivery" "proposal lifecycle bundle matrix hook"
require_token "$BUNDLE_MATRIX_PATH" "octon-proposal-run-program-delivery" "proposal lifecycle bundle matrix alias hook"
require_token "$BUNDLE_MATRIX_PATH" "Run Program to Clean Delivery" "proposal lifecycle bundle matrix alias display label"
require_token "$BUNDLE_MATRIX_PATH" "does not create an independent workflow, lifecycle mode" "proposal lifecycle bundle matrix denies alias authority widening"
require_token "$BUNDLE_MATRIX_PATH" "profile path, and" "bundle matrix documents required profile path"
require_token "$BUNDLE_MATRIX_PATH" "delivery run id before admission" "bundle matrix documents required delivery run id"
require_token "$LIFECYCLE_CONTRACT_PATH" "proposal-program-delivery" "proposal program lifecycle hook"
require_token "$LIFECYCLE_CONTRACT_PATH" "profile_path" "proposal program lifecycle requires profile_path"
require_token "$LIFECYCLE_CONTRACT_PATH" "delivery_run_id" "proposal program lifecycle requires delivery_run_id"
require_yaml_value "$LIFECYCLE_CONTRACT_PATH" '.delivery_modes[] | select(.mode_id == "proposal-program-delivery") | .input_contract.resume_evidence.forbidden[] | select(. == "generated outputs")' 'generated outputs' "proposal program lifecycle forbids generated output resume authority"
require_token "$LIFECYCLE_CONTRACT_PATH" 'missing_required_input_behavior: "fail-closed-before-mutation"' "proposal program lifecycle fails closed on missing required inputs"
reject_yaml_match "$LIFECYCLE_CONTRACT_PATH" '.delivery_modes[]? | select(.mode_id == "octon-proposal-run-program-delivery")' "proposal program lifecycle has no alias delivery mode"
reject_path "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/meta/octon-proposal-run-program-delivery" "alias workflow surface"
reject_token "$MANIFEST_PATH" "octon-proposal-run-program-delivery" "workflow manifest has no alias workflow"
reject_token "$REGISTRY_PATH" "octon-proposal-run-program-delivery" "workflow registry has no alias workflow"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
