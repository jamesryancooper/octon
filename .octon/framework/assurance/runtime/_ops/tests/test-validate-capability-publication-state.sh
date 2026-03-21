#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"
PUBLISH_SCRIPT="$REPO_ROOT/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf -- "$dir"
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
  mktemp -d "${TMPDIR:-/tmp}/capability-publication.XXXXXX"
}

write_fixture() {
  local root="$1"
  mkdir -p \
    "$root/.octon/framework/capabilities/runtime/commands" \
    "$root/.octon/framework/capabilities/runtime/skills/demo" \
    "$root/.octon/framework/capabilities/runtime/services/demo" \
    "$root/.octon/framework/capabilities/runtime/tools" \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands" \
    "$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill" \
    "$root/.octon/generated/effective/locality" \
    "$root/.octon/generated/effective/capabilities/filesystem-snapshots" \
    "$root/.octon/instance/capabilities/runtime/commands" \
    "$root/.octon/instance/capabilities/runtime/skills"

  cat >"$root/.octon/octon.yml" <<'EOF'
schema_version: octon-root-manifest-v2
versioning:
  harness:
    release_version: 0.5.1
EOF

  cat >"$root/.octon/framework/capabilities/runtime/commands/manifest.yml" <<'EOF'
schema_version: "1.0"
commands:
  - id: demo-command
    display_name: Demo Command
    path: demo-command.md
    summary: Demo command summary.
    access: agent
    routing:
      selectors:
        include:
          - "**"
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
    host_adapters: [claude, cursor, codex]
EOF

  cat >"$root/.octon/framework/capabilities/runtime/commands/demo-command.md" <<'EOF'
# Demo Command
EOF

  cat >"$root/.octon/framework/capabilities/runtime/skills/manifest.yml" <<'EOF'
schema_version: "3.0"
default: null
skills:
  - id: demo-skill
    display_name: Demo Skill
    group: synthesis
    path: demo/
    skill_class: invocable
    summary: Demo skill summary.
    status: active
    tags: []
    triggers: []
    skill_sets: []
    capabilities: []
EOF

  cat >"$root/.octon/framework/capabilities/runtime/skills/registry.yml" <<'EOF'
schema_version: "4.0"
routing:
  explicit_command_required: false
  ambiguity_resolution: "ask"
skills:
  demo-skill:
    version: "1.0.0"
    host_adapters: [claude, cursor, codex]
    routing:
      selectors:
        include:
          - "**"
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
    commands:
      - /demo-skill
    requires:
      context: []
    io:
      inputs: []
      outputs: []
EOF

  cat >"$root/.octon/framework/capabilities/runtime/skills/demo/SKILL.md" <<'EOF'
# Demo Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/framework/capabilities/runtime/services/manifest.yml" <<'EOF'
schema_version: "1.0"
services:
  - id: demo-service
    display_name: Demo Service
    path: demo/
    summary: Demo service summary.
    status: active
    interface_type: shell
    category: planning
    routing:
      selectors:
        include:
          - "**"
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
    host_adapters: [claude, cursor, codex]
EOF

  cat >"$root/.octon/framework/capabilities/runtime/services/demo/SERVICE.md" <<'EOF'
---
fail_closed: true
---
allowed-tools: Read
EOF

  cat >"$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands/demo-ext-command.md" <<'EOF'
# Demo Ext Command
EOF

  cat >"$root/.octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill/SKILL.md" <<'EOF'
# Demo Ext Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/framework/capabilities/runtime/tools/manifest.yml" <<'EOF'
schema_version: "1.0"
packs:
  - id: read-only
    display_name: Read Only
    summary: Read only tools.
    tools: [Read]
    routing:
      selectors:
        include:
          - "**"
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
    host_adapters: [claude, cursor, codex]
tools: []
EOF

  cat >"$root/.octon/instance/capabilities/runtime/commands/manifest.yml" <<'EOF'
schema_version: "octon-instance-command-manifest-v1"
commands: []
EOF

  cat >"$root/.octon/instance/capabilities/runtime/skills/manifest.yml" <<'EOF'
schema_version: "octon-instance-skill-manifest-v1"
skills: []
EOF

  cat >"$root/.octon/generated/effective/locality/scopes.effective.yml" <<'EOF'
schema_version: "octon-locality-effective-scopes-v2"
generator_version: "0.5.1"
generation_id: "locality-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
publication_receipt_path: ".octon/state/evidence/validation/publication/locality/fixture.yml"
invalidation_conditions:
  - "locality-manifest-sha-changed"
resolution_mode: "single-active-scope"
source:
  locality_manifest_path: ".octon/instance/locality/manifest.yml"
  locality_manifest_sha256: "fixture"
  locality_registry_path: ".octon/instance/locality/registry.yml"
  locality_registry_sha256: "fixture"
  quarantine_path: ".octon/state/control/locality/quarantine.yml"
  quarantine_sha256: "fixture"
active_scope_ids:
  - "octon-harness"
scopes:
  - scope_id: "octon-harness"
    manifest_path: ".octon/instance/locality/scopes/octon-harness/scope.yml"
    display_name: "Octon Harness"
    root_path: ".octon"
    owner: "Fixture Maintainers"
    status: "active"
    tech_tags: ["octon"]
    language_tags: ["yaml"]
    include_globs: []
    exclude_globs: []
    routing_hints:
      preferred_capability_domains: ["architecture"]
EOF

  cat >"$root/.octon/generated/effective/locality/generation.lock.yml" <<'EOF'
schema_version: "octon-locality-generation-lock-v2"
generator_version: "0.5.1"
generation_id: "locality-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
publication_receipt_path: ".octon/state/evidence/validation/publication/locality/fixture.yml"
publication_receipt_sha256: "fixture"
locality_manifest_sha256: "fixture"
locality_registry_sha256: "fixture"
quarantine_sha256: "fixture"
published_files:
  - path: ".octon/generated/effective/locality/scopes.effective.yml"
  - path: ".octon/generated/effective/locality/artifact-map.yml"
  - path: ".octon/generated/effective/locality/generation.lock.yml"
required_inputs:
  - ".octon/octon.yml"
invalidation_conditions:
  - "locality-manifest-sha-changed"
scope_manifest_digests: []
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
dependency_closure:
  - pack_id: "demo-ext"
    source_id: "bundled-first-party"
    version: "1.0.0"
    origin_class: "first_party_bundled"
    manifest_path: ".octon/inputs/additive/extensions/demo-ext/pack.yml"
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

  cat >"$root/.octon/generated/effective/extensions/generation.lock.yml" <<'EOF'
schema_version: "octon-extension-generation-lock-v4"
generator_version: "0.5.1"
generation_id: "extensions-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/fixture.yml"
publication_receipt_sha256: "fixture"
desired_config_sha256: "fixture"
root_manifest_sha256: "fixture"
published_files:
  - path: ".octon/generated/effective/extensions/catalog.effective.yml"
  - path: ".octon/generated/effective/extensions/artifact-map.yml"
  - path: ".octon/generated/effective/extensions/generation.lock.yml"
  - path: ".octon/generated/effective/extensions/published"
  - path: ".octon/generated/effective/extensions/published/demo-ext"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/commands/demo-ext-command.md"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill"
  - path: ".octon/generated/effective/extensions/published/demo-ext/bundled-first-party/skills/demo-ext-skill/SKILL.md"
required_inputs:
  - ".octon/instance/extensions.yml"
  - ".octon/octon.yml"
invalidation_conditions:
  - "desired-config-sha-changed"
pack_payload_digests: []
EOF
}

