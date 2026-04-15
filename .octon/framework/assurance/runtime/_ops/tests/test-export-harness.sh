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

run_export() {
  local fixture_root="$1"
  shift
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh" "$@"
}

write_pack() {
  local fixture_root="$1"
  local pack_id="$2"
  local source_id="${3:-bundled-first-party}"
  local origin_class="${4:-first_party_bundled}"
  local requires_block="${5:-    []}"
  local conflicts_block="${6:-    []}"
  local imported_from="null"

  if [[ "$origin_class" != "first_party_bundled" ]]; then
    imported_from="\"https://example.com/${pack_id}.git\""
  fi

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/$pack_id/validation"
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/README.md" <<EOF
# $pack_id
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/$pack_id/pack.yml" <<EOF
schema_version: "octon-extension-pack-v4"
pack_id: "$pack_id"
version: "1.0.0"
origin_class: "$origin_class"
compatibility:
  octon_version: "0.5.0"
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
  suggested_action: "allow"
content_entrypoints:
  skills: null
  commands: null
  templates: null
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

case_repo_snapshot_empty_enabled_exports_core_only() {
  local fixture_root output_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  output_root="$fixture_root/out"
  run_export "$fixture_root" --profile repo_snapshot --output-dir "$output_root" >/dev/null || return 1

  [[ -f "$output_root/.octon/octon.yml" ]]
  [[ -d "$output_root/.octon/framework" ]]
  [[ -d "$output_root/.octon/instance" ]]
  [[ ! -e "$output_root/.octon/state" ]]
  [[ ! -e "$output_root/.octon/generated" ]]
}

case_repo_snapshot_missing_enabled_pack_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "missing-pack"
      source_id: "bundled-first-party"
  disabled: []
sources:
  catalog:
    bundled-first-party:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_bundled"
trust:
  default_actions:
    first_party_bundled: "allow"
    first_party_external: "require_acknowledgement"
    third_party: "deny"
  source_overrides: {}
  pack_overrides: {}
acknowledgements: []
EOF

  ! run_export "$fixture_root" --profile repo_snapshot --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_repo_snapshot_acknowledgement_required_pack_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "external-pack" "first-party-imported" "first_party_external" "    []" "    []"
  perl -0pi -e 's/imported_from: null/imported_from: "https:\/\/example.com\/external-pack.git"/' \
    "$fixture_root/.octon/inputs/additive/extensions/external-pack/pack.yml"

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
acknowledgements: []
EOF

  ! run_export "$fixture_root" --profile repo_snapshot --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_repo_snapshot_quarantined_publication_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "third-party-pack" "third-party-imported" "third_party" "    []" "    []"

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

  ! run_export "$fixture_root" --profile repo_snapshot --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_repo_snapshot_incompatible_selected_pack_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/incompatible/validation"
  cat >"$fixture_root/.octon/inputs/additive/extensions/incompatible/pack.yml" <<'EOF'
schema_version: "octon-extension-pack-v4"
pack_id: "incompatible"
version: "1.0.0"
origin_class: "first_party_bundled"
compatibility:
  octon_version: "^9.0.0"
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
  prompts: null
  context: null
  validation: "validation/"
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/incompatible/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF

  cat >"$fixture_root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "incompatible"
      source_id: "bundled-first-party"
  disabled: []
sources:
  catalog:
    bundled-first-party:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_bundled"
trust:
  default_actions:
    first_party_bundled: "allow"
    first_party_external: "require_acknowledgement"
    third_party: "deny"
  source_overrides: {}
  pack_overrides: {}
acknowledgements: []
EOF

  ! run_export "$fixture_root" --profile repo_snapshot --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_pack_bundle_includes_dependency_closure_only() {
  local fixture_root output_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "b" "bundled-first-party" "first_party_bundled" "    []" "    []"
  write_pack "$fixture_root" "a" "bundled-first-party" "first_party_bundled" $'    - pack_id: "b"\n      version_range: "1.0.0"' "    []"

  output_root="$fixture_root/out"
  run_export "$fixture_root" --profile pack_bundle --output-dir "$output_root" --pack-ids "a" >/dev/null || return 1

  [[ -d "$output_root/.octon/inputs/additive/extensions/a" ]]
  [[ -d "$output_root/.octon/inputs/additive/extensions/b" ]]
  [[ ! -e "$output_root/.octon/framework" ]]
  [[ ! -e "$output_root/.octon/instance" ]]
  [[ ! -e "$output_root/.octon/state" ]]
  [[ ! -e "$output_root/.octon/generated" ]]
}

case_full_fidelity_rejected() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  ! run_export "$fixture_root" --profile full_fidelity --output-dir "$fixture_root/out" >/dev/null 2>&1
}

