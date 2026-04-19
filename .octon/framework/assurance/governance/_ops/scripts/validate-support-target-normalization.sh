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

  require_yq '.support_claim_mode == "bounded-admitted-finite"' "$SUPPORT_TARGETS" "support-target declaration uses bounded admitted-finite claim mode"
  require_yq '.live_support_universe.model_classes[] | select(. == "repo-local-governed")' "$SUPPORT_TARGETS" "live support universe includes repo-local-governed"
  require_yq '.resolved_non_live_surfaces.model_classes[] | select(. == "frontier-governed")' "$SUPPORT_TARGETS" "frontier-governed is explicitly non-live"
  require_yq '.resolved_non_live_surfaces.host_adapters[] | select(. == "github-control-plane")' "$SUPPORT_TARGETS" "github-control-plane is explicitly non-live"
  require_yq '.live_support_universe.host_adapters[] | select(. == "ci-control-plane")' "$SUPPORT_TARGETS" "live support universe includes ci-control-plane"
  require_yq '.resolved_non_live_surfaces.host_adapters[] | select(. == "studio-control-plane")' "$SUPPORT_TARGETS" "studio-control-plane is explicitly non-live"
  require_yq 'has("compatibility_matrix") | not' "$SUPPORT_TARGETS" "support-target declaration no longer embeds a duplicate compatibility matrix"
  require_yq '(.tuple_admissions | length) == 3' "$SUPPORT_TARGETS" "live tuple admissions are narrowed to the three active tuples"
  require_yq '.tuple_admissions[] | select(.tuple_id == "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/repo-shell") | .admission_ref == ".octon/instance/governance/support-target-admissions/repo-shell-repo-consequential-en.yml"' "$SUPPORT_TARGETS" "repo-shell consequential tuple points at canonical admission"
  require_yq '(.resolved_non_live_surfaces.host_adapters | length) >= 1' "$SUPPORT_TARGETS" "resolved non-live host adapters are tracked explicitly"
  require_ref "$(yq -r '.generated_projection_ref' "$SUPPORT_TARGETS")" "generated effective matrix ref"
  require_yq '.supported_tuples | length == 3' "$EFFECTIVE_MATRIX" "effective matrix reflects only the supported live tuples"
  require_yq '[.supported_tuples[].capability_packs[] | select(. == "browser" or . == "api")] | length == 0' "$EFFECTIVE_MATRIX" "supported effective matrix excludes browser and api while unadmitted"

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_ref "$ref" "tuple admission dossier $ref"
  done < <(yq -r '.tuple_admissions[].admission_ref' "$SUPPORT_TARGETS")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
