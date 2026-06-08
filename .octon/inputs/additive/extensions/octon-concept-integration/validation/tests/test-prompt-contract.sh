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

assert_contains() {
  local file="$1" pattern="$2"
  grep -Fq -- "$pattern" "$file"
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

case_architecture_review_method_contract_is_wired() {
  local shared arch_manifest source_manifest subsystem_manifest
  local arch_stage1 arch_stage2 arch_stage3 arch_stage4
  local source_verify source_build subsystem_verify subsystem_build
  local prompt_root

  prompt_root="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts"
  shared="$prompt_root/shared/architecture-review-method.md"
  arch_manifest="$prompt_root/architecture-revision-packet/manifest.yml"
  source_manifest="$prompt_root/source-to-architecture-packet/manifest.yml"
  subsystem_manifest="$prompt_root/subsystem-targeted-integration/manifest.yml"
  arch_stage1="$prompt_root/architecture-revision-packet/stages/01-identify-architectural-pressure.md"
  arch_stage2="$prompt_root/architecture-revision-packet/stages/02-map-current-constraints.md"
  arch_stage3="$prompt_root/architecture-revision-packet/stages/03-design-revised-architecture.md"
  arch_stage4="$prompt_root/architecture-revision-packet/stages/04-build-revision-packet.md"
  source_verify="$prompt_root/source-to-architecture-packet/stages/02-verify.md"
  source_build="$prompt_root/source-to-architecture-packet/stages/03-build-architecture-packet.md"
  subsystem_verify="$prompt_root/subsystem-targeted-integration/stages/03-verify-subsystem-fit.md"
  subsystem_build="$prompt_root/subsystem-targeted-integration/stages/04-build-subsystem-packet.md"

  [[ -f "$shared" ]] || return 1
  assert_contains "$shared" "first-principles"
  assert_contains "$shared" "current architecture steelmanning"
  assert_contains "$shared" "Chesterton's Fence"
  assert_contains "$shared" "constraint ledger"
  assert_contains "$shared" "complexity ledger"
  assert_contains "$shared" "bottlenecks"
  assert_contains "$shared" "failure modes"
  assert_contains "$shared" "quality attributes"
  assert_contains "$shared" "hardening"
  assert_contains "$shared" "rollback"
  assert_contains "$shared" "Octon-Fit Gates"

  [[ "$(yq -r '.shared_references[]? | select(.ref_id == "architecture-review-method") | .path' "$arch_manifest")" == "shared/architecture-review-method.md" ]] || return 1
  [[ "$(yq -r '.shared_references[]? | select(.ref_id == "architecture-review-method") | .path' "$source_manifest")" == "shared/architecture-review-method.md" ]] || return 1
  [[ "$(yq -r '.shared_references[]? | select(.ref_id == "architecture-review-method") | .path' "$subsystem_manifest")" == "shared/architecture-review-method.md" ]] || return 1

  assert_contains "$arch_stage1" "../../shared/architecture-review-method.md"
  assert_contains "$arch_stage1" "review objective"
  assert_contains "$arch_stage1" "first-principles"
  assert_contains "$arch_stage1" "clean-sheet"
  assert_contains "$arch_stage2" "../../shared/architecture-review-method.md"
  assert_contains "$arch_stage2" "current reality maps"
  assert_contains "$arch_stage2" "stealmans the current architecture"
  assert_contains "$arch_stage2" "Chesterton's Fence"
  assert_contains "$arch_stage2" "constraint, complexity, bottleneck, and leverage ledgers"
  assert_contains "$arch_stage3" "../../shared/architecture-review-method.md"
  assert_contains "$arch_stage3" "quality attributes"
  assert_contains "$arch_stage3" "hardening gates"
  assert_contains "$arch_stage3" "rollback"
  assert_contains "$arch_stage4" "../../shared/architecture-review-method.md"
  assert_contains "$arch_stage4" "source -> review -> pressure"
  assert_contains "$arch_stage4" "Octon-fit notes"
  assert_contains "$arch_stage4" "non-authoritative"

  assert_contains "$source_verify" "../../shared/architecture-review-method.md"
  assert_contains "$source_build" "first-principles decomposition was paired"
  assert_contains "$source_build" "Octon-fit gates"
  assert_contains "$subsystem_verify" "../../shared/architecture-review-method.md"
  assert_contains "$subsystem_verify" "Octon-fit gates"
  assert_contains "$subsystem_build" "../../shared/architecture-review-method.md"
  assert_contains "$subsystem_build" "quality/hardening criteria"

  ! rg -n 'architecture-review-and-octon-integration-prompt-set|octon-concept-integration-architecture-review-refinement' \
    "$prompt_root" >/dev/null 2>&1
}

case_runtime_facing_assets_avoid_raw_pack_self_references() {
  ! rg -n '\.octon/inputs/additive/extensions/octon-concept-integration' \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/README.md" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/commands" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/context" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/validation/README.md" \
    "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/validation/bundle-matrix.md" \
    >/dev/null 2>&1
}

main() {
  assert_success "all 10 prompt bundles declare unique prompt_set_ids" case_unique_prompt_set_ids
  assert_success "bundle folder names match canonical prompt_set_id suffixes" case_bundle_folder_names_match_ids
  assert_success "dispatcher defaults to source-to-architecture-packet" case_dispatcher_defaults_to_architecture
  assert_success "leaf commands and skills use the family-prefixed naming rule" case_leaf_commands_and_skills_are_family_prefixed
  assert_success "leaf skill parameters differ by bundle where required" case_leaf_skill_parameters_differ_by_bundle
  assert_success "architecture revision includes the implementation-prompt companion" case_architecture_revision_has_prompt_generation_companion
  assert_success "constitutional challenge excludes the implementation-prompt companion" case_constitutional_challenge_has_no_prompt_generation_companion
  assert_success "architecture review method contract is wired into architecture routes" case_architecture_review_method_contract_is_wired
  assert_success "runtime-facing assets avoid raw pack self-references" case_runtime_facing_assets_avoid_raw_pack_self_references

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
