#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
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

assert_failure_contains() {
  local name="$1" needle="$2"
  shift 2
  local output="" rc=0
  output="$("$@" 2>&1)" || rc=$?
  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi
  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-standard.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
  printf '%s\n' "$fixture_root"
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  cat >"$path"
}

write_policy_proposal() {
  local root="$1"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/policy/shared-id"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/policy"

  write_file "$proposal_dir/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "shared-id"
title: "Shared Policy"
summary: "Policy fixture."
proposal_kind: "policy"
promotion_scope: "repo-local"
promotion_targets:
  - "docs/policy.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/policy-proposal.yml" <<'EOF'
schema_version: "policy-proposal-v1"
policy_area: "proposal-governance"
change_type: "policy-update"
EOF

  write_file "$proposal_dir/README.md" <<'EOF'
# Shared Policy
EOF

  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF

  write_file "$proposal_dir/policy/decision.md" <<'EOF'
# Decision
EOF

  write_file "$proposal_dir/policy/policy-delta.md" <<'EOF'
# Delta
EOF

  write_file "$proposal_dir/policy/enforcement-plan.md" <<'EOF'
# Enforcement
EOF

  write_file "$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Proposal

- `proposal_id`: `shared-id`
- `proposal_kind`: `policy`
- `proposal_path`: `.octon/inputs/exploratory/proposals/policy/shared-id`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Generated inventory entry |
| `proposal.yml` | Generated inventory entry |
| `policy-proposal.yml` | Generated inventory entry |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Generated inventory entry |
| `policy/decision.md` | Generated inventory entry |
| `policy/policy-delta.md` | Generated inventory entry |
| `policy/enforcement-plan.md` | Generated inventory entry |
EOF
}

write_migration_proposal() {
  local root="$1"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/migration/shared-id"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/migration"

  write_file "$proposal_dir/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "shared-id"
title: "Shared Migration"
summary: "Migration fixture."
proposal_kind: "migration"
promotion_scope: "repo-local"
promotion_targets:
  - "docs/migration.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/migration-proposal.yml" <<'EOF'
schema_version: "migration-proposal-v1"
change_profile: "atomic"
release_state: "pre-1.0"
EOF

  write_file "$proposal_dir/README.md" <<'EOF'
# Shared Migration
EOF

  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF

  write_file "$proposal_dir/migration/plan.md" <<'EOF'
# Plan
EOF

  write_file "$proposal_dir/migration/release-notes.md" <<'EOF'
# Release Notes
EOF

  write_file "$proposal_dir/migration/rollback.md" <<'EOF'
# Rollback
EOF

  write_file "$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Proposal

- `proposal_id`: `shared-id`
- `proposal_kind`: `migration`
- `proposal_path`: `.octon/inputs/exploratory/proposals/migration/shared-id`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Generated inventory entry |
| `proposal.yml` | Generated inventory entry |
| `migration-proposal.yml` | Generated inventory entry |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Generated inventory entry |
| `migration/plan.md` | Generated inventory entry |
| `migration/release-notes.md` | Generated inventory entry |
| `migration/rollback.md` | Generated inventory entry |
EOF
}

write_registry() {
  local root="$1"
  write_file "$root/.octon/generated/proposals/registry.yml" <<'EOF'
schema_version: "proposal-registry-v1"

active:
  - id: "shared-id"
    kind: "migration"
    scope: "repo-local"
    path: ".octon/inputs/exploratory/proposals/migration/shared-id"
    title: "Shared Migration"
    status: "draft"
    promotion_targets:
      - "docs/migration.md"
  - id: "shared-id"
    kind: "policy"
    scope: "repo-local"
    path: ".octon/inputs/exploratory/proposals/policy/shared-id"
    title: "Shared Policy"
    status: "draft"
    promotion_targets:
      - "docs/policy.md"
archived: []
EOF
}

create_valid_fixture() {
  local fixture_root="$1"
  write_policy_proposal "$fixture_root"
  write_migration_proposal "$fixture_root"
  write_registry "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  local proposal_path="$2"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT" --package "$proposal_path"
  )
}

case_registry_lookup_uses_kind_and_id() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_valid_fixture "$fixture_root"
  run_validator_in_fixture "$fixture_root" ".octon/inputs/exploratory/proposals/policy/shared-id"
}

case_absolute_package_path_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_valid_fixture "$fixture_root"
  run_validator_in_fixture "$fixture_root" "$fixture_root/.octon/inputs/exploratory/proposals/policy/shared-id"
}

case_top_level_exit_expectation_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_valid_fixture "$fixture_root"
  printf '\nexit_expectation: "bad-root-field"\n' >>"$fixture_root/.octon/inputs/exploratory/proposals/policy/shared-id/proposal.yml"
  run_validator_in_fixture "$fixture_root" ".octon/inputs/exploratory/proposals/policy/shared-id"
}

case_artifact_catalog_drift_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  create_valid_fixture "$fixture_root"
  python3 - "$fixture_root/.octon/inputs/exploratory/proposals/policy/shared-id/navigation/artifact-catalog.md" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
path.write_text(path.read_text() + "| `policy/nonexistent.md` | Generated inventory entry |\n")
PY
  run_validator_in_fixture "$fixture_root" ".octon/inputs/exploratory/proposals/policy/shared-id"
}

main() {
  assert_success \
    "proposal standard validator accepts the same proposal_id across different kinds" \
    case_registry_lookup_uses_kind_and_id
  assert_success \
    "proposal standard validator accepts absolute package paths" \
    case_absolute_package_path_passes
  assert_failure_contains \
    "proposal standard validator rejects top-level exit_expectation" \
    "top-level exit_expectation is forbidden" \
    case_top_level_exit_expectation_fails
  assert_failure_contains \
    "proposal standard validator rejects stale artifact-catalog inventory" \
    "artifact catalog references only on-disk files" \
    case_artifact_catalog_drift_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
