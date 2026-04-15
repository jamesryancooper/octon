#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

expected_prompt_sets=(
  octon-concept-integration-source-to-architecture-packet
  octon-concept-integration-architecture-revision-packet
  octon-concept-integration-constitutional-challenge-packet
  octon-concept-integration-source-to-policy-packet
  octon-concept-integration-source-to-migration-packet
  octon-concept-integration-multi-source-synthesis-packet
  octon-concept-integration-packet-refresh-and-supersession
  octon-concept-integration-packet-to-implementation
  octon-concept-integration-subsystem-targeted-integration
  octon-concept-integration-repo-internal-concept-mining
)

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

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

create_fixture() {
  mktemp -d "${TMPDIR:-/tmp}/prompt-bundle-fixture.XXXXXX"
}

copy_file() {
  local root="$1" rel="$2"
  mkdir -p "$root/$(dirname "$rel")"
  cp "$REPO_ROOT/$rel" "$root/$rel"
}

write_fixture() {
  local root="$1"
  mkdir -p \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts" \
    "$root/.octon/inputs/additive/extensions" \
    "$root/.octon/instance" \
    "$root/.octon/state/control/extensions" \
    "$root/.octon/state/evidence/validation/publication/extensions" \
    "$root/.octon/state/evidence/validation/extensions" \
    "$root/.octon/generated/effective/extensions"

  copy_file "$root" "README.md"
  copy_file "$root" ".octon/README.md"
  copy_file "$root" ".octon/octon.yml"
  copy_file "$root" ".octon/framework/manifest.yml"
  copy_file "$root" ".octon/instance/manifest.yml"
  copy_file "$root" ".octon/instance/ingress/AGENTS.md"
  copy_file "$root" ".octon/framework/constitution/CHARTER.md"
  copy_file "$root" ".octon/framework/constitution/charter.yml"
  copy_file "$root" ".octon/framework/constitution/precedence/normative.yml"
  copy_file "$root" ".octon/framework/constitution/precedence/epistemic.yml"
  copy_file "$root" ".octon/framework/constitution/obligations/fail-closed.yml"
  copy_file "$root" ".octon/framework/constitution/obligations/evidence.yml"
  copy_file "$root" ".octon/framework/constitution/ownership/roles.yml"
  copy_file "$root" ".octon/framework/constitution/contracts/registry.yml"
  copy_file "$root" ".octon/instance/charter/workspace.md"
  copy_file "$root" ".octon/instance/charter/workspace.yml"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/specification.md"

  cp -R "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration" \
    "$root/.octon/inputs/additive/extensions/"

  cat >"$root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "octon-concept-integration"
      source_id: "bundled-first-party"
  disabled: []
sources:
  catalog:
    bundled-first-party:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_bundled"
    first-party-imported:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_external"
    third-party-imported:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "third_party"
trust:
  default_actions:
    first_party_bundled: "allow"
    first_party_external: "require_acknowledgement"
    third_party: "deny"
  source_overrides: {}
  pack_overrides: {}
acknowledgements: []
EOF

  cat >"$root/.octon/state/control/extensions/active.yml" <<'EOF'
schema_version: "octon-extension-active-state-v3"
desired_config_revision:
  path: ".octon/instance/extensions.yml"
  sha256: "stub"
desired_selected_packs: []
published_active_packs: []
dependency_closure: []
generation_id: "stub"
published_effective_catalog: ".octon/generated/effective/extensions/catalog.effective.yml"
published_artifact_map: ".octon/generated/effective/extensions/artifact-map.yml"
published_generation_lock: ".octon/generated/effective/extensions/generation.lock.yml"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
publication_receipt_sha256: "stub"
invalidation_conditions: []
required_inputs: []
validation_timestamp: "1970-01-01T00:00:00Z"
status: "withdrawn"
EOF

  cat >"$root/.octon/state/control/extensions/quarantine.yml" <<'EOF'
schema_version: "octon-extension-quarantine-state-v3"
updated_at: "1970-01-01T00:00:00Z"
records: []
EOF

  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'EOF'
schema_version: "octon-extension-effective-catalog-v4"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
invalidation_conditions: []
desired_selected_packs: []
published_active_packs: []
dependency_closure: []
packs: []
source:
  desired_config_path: ".octon/instance/extensions.yml"
  desired_config_sha256: "stub"
  root_manifest_path: ".octon/octon.yml"
  root_manifest_sha256: "stub"
EOF

  cat >"$root/.octon/generated/effective/extensions/artifact-map.yml" <<'EOF'
schema_version: "octon-extension-artifact-map-v4"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
artifacts: []
EOF

  cat >"$root/.octon/generated/effective/extensions/generation.lock.yml" <<'EOF'
schema_version: "octon-extension-generation-lock-v4"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
publication_receipt_sha256: "stub"
desired_config_sha256: "stub"
root_manifest_sha256: "stub"
published_files: []
required_inputs: []
invalidation_conditions: []
pack_payload_digests: []
EOF

  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"
  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh"

  chmod +x \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh"
}

