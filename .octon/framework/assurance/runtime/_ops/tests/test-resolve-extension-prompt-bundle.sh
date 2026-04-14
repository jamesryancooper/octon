#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

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
  local root="$1" mode="$2"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-concept-integration \
      --prompt-set-id octon-concept-integration-pipeline \
      --alignment-mode "$mode"
}

case_fresh_bundle_allows_auto() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  out="$(resolve_bundle "$fixture" auto)"
  jq -e '.status == "fresh" and .safe_to_run == true and .alignment_mode == "auto"' <<<"$out" >/dev/null
}

case_stale_bundle_blocks_auto() {
  local fixture out rel
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale fixture mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/octon-implementable-concept-extraction.md"
  out="$(resolve_bundle "$fixture" auto)" && return 1
  jq -e '.status == "blocked" and .safe_to_run == false and (.reason_codes | any(startswith("prompt-asset-sha-changed:octon-implementable-concept-extraction.md")))' <<<"$out" >/dev/null
}

case_stale_bundle_skip_degrades() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale fixture mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/octon-implementable-concept-extraction.md"
  out="$(resolve_bundle "$fixture" skip)"
  jq -e '.status == "degraded_skip" and .safe_to_run == true and .alignment_mode == "skip" and (.reason_codes | any(startswith("prompt-asset-sha-changed:octon-implementable-concept-extraction.md")))' <<<"$out" >/dev/null
}

case_republish_after_prompt_change_restores_auto() {
  local fixture first second first_sha second_sha
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  first="$(resolve_bundle "$fixture" auto)"
  first_sha="$(jq -r '.prompt_bundle_sha256' <<<"$first")"
  printf '\n<!-- prompt asset changed before republish -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/octon-implementable-concept-extraction.md"
  publish_state "$fixture"
  second="$(resolve_bundle "$fixture" auto)"
  second_sha="$(jq -r '.prompt_bundle_sha256' <<<"$second")"
  [[ "$first_sha" != "$second_sha" ]]
  jq -e '.status == "fresh" and .safe_to_run == true' <<<"$second" >/dev/null
}

main() {
  assert_success "fresh bundle allows auto mode" case_fresh_bundle_allows_auto
  assert_success "stale bundle blocks auto mode" case_stale_bundle_blocks_auto
  assert_success "stale bundle degrades skip mode" case_stale_bundle_skip_degrades
  assert_success "republishing after prompt change restores fresh auto mode" case_republish_after_prompt_change_restores_auto

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
