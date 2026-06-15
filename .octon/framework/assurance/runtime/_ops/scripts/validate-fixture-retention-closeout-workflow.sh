#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
WORKFLOW_DIR="$FRAMEWORK_DIR/orchestration/runtime/workflows/meta/fixture-retention-closeout"
WORKFLOW_PATH="$WORKFLOW_DIR/workflow.yml"
WORKFLOW_MANIFEST="$FRAMEWORK_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$FRAMEWORK_DIR/orchestration/runtime/workflows/registry.yml"
COMMAND_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/commands/manifest.yml"
SKILL_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/skills/manifest.yml"
RECEIPT_SCHEMA="$FRAMEWORK_DIR/product/contracts/fixture-retention-closeout-receipt-v1.schema.json"
RECEIPT_VALIDATOR="$FRAMEWORK_DIR/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh"
ENGINE_WORKFLOW="$FRAMEWORK_DIR/engine/runtime/crates/kernel/src/workflow.rs"
errors=0

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

need_tool jq
need_tool yq

echo "== Fixture Retention Closeout Workflow Validation =="

[[ -d "$WORKFLOW_DIR" ]] && pass "workflow directory exists" || fail "workflow directory missing"
[[ -f "$WORKFLOW_PATH" ]] && pass "workflow.yml exists" || fail "workflow.yml missing"
[[ -f "$WORKFLOW_DIR/README.md" ]] && pass "workflow README exists" || fail "workflow README missing"
[[ -f "$RECEIPT_SCHEMA" ]] && pass "receipt schema exists" || fail "receipt schema missing"
[[ -f "$RECEIPT_VALIDATOR" ]] && pass "receipt validator exists" || fail "receipt validator missing"
jq -e '.' "$RECEIPT_SCHEMA" >/dev/null 2>&1 && pass "receipt schema JSON parses" || fail "receipt schema JSON does not parse"
yq -e '.' "$WORKFLOW_PATH" >/dev/null 2>&1 && pass "workflow YAML parses" || fail "workflow YAML does not parse"

[[ "$(yq -r '.schema_version // ""' "$WORKFLOW_PATH" 2>/dev/null || true)" == "workflow-contract-v2" ]] \
  && pass "workflow schema version correct" \
  || fail "workflow schema version must be workflow-contract-v2"
[[ "$(yq -r '.name // ""' "$WORKFLOW_PATH" 2>/dev/null || true)" == "fixture-retention-closeout" ]] \
  && pass "workflow name correct" \
  || fail "workflow name must be fixture-retention-closeout"

for input in fixture_path purpose owner_scope evidence_refs; do
  yq -e ".inputs[]? | select(.name == \"$input\")" "$WORKFLOW_PATH" >/dev/null 2>&1 \
    && pass "workflow input declared: $input" \
    || fail "workflow input missing: $input"
done

for stage_id in \
  resolve-fixture-identity \
  bind-retention-scope \
  verify-retained-evidence \
  classify-retained-path-set \
  emit-retention-receipt; do
  asset="$(yq -r ".stages[]? | select(.id == \"$stage_id\") | .asset // \"\"" "$WORKFLOW_PATH" 2>/dev/null || true)"
  if [[ -n "$asset" && -f "$WORKFLOW_DIR/$asset" ]]; then
    pass "stage declared with local asset: $stage_id"
  else
    fail "stage missing or asset absent: $stage_id"
  fi
done

for token in \
  "fixture-retention-closeout-receipt-v1" \
  "retention-receipt.yml" \
  "no_archive_relocation: true" \
  "no_git_mutation: true" \
  "no_residue_deletion: true" \
  "no_repo_hygiene_deletion_authority: true" \
  "exact path-set match" \
  "generated artifact refs are derived-only non-authority"; do
  grep -Fq "$token" "$WORKFLOW_PATH" "$WORKFLOW_DIR"/stages/*.md "$WORKFLOW_DIR/README.md" \
    && pass "workflow token present: $token" \
    || fail "workflow token missing: $token"
done

yq -e '.workflows[] | select(.id == "fixture-retention-closeout" and .path == "meta/fixture-retention-closeout/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 \
  && pass "workflow manifest registration exists" \
  || fail "workflow manifest registration missing"
yq -e '.workflows."fixture-retention-closeout"' "$WORKFLOW_REGISTRY" >/dev/null 2>&1 \
  && pass "workflow registry entry exists" \
  || fail "workflow registry entry missing"
yq -e '.commands[] | select(.id == "fixture-retention-closeout")' "$COMMAND_MANIFEST" >/dev/null 2>&1 \
  && pass "command manifest entry exists" \
  || fail "command manifest entry missing"
yq -e '.skills[] | select(.id == "fixture-retention-closeout")' "$SKILL_MANIFEST" >/dev/null 2>&1 \
  && pass "skill manifest entry exists" \
  || fail "skill manifest entry missing"

if grep -nE 'terminal-closeout-genericity-policy-fixture|proposal-program-delivery|architecture/proposal-program-delivery' \
  "$ENGINE_WORKFLOW" \
  "$FRAMEWORK_DIR/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh" \
  "$FRAMEWORK_DIR/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh" >/tmp/fixture-retention-hardcoding.$$ 2>/dev/null; then
  cat /tmp/fixture-retention-hardcoding.$$
  rm -f /tmp/fixture-retention-hardcoding.$$
  fail "generic fixture retention and hygiene logic must not hardcode packet or fixture ids"
else
  rm -f /tmp/fixture-retention-hardcoding.$$
  pass "generic fixture retention and hygiene logic has no packet/fixture id hardcoding"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
