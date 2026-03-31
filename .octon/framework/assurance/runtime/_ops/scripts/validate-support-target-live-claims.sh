#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
AUTHORED_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
ATOMIC_RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml"
CLOSURE_RELEASE_CARD="$OCTON_DIR/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-closure/harness-card.yml"
CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

yaml_value() {
  local expr="$1"
  local file="$2"
  yq -r "${expr} // \"\"" "$file"
}

yaml_json() {
  local expr="$1"
  local file="$2"
  yq -o=json "$expr" "$file"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_yq() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

compare_scalar() {
  local label="$1"
  local expr="$2"
  local left_file="$3"
  local right_file="$4"
  local left_value right_value
  left_value="$(yaml_value "$expr" "$left_file")"
  right_value="$(yaml_value "$expr" "$right_file")"
  if [[ "$left_value" == "$right_value" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

compare_scalar_exprs() {
  local label="$1"
  local left_expr="$2"
  local left_file="$3"
  local right_expr="$4"
  local right_file="$5"
  local left_value right_value
  left_value="$(yaml_value "$left_expr" "$left_file")"
  right_value="$(yaml_value "$right_expr" "$right_file")"
  if [[ "$left_value" == "$right_value" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

compare_json() {
  local label="$1"
  local expr="$2"
  local left_file="$3"
  local right_file="$4"
  local left_value right_value
  left_value="$(yaml_json "$expr" "$left_file")"
  right_value="$(yaml_json "$expr" "$right_file")"
  if [[ "$left_value" == "$right_value" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

resolve_ref() {
  local ref="$1"
  if [[ -z "$ref" || "$ref" == "null" ]]; then
    return 1
  fi
  if [[ "$ref" == /* ]]; then
    printf '%s\n' "$ref"
    return 0
  fi
  if [[ "$ref" == .octon/* ]]; then
    printf '%s/%s\n' "$ROOT_DIR" "$ref"
    return 0
  fi
  printf '%s/%s\n' "$OCTON_DIR" "$ref"
}

require_ref_file() {
  local ref="$1"
  local label="$2"
  local path
  if ! path="$(resolve_ref "$ref")"; then
    fail "$label"
    return
  fi
  if [[ -f "$path" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_proof_bundle() {
  local card="$1"
  local label="$2"
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    require_ref_file "$ref" "$label proof bundle resolves: $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$card")
}

main() {
  echo "== Support-Target Live-Claim Validation =="

  require_file "$SUPPORT_TARGETS"
  require_file "$AUTHORED_CARD"
  require_file "$ATOMIC_RELEASE_CARD"
  require_file "$CLOSURE_RELEASE_CARD"
  require_file "$CLOSURE_MANIFEST"

  compare_scalar_exprs "authored HarnessCard wording matches closure manifest" '.claim_summary' "$AUTHORED_CARD" '.permitted_release_wording' "$CLOSURE_MANIFEST"
  compare_scalar_exprs "closure supported claim statement matches permitted release wording" '.supported_claim.claim_statement' "$CLOSURE_MANIFEST" '.permitted_release_wording' "$CLOSURE_MANIFEST"
  compare_scalar "atomic release HarnessCard wording matches authored claim" '.claim_summary' "$ATOMIC_RELEASE_CARD" "$AUTHORED_CARD"
  compare_scalar "closure release HarnessCard wording matches authored claim" '.claim_summary' "$CLOSURE_RELEASE_CARD" "$AUTHORED_CARD"

  compare_json "atomic release tuple matches authored tuple" '.compatibility_tuple' "$ATOMIC_RELEASE_CARD" "$AUTHORED_CARD"
  compare_json "closure release tuple matches authored tuple" '.compatibility_tuple' "$CLOSURE_RELEASE_CARD" "$AUTHORED_CARD"
  compare_json "atomic release adapter tuple matches authored tuple" '.adapter_support' "$ATOMIC_RELEASE_CARD" "$AUTHORED_CARD"
  compare_json "closure release adapter tuple matches authored tuple" '.adapter_support' "$CLOSURE_RELEASE_CARD" "$AUTHORED_CARD"
  compare_json "closure manifest known limits match authored HarnessCard" '.known_limits' "$CLOSURE_MANIFEST" "$AUTHORED_CARD"
  compare_json "atomic release known limits match authored HarnessCard" '.known_limits' "$ATOMIC_RELEASE_CARD" "$AUTHORED_CARD"
  compare_json "closure release known limits match authored HarnessCard" '.known_limits' "$CLOSURE_RELEASE_CARD" "$AUTHORED_CARD"

  if [[ "$(yq -r '[.compatibility_matrix[] | select(.support_status == "supported")] | length' "$SUPPORT_TARGETS")" == "1" ]]; then
    pass "support matrix has exactly one supported tuple"
  else
    fail "support matrix has exactly one supported tuple"
  fi

  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-B" and .workload_tier == "WT-2" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-EN" and .support_status == "supported" and .default_route == "allow")' "$SUPPORT_TARGETS" "supported tuple remains the proved repo-local consequential envelope"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-B" and .workload_tier == "WT-3" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-EN" and .support_status == "reduced" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "reduced tuple remains retained stage_only evidence"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-A" and .workload_tier == "WT-1" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-EN" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "MT-A / WT-1 tuple is demoted to experimental"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-B" and .workload_tier == "WT-2" and .language_resource_tier == "LT-EXT" and .locale_tier == "LOC-EN" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "extended-context tuple is demoted to experimental"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-B" and .workload_tier == "WT-2" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-MX" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "secondary-locale tuple is demoted to experimental"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-C" and .workload_tier == "WT-2" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-EN" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "experimental model tuple remains staged"
  require_yq '.compatibility_matrix[] | select(.model_tier == "MT-B" and .workload_tier == "WT-4" and .language_resource_tier == "LT-REF" and .locale_tier == "LOC-EN" and .support_status == "unsupported" and .default_route == "deny")' "$SUPPORT_TARGETS" "unsupported tuple remains denied"

  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and .support_status == "supported" and .default_route == "allow")' "$SUPPORT_TARGETS" "repo-shell remains the only supported host adapter"
  require_yq '.host_adapters[] | select(.adapter_id == "studio-control-plane" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "studio host is demoted to experimental"
  require_yq '.host_adapters[] | select(.adapter_id == "github-control-plane" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "GitHub host is demoted to experimental"
  require_yq '.host_adapters[] | select(.adapter_id == "ci-control-plane" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "CI host is demoted to experimental"
  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and .support_status == "supported" and .default_route == "allow")' "$SUPPORT_TARGETS" "repo-local-governed remains the supported model adapter"
  require_yq '.model_adapters[] | select(.adapter_id == "experimental-external" and .support_status == "experimental" and .default_route == "stage_only")' "$SUPPORT_TARGETS" "experimental external model remains staged"
  require_yq '[.host_adapters[] | select(.support_status == "supported")] | length == 1' "$SUPPORT_TARGETS" "support matrix has exactly one supported host adapter"
  require_yq '.host_adapters[] | select(.support_status == "supported") | .adapter_id == "repo-shell"' "$SUPPORT_TARGETS" "repo-shell is the unique supported host adapter"
  require_yq '[.model_adapters[] | select(.support_status == "supported")] | length == 1' "$SUPPORT_TARGETS" "support matrix has exactly one supported model adapter"
  require_yq '.model_adapters[] | select(.support_status == "supported") | .adapter_id == "repo-local-governed"' "$SUPPORT_TARGETS" "repo-local-governed is the unique supported model adapter"

  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and (.allowed_model_tiers | length) == 1 and .allowed_model_tiers[0] == "MT-B")' "$SUPPORT_TARGETS" "repo-shell allowed model tiers are narrowed to proved live support"
  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and (.allowed_workload_tiers | length) == 2 and .allowed_workload_tiers[0] == "WT-2" and .allowed_workload_tiers[1] == "WT-3")' "$SUPPORT_TARGETS" "repo-shell allowed workload tiers are narrowed to proved live support"
  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and (.allowed_language_resource_tiers | length) == 1 and .allowed_language_resource_tiers[0] == "LT-REF")' "$SUPPORT_TARGETS" "repo-shell allowed language-resource tiers are narrowed to proved live support"
  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and (.allowed_locale_tiers | length) == 1 and .allowed_locale_tiers[0] == "LOC-EN")' "$SUPPORT_TARGETS" "repo-shell allowed locale tiers are narrowed to proved live support"

  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and (.allowed_model_tiers | length) == 1 and .allowed_model_tiers[0] == "MT-B")' "$SUPPORT_TARGETS" "repo-local-governed allowed model tiers are narrowed to proved live support"
  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and (.allowed_workload_tiers | length) == 2 and .allowed_workload_tiers[0] == "WT-2" and .allowed_workload_tiers[1] == "WT-3")' "$SUPPORT_TARGETS" "repo-local-governed allowed workload tiers are narrowed to proved live support"
  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and (.allowed_language_resource_tiers | length) == 1 and .allowed_language_resource_tiers[0] == "LT-REF")' "$SUPPORT_TARGETS" "repo-local-governed allowed language-resource tiers are narrowed to proved live support"
  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and (.allowed_locale_tiers | length) == 1 and .allowed_locale_tiers[0] == "LOC-EN")' "$SUPPORT_TARGETS" "repo-local-governed allowed locale tiers are narrowed to proved live support"

  require_yq '.supported_claim.model_tier == "MT-B" and .supported_claim.workload_tier == "WT-2" and .supported_claim.language_resource_tier == "LT-REF" and .supported_claim.locale_tier == "LOC-EN" and .supported_claim.host_adapter == "repo-shell" and .supported_claim.model_adapter == "repo-local-governed"' "$CLOSURE_MANIFEST" "closure manifest freezes the proved supported tuple"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "MT-A/WT-1" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes MT-A / WT-1"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "studio-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes Studio host"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "github-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes GitHub host"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "ci-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes CI host"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "WT-3" and .status == "reduced" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest preserves reduced WT-3 proof"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "LT-EXT" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes extended-context support"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "LOC-MX" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest demotes secondary-locale support"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "MT-C" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest preserves staged experimental model support"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "WT-4" and .status == "unsupported" and .route == "deny")' "$CLOSURE_MANIFEST" "closure manifest preserves unsupported deny surface"

  check_proof_bundle "$AUTHORED_CARD" "authored HarnessCard"
  check_proof_bundle "$ATOMIC_RELEASE_CARD" "atomic release HarnessCard"
  check_proof_bundle "$CLOSURE_RELEASE_CARD" "closure release HarnessCard"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
