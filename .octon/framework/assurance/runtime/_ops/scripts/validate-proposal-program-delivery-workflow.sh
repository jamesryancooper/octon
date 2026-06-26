#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
WORKFLOW_DIR="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery"
WORKFLOW_PATH="$WORKFLOW_DIR/workflow.yml"
README_PATH="$WORKFLOW_DIR/README.md"
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

require_token() {
  local path="$1" token="$2" label="$3"
  if [[ -f "$path" ]] && grep -Fq "$token" "$path"; then
    pass "$label"
  else
    fail "$label missing token: $token"
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
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json" "order override receipt schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-program-delivery-evidence-index-v1.schema.json" "delivery evidence index schema"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh" "profile validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh" "receipt validator"
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
  stage_count="$(yq -r '(.workflow.stages // []) | length' "$WORKFLOW_PATH" 2>/dev/null || echo 0)"
  [[ "$stage_count" -ge 9 ]] && pass "workflow has at least nine stages" || fail "workflow must have at least nine stages"
  require_yaml_value "$WORKFLOW_PATH" '.stages[1].id' 'delivery-readiness-preflight' "top-level delivery readiness preflight placement"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.stages[1].id' 'delivery-readiness-preflight' "workflow delivery readiness preflight placement"
  for stage_id in \
    bind-profile \
    delivery-readiness-preflight \
    validate-program-state \
    run-or-resume-child-lifecycles \
    validate-child-receipts \
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
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md" "proposal-program-delivery" "command file registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml" "proposal-program-delivery" "command manifest registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md" "proposal-program-delivery" "skill file registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml" "proposal-program-delivery" "skill manifest registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml" "proposal-program-delivery" "skill registry registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/capabilities.yml" "proposal-program-delivery" "skill capability registration"
require_token "$ROOT_DIR/.octon/framework/product/features/catalog.yml" "governed-proposal-delivery" "product feature catalog registration"
require_token "$ROOT_DIR/.octon/framework/product/features/governed-proposal-delivery.md" "Proposal Program Delivery" "product feature doc"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md" "proposal-program-delivery" "proposal lifecycle bundle matrix hook"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml" "proposal-program-delivery" "proposal program lifecycle hook"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
