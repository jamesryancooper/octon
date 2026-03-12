#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"
PROPOSAL_PATH="${2:-}"
[[ "${1:-}" == "--package" && -n "$PROPOSAL_PATH" ]] || { echo "usage: validate-policy-proposal.sh --package <path>" >&2; exit 2; }
[[ "$PROPOSAL_PATH" = /* ]] && PROPOSAL_DIR="$PROPOSAL_PATH" || PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"

errors=0
req() { [[ -e "$1" ]] && echo "[OK] $2" || { echo "[ERROR] $2"; errors=$((errors+1)); }; }

req "$PROPOSAL_DIR/proposal.yml" "base proposal manifest exists"
req "$PROPOSAL_DIR/policy-proposal.yml" "policy proposal manifest exists"
req "$PROPOSAL_DIR/README.md" "README exists"
req "$PROPOSAL_DIR/navigation/artifact-catalog.md" "artifact catalog exists"
req "$PROPOSAL_DIR/navigation/source-of-truth-map.md" "source-of-truth map exists"
req "$PROPOSAL_DIR/policy/decision.md" "decision doc exists"
req "$PROPOSAL_DIR/policy/policy-delta.md" "policy delta exists"
req "$PROPOSAL_DIR/policy/enforcement-plan.md" "enforcement plan exists"

if [[ -f "$PROPOSAL_DIR/policy-proposal.yml" ]] && yq -e '.' "$PROPOSAL_DIR/policy-proposal.yml" >/dev/null 2>&1; then
  [[ "$(yq -r '.schema_version' "$PROPOSAL_DIR/policy-proposal.yml")" == "policy-proposal-v1" ]] || errors=$((errors+1))
  [[ -n "$(yq -r '.policy_area // ""' "$PROPOSAL_DIR/policy-proposal.yml")" ]] || errors=$((errors+1))
  [[ "$(yq -r '.change_type' "$PROPOSAL_DIR/policy-proposal.yml")" =~ ^(new-policy|policy-update|policy-removal)$ ]] || errors=$((errors+1))
else
  errors=$((errors+1))
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
