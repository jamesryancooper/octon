#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-impact-map-and-validation-selector"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

publish_extensions_and_routing() {
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
  bash "$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" >/dev/null
}

case_selection_rules_reuse_existing_validators_only() {
  local rules="$PACK_ROOT/context/selection-rules.md"
  grep -Fq 'validate-extension-pack-contract.sh' "$rules"
  grep -Fq 'alignment-check.sh --profile harness' "$rules"
  grep -Fq 'validate-proposal-standard.sh' "$rules"
  grep -Fq '/refactor' "$rules"
  grep -Fq '/octon-concept-integration-packet-refresh-and-supersession' "$rules"
  ! grep -Fq 'new validator' "$rules"
}

case_bundle_matrix_covers_all_public_routes() {
  local matrix="$PACK_ROOT/validation/bundle-matrix.md"
  grep -Fq '`touched-paths`' "$matrix"
  grep -Fq '`proposal-packet`' "$matrix"
  grep -Fq '`refactor-target`' "$matrix"
  grep -Fq '`mixed-inputs`' "$matrix"
}

case_registry_and_fragments_use_family_prefixed_ids() {
  grep -Fq 'octon-impact-map-and-validation-selector:' "$PACK_ROOT/skills/registry.fragment.yml"
  grep -Fq 'id: octon-impact-map-and-validation-selector-touched-paths' "$PACK_ROOT/commands/manifest.fragment.yml"
  grep -Fq 'id: octon-impact-map-and-validation-selector-proposal-packet' "$PACK_ROOT/skills/manifest.fragment.yml"
}

case_published_catalog_includes_dispatcher_and_prompt_bundles() {
  local catalog="$REPO_ROOT/.octon/generated/effective/extensions/catalog.effective.yml"
  yq -e '.packs[]? | select(.pack_id == "octon-impact-map-and-validation-selector")' "$catalog" >/dev/null
  [[ "$(yq -r '.packs[]? | select(.pack_id == "octon-impact-map-and-validation-selector") | (.route_dispatchers // []) | length' "$catalog")" == "1" ]]
  [[ "$(yq -r '.packs[]? | select(.pack_id == "octon-impact-map-and-validation-selector") | (.prompt_bundles // []) | length' "$catalog")" == "4" ]]
}

case_capability_routing_publication_includes_dispatcher_command() {
  local routing="$REPO_ROOT/.octon/generated/effective/capabilities/routing.effective.yml"
  grep -Fq 'octon-impact-map-and-validation-selector' "$routing"
  grep -Fq 'octon-impact-map-and-validation-selector-touched-paths' "$routing"
}

main() {
  publish_extensions_and_routing

  assert_success "selection rules reuse existing repo validators and workflows" case_selection_rules_reuse_existing_validators_only
  assert_success "bundle matrix covers all public routes" case_bundle_matrix_covers_all_public_routes
  assert_success "registry and manifest fragments use family-prefixed ids" case_registry_and_fragments_use_family_prefixed_ids
  assert_success "published catalog includes the dispatcher and all four prompt bundles" case_published_catalog_includes_dispatcher_and_prompt_bundles
  assert_success "capability routing publication includes the dispatcher and leaf exports" case_capability_routing_publication_includes_dispatcher_command

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
