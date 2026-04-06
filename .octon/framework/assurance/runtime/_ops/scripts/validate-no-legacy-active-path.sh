#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
errors=0

check_no_text() {
  local pattern="$1"
  shift
  if rg -n "$pattern" "$@" >/dev/null 2>&1; then
    echo "[ERROR] legacy pattern '$pattern' still exists in active-path surfaces" >&2
    errors=$((errors + 1))
  fi
}

check_no_text 'architect/SOUL|SOUL\.md' \
  "$ROOT_DIR/instance/ingress/AGENTS.md" \
  "$ROOT_DIR/framework/agency/runtime/agents/orchestrator/AGENT.md" \
  "$ROOT_DIR/framework/agency/runtime/agents/verifier/AGENT.md" \
  "$ROOT_DIR/framework/agency/manifest.yml"

[[ -f "$ROOT_DIR/framework/agency/runtime/agents/orchestrator/SOUL.md" ]] && {
  echo "[ERROR] orchestrator SOUL overlay still exists" >&2
  errors=$((errors + 1))
}

[[ -f "$ROOT_DIR/framework/agency/runtime/agents/verifier/SOUL.md" ]] && {
  echo "[ERROR] verifier SOUL overlay still exists" >&2
  errors=$((errors + 1))
}

[[ $errors -eq 0 ]]
