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
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" >/dev/null
}

publish_state() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

write_enabled_pack_manifest() {
  local fixture_root="$1" pack_id="$2" source_id="$3"
  cat >"$fixture_root/.octon/instance/extensions.yml" <<EOF
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "$pack_id"
      source_id: "$source_id"
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

case_empty_selection_publishes_clean_empty_generation() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "published" ]]
  [[ "$(yq -r '.published_active_packs | length' "$fixture_root/.octon/state/control/extensions/active.yml")" == "0" ]]
  run_validator "$fixture_root"
}

case_partial_surviving_set_publishes_with_quarantine() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_packet8_pack "$fixture_root" "third-party-pack" "third-party-imported" "third_party" "allow" "    []" "    []" "templates"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "docs"
      source_id: "bundled-first-party"
    - pack_id: "third-party-pack"
      source_id: "third-party-imported"
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

  publish_state "$fixture_root"
  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "published_with_quarantine" ]]
  [[ "$(yq -r '.published_active_packs[0].pack_id // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "docs" ]]
  [[ "$(yq -r '.records[0].pack_id // ""' "$fixture_root/.octon/state/control/extensions/quarantine.yml")" == "third-party-pack" ]]
  run_validator "$fixture_root"
}

case_acknowledged_first_party_external_pack_publishes_cleanly() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_packet8_pack "$fixture_root" "external-pack" "first-party-imported" "first_party_external" "allow" "    []" "    []" "templates"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "external-pack"
      source_id: "first-party-imported"
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
acknowledgements:
  - acknowledgement_id: "ack-ext-pack"
    pack_id: "external-pack"
    source_id: "first-party-imported"
    action: "allow"
    reason_code: "operator-reviewed"
EOF

  publish_state "$fixture_root"
  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "published" ]]
  [[ "$(yq -r '.published_active_packs[0].pack_id // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "external-pack" ]]
  [[ "$(yq -r '.records | length' "$fixture_root/.octon/state/control/extensions/quarantine.yml")" == "0" ]]
  run_validator "$fixture_root"
}

case_publication_receipt_is_emitted_for_clean_publish() {
  local fixture_root receipt_rel
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  receipt_rel="$(yq -r '.publication_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  [[ -n "$receipt_rel" ]]
  [[ -f "$fixture_root/$receipt_rel" ]]
  [[ "$(yq -r '.result // ""' "$fixture_root/$receipt_rel")" == "published" ]]
}

case_fully_invalid_selection_withdraws_extensions() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_packet8_pack "$fixture_root" "third-party-pack" "third-party-imported" "third_party" "allow" "    []" "    []" "templates"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "third-party-pack"
      source_id: "third-party-imported"
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

  publish_state "$fixture_root"
  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "withdrawn" ]]
  [[ "$(yq -r '.published_active_packs | length' "$fixture_root/.octon/state/control/extensions/active.yml")" == "0" ]]
  [[ "$(yq -r '.records | length' "$fixture_root/.octon/state/control/extensions/quarantine.yml")" == "1" ]]
  run_validator "$fixture_root"
}

case_active_state_generation_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/^generation_id: .*/generation_id: "extensions-bad"/m' \
    "$fixture_root/.octon/state/control/extensions/active.yml"

  ! run_validator "$fixture_root"
}

case_non_manifest_payload_change_invalidates_generation_lock() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "docs"
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

  publish_state "$fixture_root"
  printf '# changed\n' >> "$fixture_root/.octon/inputs/additive/extensions/docs/templates/README.md"
  ! run_validator "$fixture_root"
}

case_dependency_root_cause_records_affected_dependents() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_packet8_pack "$fixture_root" "dep" "third-party-imported" "third_party" "allow" "    []" "    []" "templates"
  write_packet8_pack "$fixture_root" "app" "bundled-first-party" "first_party_bundled" "allow" $'    - pack_id: "dep"\n      version_range: "1.0.0"' "    []" "templates"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "app"
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

  publish_state "$fixture_root"
  [[ "$(yq -r '.records[] | select(.pack_id == "dep") | .affected_dependents[0] // ""' "$fixture_root/.octon/state/control/extensions/quarantine.yml")" == "app" ]]
}

case_native_command_collision_quarantines_before_validation() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/inputs/additive/extensions/collision/commands" \
    "$fixture_root/.octon/inputs/additive/extensions/collision/validation"

  cat >"$fixture_root/.octon/inputs/additive/extensions/collision/README.md" <<'EOF'
