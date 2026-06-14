#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

if [[ "${1:-}" == "--root" ]]; then
  REPO_ROOT="$(cd -- "$2" && pwd)"
  shift 2
fi

MECHANISM_ROOT="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms"
INDEX="$MECHANISM_ROOT/index.yml"
README="$MECHANISM_ROOT/README.md"
CLOSEOUT_TEMPLATE="$MECHANISM_ROOT/aggregate-closeout-evidence-template.md"
OPERATOR_MAP="$REPO_ROOT/.octon/generated/cognition/projections/materialized/governed-cross-surface-mechanisms/operator-map.md"
PRODUCT_CATALOG="$REPO_ROOT/.octon/framework/product/features/catalog.yml"
GMI_PROFILE_VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() {
  printf '[ERROR] %s\n' "$1" >&2
  errors=$((errors + 1))
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    pass "yq available"
  else
    fail "yq is required"
    exit 1
  fi
}

has_text() {
  local file="$1" text="$2"
  rg -Fq -- "$text" "$file"
}

require_file() {
  local path="$1" label="$2"
  if [[ -f "$path" ]]; then
    pass "$label present"
  else
    fail "$label missing: ${path#$REPO_ROOT/}"
  fi
}

required_mechanisms=(
  change-closeout-lifecycle
  governed-lifecycle-orchestration
  architectural-review-mechanism
  governed-incoming-intake-routing
  extension-packs
  run-lifecycle-v1
  workflow-system
  execution-authorization-effect-token
  evidence-store-proof-plane
  lifecycle-interaction-receipts
  repo-hygiene-cleanup
  mission-autonomy-runner
  mission-plan-compiler
  generated-effective-runtime-resolution
  operator-read-models
  governed-mechanism-integration-verification
)

required_sections=(
  authored_authority_refs
  product_contract_refs
  runtime_spec_refs
  runtime_implementation_refs
  mutable_operational_truth_refs
  retained_evidence_refs
  generated_effective_non_authority_refs
  generated_operator_read_model_refs
  raw_input_refs
  publication_input_only_refs
  navigation_only_refs
  compatibility_only_refs
  validator_refs
  ownership_boundaries
  non_authority_boundaries
)

validate_readme() {
  require_file "$README" "mechanism index README"
  [[ -f "$README" ]] || return

  for phrase in \
    "not runtime authority" \
    "product features" \
    "governed cross-surface mechanisms" \
    "lifecycles, workflows, routes, state machines, receipts, commands, and skills" \
    '`state/control/**` is mutable operational truth, not retained evidence' \
    "Lifecycle interaction receipts are advisory dependency context" \
    "Parent proposal-program evidence may summarize child outcomes" \
    "governed mechanism integration profiles"; do
    if has_text "$README" "$phrase"; then
      pass "README boundary phrase present: $phrase"
    else
      fail "README boundary phrase missing: $phrase"
    fi
  done
}

validate_product_catalog_boundary() {
  require_file "$PRODUCT_CATALOG" "product feature catalog"
  [[ -f "$PRODUCT_CATALOG" ]] || return

  if [[ "$(yq -r '.catalog_role // ""' "$PRODUCT_CATALOG")" == "navigation-only" ]]; then
    pass "product feature catalog remains navigation-only"
  else
    fail "product feature catalog must remain navigation-only"
  fi
}

validate_index_shape() {
  require_file "$INDEX" "mechanism index"
  [[ -f "$INDEX" ]] || return

  if yq -e '.' "$INDEX" >/dev/null 2>&1; then
    pass "mechanism index YAML parses"
  else
    fail "mechanism index YAML does not parse"
    return
  fi

  if [[ "$(yq -r '.schema_version // ""' "$INDEX")" == "governed-cross-surface-mechanism-index-v1" ]]; then
    pass "mechanism index schema_version current"
  else
    fail "mechanism index schema_version invalid"
  fi

  if [[ "$(yq -r '.index_role // ""' "$INDEX")" == "architecture-governance-navigation" ]]; then
    pass "mechanism index role is architecture-governance-navigation"
  else
    fail "mechanism index role must be architecture-governance-navigation"
  fi

  local count
  count="$(yq -r '(.mechanisms // []) | length' "$INDEX")"
  if [[ "$count" -ge 15 ]]; then
    pass "mechanism index covers at least 15 mechanisms"
  else
    fail "mechanism index must cover at least 15 mechanisms"
  fi

  local id
  for id in "${required_mechanisms[@]}"; do
    if yq -e ".mechanisms[]? | select(.mechanism_id == \"$id\")" "$INDEX" >/dev/null 2>&1; then
      pass "required mechanism covered: $id"
    else
      fail "required mechanism missing: $id"
    fi
  done
}

