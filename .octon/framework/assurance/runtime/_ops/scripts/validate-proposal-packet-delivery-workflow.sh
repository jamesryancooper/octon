#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
WORKFLOW_DIR="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery"
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

echo "== Proposal Packet Delivery Workflow Validation =="

require_file "$WORKFLOW_PATH" "workflow contract"
require_file "$README_PATH" "workflow README"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json" "profile schema"
require_file "$ROOT_DIR/.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json" "receipt schema"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh" "profile validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh" "receipt validator"
require_file "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh" "validator test"

if [[ -f "$WORKFLOW_PATH" ]] && yq -e '.' "$WORKFLOW_PATH" >/dev/null 2>&1; then
  pass "workflow YAML parses"
  require_yaml_value "$WORKFLOW_PATH" '.schema_version' 'workflow-contract-v2' "workflow schema version"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.id' 'proposal-packet-delivery' "workflow id"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.aggregate_receipt_only' 'true' "aggregate receipt only authority"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.target_receipts_remain_target_owned' 'true' "target receipts remain target-owned"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.implementation_owner' 'run-packet-implementation' "implementation owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.promotion_owner' 'promote-proposal' "promotion owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.packet_closeout_owner' 'closeout-packet' "packet closeout owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.terminal_closeout_owner' 'proposal-packet-terminal-closeout' "terminal closeout owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.archive_owner' 'archive-proposal' "archive owner"
  require_yaml_value "$WORKFLOW_PATH" '.workflow.authority.git_mutation_owner' 'closeout-change' "Git mutation owner"
  stage_count="$(yq -r '(.workflow.stages // []) | length' "$WORKFLOW_PATH" 2>/dev/null || echo 0)"
  [[ "$stage_count" -ge 10 ]] && pass "workflow has at least ten stages" || fail "workflow must have at least ten stages"
  for stage_id in \
    bind-profile \
    validate-packet-state \
    run-or-resume-packet-implementation \
    validate-implementation-receipts \
    promote-proposal \
    route-packet-closeout \
    route-terminal-closeout-and-archive \
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
  "proposal-packet-delivery-receipt" \
  "validate-proposal-packet-delivery-profile.sh" \
  "validate-proposal-packet-delivery-receipt.sh" \
  "run-packet-implementation" \
  "promote-proposal" \
  "closeout-packet" \
  "proposal-packet-terminal-closeout" \
  "archive-proposal" \
  "closeout-change" \
  "closeout-worktree" \
  "repo-hygiene-cleanup" \
  "branch landing authorization" \
  "branch cleanup authorization" \
  "terminal current-state proof" \
  "target-owned"; do
  require_token "$README_PATH" "$token" "workflow README token: $token"
done

require_token "$MANIFEST_PATH" "proposal-packet-delivery" "workflow manifest registration"
require_token "$REGISTRY_PATH" "proposal-packet-delivery" "workflow registry registration"
require_token "$REGISTRY_PATH" "/octon-proposal-run-packet-delivery" "workflow registry command uses proposal family naming"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md" "proposal-packet-delivery" "command file registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md" "route=branch-no-pr" "command documents branch-no-pr route"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml" "proposal-packet-delivery" "command manifest registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml" "route=branch-no-pr" "command manifest branch-no-pr argument"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md" "proposal-packet-delivery" "skill file registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md" "route=branch-no-pr" "skill documents branch-no-pr route"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml" "proposal-packet-delivery" "skill manifest registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml" "proposal-packet-delivery" "skill registry registration"
require_token "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/capabilities.yml" "proposal-packet-delivery" "skill capability registration"
require_token "$ROOT_DIR/.octon/framework/product/features/catalog.yml" "proposal-packet-delivery" "product feature catalog registration"
require_token "$ROOT_DIR/.octon/framework/product/features/catalog.yml" "/octon-proposal-run-packet-delivery" "product feature catalog command entrypoint"
require_token "$ROOT_DIR/.octon/framework/product/features/proposal-packet-delivery.md" "Proposal Packet Delivery" "product feature doc"
require_token "$ROOT_DIR/.octon/framework/product/features/proposal-packet-delivery.md" "/octon-proposal-run-packet-delivery" "product feature doc command entrypoint"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml" "octon-proposal-run-packet-delivery" "proposal lifecycle command manifest exposes packet delivery command"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-packet-delivery.md" "/octon-proposal-run-packet-delivery" "proposal lifecycle command projection uses family naming"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md" "proposal-packet-delivery" "proposal lifecycle bundle matrix hook"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md" "octon-proposal-run-packet-delivery" "proposal lifecycle bundle matrix command hook"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml" "proposal-packet-delivery" "proposal packet lifecycle hook"
require_token "$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml" "/octon-proposal-run-packet-delivery" "proposal packet lifecycle command entrypoint"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
