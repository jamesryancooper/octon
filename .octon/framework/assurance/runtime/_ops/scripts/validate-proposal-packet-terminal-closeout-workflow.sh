#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
WORKFLOW_DIR="$FRAMEWORK_DIR/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout"
WORKFLOW_PATH="$WORKFLOW_DIR/workflow.yml"
WORKFLOW_MANIFEST="$FRAMEWORK_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$FRAMEWORK_DIR/orchestration/runtime/workflows/registry.yml"
COMMAND_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/commands/manifest.yml"
SKILL_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/skills/manifest.yml"
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

need_tool yq

echo "== Proposal Packet Terminal Closeout Workflow Validation =="

[[ -d "$WORKFLOW_DIR" ]] && pass "workflow directory exists" || fail "workflow directory missing"
[[ -f "$WORKFLOW_PATH" ]] && pass "workflow.yml exists" || fail "workflow.yml missing"
[[ -f "$WORKFLOW_DIR/README.md" ]] && pass "workflow README exists" || fail "workflow README missing"

if yq -e '.' "$WORKFLOW_PATH" >/dev/null 2>&1; then
  pass "workflow YAML parses"
else
  fail "workflow YAML does not parse"
fi

[[ "$(yq -r '.schema_version // ""' "$WORKFLOW_PATH" 2>/dev/null || true)" == "workflow-contract-v2" ]] \
  && pass "workflow schema version correct" \
  || fail "workflow schema version must be workflow-contract-v2"
[[ "$(yq -r '.name // ""' "$WORKFLOW_PATH" 2>/dev/null || true)" == "proposal-packet-terminal-closeout" ]] \
  && pass "workflow name correct" \
  || fail "workflow name must be proposal-packet-terminal-closeout"

for input in proposal_path target_outcome profile_path terminal_run_id; do
  yq -e ".inputs[]? | select(.name == \"$input\")" "$WORKFLOW_PATH" >/dev/null 2>&1 \
    && pass "workflow input declared: $input" \
    || fail "workflow input missing: $input"
done

stage_ids=(
  bind-profile
  verify-durable-implementation-state
  verify-implementation-conformance
  verify-post-implementation-drift
  validate-publication-freshness
  classify-repo-hygiene
  classify-worktree-hygiene
  run-evidence-only-reviews
  resolve-git-github-route
  emit-terminal-receipt
)

for stage_id in "${stage_ids[@]}"; do
  asset="$(yq -r ".stages[]? | select(.id == \"$stage_id\") | .asset // \"\"" "$WORKFLOW_PATH" 2>/dev/null || true)"
  if [[ -n "$asset" && -f "$WORKFLOW_DIR/$asset" ]]; then
    pass "stage declared with local asset: $stage_id"
  else
    fail "stage missing or asset absent: $stage_id"
  fi
done

for token in \
  "proposal-packet-terminal-closeout-receipt" \
  "support/proposal-terminal-closeout.yml" \
  "validate-proposal-packet-terminal-closeout-receipt.sh" \
  "archive relocation is not performed" \
  "no_git_mutation: true" \
  "no_residue_deletion: true"; do
  grep -Fq "$token" "$WORKFLOW_PATH" "$WORKFLOW_DIR"/stages/*.md "$WORKFLOW_DIR/README.md" \
    && pass "workflow token present: $token" \
    || fail "workflow token missing: $token"
done

for stage_token in \
  "validate-proposal-implementation-conformance.sh" \
  "validate-proposal-post-implementation-drift.sh" \
  "validate-generated-non-authority.sh" \
  "validate-run-health-read-model.sh" \
  "validate-capability-publication-state.sh" \
  "validate-extension-publication-state.sh" \
  "repo-hygiene-cleanup" \
  "closeout-worktree" \
  "closeout-change" \
  "archive-proposal"; do
  grep -Fq "$stage_token" "$WORKFLOW_DIR"/stages/*.md "$WORKFLOW_DIR/README.md" \
    && pass "required adjacent route or validator referenced: $stage_token" \
    || fail "required adjacent route or validator missing: $stage_token"
done

yq -e '.workflows[] | select(.id == "proposal-packet-terminal-closeout" and .path == "meta/proposal-packet-terminal-closeout/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 \
  && pass "workflow manifest registration exists" \
  || fail "workflow manifest registration missing"
yq -e '.workflows."proposal-packet-terminal-closeout"' "$WORKFLOW_REGISTRY" >/dev/null 2>&1 \
  && pass "workflow registry entry exists" \
  || fail "workflow registry entry missing"
yq -e '.commands[] | select(.id == "proposal-packet-terminal-closeout")' "$COMMAND_MANIFEST" >/dev/null 2>&1 \
  && pass "command manifest entry exists" \
  || fail "command manifest entry missing"
yq -e '.skills[] | select(.id == "proposal-packet-terminal-closeout")' "$SKILL_MANIFEST" >/dev/null 2>&1 \
  && pass "skill manifest entry exists" \
  || fail "skill manifest entry missing"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
