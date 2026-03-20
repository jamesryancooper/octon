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
    "$root/.octon/inputs/additive/extensions/demo-ext/commands" \
    "$root/.octon/inputs/additive/extensions/demo-ext/skills/demo-ext-skill" \
    "$root/.octon/generated/effective/extensions" \
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
EOF

  cat >"$root/.octon/framework/capabilities/runtime/services/demo/SERVICE.md" <<'EOF'
---
fail_closed: true
---
allowed-tools: Read
EOF

  cat >"$root/.octon/framework/capabilities/runtime/tools/manifest.yml" <<'EOF'
schema_version: "1.0"
packs:
  - id: read-only
    display_name: Read Only
    summary: Read only tools.
    tools: [Read]
tools: []
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/commands/manifest.fragment.yml" <<'EOF'
schema_version: "extensions-commands-fragment-v1"
commands:
  - id: demo-ext-command
    display_name: Demo Ext Command
    path: demo-ext-command.md
    summary: Demo extension command summary.
    access: agent
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/commands/demo-ext-command.md" <<'EOF'
# Demo Ext Command
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/skills/manifest.fragment.yml" <<'EOF'
schema_version: "extensions-skills-fragment-v1"
skills:
  - id: demo-ext-skill
    display_name: Demo Ext Skill
    group: extensions
    path: demo-ext-skill/
    skill_class: invocable
    summary: Demo extension skill summary.
    status: active
    tags: []
    triggers: []
EOF

  cat >"$root/.octon/inputs/additive/extensions/demo-ext/skills/demo-ext-skill/SKILL.md" <<'EOF'
# Demo Ext Skill
allowed-tools: Read
EOF

  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'EOF'
schema_version: "octon-extension-effective-catalog-v2"
generator_version: "0.5.1"
generation_id: "extensions-fixture"
published_at: "2026-03-20T00:00:00Z"
publication_status: "published"
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
    content_roots:
      skills: ".octon/inputs/additive/extensions/demo-ext/skills"
      commands: ".octon/inputs/additive/extensions/demo-ext/commands"
      templates: null
      prompts: null
      context: null
      validation: null
source:
  desired_config_path: ".octon/instance/extensions.yml"
  desired_config_sha256: "fixture"
  root_manifest_path: ".octon/octon.yml"
  root_manifest_sha256: "fixture"
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

case_legacy_catalog_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  printf 'schema_version: "1.0"\n' >"$fixture/.octon/generated/effective/capabilities/deny-by-default-policy.catalog.yml"
  ! run_validator "$fixture"
}

case_raw_inputs_reference_fails() {
  local fixture
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  run_publish "$fixture"
  printf '\n  - artifact_map_id: "bad"\n    effective_id: "bad"\n    origin_class: "framework"\n    capability_kind: "command"\n    capability_id: "bad"\n    display_name: "Bad"\n    source_manifest_path: ".octon/inputs/additive/extensions/demo/pack.yml"\n    source_manifest_sha256: "bad"\n    source_path: ".octon/inputs/additive/extensions/demo/pack.yml"\n    source_sha256: "bad"\n' >>"$fixture/.octon/generated/effective/capabilities/artifact-map.yml"
  ! run_validator "$fixture"
}

case_mutable_instance_inputs_do_not_rotate_digest() {
  local fixture
  local first_id second_id
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

main() {
  assert_success "capability publication validates for a fresh published fixture" case_publish_and_validate_passes
  assert_success "capability publication includes extension-contributed commands and skills" case_extension_capabilities_are_published
  assert_success "capability publication validator fails on stale source digests" case_stale_manifest_fails
  assert_success "capability publication validator rejects legacy runtime-facing policy catalogs" case_legacy_catalog_fails
  assert_success "capability publication validator rejects raw inputs references" case_raw_inputs_reference_fails
  assert_success "mutable instance skill inputs do not rotate capability generation" case_mutable_instance_inputs_do_not_rotate_digest

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