validate_governed_mechanism_profiles() {
  local profile_count profile
  [[ -d "$MECHANISM_ROOT/profiles" ]] || {
    fail "governed mechanism profile directory missing"
    return
  }

  profile_count="$(find "$MECHANISM_ROOT/profiles" -maxdepth 1 -name '*.profile.yml' -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$profile_count" -gt 0 ]]; then
    pass "governed mechanism profiles present"
  else
    fail "governed mechanism profiles missing"
    return
  fi

  while IFS= read -r profile; do
    [[ -n "$profile" ]] || continue
    if bash "$GMI_PROFILE_VALIDATOR" --profile "$profile"; then
      pass "governed mechanism profile validates: ${profile#$REPO_ROOT/}"
    else
      fail "governed mechanism profile validates: ${profile#$REPO_ROOT/}"
    fi
  done < <(find "$MECHANISM_ROOT/profiles" -maxdepth 1 -name '*.profile.yml' -type f | sort)
}

validate_mechanism_sections() {
  [[ -f "$INDEX" ]] || return

  local count index id section len
  count="$(yq -r '(.mechanisms // []) | length' "$INDEX")"
  for ((index=0; index<count; index++)); do
    id="$(yq -r ".mechanisms[$index].mechanism_id // \"mechanisms[$index]\"" "$INDEX")"
    for section in "${required_sections[@]}"; do
      len="$(yq -r "(.mechanisms[$index].$section // []) | length" "$INDEX")"
      if [[ "$len" -gt 0 ]]; then
        pass "$id declares $section"
      else
        fail "$id missing required section: $section"
      fi
    done
  done
}

validate_path_class_boundaries() {
  [[ -f "$INDEX" ]] || return

  local ref

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    if [[ "$ref" == *".octon/state/control/"* ]]; then
      fail "state/control cannot be retained evidence: $ref"
    fi
  done < <(yq -r '.mechanisms[]?.retained_evidence_refs[]? // ""' "$INDEX")

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    if [[ "$ref" == *".octon/state/evidence/"* ]]; then
      fail "state/evidence cannot be mutable operational truth: $ref"
    fi
  done < <(yq -r '.mechanisms[]?.mutable_operational_truth_refs[]? // ""' "$INDEX")

  while IFS= read -r ref; do
    [[ -n "$ref" || "$ref" == not-applicable:* ]] || continue
    if [[ "$ref" == *".octon/generated/cognition/"* ]]; then
      fail "generated cognition path cannot be generated-effective non-authority: $ref"
    fi
  done < <(yq -r '.mechanisms[]?.generated_effective_non_authority_refs[]? // ""' "$INDEX")

  while IFS= read -r ref; do
    [[ -n "$ref" || "$ref" == not-applicable:* ]] || continue
    if [[ "$ref" == *".octon/generated/effective/"* ]]; then
      fail "generated effective path cannot be generated operator read model: $ref"
    fi
  done < <(yq -r '.mechanisms[]?.generated_operator_read_model_refs[]? // ""' "$INDEX")

  pass "path/class boundary scan completed"
}

validate_closeout_template() {
  require_file "$CLOSEOUT_TEMPLATE" "aggregate closeout template"
  [[ -f "$CLOSEOUT_TEMPLATE" ]] || return

  for phrase in \
    "child_authority_preserved: true" \
    "parent_evidence_satisfies_child_receipts: false" \
    "proposal_lifecycle: separate" \
    "change_closeout: separate" \
    "worktree_closeout: separate" \
    "repo_hygiene_cleanup: separate" \
    "parent closeout is incomplete"; do
    if has_text "$CLOSEOUT_TEMPLATE" "$phrase"; then
      pass "aggregate closeout boundary present: $phrase"
    else
      fail "aggregate closeout boundary missing: $phrase"
    fi
  done
}

validate_operator_map() {
  require_file "$OPERATOR_MAP" "governed cross-surface operator map"
  [[ -f "$OPERATOR_MAP" ]] || return

  for phrase in \
    'schema_version: `governed-cross-surface-mechanisms-operator-map-v1`' \
    "generated_at:" \
    'freshness_mode: `source-ref-bound`' \
    'authority_class: `generated-operator-read-model`' \
    "navigation only and visibility only" \
    "## Source Refs" \
    "## Forbidden Consumers" \
    "runtime policy" \
    "parent evidence satisfying child receipts" \
    "retained evidence gates"; do
    if has_text "$OPERATOR_MAP" "$phrase"; then
      pass "operator map metadata present: $phrase"
    else
      fail "operator map metadata missing: $phrase"
    fi
  done
}

main() {
  echo "== Governed Cross-Surface Mechanisms Validation =="
  require_yq
  validate_readme
  validate_product_catalog_boundary
  validate_index_shape
  validate_mechanism_sections
  validate_path_class_boundaries
  validate_governed_mechanism_profiles
  validate_closeout_template
  validate_operator_map
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"
