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

manifest_orchestrator="$(yq -r '.mandatory_read_set[] | select(. == ".octon/framework/execution-roles/runtime/orchestrator/ROLE.md")' "$MANIFEST" 2>/dev/null || true)"
if [[ -n "$manifest_orchestrator" ]] && /usr/bin/grep -Fq '.octon/framework/execution-roles/runtime/orchestrator/ROLE.md' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress read order includes manifest mandatory orchestrator contract"
else
  fail "instance ingress read order does not match manifest mandatory orchestrator contract"
fi

manifest_gate_mode="$(yq -r '.branch_closeout_gate.mode // ""' "$MANIFEST" 2>/dev/null || true)"
if [[ "$manifest_gate_mode" == "contextual" ]] && /usr/bin/grep -Fq 'branch_closeout_gate' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress closeout gate matches manifest"
else
  fail "instance ingress closeout gate does not match manifest"
fi

manifest_fallback="$(yq -r '.branch_closeout_gate.deprecated_fallback_prompt // ""' "$MANIFEST" 2>/dev/null || true)"
if [[ -z "$manifest_fallback" ]]; then
  pass "instance ingress deprecated fallback prompt is not required"
elif /usr/bin/grep -Fq "$manifest_fallback" "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress deprecated fallback prompt matches manifest"
else
  fail "instance ingress deprecated fallback prompt does not match manifest"
fi

manifest_closeout="$(yq -r '.branch_closeout_prompt // ""' "$MANIFEST" 2>/dev/null || true)"
if [[ -z "$manifest_closeout" ]]; then
  pass "legacy scalar closeout prompt is absent"
elif [[ -n "$manifest_fallback" && "$manifest_closeout" == "$manifest_fallback" ]]; then
  pass "legacy scalar closeout prompt matches deprecated fallback"
else
  fail "legacy scalar closeout prompt does not match deprecated fallback"
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
