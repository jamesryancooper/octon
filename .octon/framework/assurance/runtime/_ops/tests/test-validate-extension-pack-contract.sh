#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_packet2_fixture_lib.sh"

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

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" >/dev/null
}

case_valid_seeded_packs_pass() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  run_validator "$fixture_root"
}

case_additive_incoming_intake_units_are_ignored() {
  local fixture_root incoming
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  incoming="$fixture_root/.octon/inputs/additive/.incoming/downloaded-kit"
  mkdir -p "$incoming/install" "$incoming/repo"
  printf '# Downloaded Kit\n' >"$incoming/README.md"
  printf 'schema_version: "not-an-extension-pack"\n' >"$incoming/install/fragment.yml"

  run_validator "$fixture_root"
}

case_extension_incoming_directory_fails_closed() {
  local fixture_root incoming
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  incoming="$fixture_root/.octon/inputs/additive/extensions/.incoming/downloaded-kit"
  mkdir -p "$incoming"
  printf '# Downloaded Kit\n' >"$incoming/README.md"

  ! run_validator "$fixture_root"
}

case_invalid_pack_schema_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml" <<'EOF'
schema_version: "extension-pack-v1"
id: "docs"
EOF

  ! run_validator "$fixture_root"
}

case_supported_required_contracts_pass() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/required_contracts: \[\]/required_contracts:\n    - contract_id: "extension-effective-catalog"\n      schema_version: "octon-extension-effective-catalog-v7"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  run_validator "$fixture_root"
}

case_selected_version_pin_matching_pack_version_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/enabled: \[\]/enabled:\n    - pack_id: "docs"\n      source_id: "bundled-first-party"\n      version_pin: "1.0.0"/' \
    "$fixture_root/.octon/instance/extensions.yml"

  run_validator "$fixture_root"
}

case_required_contracts_follow_live_schema_versions() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/schema_version: "octon-extension-effective-catalog-v7"/schema_version: "octon-extension-effective-catalog-v9"/' \
    "$fixture_root/.octon/generated/effective/extensions/catalog.effective.yml"
  perl -0pi -e 's/required_contracts: \[\]/required_contracts:\n    - contract_id: "extension-effective-catalog"\n      schema_version: "octon-extension-effective-catalog-v9"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  run_validator "$fixture_root"
}

case_required_contract_version_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/required_contracts: \[\]/required_contracts:\n    - contract_id: "instance-extensions"\n      schema_version: "octon-instance-extensions-v1"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_valid_routing_contract_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/context"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/commands"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/commands/manifest.fragment.yml" <<'EOF'
schema_version: "extensions-commands-manifest-fragment-v1"
commands:
  - id: "docs-command"
    path: "docs-command.md"
    display_name: "Docs Command"
    summary: "Fixture command."
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/commands/docs-command.md" <<'EOF'
# Docs Command
EOF
  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"\n  - "template-surface"/capability_profiles:\n  - "validation-surface"\n  - "command-surface"\n  - "routing-contract"\n  - "template-surface"/; s/commands: null/commands: "commands\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  perl -0pi -e 's/context: null/context: "context\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/context/routing.contract.yml" <<'EOF'
schema_version: "octon-extension-routing-contract-v1"
dispatchers:
  - dispatcher_id: "docs-dispatcher"
    default_route_id: "docs-route"
    accepted_inputs:
      - "bundle"
    disambiguators:
      - input_name: "bundle"
        kind: "route-id"
        allowed_values:
          - "docs-route"
    precedence:
      - "explicit-bundle"
      - "missing-bundle"
    routes:
      - route_id: "docs-route"
        status: "resolved"
        execution_binding_id: "docs-route"
        matchers:
          - matcher_id: "explicit-bundle"
            reason_codes:
              - "explicit-bundle"
            all_of:
              - input_name: "bundle"
                predicate: "equals"
                value: "docs-route"
      - route_id: "missing-bundle"
        status: "escalate"
        matchers:
          - matcher_id: "missing-bundle"
            reason_codes:
              - "missing-routeable-inputs"
            all_of:
              - input_name: "bundle"
                predicate: "absent"
    execution_bindings:
      - binding_id: "docs-route"
        route_id: "docs-route"
        command_capability_id: "docs-command"
EOF

  run_validator "$fixture_root"
}

case_invalid_routing_contract_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/context"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/commands"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/commands/manifest.fragment.yml" <<'EOF'
schema_version: "extensions-commands-manifest-fragment-v1"
commands:
  - id: "docs-command"
    path: "docs-command.md"
    display_name: "Docs Command"
    summary: "Fixture command."
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/commands/docs-command.md" <<'EOF'
# Docs Command
EOF
  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"\n  - "template-surface"/capability_profiles:\n  - "validation-surface"\n  - "command-surface"\n  - "routing-contract"\n  - "template-surface"/; s/commands: null/commands: "commands\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  perl -0pi -e 's/context: null/context: "context\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/context/routing.contract.yml" <<'EOF'
schema_version: "octon-extension-routing-contract-v1"
dispatchers:
  - dispatcher_id: "docs-dispatcher"
    default_route_id: "docs-route"
    accepted_inputs:
      - "bundle"
    disambiguators: []
    precedence:
      - "missing-bundle"
    routes:
      - route_id: "docs-route"
        status: "resolved"
        execution_binding_id: "docs-route"
        matchers:
          - matcher_id: "missing-bundle"
            reason_codes:
              - "missing-routeable-inputs"
            all_of:
              - input_name: "bundle"
                predicate: "maybe"
    execution_bindings:
      - binding_id: "docs-route"
        route_id: "docs-route"
        command_capability_id: "docs-command"
EOF

  ! run_validator "$fixture_root"
}

