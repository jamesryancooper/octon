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
  source-to-architecture-packet
  architecture-revision-packet
  constitutional-challenge-packet
  source-to-policy-packet
  source-to-migration-packet
  multi-source-synthesis-packet
  packet-refresh-and-supersession
  packet-to-implementation
  subsystem-targeted-integration
  repo-internal-concept-mining
)

case_unique_prompt_set_ids() {
  local ids=""
  local manifest
  while IFS= read -r manifest; do
    ids+="$(yq -r '.prompt_set_id // ""' "$manifest")"$'\n'
  done < <(find "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts" -name manifest.yml -type f | sort)
  ids="$(awk 'NF' <<<"$ids")"
  [[ "$(wc -l <<<"$ids" | tr -d ' ')" == "10" ]]
  [[ "$(sort <<<"$ids" | uniq | wc -l | tr -d ' ')" == "10" ]]
}

case_bundle_folder_names_match_ids() {
  local bundle manifest expected_id
  for bundle in "${expected_bundles[@]}"; do
    manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/$bundle/manifest.yml"
    [[ -f "$manifest" ]] || return 1
    expected_id="octon-concept-integration-$bundle"
    [[ "$(yq -r '.prompt_set_id // ""' "$manifest")" == "$expected_id" ]] || return 1
  done
}

case_dispatcher_defaults_to_architecture() {
  grep -Fq 'default: "source-to-architecture-packet"' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  grep -Fq 'Default route:' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/commands/octon-concept-integration.md"
  grep -Fq 'source-to-architecture-packet' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/commands/octon-concept-integration.md"
}

case_leaf_commands_and_skills_are_family_prefixed() {
  local expected
  for bundle in "${expected_bundles[@]}"; do
    expected="octon-concept-integration-$bundle"
    grep -Fq "id: $expected" \
      "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/commands/manifest.fragment.yml"
    grep -Fq "id: $expected" \
      "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/manifest.fragment.yml"
    grep -Fq "$expected:" \
      "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  done
}

case_leaf_skill_parameters_differ_by_bundle() {
  grep -Fq 'source_artifacts' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  grep -Fq 'proposal_packet' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  grep -Fq 'conflicting_kernel_rules' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  grep -Fq 'repo_paths' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  grep -Fq 'subsystem_scope' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
}

case_architecture_revision_has_prompt_generation_companion() {
  local manifest
  manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/architecture-revision-packet/manifest.yml"
  [[ "$(yq -r '.companions[] | select(.role_class == "prompt-generation-companion") | .path' "$manifest")" == "companions/01-generate-implementation-prompt.md" ]]
}

case_constitutional_challenge_has_no_prompt_generation_companion() {
  local manifest
  manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/constitutional-challenge-packet/manifest.yml"
  [[ -z "$(yq -r '.companions[]? | select(.role_class == "prompt-generation-companion") | .path' "$manifest")" ]]
}

main() {
  assert_success "all 10 prompt bundles declare unique prompt_set_ids" case_unique_prompt_set_ids
  assert_success "bundle folder names match canonical prompt_set_id suffixes" case_bundle_folder_names_match_ids
  assert_success "dispatcher defaults to source-to-architecture-packet" case_dispatcher_defaults_to_architecture
  assert_success "leaf commands and skills use the family-prefixed naming rule" case_leaf_commands_and_skills_are_family_prefixed
  assert_success "leaf skill parameters differ by bundle where required" case_leaf_skill_parameters_differ_by_bundle
  assert_success "architecture revision includes the implementation-prompt companion" case_architecture_revision_has_prompt_generation_companion
  assert_success "constitutional challenge excludes the implementation-prompt companion" case_constitutional_challenge_has_no_prompt_generation_companion

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
