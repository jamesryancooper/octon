#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"

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
  adr-update
  migration-rationale
  rollback-notes
  change-receipt
)

PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-decision-drafter"

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
    expected_id="octon-decision-drafter-$bundle"
    [[ "$(yq -r '.prompt_set_id // ""' "$manifest")" == "$expected_id" ]] || return 1
  done
}

case_pack_shape_matches_plan() {
  [[ "$(yq -r '.pack_id // ""' "$PACK_ROOT/pack.yml")" == "octon-decision-drafter" ]]
  [[ "$(yq -r '.content_entrypoints.templates' "$PACK_ROOT/pack.yml")" == "null" ]]
  [[ "$(yq -r '.compatibility.profile_path // ""' "$PACK_ROOT/pack.yml")" == "validation/compatibility.yml" ]]
}

case_default_route_and_skill_defaults_are_correct() {
  [[ "$(yq -r '.dispatchers[0].default_route_id // ""' "$PACK_ROOT/context/routing.contract.yml")" == "change-receipt" ]]
  [[ "$(yq -r '.skills."octon-decision-drafter".parameters[] | select(.name == "output_mode") | .default // ""' "$PACK_ROOT/skills/registry.fragment.yml")" == "inline" ]]
  [[ "$(yq -r '.skills."octon-decision-drafter".parameters[] | select(.name == "alignment_mode") | .default // ""' "$PACK_ROOT/skills/registry.fragment.yml")" == "auto" ]]
  [[ "$(yq -r '.skills."octon-decision-drafter".parameters[] | select(.name == "dry_run_route") | .default' "$PACK_ROOT/skills/registry.fragment.yml")" == "false" ]]
}

case_leaf_commands_and_skills_are_family_prefixed() {
  local expected
  for bundle in "${expected_bundles[@]}"; do
    expected="octon-decision-drafter-$bundle"
    grep -Fq "id: $expected" "$PACK_ROOT/commands/manifest.fragment.yml"
    grep -Fq "id: $expected" "$PACK_ROOT/skills/manifest.fragment.yml"
    grep -Fq "$expected:" "$PACK_ROOT/skills/registry.fragment.yml"
  done
}

case_prompt_manifests_share_required_contracts() {
  local bundle manifest ids count
  for bundle in "${expected_bundles[@]}"; do
    manifest="$PACK_ROOT/prompts/$bundle/manifest.yml"
    ids="$(yq -r '.shared_references[]?.ref_id // ""' "$manifest" | awk 'NF' | sort)"
    count="$(wc -l <<<"$ids" | tr -d ' ')"
    [[ "$count" == "5" ]] || return 1
    grep -Fxq "repository-grounding" <<<"$ids"
    grep -Fxq "non-authoritative-draft-contract" <<<"$ids"
    grep -Fxq "diff-evidence-input-contract" <<<"$ids"
    grep -Fxq "draft-output-contract" <<<"$ids"
    grep -Fxq "draft-artifact-contract" <<<"$ids"
  done
}

case_prompt_manifests_are_three_stage_bundles() {
  local bundle manifest
  for bundle in "${expected_bundles[@]}"; do
    manifest="$PACK_ROOT/prompts/$bundle/manifest.yml"
    [[ "$(yq -r '.stages | length' "$manifest")" == "3" ]] || return 1
    [[ "$(yq -r '.companions | length' "$manifest")" == "1" ]] || return 1
    [[ "$(yq -r '.required_repo_anchors | length' "$manifest")" -gt 0 ]] || return 1
  done
}

main() {
  assert_success "all 4 prompt bundles declare unique prompt_set_ids" case_unique_prompt_set_ids
  assert_success "bundle folder names match canonical prompt_set_id suffixes" case_bundle_folder_names_match_ids
  assert_success "pack manifest shape matches the planned raw-pack posture" case_pack_shape_matches_plan
  assert_success "default route and composite skill defaults match the plan" case_default_route_and_skill_defaults_are_correct
  assert_success "leaf commands and skills use the family-prefixed naming rule" case_leaf_commands_and_skills_are_family_prefixed
  assert_success "all prompt manifests use the required shared contracts" case_prompt_manifests_share_required_contracts
  assert_success "all prompt manifests are three-stage bundles with one companion" case_prompt_manifests_are_three_stage_bundles

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