# collision
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/collision/pack.yml" <<'EOF'
schema_version: "octon-extension-pack-v4"
pack_id: "collision"
version: "1.0.0"
origin_class: "first_party_bundled"
compatibility:
  octon_version: "^0.5.0"
  extensions_api_version: "1.0"
  required_contracts: []
  profile_path: "validation/compatibility.yml"
dependencies:
  requires: []
  conflicts: []
provenance:
  source_id: "bundled-first-party"
  imported_from: null
  origin_uri: null
  digest_sha256: null
  attestation_refs: []
trust_hints:
  suggested_action: "allow"
content_entrypoints:
  skills: null
  commands: "commands/"
  templates: null
  prompts: null
  context: null
  validation: "validation/"
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/collision/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/collision/commands/manifest.fragment.yml" <<'EOF'
commands:
  - id: "native-command"
    display_name: "Collision Command"
    summary: "Conflicts with native command."
    path: "collision.md"
    access: "agent"
    host_adapters: [codex]
    routing:
      selectors:
        include: ["**"]
        exclude: []
      fingerprints:
        tech_tags: []
        language_tags: []
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/collision/commands/collision.md" <<'EOF'
# collision
EOF

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "collision"
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

  publish_state "$fixture_root"
  [[ "$(yq -r '.records[] | select(.pack_id == "collision") | .reason_code // ""' "$fixture_root/.octon/state/control/extensions/quarantine.yml")" == "native-capability-collision:command:native-command" ]]
  run_validator "$fixture_root"
}

