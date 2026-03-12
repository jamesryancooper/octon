#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/audit/audit-design-proposal"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
CAPABILITY_MAP="$HARMONY_DIR/orchestration/governance/capability-map-v1.yml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found file: ${1#$ROOT_DIR/}" || fail "missing file: ${1#$ROOT_DIR/}"; }
require_fixed() { grep -Fq -- "$1" "$2" && pass "$3" || fail "$3"; }
require_absent() { grep -Fq -- "$1" "$2" && fail "$3" || pass "$3"; }

main() {
  local required=(
    "$WORKFLOW_DIR/workflow.yml"
    "$WORKFLOW_DIR/stages/01-configure.md"
    "$WORKFLOW_DIR/stages/02-design-audit.md"
    "$WORKFLOW_DIR/stages/03-design-proposal-remediation.md"
    "$WORKFLOW_DIR/stages/12-verify.md"
    "$WORKFLOW_DIR/README.md"
    "$WORKFLOW_MANIFEST"
    "$WORKFLOW_REGISTRY"
    "$CAPABILITY_MAP"
  )

  for file in "${required[@]}"; do
    require_file "$file"
  done

  require_fixed 'name: "audit-design-proposal"' "$WORKFLOW_DIR/workflow.yml" "workflow contract name matches id"
  require_fixed 'proposal_path' "$WORKFLOW_DIR/workflow.yml" "workflow contract exposes proposal_path input"
  require_fixed 'validate-proposal-standard.sh' "$WORKFLOW_DIR/stages/12-verify.md" "verify stage runs baseline proposal validator"
  require_fixed 'validate-design-proposal.sh' "$WORKFLOW_DIR/stages/12-verify.md" "verify stage runs design proposal validator"
  require_absent '.design-packages/' "$WORKFLOW_DIR/workflow.yml" "workflow contract avoids legacy design-package paths"

  if yq -e '.workflows[] | select(.id == "audit-design-proposal" and .path == "audit/audit-design-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1; then
    pass "workflow manifest includes audit-design-proposal"
  else
    fail "workflow manifest includes audit-design-proposal"
  fi

  require_fixed 'audit-design-proposal:' "$WORKFLOW_REGISTRY" "workflow registry includes audit-design-proposal"
  require_fixed 'commands: ["/audit-design-proposal"]' "$WORKFLOW_REGISTRY" "workflow registry exposes audit-design-proposal slash command"
  require_fixed 'workflow_id: "audit-design-proposal"' "$CAPABILITY_MAP" "capability map classifies workflow"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
