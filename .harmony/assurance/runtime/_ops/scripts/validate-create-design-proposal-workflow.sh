#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

WORKFLOW_DIR="$HARMONY_DIR/orchestration/runtime/workflows/meta/create-design-proposal"
WORKFLOW_MANIFEST="$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found file: ${1#$ROOT_DIR/}" || fail "missing file: ${1#$ROOT_DIR/}"; }
require_fixed() { grep -Fq -- "$1" "$2" && pass "$3" || fail "$3"; }

main() {
  local required=(
    "$WORKFLOW_DIR/workflow.yml"
    "$WORKFLOW_DIR/stages/01-validate-request.md"
    "$WORKFLOW_DIR/stages/02-select-bundles.md"
    "$WORKFLOW_DIR/stages/03-scaffold-package.md"
    "$WORKFLOW_DIR/stages/04-validate-package.md"
    "$WORKFLOW_DIR/stages/05-report.md"
    "$WORKFLOW_DIR/README.md"
    "$WORKFLOW_MANIFEST"
    "$WORKFLOW_REGISTRY"
  )

  for file in "${required[@]}"; do
    require_file "$file"
  done

  require_fixed 'name: "create-design-proposal"' "$WORKFLOW_DIR/workflow.yml" "workflow contract name matches id"
  require_fixed 'proposal_id' "$WORKFLOW_DIR/workflow.yml" "workflow contract exposes proposal_id input"
  require_fixed 'promotion_scope' "$WORKFLOW_DIR/workflow.yml" "workflow contract exposes promotion_scope input"
  require_fixed '.proposals/registry.yml' "$WORKFLOW_DIR/stages/03-scaffold-package.md" "scaffold stage updates proposal registry"
  require_fixed 'validate-proposal-standard.sh' "$WORKFLOW_DIR/stages/04-validate-package.md" "validate stage runs baseline proposal validator"
  require_fixed 'validate-design-proposal.sh' "$WORKFLOW_DIR/stages/04-validate-package.md" "validate stage runs design proposal validator"

  if yq -e '.workflows[] | select(.id == "create-design-proposal" and .path == "meta/create-design-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1; then
    pass "workflow manifest includes create-design-proposal"
  else
    fail "workflow manifest includes create-design-proposal"
  fi

  require_fixed 'create-design-proposal:' "$WORKFLOW_REGISTRY" "workflow registry includes create-design-proposal"
  require_fixed 'commands: ["/create-design-proposal"]' "$WORKFLOW_REGISTRY" "workflow registry exposes create-design-proposal slash command"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
