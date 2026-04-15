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
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts"

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
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/README.md" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/README.md"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
  cp "$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh"
  cp "$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/validation-publication-receipt.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/validation-publication-receipt.schema.json"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json"
  mkdir -p "$fixture_root/.octon/framework/engine/governance/extensions"
  cp "$REPO_ROOT/.octon/framework/engine/governance/extensions/README.md" \
    "$fixture_root/.octon/framework/engine/governance/extensions/README.md"

  cat >"$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF

  chmod +x \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" \
    "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh" \
    "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"
}

write_packet8_pack() {
  local fixture_root="$1"
  local pack_id="$2"
  local source_id="$3"
  local origin_class="$4"
  local suggested_action="$5"
  local requires_block="$6"
  local conflicts_block="$7"
  local content_root="${8:-}"
  local templates_entry="null"
  local imported_from="null"

  if [[ "$origin_class" != "first_party_bundled" ]]; then
    imported_from="\"https://example.com/${pack_id}.git\""
  fi

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/$pack_id"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/$pack_id/validation"
  if [[ -n "$content_root" ]]; then
    templates_entry="\"$content_root/\""
    mkdir -p "$fixture_root/.octon/inputs/additive/extensions/$pack_id/$content_root"
    cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/$content_root/README.md" <<EOF
# ${pack_id} ${content_root}
EOF
  fi
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/README.md" <<EOF
# $pack_id
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/pack.yml" <<EOF
schema_version: "octon-extension-pack-v4"
pack_id: "$pack_id"
version: "1.0.0"
origin_class: "$origin_class"
compatibility:
  octon_version: "^0.5.0"
  extensions_api_version: "1.0"
  required_contracts: []
  profile_path: "validation/compatibility.yml"
dependencies:
  requires:
$requires_block
  conflicts:
$conflicts_block
provenance:
  source_id: "$source_id"
  imported_from: $imported_from
  origin_uri: null
  digest_sha256: null
  attestation_refs: []
trust_hints:
  suggested_action: "$suggested_action"
content_entrypoints:
  skills: null
  commands: null
  templates: $templates_entry
  prompts: null
  context: null
  validation: "validation/"
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF
}

write_packet8_seed_packs() {
  local fixture_root="$1"
  write_packet8_pack "$fixture_root" "docs" "bundled-first-party" "first_party_bundled" "allow" "    []" "    []" "templates"
  write_packet8_pack "$fixture_root" "nextjs" "bundled-first-party" "first_party_bundled" "allow" "    []" "    []" "templates"
  write_packet8_pack "$fixture_root" "node-ts" "bundled-first-party" "first_party_bundled" "allow" "    []" "    []" "templates"
}

