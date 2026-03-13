#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
PROPOSAL_PATH="${2:-}"
[[ "${1:-}" == "--package" && -n "$PROPOSAL_PATH" ]] || { echo "usage: validate-architecture-proposal.sh --package <path>" >&2; exit 2; }
[[ "$PROPOSAL_PATH" = /* ]] && PROPOSAL_DIR="$PROPOSAL_PATH" || PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"

errors=0
req() { [[ -e "$1" ]] && echo "[OK] $2" || { echo "[ERROR] $2"; errors=$((errors+1)); }; }

req "$PROPOSAL_DIR/proposal.yml" "base proposal manifest exists"
req "$PROPOSAL_DIR/architecture-proposal.yml" "architecture proposal manifest exists"
req "$PROPOSAL_DIR/README.md" "README exists"
req "$PROPOSAL_DIR/navigation/artifact-catalog.md" "artifact catalog exists"
req "$PROPOSAL_DIR/navigation/source-of-truth-map.md" "source-of-truth map exists"
req "$PROPOSAL_DIR/architecture/target-architecture.md" "target architecture exists"
req "$PROPOSAL_DIR/architecture/acceptance-criteria.md" "acceptance criteria exists"
req "$PROPOSAL_DIR/architecture/implementation-plan.md" "implementation plan exists"

if [[ -f "$PROPOSAL_DIR/architecture-proposal.yml" ]] && yq -e '.' "$PROPOSAL_DIR/architecture-proposal.yml" >/dev/null 2>&1; then
  [[ "$(yq -r '.schema_version' "$PROPOSAL_DIR/architecture-proposal.yml")" == "architecture-proposal-v1" ]] || errors=$((errors+1))
  [[ -n "$(yq -r '.architecture_scope // ""' "$PROPOSAL_DIR/architecture-proposal.yml")" ]] || errors=$((errors+1))
  [[ "$(yq -r '.decision_type' "$PROPOSAL_DIR/architecture-proposal.yml")" =~ ^(new-surface|surface-refactor|boundary-change)$ ]] || errors=$((errors+1))
else
  errors=$((errors+1))
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
