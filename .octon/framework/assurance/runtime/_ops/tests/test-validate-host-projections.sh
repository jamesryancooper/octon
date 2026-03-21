#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"
HOST_PUBLISHER="$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh"
HOST_VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh"

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
  mktemp -d "${TMPDIR:-/tmp}/host-projections.XXXXXX"
}

write_fixture() {
  local root="$1"
  mkdir -p \
    "$root/.octon/generated/effective/capabilities" \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands" \
    "$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill" \
    "$root/.octon/framework/capabilities/runtime/commands" \
    "$root/.octon/framework/capabilities/runtime/skills/demo" \
    "$root/.octon/inputs/additive/extensions/demo-ext/commands" \
    "$root/.octon/inputs/additive/extensions/demo-ext/skills/demo-ext-skill" \
    "$root/.claude/commands" \
    "$root/.claude/skills" \
    "$root/.cursor/commands" \
    "$root/.cursor/skills" \
    "$root/.codex/skills"

  cat >"$root/.octon/framework/capabilities/runtime/commands/demo-command.md" <<'EOF'
# Demo Command
EOF

  cat >"$root/.octon/framework/capabilities/runtime/skills/demo/SKILL.md" <<'EOF'
# Demo Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/commands/demo-ext-command.md" <<'EOF'
# Demo Ext Command
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/skills/demo-ext-skill/SKILL.md" <<'EOF'
# Demo Ext Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands/demo-ext-command.md" <<'EOF'
# Demo Ext Command
EOF

  cat >"$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill/SKILL.md" <<'EOF'
# Demo Ext Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'EOF'
schema_version: "octon-extension-effective-catalog-v4"
generator_version: "0.5.1"
generation_id: "extensions-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/fixture.yml"
invalidation_conditions:
  - "desired-config-sha-changed"
desired_selected_packs: []
published_active_packs:
  - pack_id: "demo-ext"
    source_id: "bundled-first-party"
dependency_closure: []
packs:
  - pack_id: "demo-ext"
    source_id: "bundled-first-party"
    version: "1.0.0"
    origin_class: "first_party_bundled"
    manifest_path: ".octon/inputs/additive/extensions/demo-ext/pack.yml"
    trust_decision: "allow"
    publication_status: "published"
    routing_exports:
      commands:
        - capability_id: "demo-ext-command"
          display_name: "Demo Ext Command"
          summary: "Demo extension command summary."
          status: "active"
          path: "demo-ext-command.md"
          access: "agent"
          manifest_fragment_path: ".octon/inputs/additive/extensions/demo-ext/commands/manifest.fragment.yml"
          projection_source_path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands/demo-ext-command.md"
          host_adapters: [claude, cursor, codex]
          selectors:
            include: ["**"]
            exclude: []
          fingerprints:
            tech_tags: []
            language_tags: []
      skills:
        - capability_id: "demo-ext-skill"
          display_name: "Demo Ext Skill"
          summary: "Demo extension skill summary."
          status: "active"
          path: "demo-ext-skill/"
          manifest_fragment_path: ".octon/inputs/additive/extensions/demo-ext/skills/manifest.fragment.yml"
          projection_source_path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill"
          host_adapters: [claude, cursor, codex]
          selectors:
            include: ["**"]
            exclude: []
          fingerprints:
            tech_tags: []
            language_tags: []
source:
  desired_config_path: ".octon/instance/extensions.yml"
  desired_config_sha256: "fixture"
  root_manifest_path: ".octon/octon.yml"
  root_manifest_sha256: "fixture"
EOF

  cat >"$root/.octon/generated/effective/capabilities/routing.effective.yml" <<'EOF'
schema_version: "octon-capability-routing-effective-v3"
generator_version: "0.5.1"
generation_id: "capabilities-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
publication_receipt_path: ".octon/state/evidence/validation/publication/capabilities/fixture.yml"
invalidation_conditions:
  - "root-manifest-sha-changed"
source:
  root_manifest_path: ".octon/octon.yml"
  root_manifest_sha256: "fixture"
  framework_commands_manifest_path: ".octon/framework/capabilities/runtime/commands/manifest.yml"
  framework_commands_manifest_sha256: "fixture"
  framework_skills_manifest_path: ".octon/framework/capabilities/runtime/skills/manifest.yml"
  framework_skills_manifest_sha256: "fixture"
  framework_skills_registry_path: ".octon/framework/capabilities/runtime/skills/registry.yml"
  framework_skills_registry_sha256: "fixture"
  framework_services_manifest_path: ".octon/framework/capabilities/runtime/services/manifest.yml"
  framework_services_manifest_sha256: "fixture"
  framework_tools_manifest_path: ".octon/framework/capabilities/runtime/tools/manifest.yml"
  framework_tools_manifest_sha256: "fixture"
  instance_commands_manifest_path: ".octon/instance/capabilities/runtime/commands/manifest.yml"
  instance_commands_manifest_sha256: "fixture"
  instance_skills_manifest_path: ".octon/instance/capabilities/runtime/skills/manifest.yml"
  instance_skills_manifest_sha256: "fixture"
  locality_scopes_effective_path: ".octon/generated/effective/locality/scopes.effective.yml"
  locality_scopes_effective_sha256: "fixture"
  locality_generation_lock_path: ".octon/generated/effective/locality/generation.lock.yml"
  locality_generation_lock_sha256: "fixture"
  locality_generation_id: "locality-fixture"
  extensions_catalog_path: ".octon/generated/effective/extensions/catalog.effective.yml"
  extensions_catalog_sha256: "fixture"
  extensions_generation_lock_path: ".octon/generated/effective/extensions/generation.lock.yml"
  extensions_generation_lock_sha256: "fixture"
  extensions_generation_id: "extensions-fixture"
routing_context:
  selector_schema_version: "octon-capability-routing-selectors-v1"
  locality_generation_id: "locality-fixture"
  extension_generation_id: "extensions-fixture"
  host_projection_mode: "materialized-copy-v1"
  scope_resolution_mode: "single-active-scope"
routing_candidates:
  - effective_id: "framework.command.demo-command"
    artifact_map_id: "framework-command-demo-command"
    origin_class: "framework"
    capability_kind: "command"
    capability_id: "demo-command"
    display_name: "Demo Command"
    summary: "Demo command summary."
    status: "active"
    source_manifest: ".octon/framework/capabilities/runtime/commands/manifest.yml"
    capability_domain: "command"
    host_adapters: [claude, cursor, codex]
    selectors:
      include: ["**"]
      exclude: []
    fingerprints:
      tech_tags: []
      language_tags: []
    scope_relevance:
      matching_scope_ids: []
      tech_tag_matches: []
      language_tag_matches: []
      preferred_domain_match_scope_ids: []
      preferred_kind_match_scope_ids: []
      score: 0
    precedence_tier: "native-authority"
    stable_sort_key: "0000"
    projection_name: "demo-command"
  - effective_id: "framework.skill.demo-skill"
    artifact_map_id: "framework-skill-demo-skill"
    origin_class: "framework"
    capability_kind: "skill"
    capability_id: "demo-skill"
    display_name: "Demo Skill"
    summary: "Demo skill summary."
    status: "active"
    source_manifest: ".octon/framework/capabilities/runtime/skills/manifest.yml"
    capability_domain: "synthesis"
    host_adapters: [claude, cursor, codex]
    selectors:
      include: ["**"]
      exclude: []
    fingerprints:
      tech_tags: []
      language_tags: []
    scope_relevance:
      matching_scope_ids: []
      tech_tag_matches: []
      language_tag_matches: []
      preferred_domain_match_scope_ids: []
      preferred_kind_match_scope_ids: []
      score: 0
    precedence_tier: "native-authority"
    stable_sort_key: "0001"
    projection_name: "demo-skill"
  - effective_id: "extension.command.demo-ext.demo-ext-command"
    artifact_map_id: "extension-command-demo-ext-demo-ext-command"
    origin_class: "extension"
    capability_kind: "command"
    capability_id: "demo-ext-command"
    display_name: "Demo Ext Command"
    summary: "Demo extension command summary."
    status: "active"
    source_manifest: ".octon/generated/effective/extensions/catalog.effective.yml"
    capability_domain: "extension"
    host_adapters: [claude, cursor, codex]
    selectors:
      include: ["**"]
      exclude: []
    fingerprints:
      tech_tags: []
      language_tags: []
    scope_relevance:
      matching_scope_ids: []
      tech_tag_matches: []
      language_tag_matches: []
      preferred_domain_match_scope_ids: []
      preferred_kind_match_scope_ids: []
      score: 0
    precedence_tier: "additive-extension"
    stable_sort_key: "0002"
    projection_name: "demo-ext-command"
  - effective_id: "extension.skill.demo-ext.demo-ext-skill"
    artifact_map_id: "extension-skill-demo-ext-demo-ext-skill"
    origin_class: "extension"
    capability_kind: "skill"
    capability_id: "demo-ext-skill"
    display_name: "Demo Ext Skill"
    summary: "Demo extension skill summary."
    status: "active"
    source_manifest: ".octon/generated/effective/extensions/catalog.effective.yml"
    capability_domain: "extension"
    host_adapters: [claude, cursor, codex]
    selectors:
      include: ["**"]
      exclude: []
    fingerprints:
      tech_tags: []
      language_tags: []
    scope_relevance:
      matching_scope_ids: []
      tech_tag_matches: []
      language_tag_matches: []
      preferred_domain_match_scope_ids: []
      preferred_kind_match_scope_ids: []
      score: 0
    precedence_tier: "additive-extension"
    stable_sort_key: "0003"
    projection_name: "demo-ext-skill"
resolution_order:
  - "framework.command.demo-command"
  - "framework.skill.demo-skill"
  - "extension.command.demo-ext.demo-ext-command"
  - "extension.skill.demo-ext.demo-ext-skill"
EOF

  cat >"$root/.octon/generated/effective/capabilities/artifact-map.yml" <<'EOF'
schema_version: "octon-capability-routing-artifact-map-v3"
generator_version: "0.5.1"
generation_id: "capabilities-fixture"
published_at: "2026-03-20T00:00:00Z"
artifacts:
  - artifact_map_id: "framework-command-demo-command"
    effective_id: "framework.command.demo-command"
    origin_class: "framework"
    capability_kind: "command"
    capability_id: "demo-command"
    display_name: "Demo Command"
    source_kind: "framework-native"
    source_manifest_path: ".octon/framework/capabilities/runtime/commands/manifest.yml"
    source_manifest_sha256: "fixture"
    source_path: ".octon/framework/capabilities/runtime/commands/demo-command.md"
    source_sha256: "fixture"
  - artifact_map_id: "framework-skill-demo-skill"
    effective_id: "framework.skill.demo-skill"
    origin_class: "framework"
    capability_kind: "skill"
    capability_id: "demo-skill"
    display_name: "Demo Skill"
    source_kind: "framework-native"
    source_manifest_path: ".octon/framework/capabilities/runtime/skills/registry.yml"
    source_manifest_sha256: "fixture"
    source_path: ".octon/framework/capabilities/runtime/skills/demo/SKILL.md"
    source_sha256: "fixture"
  - artifact_map_id: "extension-command-demo-ext-demo-ext-command"
    effective_id: "extension.command.demo-ext.demo-ext-command"
    origin_class: "extension"
    capability_kind: "command"
    capability_id: "demo-ext-command"
    display_name: "Demo Ext Command"
    source_kind: "extension-export"
    source_manifest_path: ".octon/generated/effective/extensions/catalog.effective.yml"
    source_manifest_sha256: "fixture"
    source_path: ".octon/generated/effective/extensions/catalog.effective.yml"
    source_sha256: "fixture"
    extension_pack_id: "demo-ext"
    extension_source_id: "bundled-first-party"
    extension_export_kind: "command"
    extension_export_id: "demo-ext-command"
  - artifact_map_id: "extension-skill-demo-ext-demo-ext-skill"
    effective_id: "extension.skill.demo-ext.demo-ext-skill"
    origin_class: "extension"
    capability_kind: "skill"
    capability_id: "demo-ext-skill"
    display_name: "Demo Ext Skill"
    source_kind: "extension-export"
    source_manifest_path: ".octon/generated/effective/extensions/catalog.effective.yml"
    source_manifest_sha256: "fixture"
    source_path: ".octon/generated/effective/extensions/catalog.effective.yml"
    source_sha256: "fixture"
    extension_pack_id: "demo-ext"
    extension_source_id: "bundled-first-party"
    extension_export_kind: "skill"
    extension_export_id: "demo-ext-skill"
EOF
}

run_publish() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$HOST_PUBLISHER" >/dev/null
}

run_validator() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$HOST_VALIDATOR" >/dev/null
}

case_publish_and_validate_passes() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  run_validator "$fixture"
}

case_stale_projection_is_pruned() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  mkdir -p "$fixture/.cursor/skills/stale-skill"
  printf 'stale\n' >"$fixture/.cursor/commands/stale.md"
  run_publish "$fixture"
  [[ ! -e "$fixture/.cursor/commands/stale.md" && ! -e "$fixture/.cursor/skills/stale-skill" ]]
}

case_symlink_replaced_by_materialized_copy() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  ln -s ../../.octon/framework/capabilities/runtime/commands/demo-command.md "$fixture/.claude/commands/demo-command.md"
  run_publish "$fixture"
  [[ ! -L "$fixture/.claude/commands/demo-command.md" && -f "$fixture/.claude/commands/demo-command.md" ]]
}

main() {
  assert_success "host projections publish and validate for native and extension capabilities" case_publish_and_validate_passes
  assert_success "stale host projections are pruned on republish" case_stale_projection_is_pruned
  assert_success "legacy symlink projections are replaced with materialized copies" case_symlink_replaced_by_materialized_copy

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
