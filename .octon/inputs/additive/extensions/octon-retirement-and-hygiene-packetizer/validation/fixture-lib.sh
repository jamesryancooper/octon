#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$TEST_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$TEST_DIR/../../../../../.." && pwd)"
PACK_ID="octon-retirement-and-hygiene-packetizer"
PACK_REL=".octon/inputs/additive/extensions/$PACK_ID"

create_fixture_root() {
  mktemp -d "${TMPDIR:-/tmp}/${PACK_ID}-fixture.XXXXXX"
}

copy_file_into_fixture() {
  local fixture_root="$1"
  local rel="$2"
  mkdir -p "$fixture_root/$(dirname "$rel")"
  cp "$REPO_ROOT/$rel" "$fixture_root/$rel"
}

copy_dir_into_fixture() {
  local fixture_root="$1"
  local rel="$2"
  mkdir -p "$fixture_root/$rel"
  cp -R "$REPO_ROOT/$rel"/. "$fixture_root/$rel"
}

write_extensions_manifest() {
  local fixture_root="$1"
  cat >"$fixture_root/.octon/instance/extensions.yml" <<EOF
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "$PACK_ID"
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
}

write_extension_state_stubs() {
  local fixture_root="$1"
  cat >"$fixture_root/.octon/state/control/extensions/active.yml" <<'EOF'
schema_version: "octon-extension-active-state-v4"
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
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
invalidation_conditions: []
required_inputs: []
validation_timestamp: "1970-01-01T00:00:00Z"
status: "withdrawn"
EOF

  cat >"$fixture_root/.octon/state/control/extensions/quarantine.yml" <<'EOF'
schema_version: "octon-extension-quarantine-state-v3"
updated_at: "1970-01-01T00:00:00Z"
records: []
EOF

  cat >"$fixture_root/.octon/generated/effective/extensions/catalog.effective.yml" <<'EOF'
schema_version: "octon-extension-effective-catalog-v6"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
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

  cat >"$fixture_root/.octon/generated/effective/extensions/artifact-map.yml" <<'EOF'
schema_version: "octon-extension-artifact-map-v4"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
artifacts: []
EOF

  cat >"$fixture_root/.octon/generated/effective/extensions/generation.lock.yml" <<'EOF'
schema_version: "octon-extension-generation-lock-v5"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
publication_receipt_sha256: "stub"
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
desired_config_sha256: "stub"
root_manifest_sha256: "stub"
published_files: []
required_inputs: []
invalidation_conditions: []
pack_payload_digests: []
EOF
}

setup_publication_fixture() {
  local fixture_root
  fixture_root="$(create_fixture_root)"

  mkdir -p \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas" \
    "$fixture_root/.octon/framework/capabilities/runtime/commands" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills" \
    "$fixture_root/.octon/framework/capabilities/runtime/services" \
    "$fixture_root/.octon/framework/capabilities/runtime/tools" \
    "$fixture_root/.octon/framework/engine/governance/extensions" \
    "$fixture_root/.octon/instance/capabilities/runtime/commands" \
    "$fixture_root/.octon/instance/capabilities/runtime/skills" \
    "$fixture_root/.octon/instance" \
    "$fixture_root/.octon/inputs/additive/extensions" \
    "$fixture_root/.octon/inputs/exploratory/proposals" \
    "$fixture_root/.octon/generated/effective/locality" \
    "$fixture_root/.octon/generated/effective/extensions" \
    "$fixture_root/.octon/generated/effective/capabilities" \
    "$fixture_root/.octon/state/control/extensions" \
    "$fixture_root/.octon/state/control/skills/checkpoints" \
    "$fixture_root/.octon/state/evidence/runs/skills" \
    "$fixture_root/.octon/state/evidence/validation/publication/extensions" \
    "$fixture_root/.octon/state/evidence/validation/compatibility/extensions" \
    "$fixture_root/.octon/state/evidence/validation/publication/capabilities" \
    "$fixture_root/.octon/state/evidence/validation/extensions"

  copy_file_into_fixture "$fixture_root" ".octon/octon.yml"
  copy_file_into_fixture "$fixture_root" ".octon/framework/manifest.yml"
  copy_file_into_fixture "$fixture_root" ".octon/instance/manifest.yml"
  copy_dir_into_fixture "$fixture_root" ".octon/framework/capabilities/runtime/commands"
  copy_dir_into_fixture "$fixture_root" ".octon/framework/capabilities/runtime/skills"
  copy_dir_into_fixture "$fixture_root" ".octon/framework/capabilities/runtime/services"
  copy_dir_into_fixture "$fixture_root" ".octon/framework/capabilities/runtime/tools"
  copy_dir_into_fixture "$fixture_root" ".octon/instance/capabilities/runtime/commands"
  copy_dir_into_fixture "$fixture_root" ".octon/instance/capabilities/runtime/skills"
  copy_file_into_fixture "$fixture_root" ".octon/generated/effective/locality/scopes.effective.yml"
  copy_file_into_fixture "$fixture_root" ".octon/generated/effective/locality/generation.lock.yml"
  copy_file_into_fixture "$fixture_root" ".octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/capabilities/_ops/scripts/publish-host-projections.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/README.md"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-pack.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-compatibility-profile.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-routing-contract.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/README.md"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-effective-catalog.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-artifact-map.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-generation-lock.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-route-resolution.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/validation-publication-receipt.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json"
  copy_file_into_fixture "$fixture_root" ".octon/framework/engine/governance/extensions/README.md"
  copy_dir_into_fixture "$fixture_root" "$PACK_REL"

  write_extensions_manifest "$fixture_root"
  write_extension_state_stubs "$fixture_root"
  printf '%s\n' "$fixture_root"
}

run_in_fixture() {
  local fixture_root="$1"
  shift
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" "$@"
}

replace_placeholder() {
  local file="$1"
  local key="$2"
  local value="$3"
  KEY="$key" VALUE="$value" perl -0pi -e 's/\{\{\Q$ENV{KEY}\E\}\}/$ENV{VALUE}/g' "$file"
}

render_template_to() {
  local template="$1"
  local output="$2"
  shift 2

  mkdir -p "$(dirname "$output")"
  cp "$template" "$output"
  while [[ $# -gt 1 ]]; do
    replace_placeholder "$output" "$1" "$2"
    shift 2
  done
}
