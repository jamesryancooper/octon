#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

MANIFEST="$OCTON_DIR/instance/ingress/manifest.yml"
OCTON_ADAPTER="$OCTON_DIR/AGENTS.md"
ROOT_ADAPTER="$ROOT_DIR/AGENTS.md"
CLAUDE_ADAPTER="$ROOT_DIR/CLAUDE.md"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Ingress Manifest Parity Validation =="
[[ -f "$MANIFEST" ]] && pass "ingress manifest exists" || fail "missing ingress manifest"

manifest_orchestrator="$(yq -r '.mandatory_reads[] | select(. == ".octon/framework/execution-roles/runtime/orchestrator/ROLE.md")' "$MANIFEST" 2>/dev/null || true)"
if [[ -n "$manifest_orchestrator" ]] && /usr/bin/grep -Fq '.octon/framework/execution-roles/runtime/orchestrator/ROLE.md' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress read order includes manifest mandatory orchestrator contract"
else
  fail "instance ingress read order does not match manifest mandatory orchestrator contract"
fi

manifest_closeout_workflow="$(yq -r '.closeout_workflow_ref // ""' "$MANIFEST" 2>/dev/null || true)"
if [[ -n "$manifest_closeout_workflow" ]] && [[ -f "$ROOT_DIR/$manifest_closeout_workflow" ]] && /usr/bin/grep -Fq 'closeout_workflow_ref' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress points to canonical closeout workflow"
else
  fail "instance ingress closeout workflow pointer does not match manifest"
fi

if yq -e 'has("branch_closeout_gate") | not' "$MANIFEST" >/dev/null 2>&1; then
  pass "instance ingress manifest no longer carries inline closeout gate policy"
else
  fail "instance ingress manifest must not carry inline closeout gate policy"
fi

if yq -e 'has("branch_closeout_prompt") | not' "$MANIFEST" >/dev/null 2>&1; then
  pass "legacy scalar closeout prompt is absent from ingress manifest"
else
  fail "legacy scalar closeout prompt must not remain in ingress manifest"
fi

for target in "$OCTON_ADAPTER" "$ROOT_ADAPTER" "$CLAUDE_ADAPTER"; do
  if cmp -s "$OCTON_ADAPTER" "$target"; then
    pass "${target#$ROOT_DIR/} matches .octon adapter text"
  else
    fail "${target#$ROOT_DIR/} does not match .octon adapter text"
  fi
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