case_unexpected_top_level_bucket_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/agency"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/agency/README.md" <<'EOF'
# Invalid
EOF

  ! run_validator "$fixture_root"
}

case_missing_required_provenance_fields_fail() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/\n  origin_uri: null\n  digest_sha256: null\n  attestation_refs: \[\]//' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_provenance_source_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/source_id: "bundled-first-party"/source_id: "third-party-imported"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_external_pack_requires_external_provenance() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_packet8_pack "$fixture_root" "external-pack" "first-party-imported" "first_party_external" "allow" "    []" "    []" "templates"
  perl -0pi -e 's/imported_from: "https:\/\/example.com\/external-pack.git"/imported_from: null/' \
    "$fixture_root/.octon/inputs/additive/extensions/external-pack/pack.yml"

  ! run_validator "$fixture_root"
}

case_unsupported_required_contract_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/required_contracts: \[\]/required_contracts:\n    - contract_id: "unsupported-contract"\n      schema_version: "contract-v1"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_missing_capability_profiles_fail() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/capability_profiles:\n(?:  - "[^"]+"\n)+//' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_duplicate_capability_profile_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "validation-surface"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_unknown_capability_profile_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "unknown-surface"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_validation_surface_required() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/  - "validation-surface"\n//' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_capability_artifact_dependencies_fail_closed() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "command-surface"/; s/commands: null/commands: "commands\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_prompt_bundle_requires_manifest() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/prompts"
  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "prompt-bundle"/; s/prompts: null/prompts: "prompts\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  ! run_validator "$fixture_root"
}

case_routing_references_require_declared_profiles() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/context"
  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "routing-contract"/; s/context: null/context: "context\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/context/routing.contract.yml" <<'EOF'
schema_version: "octon-extension-routing-contract-v1"
dispatchers:
  - dispatcher_id: "docs-dispatcher"
    default_route_id: "docs-route"
    accepted_inputs: []
    disambiguators: []
    precedence:
      - "always"
    routes:
      - route_id: "docs-route"
        status: "resolved"
        execution_binding_id: "docs-route"
        matchers:
          - matcher_id: "always"
            reason_codes:
              - "always"
            all_of: []
    execution_bindings:
      - binding_id: "docs-route"
        route_id: "docs-route"
        command_capability_id: "docs-command"
EOF

  ! run_validator "$fixture_root"
}

case_lifecycle_extension_routes_require_routing_profile() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/docs/context"
  perl -0pi -e 's/capability_profiles:\n  - "validation-surface"/capability_profiles:\n  - "validation-surface"\n  - "lifecycle-contract"/; s/context: null/context: "context\/"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"
  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/context/lifecycle.contract.yml" <<'EOF'
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "docs-lifecycle"
owner_extension: "docs"
version: "1.0.0"
target:
  input: "target"
  manifest_path: "manifest.yml"
  status_field: "status"
  allowed_statuses: ["draft"]
states: []
terminal_outcomes: []
validators: []
gates: []
receipts: []
loops: []
input_bindings: {}
routes:
  - route_id: "docs-route"
    route_type: "extension"
    enter_when:
      target_missing: true
EOF

  ! run_validator "$fixture_root"
}

case_missing_compatibility_profile_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  rm "$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml"

  ! run_validator "$fixture_root"
}

case_invalid_compatibility_profile_contract_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior:
    unsupported_flag: true
  optional_features: []
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "seeded packet-8 packs satisfy the pack contract" case_valid_seeded_packs_pass
  assert_success "additive incoming intake units are ignored by pack validation" case_additive_incoming_intake_units_are_ignored
  assert_success "extension incoming directory fails closed" case_extension_incoming_directory_fails_closed
  assert_success "supported required_contracts entries are accepted" case_supported_required_contracts_pass
  assert_success "matching selected version pins are accepted" case_selected_version_pin_matching_pack_version_passes
  assert_success "required_contracts resolve against live schema versions" case_required_contracts_follow_live_schema_versions
  assert_success "required_contracts reject live version mismatches" case_required_contract_version_mismatch_fails
  assert_success "pack validator rejects legacy pack manifest shape" case_invalid_pack_schema_fails
  assert_success "pack validator rejects disallowed top-level pack buckets" case_unexpected_top_level_bucket_fails
  assert_success "valid routing contracts are accepted" case_valid_routing_contract_passes
  assert_success "invalid routing contracts are rejected" case_invalid_routing_contract_fails
  assert_success "pack validator rejects missing required provenance fields" case_missing_required_provenance_fields_fail
  assert_success "pack validator rejects provenance/source mismatches" case_provenance_source_mismatch_fails
  assert_success "external packs require external provenance" case_external_pack_requires_external_provenance
  assert_success "unsupported required_contracts entries are rejected" case_unsupported_required_contract_fails
  assert_success "missing capability_profiles are rejected" case_missing_capability_profiles_fail
  assert_success "duplicate capability profiles are rejected" case_duplicate_capability_profile_fails
  assert_success "unknown capability profiles are rejected" case_unknown_capability_profile_fails
  assert_success "validation-surface is required for every pack" case_validation_surface_required
  assert_success "capability profiles require their artifacts" case_capability_artifact_dependencies_fail_closed
  assert_success "prompt-bundle requires a manifest-based prompt bundle" case_prompt_bundle_requires_manifest
  assert_success "routing contracts require referenced capability profiles" case_routing_references_require_declared_profiles
  assert_success "lifecycle extension routes require routing capability profile" case_lifecycle_extension_routes_require_routing_profile
  assert_success "missing compatibility profiles are rejected" case_missing_compatibility_profile_fails
  assert_success "invalid compatibility profile behavior keys are rejected" case_invalid_compatibility_profile_contract_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