publish_state() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_bundle() {
  local root="$1" prompt_set_id="$2" mode="$3"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-concept-integration \
      --prompt-set-id "$prompt_set_id" \
      --alignment-mode "$mode"
}

case_all_bundles_publish_fresh() {
  local fixture out prompt_set
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  for prompt_set in "${expected_prompt_sets[@]}"; do
    out="$(resolve_bundle "$fixture" "$prompt_set" auto)"
    jq -e --arg prompt_set "$prompt_set" '.status == "fresh" and .safe_to_run == true and .prompt_set_id == $prompt_set' <<<"$out" >/dev/null || return 1
  done
}

case_stale_architecture_prompt_blocks_auto() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale fixture mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/source-to-architecture-packet/stages/01-extract.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)" && return 1
  jq -e '.status == "blocked" and .safe_to_run == false and (.reason_codes | any(startswith("prompt-asset-sha-changed:stages/01-extract.md")))' <<<"$out" >/dev/null
}

case_stale_architecture_prompt_skip_degrades() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale fixture mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/source-to-architecture-packet/stages/01-extract.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet skip)"
  jq -e '.status == "degraded_skip" and .safe_to_run == true and (.reason_codes | any(startswith("prompt-asset-sha-changed:stages/01-extract.md")))' <<<"$out" >/dev/null
}

case_shared_reference_change_blocks_auto() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale reference mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/repository-grounding.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)" && return 1
  jq -e '.status == "blocked" and .safe_to_run == false and (.reason_codes | any(startswith("shared-reference-asset-sha-changed:shared/repository-grounding.md")))' <<<"$out" >/dev/null
}

case_shared_reference_change_degrades_skip() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale reference mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet skip)"
  jq -e '.status == "degraded_skip" and .safe_to_run == true and (.reason_codes | any(startswith("shared-reference-asset-sha-changed:shared/managed-artifact-contract.md")))' <<<"$out" >/dev/null
}

case_republish_after_prompt_change_restores_auto() {
  local fixture first second first_sha second_sha
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  first="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  first_sha="$(jq -r '.prompt_bundle_sha256' <<<"$first")"
  printf '\n<!-- prompt asset changed before republish -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/source-to-architecture-packet/stages/01-extract.md"
  publish_state "$fixture"
  second="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  second_sha="$(jq -r '.prompt_bundle_sha256' <<<"$second")"
  [[ "$first_sha" != "$second_sha" ]]
  jq -e '.status == "fresh" and .safe_to_run == true' <<<"$second" >/dev/null
}

case_republish_after_shared_reference_change_restores_auto() {
  local fixture first second first_sha second_sha
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  first="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  first_sha="$(jq -r '.prompt_bundle_sha256' <<<"$first")"
  printf '\n<!-- shared reference changed before republish -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md"
  publish_state "$fixture"
  second="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  second_sha="$(jq -r '.prompt_bundle_sha256' <<<"$second")"
  [[ "$first_sha" != "$second_sha" ]]
  jq -e '.status == "fresh" and .safe_to_run == true' <<<"$second" >/dev/null
}

main() {
  assert_success "all bundles publish fresh in auto mode" case_all_bundles_publish_fresh
  assert_success "stale architecture prompt blocks auto mode" case_stale_architecture_prompt_blocks_auto
  assert_success "stale architecture prompt degrades skip mode" case_stale_architecture_prompt_skip_degrades
  assert_success "shared reference change blocks auto mode" case_shared_reference_change_blocks_auto
  assert_success "shared reference change degrades skip mode" case_shared_reference_change_degrades_skip
  assert_success "republishing after prompt change restores fresh auto mode" case_republish_after_prompt_change_restores_auto
  assert_success "republishing after shared reference change restores fresh auto mode" case_republish_after_shared_reference_change_restores_auto

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