case_pack_bundle_cycle_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "a" "bundled-first-party" "first_party_bundled" $'    - pack_id: "b"\n      version_range: "1.0.0"' "    []"
  write_pack "$fixture_root" "b" "bundled-first-party" "first_party_bundled" $'    - pack_id: "a"\n      version_range: "1.0.0"' "    []"

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a" >/dev/null 2>&1
}

case_pack_bundle_conflict_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "b" "bundled-first-party" "first_party_bundled" "    []" "    []"
  write_pack "$fixture_root" "a" "bundled-first-party" "first_party_bundled" "    []" $'    - pack_id: "b"\n      version_range: "1.0.0"'

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a,b" >/dev/null 2>&1
}

case_pack_bundle_compatibility_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/a/validation"
  cat >"$fixture_root/.octon/inputs/additive/extensions/a/pack.yml" <<'EOF'
schema_version: "octon-extension-pack-v4"
pack_id: "a"
version: "1.0.0"
origin_class: "first_party_bundled"
compatibility:
  octon_version: "^9.0.0"
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
  prompts: null
  context: null
  validation: "validation/"
EOF
  cat >"$fixture_root/.octon/inputs/additive/extensions/a/validation/compatibility.yml" <<'EOF'
schema_version: "octon-extension-compatibility-profile-v1"
version: "1.0.0"
compatibility:
  required_files: []
  required_directories: []
  required_commands: []
  minimum_behavior: {}
  optional_features: []
EOF

  ! run_export "$fixture_root" --profile pack_bundle --output-dir "$fixture_root/out" --pack-ids "a" >/dev/null 2>&1
}

case_pack_bundle_ignores_repo_trust_denial() {
  local fixture_root output_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  write_pack "$fixture_root" "third-party-pack" "third-party-imported" "third_party" "    []" "    []"

  output_root="$fixture_root/out"
  run_export "$fixture_root" --profile pack_bundle --output-dir "$output_root" --pack-ids "third-party-pack" >/dev/null || return 1

  [[ -d "$output_root/.octon/inputs/additive/extensions/third-party-pack" ]]
}

main() {
  assert_success "repo_snapshot with empty enabled set exports only core payload" case_repo_snapshot_empty_enabled_exports_core_only
  assert_success "repo_snapshot fails when an enabled pack payload is missing" case_repo_snapshot_missing_enabled_pack_fails
  assert_success "repo_snapshot fails when an enabled pack requires acknowledgement" case_repo_snapshot_acknowledgement_required_pack_fails
  assert_success "repo_snapshot fails when extension publication is quarantined" case_repo_snapshot_quarantined_publication_fails
  assert_success "repo_snapshot fails when an enabled pack is incompatible" case_repo_snapshot_incompatible_selected_pack_fails
  assert_success "pack_bundle exports selected packs plus dependency closure only" case_pack_bundle_includes_dependency_closure_only
  assert_success "pack_bundle exports raw packs even when repo trust would deny activation" case_pack_bundle_ignores_repo_trust_denial
  assert_success "full_fidelity export is rejected" case_full_fidelity_rejected
  assert_success "pack_bundle fails on dependency cycles" case_pack_bundle_cycle_fails
  assert_success "pack_bundle fails on declared conflicts" case_pack_bundle_conflict_fails
  assert_success "pack_bundle fails on compatibility mismatch" case_pack_bundle_compatibility_mismatch_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
