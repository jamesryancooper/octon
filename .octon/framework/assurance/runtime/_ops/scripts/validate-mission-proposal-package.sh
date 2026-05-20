#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/generated/proposals/registry.yml"
ACTIVE_DIR="$OCTON_DIR/inputs/exploratory/proposals/architecture/mission-scoped-reversible-autonomy"
ARCHIVED_DIR="$OCTON_DIR/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

main() {
  local proposal_dir=""
  echo "== Mission Proposal Package Validation =="

  require_file "$REGISTRY"
  if [[ -d "$ACTIVE_DIR" ]]; then
    proposal_dir="$ACTIVE_DIR"
    pass "active proposal packet present"
  elif [[ -d "$ARCHIVED_DIR" ]]; then
    proposal_dir="$ARCHIVED_DIR"
    pass "archived proposal packet present"
  else
    fail "mission-scoped-reversible-autonomy proposal packet is missing"
  fi

  if [[ -n "$proposal_dir" ]]; then
    require_file "$proposal_dir/README.md"
    require_file "$proposal_dir/proposal.yml"
    require_file "$proposal_dir/architecture-proposal.yml"
    require_file "$proposal_dir/navigation/artifact-catalog.md"
    require_file "$proposal_dir/navigation/source-of-truth-map.md"
    require_file "$proposal_dir/resources/current-state-gap-analysis.md"
    require_file "$proposal_dir/architecture/target-architecture.md"
    require_file "$proposal_dir/architecture/acceptance-criteria.md"
    require_file "$proposal_dir/architecture/implementation-plan.md"
    require_file "$proposal_dir/architecture/validation-plan.md"
    require_file "$proposal_dir/architecture/cutover-checklist.md"
  fi

  if yq -e '.active[]? | select(.id == "mission-scoped-reversible-autonomy")' "$REGISTRY" >/dev/null 2>&1 || \
     yq -e '.archived[]? | select(.id == "mission-scoped-reversible-autonomy")' "$REGISTRY" >/dev/null 2>&1; then
    pass "proposal registry contains mission-scoped-reversible-autonomy"
  else
    fail "generated proposal registry must include mission-scoped-reversible-autonomy"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
