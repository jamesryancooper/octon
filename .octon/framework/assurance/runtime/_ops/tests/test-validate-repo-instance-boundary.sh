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

copy_packet4_runtime_scripts() {
  local fixture_root="$1"
  copy_packet2_runtime_scripts "$fixture_root"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh"
}

write_valid_packet4_fixture() {
  local fixture_root="$1"
  write_valid_packet2_fixture "$fixture_root"

  mkdir -p \
    "$fixture_root/.octon/instance/ingress" \
    "$fixture_root/.octon/instance/bootstrap" \
    "$fixture_root/.octon/instance/capabilities/runtime/commands" \
    "$fixture_root/.octon/instance/orchestration/missions/.archive" \
    "$fixture_root/.octon/instance/orchestration/missions/_scaffold/template" \
    "$fixture_root/.octon/instance/governance/policies" \
    "$fixture_root/.octon/instance/governance/contracts" \
    "$fixture_root/.octon/instance/agency/runtime" \
    "$fixture_root/.octon/instance/assurance/runtime" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture" \
    "$fixture_root/.octon/framework/orchestration/practices" \
    "$fixture_root/.octon/framework/orchestration/_meta/architecture" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/update-harness/stages" \
    "$fixture_root/.octon/framework/scaffolding/runtime/templates/octon"

  cat >"$fixture_root/.octon/framework/overlay-points/registry.yml" <<'EOF'
schema_version: "octon-overlay-points-registry-v1"
overlay_points:
  - overlay_point_id: "instance-governance-policies"
    owning_domain: "governance"
    instance_glob: ".octon/instance/governance/policies/**"
    merge_mode: "replace_by_path"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 10
  - overlay_point_id: "instance-governance-contracts"
    owning_domain: "governance"
    instance_glob: ".octon/instance/governance/contracts/**"
    merge_mode: "replace_by_path"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 20
  - overlay_point_id: "instance-agency-runtime"
    owning_domain: "agency"
    instance_glob: ".octon/instance/agency/runtime/**"
    merge_mode: "merge_by_id"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 30
  - overlay_point_id: "instance-assurance-runtime"
    owning_domain: "assurance"
    instance_glob: ".octon/instance/assurance/runtime/**"
    merge_mode: "append_only"
    validator: ".octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh"
    precedence: 40
EOF

  cat >"$fixture_root/.octon/instance/manifest.yml" <<'EOF'
schema_version: "octon-instance-manifest-v1"
instance_id: "fixture"
framework_id: "octon-core"
enabled_overlay_points:
  - "instance-governance-policies"
  - "instance-governance-contracts"
  - "instance-agency-runtime"
  - "instance-assurance-runtime"
locality:
  registry_path: ".octon/instance/locality/registry.yml"
  manifest_path: ".octon/instance/locality/manifest.yml"
feature_toggles:
  integrated_inputs: true
  generated_registry: true
  state_class_root: true
EOF

  cat >"$fixture_root/.octon/instance/ingress/AGENTS.md" <<'EOF'
# Instance Ingress
Read `.octon/state/continuity/repo/log.md`.
EOF

  cat >"$fixture_root/.octon/instance/bootstrap/START.md" <<'EOF'
# Start
Read `.octon/instance/cognition/context/shared/constraints.md`.
EOF

  cat >"$fixture_root/.octon/instance/capabilities/runtime/commands/README.md" <<'EOF'
# Commands
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/README.md" <<'EOF'
# Missions
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/registry.yml" <<'EOF'
schema_version: "octon-mission-registry-v1"
active: []
archived: []
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/_scaffold/template/mission.yml" <<'EOF'
schema_version: "octon-mission-v1"
mission_id: "<mission-id>"
title: "Mission: <mission-id>"
summary: ""
status: "created"
owner: null
created_at: "YYYY-MM-DD"
success_criteria: []
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/_scaffold/template/mission.md" <<'EOF'
# Mission
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/_scaffold/template/tasks.json" <<'EOF'
{"schema_version":"octon-mission-tasks-v1","mission_id":"<mission-id>","tasks":[]}
EOF

  cat >"$fixture_root/.octon/instance/orchestration/missions/_scaffold/template/log.md" <<'EOF'
# Mission Log
EOF

  cat >"$fixture_root/.octon/instance/governance/policies/README.md" <<'EOF'
# Policies
EOF
  cat >"$fixture_root/.octon/instance/governance/contracts/README.md" <<'EOF'
# Contracts
EOF
  cat >"$fixture_root/.octon/instance/agency/runtime/README.md" <<'EOF'
# Agency Runtime
EOF
  cat >"$fixture_root/.octon/instance/assurance/runtime/README.md" <<'EOF'
# Assurance Runtime
EOF

  cat >"$fixture_root/.octon/framework/cognition/_meta/architecture/specification.md" <<'EOF'
# Spec
instance/** is canonical.
EOF
  cat >"$fixture_root/.octon/framework/cognition/_meta/architecture/shared-foundation.md" <<'EOF'
# Shared Foundation
instance/** is canonical.
EOF
  cat >"$fixture_root/.octon/framework/orchestration/practices/mission-lifecycle-standards.md" <<'EOF'
# Mission Standards
Use `/.octon/instance/orchestration/missions/registry.yml`.
EOF
  cat >"$fixture_root/.octon/framework/orchestration/_meta/architecture/missions.md" <<'EOF'
# Missions
Use `/.octon/instance/orchestration/missions/`.
EOF
  cat >"$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/update-harness/stages/05-execute.md" <<'EOF'
# Execute
Use `.octon/state/continuity/repo/log.md`.
EOF
  cat >"$fixture_root/.octon/framework/scaffolding/runtime/templates/octon/START.md" <<'EOF'
# Template Start
Check `instance/cognition/context/shared/decisions.md`.
EOF
}

run_validator() {
  local fixture_root="$1"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh" >/dev/null
}

case_valid_fixture_passes() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet4_runtime_scripts "$fixture_root"
  write_valid_packet4_fixture "$fixture_root"

  run_validator "$fixture_root"
}

case_missing_missions_registry_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet4_runtime_scripts "$fixture_root"
  write_valid_packet4_fixture "$fixture_root"

  rm -f "$fixture_root/.octon/instance/orchestration/missions/registry.yml"
  ! run_validator "$fixture_root"
}

case_legacy_context_reference_fails() {
  local fixture_root
  fixture_root="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture_root")
  copy_packet4_runtime_scripts "$fixture_root"
  write_valid_packet4_fixture "$fixture_root"

  cat >"$fixture_root/.octon/instance/bootstrap/START.md" <<'EOF'
# Start
Read `cognition/runtime/context/decisions.md`.
EOF

  ! run_validator "$fixture_root"
}

main() {
  assert_success "repo-instance validator accepts valid packet-4 fixture" case_valid_fixture_passes
  assert_success "repo-instance validator rejects missing mission registry" case_missing_missions_registry_fails
  assert_success "repo-instance validator rejects legacy mixed-path references" case_legacy_context_reference_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
