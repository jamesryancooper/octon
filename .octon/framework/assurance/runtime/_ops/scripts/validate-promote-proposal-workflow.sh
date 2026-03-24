#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
WORKFLOW_DIR="$OCTON_DIR/orchestration/runtime/workflows/meta/promote-proposal"
WORKFLOW_MANIFEST="$OCTON_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$OCTON_DIR/orchestration/runtime/workflows/registry.yml"
errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }
grep -Fq 'name: promote-proposal' "$WORKFLOW_DIR/workflow.yml" && pass "workflow id matches" || fail "workflow id matches"
grep -Fq 'validate-proposal-standard.sh' "$WORKFLOW_DIR/stages/01-validate-proposal.md" && pass "baseline proposal validator referenced" || fail "baseline proposal validator referenced"
grep -Fq 'generated/proposals/registry.yml' "$WORKFLOW_DIR/stages/02-promote-proposal.md" && pass "registry regeneration documented" || fail "registry regeneration documented"
grep -Fq 'promotion_evidence' "$WORKFLOW_DIR/workflow.yml" && pass "promotion evidence input declared" || fail "promotion evidence input declared"
yq -e '.workflows[] | select(.id == "promote-proposal" and .path == "meta/promote-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 && pass "manifest registration exists" || fail "manifest registration exists"
grep -Fq 'promote-proposal:' "$WORKFLOW_REGISTRY" && pass "registry entry exists" || fail "registry entry exists"
echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
