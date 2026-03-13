#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

filter_allowed_matches() {
  awk '
    /runtime\/workflows\/registry\.yml:[0-9]+:.*Kebab-case (design|migration|policy|architecture) proposal id and directory name under \.proposals\// { next }
    /runtime\/workflows\/registry\.yml:[0-9]+:.*path: "\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.proposals\/(design|migration|policy|architecture)\/\{\{proposal_id\}\}\/"/ { next }
    /runtime\/workflows\/registry\.yml:[0-9]+:.*path: "\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.proposals\/(design|migration|policy|architecture)\/\{\{proposal_id\}\}\/proposal\.yml"/ { next }
    /runtime\/workflows\/registry\.yml:[0-9]+:.*path: "\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.proposals\/(design|migration|policy|architecture)\/\{\{proposal_id\}\}\/(design|migration|policy|architecture)-proposal\.yml"/ { next }
    /runtime\/workflows\/registry\.yml:[0-9]+:.*path: "\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.proposals\/registry\.yml"/ { next }
    { print }
  '
}

scan_matches() {
  local raw_matches

  if command -v rg >/dev/null 2>&1; then
    raw_matches="$(
      cd "$ORCHESTRATION_DIR" && \
        rg -n --hidden --glob '!.git' \
          --glob '!_meta/architecture/specification.md' \
          --glob '!practices/workflow-authoring-standards.md' \
          --glob '!runtime/_ops/scripts/validate-orchestration-live-independence.sh' \
          --glob '!runtime/_ops/tests/test-orchestration-live-independence.sh' \
          --glob '!runtime/queue/_ops/scripts/validate-queue.sh' \
          --glob '!runtime/workflows/_ops/scripts/validate-workflows.sh' \
          --glob '!runtime/workflows/meta/create-design-proposal/**' \
          --glob '!runtime/workflows/meta/create-migration-proposal/**' \
          --glob '!runtime/workflows/meta/create-policy-proposal/**' \
          --glob '!runtime/workflows/meta/create-architecture-proposal/**' \
          --glob '!runtime/workflows/audit/audit-design-proposal/**' \
          --glob '!runtime/workflows/audit/audit-migration-proposal/**' \
          --glob '!runtime/workflows/audit/audit-policy-proposal/**' \
          --glob '!runtime/workflows/audit/audit-architecture-proposal/**' \
          '\.proposals/' . || true
    )"
  else
    raw_matches="$(
      grep -R -n -E '\.proposals/' "$ORCHESTRATION_DIR" 2>/dev/null \
        | grep -v '/_meta/architecture/specification.md:' \
        | grep -v '/practices/workflow-authoring-standards.md:' \
        | grep -v '/runtime/_ops/scripts/validate-orchestration-live-independence.sh:' \
        | grep -v '/runtime/_ops/tests/test-orchestration-live-independence.sh:' \
        | grep -v '/runtime/queue/_ops/scripts/validate-queue.sh:' \
        | grep -v '/runtime/workflows/_ops/scripts/validate-workflows.sh:' \
        | grep -v '/runtime/workflows/meta/create-design-proposal/' \
        | grep -v '/runtime/workflows/meta/create-migration-proposal/' \
        | grep -v '/runtime/workflows/meta/create-policy-proposal/' \
        | grep -v '/runtime/workflows/meta/create-architecture-proposal/' \
        | grep -v '/runtime/workflows/audit/audit-design-proposal/' \
        | grep -v '/runtime/workflows/audit/audit-migration-proposal/' \
        | grep -v '/runtime/workflows/audit/audit-policy-proposal/' \
        | grep -v '/runtime/workflows/audit/audit-architecture-proposal/' \
        || true
    )"
  fi

  printf '%s\n' "$raw_matches" | filter_allowed_matches
}

matches="$(scan_matches)"

if [[ -n "$matches" ]]; then
  fail "live orchestration artifacts must not depend on temporary .proposals paths"
  printf '%s\n' "$matches"
else
  pass "live orchestration artifacts avoid temporary .proposals paths"
fi

echo "orchestration live-independence validation summary: errors=$errors"
if (( errors > 0 )); then
  exit 1
fi
