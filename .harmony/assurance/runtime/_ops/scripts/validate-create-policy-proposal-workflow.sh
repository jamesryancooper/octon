#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/meta/create-policy-proposal"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }
grep -Fq 'name: "create-policy-proposal"' "$WORKFLOW_DIR/workflow.yml" && pass "workflow id matches" || fail "workflow id matches"
grep -Fq 'validate-policy-proposal.sh' "$WORKFLOW_DIR/workflow.yml" && pass "policy validator referenced" || fail "policy validator referenced"
yq -e '.workflows[] | select(.id == "create-policy-proposal" and .path == "meta/create-policy-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 && pass "manifest registration exists" || fail "manifest registration exists"
grep -Fq 'create-policy-proposal:' "$WORKFLOW_REGISTRY" && pass "registry entry exists" || fail "registry entry exists"
echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
