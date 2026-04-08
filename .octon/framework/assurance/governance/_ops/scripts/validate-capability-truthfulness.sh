#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
EFFECTIVE_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"
EXTERNAL_RUN="$OCTON_DIR/state/evidence/disclosure/runs/uec-global-frontier-browser-api-studio-20260404/run-card.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
require_ref() {
  local ref="$1"
  local label="$2"
  [[ -n "$ref" && "$ref" != "null" ]] || { fail "$label missing"; return; }
  [[ -e "$ROOT_DIR/$ref" ]] && pass "$label resolves" || fail "$label missing target $ref"
}
contains_text() {
  local pattern="$1"
  local path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$path"
  else
    grep -q "$pattern" "$path"
  fi
}

main() {
  echo "== Capability Truthfulness Validation =="

  require_file "$OCTON_DIR/framework/capabilities/runtime/services/browser-session/contract.yml"
  require_file "$OCTON_DIR/framework/capabilities/runtime/services/api-client/contract.yml"
  require_yq '.packs[] | select(.pack_id == "repo" and .admission_status == "admitted")' "$REGISTRY" "repo pack is admitted"
  require_yq '.packs[] | select(.pack_id == "git" and .admission_status == "admitted")' "$REGISTRY" "git pack is admitted"
  require_yq '.packs[] | select(.pack_id == "shell" and .admission_status == "admitted")' "$REGISTRY" "shell pack is admitted"
  require_yq '.packs[] | select(.pack_id == "telemetry" and .admission_status == "admitted")' "$REGISTRY" "telemetry pack is admitted"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "unsupported" and .default_route == "deny")' "$REGISTRY" "browser pack is explicitly unsupported"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "unsupported" and .default_route == "deny")' "$REGISTRY" "api pack is explicitly unsupported"
  require_yq '.requested_capability_packs | contains(["browser","api"])' "$EXTERNAL_RUN" "historical non-live external run retains browser/api evidence"
  require_yq '[.supported_tuples[].capability_packs[] | select(. == "browser" or . == "api")] | length == 0' "$EFFECTIVE_MATRIX" "supported tuples exclude browser/api"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "pack admission dossier $ref"
  done < <(yq -r '.generated_from[]' "$REGISTRY")

  if contains_text 'unsupported' "$OCTON_DIR/framework/capabilities/packs/browser/README.md"; then
    pass "browser README matches unsupported posture"
  else
    fail "browser README matches unsupported posture"
  fi
  if contains_text 'unsupported' "$OCTON_DIR/framework/capabilities/packs/api/README.md"; then
    pass "api README matches unsupported posture"
  else
    fail "api README matches unsupported posture"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
