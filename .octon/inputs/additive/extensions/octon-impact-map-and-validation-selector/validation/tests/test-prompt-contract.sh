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

expected_bundles=(
  touched-paths-impact-map
  proposal-packet-impact-map
  refactor-target-impact-map
  mixed-input-reconciliation
)

case_unique_prompt_set_ids() {
  local ids=""
  local manifest
  while IFS= read -r manifest; do
    ids+="$(yq -r '.prompt_set_id // ""' "$manifest")"$'\n'
  done < <(find "$PACK_ROOT/prompts" -name manifest.yml -type f | sort)
  ids="$(awk 'NF' <<<"$ids")"
  [[ "$(wc -l <<<"$ids" | tr -d ' ')" == "4" ]]
  [[ "$(sort <<<"$ids" | uniq | wc -l | tr -d ' ')" == "4" ]]
}

case_bundle_folder_names_match_ids() {
  local bundle manifest expected_id
  for bundle in "${expected_bundles[@]}"; do
    manifest="$PACK_ROOT/prompts/$bundle/manifest.yml"
    [[ -f "$manifest" ]] || return 1
    expected_id="octon-impact-map-and-validation-selector-$bundle"
    [[ "$(yq -r '.prompt_set_id // ""' "$manifest")" == "$expected_id" ]] || return 1
  done
}

case_every_bundle_has_alignment_companion_and_shared_contracts() {
  local manifest
  while IFS= read -r manifest; do
    [[ "$(yq -r '.companions[]? | select(.role_class == "maintenance-companion") | .path' "$manifest")" == "companions/01-align-bundle.md" ]] || return 1
    grep -Fq 'path: "shared/output-contract.md"' "$manifest" || return 1
    grep -Fq 'path: "shared/repository-grounding.md"' "$manifest" || return 1
    grep -Fq 'path: "shared/validation-selection-rules.md"' "$manifest" || return 1
    grep -Fq 'path: "shared/next-step-routing-rules.md"' "$manifest" || return 1
  done < <(find "$PACK_ROOT/prompts" -name manifest.yml -type f | sort)
}

case_dispatcher_defaults_to_touched_paths() {
  grep -Fq 'default_route_id: "touched-paths"' "$PACK_ROOT/context/routing.contract.yml"
  grep -Fq 'Default route:' "$PACK_ROOT/commands/octon-impact-map-and-validation-selector.md"
  grep -Fq '`touched-paths`' "$PACK_ROOT/commands/octon-impact-map-and-validation-selector.md"
}

case_runtime_facing_assets_avoid_raw_pack_self_references() {
  ! rg -n '\.octon/inputs/additive/extensions/octon-impact-map-and-validation-selector' \
    "$PACK_ROOT/README.md" \
    "$PACK_ROOT/commands" \
    "$PACK_ROOT/context" \
    "$PACK_ROOT/prompts" \
    "$PACK_ROOT/skills" \
    "$PACK_ROOT/validation/README.md" \
    "$PACK_ROOT/validation/bundle-matrix.md" \
    >/dev/null 2>&1
}

main() {
  assert_success "all four prompt bundles declare unique prompt_set_ids" case_unique_prompt_set_ids
  assert_success "bundle folder names match canonical prompt_set_id suffixes" case_bundle_folder_names_match_ids
  assert_success "every bundle carries the alignment companion and shared contracts" case_every_bundle_has_alignment_companion_and_shared_contracts
  assert_success "dispatcher defaults to touched-paths" case_dispatcher_defaults_to_touched_paths
  assert_success "runtime-facing assets avoid raw pack self-references" case_runtime_facing_assets_avoid_raw_pack_self_references

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
