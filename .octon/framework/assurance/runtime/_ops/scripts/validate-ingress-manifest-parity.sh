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

manifest_orchestrator="$(yq -r '.mandatory_read_set[] | select(. == ".octon/framework/agency/runtime/agents/orchestrator/AGENT.md")' "$MANIFEST" 2>/dev/null || true)"
if [[ -n "$manifest_orchestrator" ]] && /usr/bin/grep -Fq '.octon/framework/agency/runtime/agents/orchestrator/AGENT.md' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress read order includes manifest mandatory orchestrator contract"
else
  fail "instance ingress read order does not match manifest mandatory orchestrator contract"
fi

manifest_closeout="$(yq -r '.branch_closeout_prompt // ""' "$MANIFEST" 2>/dev/null || true)"
if [[ "$manifest_closeout" == "Are you ready to closeout this branch?" ]] && /usr/bin/grep -Fq 'Are you ready to closeout this branch?' "$OCTON_DIR/instance/ingress/AGENTS.md"; then
  pass "instance ingress closeout prompt matches manifest"
else
  fail "instance ingress closeout prompt does not match manifest"
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