run_publish() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$PUBLISH_SCRIPT" >/dev/null
}

run_validator() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/dev/null
}

case_publish_and_validate_passes() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  run_validator "$fixture"
}

case_extension_capabilities_are_published() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  grep -Fq 'extension.command.demo-ext.demo-ext-command' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml"
  grep -Fq 'extension.skill.demo-ext.demo-ext-skill' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml"
}

case_stale_manifest_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  perl -0pi -e 's/Demo command summary\./Changed summary./' "$fixture/.octon/framework/capabilities/runtime/commands/manifest.yml"
  ! run_validator "$fixture"
}

case_stale_locality_generation_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  perl -0pi -e 's/locality-fixture/locality-stale/' "$fixture/.octon/generated/effective/locality/generation.lock.yml"
  ! run_validator "$fixture"
}

case_stale_extension_generation_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  perl -0pi -e 's/extensions-fixture/extensions-stale/' "$fixture/.octon/generated/effective/extensions/generation.lock.yml"
  ! run_validator "$fixture"
}

case_raw_inputs_reference_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  printf '\n  - artifact_map_id: "bad"\n    effective_id: "bad"\n    origin_class: "framework"\n    capability_kind: "command"\n    capability_id: "bad"\n    display_name: "Bad"\n    source_kind: "framework-native"\n    source_manifest_path: ".octon/inputs/additive/extensions/demo/pack.yml"\n    source_manifest_sha256: "bad"\n    source_path: ".octon/inputs/additive/extensions/demo/pack.yml"\n    source_sha256: "bad"\n' >>"$fixture/.octon/generated/effective/capabilities/artifact-map.yml"
  ! run_validator "$fixture"
}

