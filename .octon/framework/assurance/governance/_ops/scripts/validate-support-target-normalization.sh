#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
EFFECTIVE_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }
require_ref() {
  local ref="$1"
  local label="$2"
  [[ -n "$ref" && "$ref" != "null" ]] || { fail "$label missing"; return; }
  [[ -e "$ROOT_DIR/$ref" ]] && pass "$label resolves" || fail "$label missing target $ref"
}

main() {
  echo "== Support-Target Normalization Validation =="

  require_yq '.support_claim_mode == "bounded-admitted-finite"' "$SUPPORT_TARGETS" "support-target declaration uses bounded admitted claim mode"
  require_yq '(.live_support_universe.model_classes | length) == 1 and .live_support_universe.model_classes[0] == "repo-local-governed"' "$SUPPORT_TARGETS" "live support universe is narrowed to repo-local-governed"
  require_yq '(.live_support_universe.host_adapters | length) == 1 and .live_support_universe.host_adapters[0] == "repo-shell"' "$SUPPORT_TARGETS" "live support universe is narrowed to repo-shell"
  require_yq '[.compatibility_matrix[] | select(.support_status != "supported")] | length == 0' "$SUPPORT_TARGETS" "compatibility matrix contains only supported runtime tuples"
  require_yq '[.tuple_admissions[] | select(.support_status == "supported")] | length == 2' "$SUPPORT_TARGETS" "exactly two tuples are live supported"
  require_yq '.tuple_admissions[] | select(.admission_id == "tuple-repo-shell-repo-consequential-en" and .requires_mission == true)' "$SUPPORT_TARGETS" "supported consequential tuple requires mission"
  require_yq '.tuple_admissions[] | select(.support_status == "stage_only") | length >= 1' "$SUPPORT_TARGETS" "stage-only surfaces remain explicit"
  require_ref "$(yq -r '.generated_projection_ref' "$SUPPORT_TARGETS")" "generated effective matrix ref"
  require_yq '.supported_tuples | length == 2' "$EFFECTIVE_MATRIX" "effective matrix reflects two supported tuples"
  require_yq '[.supported_tuples[].capability_packs[] | select(. == "browser" or . == "api")] | length == 0' "$EFFECTIVE_MATRIX" "supported effective matrix excludes browser and api"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "tuple admission dossier $ref"
  done < <(yq -r '.tuple_admissions[].admission_dossier_ref' "$SUPPORT_TARGETS")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
