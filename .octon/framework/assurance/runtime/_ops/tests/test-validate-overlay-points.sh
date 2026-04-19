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

copy_packet5_runtime_scripts() {
  local fixture_root="$1"
  copy_packet2_runtime_scripts "$fixture_root"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
}

write_valid_packet5_fixture() {
  local fixture_root="$1"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/instance/governance/policies" \
    "$fixture_root/.octon/instance/governance/contracts" \
    "$fixture_root/.octon/instance/execution-roles/runtime" \
    "$fixture_root/.octon/instance/assurance/runtime"

  cat >"$fixture_root/.octon/framework/overlay-points/registry.yml" <<'EOF'
schema_version: "octon-overlay-points-registry-v1"
overlay_points:
  - overlay_point_id: "instance-governance-policies"
    owning_domain: "governance"
    instance_glob: ".octon/instance/governance/policies/**"
    merge_mode: "replace_by_path"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 10
    artifact_kinds:
      - "policy"
  - overlay_point_id: "instance-governance-contracts"
    owning_domain: "governance"
    instance_glob: ".octon/instance/governance/contracts/**"
    merge_mode: "replace_by_path"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 20
    artifact_kinds:
      - "contract"
  - overlay_point_id: "instance-execution-roles-runtime"
    owning_domain: "agency"
    instance_glob: ".octon/instance/execution-roles/runtime/**"
    merge_mode: "merge_by_id"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 30
    artifact_kinds:
      - "runtime"
  - overlay_point_id: "instance-assurance-runtime"
    owning_domain: "assurance"
    instance_glob: ".octon/instance/assurance/runtime/**"
    merge_mode: "append_only"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 40
    artifact_kinds:
      - "runtime"
EOF

  cat >"$fixture_root/.octon/instance/manifest.yml" <<'EOF'
schema_version: "octon-instance-manifest-v1"
instance_id: "fixture"
framework_id: "octon-core"
enabled_overlay_points:
  - "instance-governance-policies"
  - "instance-governance-contracts"
  - "instance-execution-roles-runtime"
  - "instance-assurance-runtime"
locality:
  registry_path: ".octon/instance/locality/registry.yml"
  manifest_path: ".octon/instance/locality/manifest.yml"
feature_toggles:
  integrated_inputs: true
  generated_registry: true
  state_class_root: true
EOF

  cat >"$fixture_root/.octon/instance/governance/policies/README.md" <<'EOF'
# Policies
EOF
  cat >"$fixture_root/.octon/instance/governance/contracts/README.md" <<'EOF'
# Contracts
EOF
  cat >"$fixture_root/.octon/instance/execution-roles/runtime/README.md" <<'EOF'
# Agency Runtime
EOF
  cat >"$fixture_root/.octon/instance/assurance/runtime/README.md" <<'EOF'
# Assurance Runtime
EOF
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet5_runtime_scripts "$fixture_root"
  write_valid_packet5_fixture "$fixture_root"

  run_validator "$fixture_root"
}

case_undeclared_enabled_overlay_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet5_runtime_scripts "$fixture_root"
  write_valid_packet5_fixture "$fixture_root"

  cat >>"$fixture_root/.octon/instance/manifest.yml" <<'EOF'
  - "instance-nonexistent-runtime"
EOF

  ! run_validator "$fixture_root"
}

case_invalid_merge_mode_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet5_runtime_scripts "$fixture_root"
  write_valid_packet5_fixture "$fixture_root"

  perl -0pi -e 's/merge_mode: "append_only"/merge_mode: "overlay_anything"/' \
    "$fixture_root/.octon/framework/overlay-points/registry.yml"

  ! run_validator "$fixture_root"
}

case_disabled_overlay_root_with_real_file_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet5_runtime_scripts "$fixture_root"
  write_valid_packet5_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/manifest.yml" <<'EOF'
schema_version: "octon-instance-manifest-v1"
instance_id: "fixture"
framework_id: "octon-core"
enabled_overlay_points:
  - "instance-governance-policies"
  - "instance-governance-contracts"
  - "instance-execution-roles-runtime"
locality:
  registry_path: ".octon/instance/locality/registry.yml"
  manifest_path: ".octon/instance/locality/manifest.yml"
feature_toggles:
  integrated_inputs: true
  generated_registry: true
  state_class_root: true
EOF

  cat >"$fixture_root/.octon/instance/assurance/runtime/check.yml" <<'EOF'
schema_version: "fixture"
EOF

  ! run_validator "$fixture_root"
}

case_closed_domain_overlay_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet5_runtime_scripts "$fixture_root"
  write_valid_packet5_fixture "$fixture_root"

  perl -0pi -e 's/owning_domain: "assurance"/owning_domain: "engine"/' \
    "$fixture_root/.octon/framework/overlay-points/registry.yml"

  ! run_validator "$fixture_root"
}

main() {
  assert_success "overlay validator accepts valid packet-5 fixture" case_valid_fixture_passes
  assert_success "overlay validator rejects undeclared enabled overlay point" case_undeclared_enabled_overlay_fails
  assert_success "overlay validator rejects unsupported merge mode" case_invalid_merge_mode_fails
  assert_success "overlay validator rejects real files under disabled overlay roots" case_disabled_overlay_root_with_real_file_fails
  assert_success "overlay validator rejects closed-domain overlay points" case_closed_domain_overlay_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