write_valid_packet2_fixture() {
  local fixture_root="$1"

  mkdir -p \
    "$fixture_root/.octon/framework/overlay-points" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture" \
    "$fixture_root/.octon/framework/engine/runtime/crates/core/src" \
    "$fixture_root/.octon/framework/engine/runtime/crates/kernel/src" \
    "$fixture_root/.octon/framework/engine/runtime/crates/wasm_host/src" \
    "$fixture_root/.octon/framework/engine/runtime/spec" \
    "$fixture_root/.octon/framework/engine/runtime/config" \
    "$fixture_root/.octon/framework/capabilities/runtime/commands" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/native-skill" \
    "$fixture_root/.octon/framework/capabilities/runtime/services" \
    "$fixture_root/.octon/framework/capabilities/runtime/tools" \
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
    "$fixture_root/.octon/instance/bootstrap" \
    "$fixture_root/.octon/instance/capabilities/runtime/commands" \
    "$fixture_root/.octon/instance/capabilities/runtime/skills" \
    "$fixture_root/.octon/instance/governance/policies" \
    "$fixture_root/.octon/inputs/additive/extensions/.archive" \
    "$fixture_root/.octon/state/control/locality" \
    "$fixture_root/.octon/state/control/execution" \
    "$fixture_root/.octon/state/evidence/validation/publication/extensions" \
    "$fixture_root/.octon/state/evidence/validation/compatibility/extensions" \
    "$fixture_root/.octon/generated/effective/locality" \
    "$fixture_root/.octon/generated/effective/extensions" \
    "$fixture_root/.octon/generated/effective/capabilities" \
    "$fixture_root/.octon/generated/proposals"

  printf '0.5.0\n' >"$fixture_root/version.txt"

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
  generated_commit_defaults:
    "generated/effective/**": "commit"
    "generated/proposals/registry.yml": "commit"
    "generated/cognition/summaries/**": "commit"
    "generated/cognition/projections/definitions/**": "commit"
    "generated/cognition/graph/**": "rebuild"
    "generated/cognition/projections/materialized/**": "rebuild"
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

  cat >"$fixture_root/.octon/framework/cognition/_meta/architecture/contract-registry.yml" <<'EOF'
schema_version: "architecture-contract-registry-v1"
execution:
  write_roots:
    run_evidence_root: ".octon/state/evidence/runs"
    execution_control_root: ".octon/state/control/execution"
    execution_tmp_root: ".octon/generated/.tmp/execution"
  policy_roots:
    network_egress: ".octon/instance/governance/policies/network-egress.yml"
    execution_budgets: ".octon/instance/governance/policies/execution-budgets.yml"
  control_state:
    budget_state: ".octon/state/control/execution/budget-state.yml"
    exception_leases: ".octon/state/control/execution/exceptions/leases.yml"
  forbidden_write_prefixes:
    - ".octon/framework/engine/_ops/state"
  required_doc_surfaces:
    - ".octon/framework/cognition/_meta/architecture/specification.md"
    - ".octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md"
    - ".octon/instance/bootstrap/START.md"
    - ".octon/framework/engine/README.md"
    - ".octon/framework/engine/runtime/spec/policy-interface-v1.md"
    - ".octon/framework/engine/runtime/spec/policy-receipt-v1.schema.json"
  blocking_checks:
    - ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh"
    - ".octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh"
    - ".github/workflows/architecture-conformance.yml"
EOF

  cat >"$fixture_root/.octon/framework/cognition/_meta/architecture/specification.md" <<'EOF'
# Spec

state roots:
- .octon/state/control/execution
- .octon/generated/.tmp/execution
- .octon/instance/governance/policies/network-egress.yml
- .octon/instance/governance/policies/execution-budgets.yml
EOF

  cat >"$fixture_root/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md" <<'EOF'
# Runtime vs Ops

- .octon/state/control/execution/**
- .octon/generated/.tmp/execution/**
EOF

  cat >"$fixture_root/.octon/framework/engine/README.md" <<'EOF'
# Engine

| `_ops/` | Portable operational assets | helper binaries and portable support scripts |
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/spec/policy-interface-v1.md" <<'EOF'
# Policy Interface

- .octon/instance/governance/policies/network-egress.yml
- .octon/instance/governance/policies/execution-budgets.yml
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/spec/policy-receipt-v1.schema.json" <<'EOF'
{
  "properties": {
    "budget_rule_id": { "type": "string" }
  }
}
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/config/policy.yml" <<'EOF'
format_version: policy-v1
default:
  allow: []
services:
  execution/flow:
    allow:
      - log.write
      - fs.read
      - fs.write
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/crates/core/src/config.rs" <<'EOF'
pub struct RuntimeConfig {
    pub run_evidence_root: String,
    pub execution_control_root: String,
    pub execution_tmp_root: String,
}
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/crates/core/src/trace.rs" <<'EOF'
fn trace_path() -> &'static str {
    "trace.ndjson"
}
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/crates/kernel/src/main.rs" <<'EOF'
fn main() {}
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/crates/kernel/src/stdio.rs" <<'EOF'
pub fn serve_stdio() {}
EOF

  cat >"$fixture_root/.octon/framework/engine/runtime/crates/wasm_host/src/invoke.rs" <<'EOF'
pub fn invoke() {}
EOF

  cat >"$fixture_root/.octon/framework/overlay-points/registry.yml" <<'EOF'
schema_version: "octon-overlay-points-registry-v1"
overlay_points: []
EOF

  cat >"$fixture_root/.octon/instance/bootstrap/START.md" <<'EOF'
# START

- _ops is portable operational support
EOF

  cat >"$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/README.md" <<'EOF'
# migrate-harness
EOF

  cat >"$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/00-overview.md" <<'EOF'
# migrate-harness overview
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/commands/manifest.yml" <<'EOF'
schema_version: "1.0"
commands:
  - id: native-command
    display_name: Native Command
    path: native-command.md
    summary: Native command summary.
    access: agent
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/commands/native-command.md" <<'EOF'
# Native Command
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/skills/manifest.yml" <<'EOF'
schema_version: "3.0"
default: null
skills:
  - id: native-skill
    display_name: Native Skill
    group: synthesis
    path: native-skill/
    skill_class: invocable
    summary: Native skill summary.
    status: active
    tags: []
    triggers: []
    skill_sets: []
    capabilities: []
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/skills/registry.yml" <<'EOF'
schema_version: "4.0"
routing:
  explicit_command_required: false
  ambiguity_resolution: "ask"
skills:
  native-skill:
    version: "1.0.0"
    host_adapters: [codex]
    routing:
      selectors:
        include:
          - "**"
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
    commands:
      - /native-skill
    requires:
      context: []
    io:
      inputs: []
      outputs: []
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/skills/native-skill/SKILL.md" <<'EOF'
# Native Skill
allowed-tools: Read
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/services/manifest.yml" <<'EOF'
schema_version: "1.0"
services: []
EOF

  cat >"$fixture_root/.octon/framework/capabilities/runtime/tools/manifest.yml" <<'EOF'
schema_version: "1.0"
packs: []
tools: []
EOF

  cat >"$fixture_root/.octon/instance/capabilities/runtime/commands/manifest.yml" <<'EOF'
schema_version: "octon-instance-command-manifest-v1"
commands: []
EOF

  cat >"$fixture_root/.octon/instance/capabilities/runtime/skills/manifest.yml" <<'EOF'
schema_version: "octon-instance-skill-manifest-v1"
skills: []
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
schema_version: "octon-instance-extensions-v2"
selection:
  enabled: []
  disabled:
    - pack_id: "docs"
      source_id: "bundled-first-party"
      reason: "seeded-off-by-default"
    - pack_id: "nextjs"
      source_id: "bundled-first-party"
      reason: "seeded-off-by-default"
    - pack_id: "node-ts"
      source_id: "bundled-first-party"
      reason: "seeded-off-by-default"
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

  cat >"$fixture_root/.octon/instance/governance/policies/network-egress.yml" <<'EOF'
schema_version: "network-egress-policy-v1"
rules:
  - id: "langgraph-http-local-runner"
    services: ["execution/flow"]
    adapters: ["langgraph-http"]
    methods: ["POST"]
    schemes: ["http"]
    hosts: ["127.0.0.1", "localhost"]
    ports: [8410]
    path_prefixes: ["/flows/run"]
    reason: "Allow explicit local LangGraph flow forwarding when the external HTTP adapter is selected."
EOF

  cat >"$fixture_root/.octon/instance/governance/policies/execution-budgets.yml" <<'EOF'
schema_version: "execution-budgets-v1"
missing_cost_evidence_action: "stage_only"
rules: []
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
schema_version: "octon-locality-scope-v2"
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
schema_version: "octon-locality-quarantine-state-v2"
updated_at: "2026-03-19T00:00:00Z"
records: []
EOF

  cat >"$fixture_root/.octon/state/control/execution/budget-state.yml" <<'EOF'
schema_version: "execution-budget-state-v1"
updated_at: "2026-03-22T00:00:00Z"
rules: {}
EOF

  mkdir -p "$fixture_root/.octon/state/control/execution/exceptions"
  cat >"$fixture_root/.octon/state/control/execution/exceptions/leases.yml" <<'EOF'
schema_version: "authority-exception-lease-set-v1"
leases: []
EOF

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh" >/dev/null

  write_packet8_seed_packs "$fixture_root"

  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}