case_missing_required_file_marks_pack_incompatible() {
  local fixture_root compatibility_receipt
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  write_enabled_pack_manifest "$fixture_root" "docs" "bundled-first-party"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files:
    - ".octon/missing-required-file.md"
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF

  publish_state "$fixture_root"
  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "withdrawn" ]]
  [[ "$(yq -r '.compatibility_status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "incompatible" ]]
  compatibility_receipt="$(yq -r '.compatibility_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  [[ "$(yq -r '.pack_results[0].missing_required_files[0] // ""' "$fixture_root/$compatibility_receipt")" == ".octon/missing-required-file.md" ]]
  run_validator "$fixture_root"
}

case_missing_required_directory_marks_pack_incompatible() {
  local fixture_root compatibility_receipt
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  write_enabled_pack_manifest "$fixture_root" "docs" "bundled-first-party"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories:
    - ".octon/state/evidence/validation/missing-dir"
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF

  publish_state "$fixture_root"
  [[ "$(yq -r '.compatibility_status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "incompatible" ]]
  compatibility_receipt="$(yq -r '.compatibility_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  [[ "$(yq -r '.pack_results[0].missing_required_directories[0] // ""' "$fixture_root/$compatibility_receipt")" == ".octon/state/evidence/validation/missing-dir" ]]
  run_validator "$fixture_root"
}

case_missing_required_command_marks_pack_incompatible() {
  local fixture_root compatibility_receipt
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  write_enabled_pack_manifest "$fixture_root" "docs" "bundled-first-party"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands:
    - ".octon/framework/assurance/runtime/_ops/scripts/does-not-exist.sh"
  minimum_behavior: {}
  optional_features: []
EOF

  publish_state "$fixture_root"
  [[ "$(yq -r '.compatibility_status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "incompatible" ]]
  compatibility_receipt="$(yq -r '.compatibility_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  [[ "$(yq -r '.pack_results[0].missing_required_commands[0] // ""' "$fixture_root/$compatibility_receipt")" == ".octon/framework/assurance/runtime/_ops/scripts/does-not-exist.sh" ]]
  run_validator "$fixture_root"
}

case_missing_optional_feature_degrades_without_blocking_publish() {
  local fixture_root compatibility_receipt
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"
  write_enabled_pack_manifest "$fixture_root" "docs" "bundled-first-party"

  cat >"$fixture_root/.octon/inputs/additive/extensions/docs/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features:
    - feature_id: "host-projections"
      description: "Optional host projection support."
      required_files: []
      required_directories: []
      required_commands:
        - ".octon/framework/capabilities/_ops/scripts/does-not-exist.sh"
      minimum_behavior: {}
EOF

  publish_state "$fixture_root"
  [[ "$(yq -r '.status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "published" ]]
  [[ "$(yq -r '.compatibility_status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "degraded" ]]
  compatibility_receipt="$(yq -r '.compatibility_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  [[ "$(yq -r '.pack_results[0].degraded_optional_features[0] // ""' "$fixture_root/$compatibility_receipt")" == "host-projections" ]]
  run_validator "$fixture_root"
}

case_prompt_anchor_paths_appear_in_compatibility_inputs() {
  local fixture_root compatibility_receipt
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/inputs/additive/extensions/prompt-pack/prompts/simple/stages" \
    "$fixture_root/.octon/inputs/additive/extensions/prompt-pack/validation"
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/README.md" <<'EOF'
# prompt-pack
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/pack.yml" <<'EOF'
schema_version: "octon-extension-pack-v4"
pack_id: "prompt-pack"
version: "1.0.0"
origin_class: "first_party_bundled"
compatibility:
  octon_version: "^0.5.0"
  extensions_api_version: "1.0"
  required_contracts: []
  profile_path: "validation/compatibility.yml"
dependencies:
  requires: []
  conflicts: []
provenance:
  source_id: "bundled-first-party"
  imported_from: null
  origin_uri: null
  digest_sha256: null
  attestation_refs: []
trust_hints:
  suggested_action: "allow"
content_entrypoints:
  skills: null
  commands: null
  templates: null
  prompts: "prompts/"
  context: null
  validation: "validation/"
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/prompts/simple/README.md" <<'EOF'
# simple prompt bundle
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/prompts/simple/manifest.yml" <<'EOF'
schema_version: "octon-extension-prompt-set-v1"
prompt_set_id: "prompt-pack-simple"
version: "1.0.0"
stages:
  - stage_id: "single-stage"
    prompt_id: "prompt-pack-simple-stage"
    path: "stages/01-stage.md"
    role_class: "stage"
    order: 1
companions: []
references: []
shared_references: []
required_repo_anchors:
  - ".octon/instance/ingress/AGENTS.md"
alignment_policy:
  default_mode: "auto"
  stale_behavior: "realign_or_fail_closed"
  skip_mode_policy: "degraded-retained-explicit"
  receipt_root: ".octon/state/evidence/validation/extensions/prompt-alignment"
invalidation_conditions: []
artifact_policy:
  internal_artifacts: []
  packet_support_files: []
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/prompt-pack/prompts/simple/stages/01-stage.md" <<'EOF'
# stage
EOF
  write_enabled_pack_manifest "$fixture_root" "prompt-pack" "bundled-first-party"

  publish_state "$fixture_root"
  [[ "$(yq -r '.compatibility_status // ""' "$fixture_root/.octon/state/control/extensions/active.yml")" == "compatible" ]]
  compatibility_receipt="$(yq -r '.compatibility_receipt_path // ""' "$fixture_root/.octon/state/control/extensions/active.yml")"
  yq -e '.pack_results[0].required_inputs[] | select(. == ".octon/instance/ingress/AGENTS.md")' "$fixture_root/$compatibility_receipt" >/dev/null
  run_validator "$fixture_root"
}

main() {
  assert_success "empty desired selection publishes a clean empty generation" case_empty_selection_publishes_clean_empty_generation
  assert_success "one valid and one denied selected pack publishes with quarantine" case_partial_surviving_set_publishes_with_quarantine
  assert_success "acknowledged first-party external pack publishes cleanly" case_acknowledged_first_party_external_pack_publishes_cleanly
  assert_success "clean extension publish emits a publication receipt" case_publication_receipt_is_emitted_for_clean_publish
  assert_success "fully invalid selected set withdraws extension contributions" case_fully_invalid_selection_withdraws_extensions
  assert_success "active-state generation mismatches fail validation" case_active_state_generation_mismatch_fails
  assert_success "non-manifest payload changes invalidate the generation lock" case_non_manifest_payload_change_invalidates_generation_lock
  assert_success "dependency root-cause quarantine records carry affected dependents" case_dependency_root_cause_records_affected_dependents
  assert_success "native command collisions quarantine before validation" case_native_command_collision_quarantines_before_validation
  assert_success "missing required files mark selected packs incompatible" case_missing_required_file_marks_pack_incompatible
  assert_success "missing required directories mark selected packs incompatible" case_missing_required_directory_marks_pack_incompatible
  assert_success "missing required commands mark selected packs incompatible" case_missing_required_command_marks_pack_incompatible
  assert_success "missing optional feature groups degrade without blocking publish" case_missing_optional_feature_degrades_without_blocking_publish
  assert_success "prompt-manifest anchors appear in compatibility required inputs" case_prompt_anchor_paths_appear_in_compatibility_inputs

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
