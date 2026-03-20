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

  perl -0pi -e 's/required_contracts: \[\]/required_contracts:\n    - contract_id: "extension-effective-catalog"\n      schema_version: "octon-extension-effective-catalog-v3"/' \
    "$fixture_root/.octon/inputs/additive/extensions/docs/pack.yml"

  run_validator "$fixture_root"
}

case_required_contracts_follow_live_schema_versions() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet2_runtime_scripts "$fixture_root"
  write_valid_packet2_fixture "$fixture_root"

  perl -0pi -e 's/schema_version: "octon-extension-effective-catalog-v3"/schema_version: "octon-extension-effective-catalog-v9"/' \
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

main() {
  assert_success "seeded packet-8 packs satisfy the pack contract" case_valid_seeded_packs_pass
  assert_success "supported required_contracts entries are accepted" case_supported_required_contracts_pass
  assert_success "required_contracts resolve against live schema versions" case_required_contracts_follow_live_schema_versions
  assert_success "required_contracts reject live version mismatches" case_required_contract_version_mismatch_fails
  assert_success "pack validator rejects legacy pack manifest shape" case_invalid_pack_schema_fails
  assert_success "pack validator rejects disallowed top-level pack buckets" case_unexpected_top_level_bucket_fails
  assert_success "pack validator rejects missing required provenance fields" case_missing_required_provenance_fields_fail
  assert_success "pack validator rejects provenance/source mismatches" case_provenance_source_mismatch_fails
  assert_success "external packs require external provenance" case_external_pack_requires_external_provenance
  assert_success "unsupported required_contracts entries are rejected" case_unsupported_required_contract_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
