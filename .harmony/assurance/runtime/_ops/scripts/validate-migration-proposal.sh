#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"
PROPOSAL_PATH="${2:-}"
[[ "${1:-}" == "--package" && -n "$PROPOSAL_PATH" ]] || { echo "usage: validate-migration-proposal.sh --package <path>" >&2; exit 2; }
[[ "$PROPOSAL_PATH" = /* ]] && PROPOSAL_DIR="$PROPOSAL_PATH" || PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"

errors=0
req() { [[ -e "$1" ]] && echo "[OK] $2" || { echo "[ERROR] $2"; errors=$((errors+1)); }; }

req "$PROPOSAL_DIR/proposal.yml" "base proposal manifest exists"
req "$PROPOSAL_DIR/migration-proposal.yml" "migration proposal manifest exists"
req "$PROPOSAL_DIR/README.md" "README exists"
req "$PROPOSAL_DIR/navigation/artifact-catalog.md" "artifact catalog exists"
req "$PROPOSAL_DIR/navigation/source-of-truth-map.md" "source-of-truth map exists"
req "$PROPOSAL_DIR/migration/plan.md" "migration plan exists"
req "$PROPOSAL_DIR/migration/release-notes.md" "release notes exist"
req "$PROPOSAL_DIR/migration/rollback.md" "rollback doc exists"

if [[ -f "$PROPOSAL_DIR/migration-proposal.yml" ]] && yq -e '.' "$PROPOSAL_DIR/migration-proposal.yml" >/dev/null 2>&1; then
  [[ "$(yq -r '.schema_version' "$PROPOSAL_DIR/migration-proposal.yml")" == "migration-proposal-v1" ]] || errors=$((errors+1))
  [[ "$(yq -r '.change_profile' "$PROPOSAL_DIR/migration-proposal.yml")" =~ ^(atomic|transitional)$ ]] || errors=$((errors+1))
  [[ "$(yq -r '.release_state' "$PROPOSAL_DIR/migration-proposal.yml")" =~ ^(pre-1.0|stable)$ ]] || errors=$((errors+1))
else
  errors=$((errors+1))
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