case_mutable_instance_inputs_do_not_rotate_digest() {
  local fixture first_id second_id
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  mkdir -p "$fixture/.octon/instance/capabilities/runtime/skills/resources/demo" "$fixture/.octon/instance/capabilities/runtime/skills/configs/demo"
  run_publish "$fixture"
  first_id="$(yq -r '.generation_id // ""' "$fixture/.octon/generated/effective/capabilities/generation.lock.yml")"
  printf 'note\n' >"$fixture/.octon/instance/capabilities/runtime/skills/resources/demo/notes.md"
  printf 'config: true\n' >"$fixture/.octon/instance/capabilities/runtime/skills/configs/demo/settings.yml"
  run_publish "$fixture"
  second_id="$(yq -r '.generation_id // ""' "$fixture/.octon/generated/effective/capabilities/generation.lock.yml")"
  [[ "$first_id" == "$second_id" ]]
}

case_inactive_scopes_do_not_affect_scope_relevance() {
  local fixture preferred_scope_hits scope_score
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  cat >>"$fixture/.octon/generated/effective/locality/scopes.effective.yml" <<'EOF'
  - scope_id: "dormant-command-scope"
    manifest_path: ".octon/instance/locality/scopes/dormant-command-scope/scope.yml"
    display_name: "Dormant Command Scope"
    root_path: ".octon"
    owner: "Fixture Maintainers"
    status: "inactive"
    tech_tags: []
    language_tags: []
    include_globs: []
    exclude_globs: []
    routing_hints:
      preferred_capability_domains: ["command"]
EOF
  run_publish "$fixture"
  preferred_scope_hits="$(yq -r '.routing_candidates[] | select(.effective_id == "framework.command.demo-command") | .scope_relevance.preferred_domain_match_scope_ids[]? // ""' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml" | awk 'NF')"
  scope_score="$(yq -r '.routing_candidates[] | select(.effective_id == "framework.command.demo-command") | .scope_relevance.score // -1' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml")"
  [[ -z "$preferred_scope_hits" && "$scope_score" == "0" ]]
}

case_degraded_extension_generation_publishes_with_quarantine() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  perl -0pi -e 's/publication_status: "published"/publication_status: "published_with_quarantine"/' \
    "$fixture/.octon/generated/effective/extensions/catalog.effective.yml"
  run_publish "$fixture"
  [[ "$(yq -r '.publication_status // ""' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml")" == "published_with_quarantine" ]]
  [[ "$(yq -r '.routing_context.extension_publication_status // ""' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml")" == "published_with_quarantine" ]]
  run_validator "$fixture"
}

case_quarantined_scope_is_excluded_from_scope_relevance() {
  local fixture preferred_scope_hits scope_score
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  perl -0pi -e 's/publication_status: published/publication_status: published_with_quarantine/' \
    "$fixture/.octon/generated/effective/locality/scopes.effective.yml"
  cat >>"$fixture/.octon/generated/effective/locality/scopes.effective.yml" <<'EOF'
  - scope_id: "quarantined-command-scope"
    manifest_path: ".octon/instance/locality/scopes/quarantined-command-scope/scope.yml"
    display_name: "Quarantined Command Scope"
    root_path: ".octon"
    owner: "Fixture Maintainers"
    status: "active"
    tech_tags: []
    language_tags: []
    include_globs: []
    exclude_globs: []
    routing_hints:
      preferred_capability_domains: ["command"]
EOF
  run_publish "$fixture"
  preferred_scope_hits="$(yq -r '.routing_candidates[] | select(.effective_id == "framework.command.demo-command") | .scope_relevance.preferred_domain_match_scope_ids[]? // ""' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml" | awk 'NF')"
  scope_score="$(yq -r '.routing_candidates[] | select(.effective_id == "framework.command.demo-command") | .scope_relevance.score // -1' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml")"
  [[ "$(yq -r '.publication_status // ""' "$fixture/.octon/generated/effective/capabilities/routing.effective.yml")" == "published_with_quarantine" ]]
  [[ -z "$preferred_scope_hits" && "$scope_score" == "0" ]]
  run_validator "$fixture"
}

main() {
  assert_success "capability publication validates for a fresh published fixture" case_publish_and_validate_passes
  assert_success "capability publication includes extension-contributed commands and skills" case_extension_capabilities_are_published
  assert_success "capability publication validator fails on stale source digests" case_stale_manifest_fails
  assert_success "capability publication validator fails on stale locality linkage" case_stale_locality_generation_fails
  assert_success "capability publication validator fails on stale extension linkage" case_stale_extension_generation_fails
  assert_success "capability publication validator rejects raw inputs references" case_raw_inputs_reference_fails
  assert_success "mutable instance skill inputs do not rotate capability generation" case_mutable_instance_inputs_do_not_rotate_digest
  assert_success "inactive scopes do not influence routing scope relevance" case_inactive_scopes_do_not_affect_scope_relevance
  assert_success "degraded extension publication still yields coherent routing" case_degraded_extension_generation_publishes_with_quarantine
  assert_success "quarantined scopes are excluded from routing relevance" case_quarantined_scope_is_excluded_from_scope_relevance

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
