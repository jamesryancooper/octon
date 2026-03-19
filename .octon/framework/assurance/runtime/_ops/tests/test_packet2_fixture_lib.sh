#!/usr/bin/env bash
set -euo pipefail

TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_LIB_DIR/../../../../../.." && pwd)"

create_packet2_fixture_repo() {
  mktemp -d "${TMPDIR:-/tmp}/packet2-fixture.XXXXXX"
}

copy_packet2_runtime_scripts() {
  local fixture_root="$1"
  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/README.md" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/README.md"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"

  chmod +x \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
}

write_valid_packet2_fixture() {
  local fixture_root="$1"

  mkdir -p \
    "$fixture_root/.octon/framework/overlay-points" \
    "$fixture_root/.octon/framework/agency/governance" \
    "$fixture_root/.octon/framework/assurance/governance" \
    "$fixture_root/.octon/framework/capabilities/governance" \
    "$fixture_root/.octon/framework/cognition/governance" \
    "$fixture_root/.octon/framework/engine/governance" \
    "$fixture_root/.octon/framework/orchestration/governance" \
    "$fixture_root/.octon/framework/scaffolding/governance" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/migrate-harness" \
    "$fixture_root/.octon/instance/locality" \
    "$fixture_root/.octon/instance/locality/scopes/octon-harness" \
    "$fixture_root/.octon/instance/cognition/context/scopes/octon-harness" \
    "$fixture_root/.octon/inputs/additive/extensions" \
    "$fixture_root/.octon/state/control/locality" \
    "$fixture_root/.octon/generated/effective/locality" \
    "$fixture_root/.octon/generated/proposals"

  cat >"$fixture_root/.octon/octon.yml" <<'EOF'
schema_version: "octon-root-manifest-v2"
topology:
  super_root: ".octon/"
  class_roots:
    framework: "framework/"
    instance: "instance/"
    inputs: "inputs/"
    state: "state/"
    generated: "generated/"
versioning:
  harness:
    release_version: "0.5.0"
    supported_schema_versions:
      - "octon-root-manifest-v2"
      - "octon-framework-manifest-v2"
      - "octon-instance-manifest-v1"
    rejection_mode: "fail-closed"
    migration_workflow: "framework/orchestration/runtime/workflows/meta/migrate-harness/README.md"
    migration_overview: "framework/orchestration/runtime/workflows/meta/migrate-harness/00-overview.md"
    deterministic_upgrade_instructions:
      - "Upgrade the root manifest."
      - "Upgrade the framework manifest."
      - "Re-run validators."
  extensions:
    api_version: "1.0"
profiles:
  bootstrap_core:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/manifest.yml"
  repo_snapshot:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/**"
      - "inputs/additive/extensions/<enabled-and-dependent>/**"
    exclude:
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  pack_bundle:
    selector: "inputs/additive/extensions/<selected>/**"
    include_dependency_closure: true
    exclude:
      - "framework/**"
      - "instance/**"
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  full_fidelity:
    advisory: "Use a normal Git clone for exact repository reproduction."
policies:
  raw_input_dependency: "fail-closed"
  generated_staleness: "fail-closed"
  required_generated:
    - "generated/proposals/registry.yml"
    - "generated/effective/extensions/catalog.effective.yml"
    - "generated/effective/extensions/artifact-map.yml"
    - "generated/effective/extensions/generation.lock.yml"
zones:
  human_led:
    - "inputs/exploratory/ideation/**"
EOF

  cat >"$fixture_root/.octon/framework/manifest.yml" <<'EOF'
schema_version: "octon-framework-manifest-v2"
framework_id: "octon-core"
release_version: "0.5.0"
supported_instance_schema_versions:
  - "octon-instance-manifest-v1"
overlay_registry: ".octon/framework/overlay-points/registry.yml"
subsystems:
  - "agency"
  - "assurance"
  - "capabilities"
  - "cognition"
  - "engine"
  - "orchestration"
  - "scaffolding"
generators:
  - "proposal-registry"
bundled_policy_sets:
  - ".octon/framework/agency/governance/"
  - ".octon/framework/assurance/governance/"
  - ".octon/framework/capabilities/governance/"
  - ".octon/framework/cognition/governance/"
  - ".octon/framework/engine/governance/"
  - ".octon/framework/orchestration/governance/"
  - ".octon/framework/scaffolding/governance/"
EOF

  cat >"$fixture_root/.octon/framework/overlay-points/registry.yml" <<'EOF'
schema_version: "octon-overlay-points-registry-v1"
overlay_points: []
EOF

  cat >"$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/README.md" <<'EOF'
# migrate-harness
EOF

  cat >"$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/00-overview.md" <<'EOF'
# migrate-harness overview
EOF

  cat >"$fixture_root/.octon/instance/manifest.yml" <<'EOF'
schema_version: "octon-instance-manifest-v1"
instance_id: "fixture"
framework_id: "octon-core"
enabled_overlay_points:
  - "instance-governance-policies"
locality:
  registry_path: ".octon/instance/locality/registry.yml"
  manifest_path: ".octon/instance/locality/manifest.yml"
feature_toggles:
  integrated_inputs: true
EOF

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v1"
selection:
  enabled: []
sources: {}
trust: {}
acknowledgements: []
EOF

  cat >"$fixture_root/.octon/instance/locality/manifest.yml" <<'EOF'
schema_version: "octon-locality-manifest-v1"
registry_path: ".octon/instance/locality/registry.yml"
resolution_mode: "single-active-scope"
EOF

  cat >"$fixture_root/.octon/instance/locality/README.md" <<'EOF'
# Locality
EOF

  cat >"$fixture_root/.octon/instance/locality/registry.yml" <<'EOF'
schema_version: "octon-locality-registry-v1"
scopes:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
EOF

  cat >"$fixture_root/.octon/instance/locality/scopes/octon-harness/scope.yml" <<'EOF'
schema_version: "octon-locality-scope-v1"
scope_id: "octon-harness"
display_name: "Octon Harness"
root_path: ".octon"
owner: "Fixture Maintainers"
status: "active"
tech_tags:
  - "octon"
language_tags:
  - "yaml"
EOF

  cat >"$fixture_root/.octon/instance/cognition/context/scopes/README.md" <<'EOF'
# Scope Context
EOF

  cat >"$fixture_root/.octon/instance/cognition/context/scopes/octon-harness/README.md" <<'EOF'
# Octon Harness Scope Context
EOF

  cat >"$fixture_root/.octon/generated/proposals/registry.yml" <<'EOF'
schema_version: "proposal-registry-v1"
active: []
archived: []
EOF

  cat >"$fixture_root/.octon/state/control/locality/quarantine.yml" <<'EOF'
schema_version: "octon-locality-quarantine-state-v1"
updated_at: "2026-03-19T00:00:00Z"
records: []
EOF

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}
