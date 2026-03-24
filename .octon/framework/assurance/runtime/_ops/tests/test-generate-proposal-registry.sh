#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
GENERATE_SCRIPT=".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"

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
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-registry.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"
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

write_active_architecture_proposal() {
  local root="$1"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture"

  write_file "$proposal_dir/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "fixture-proposal"
title: "Fixture Proposal"
summary: "Architecture fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/README.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF

  write_file "$proposal_dir/README.md" <<'EOF'
# Fixture Proposal
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Plan
EOF
  write_file "$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Proposal

- `proposal_id`: `fixture-proposal`
- `proposal_kind`: `architecture`
- `proposal_path`: `.octon/inputs/exploratory/proposals/architecture/fixture-proposal`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Generated inventory entry |
| `proposal.yml` | Generated inventory entry |
| `architecture-proposal.yml` | Generated inventory entry |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Generated inventory entry |
| `architecture/target-architecture.md` | Generated inventory entry |
| `architecture/acceptance-criteria.md` | Generated inventory entry |
| `architecture/implementation-plan.md` | Generated inventory entry |
EOF
}

write_archived_architecture_proposal() {
  local root="$1"
  local archived_from_status="$2"
  local status="$3"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-proposal"
  mkdir -p "$proposal_dir/navigation" "$proposal_dir/architecture"

  write_file "$proposal_dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "fixture-proposal"
title: "Fixture Proposal"
summary: "Architecture fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/README.md"
status: "$status"
archive:
  archived_at: "2026-03-24"
  archived_from_status: "$archived_from_status"
  disposition: "implemented"
  original_path: ".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  promotion_evidence:
    - ".octon/README.md"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF

  write_file "$proposal_dir/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF

  write_file "$proposal_dir/README.md" <<'EOF'
# Fixture Proposal
EOF
  write_file "$proposal_dir/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF
  write_file "$proposal_dir/architecture/target-architecture.md" <<'EOF'
# Target
EOF
  write_file "$proposal_dir/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance
EOF
  write_file "$proposal_dir/architecture/implementation-plan.md" <<'EOF'
# Plan
EOF
  write_file "$proposal_dir/navigation/artifact-catalog.md" <<'EOF'
# Artifact Catalog

## Proposal

- `proposal_id`: `fixture-proposal`
- `proposal_kind`: `architecture`
- `proposal_path`: `.octon/inputs/exploratory/proposals/.archive/architecture/fixture-proposal`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Generated inventory entry |
| `proposal.yml` | Generated inventory entry |
| `architecture-proposal.yml` | Generated inventory entry |
| `navigation/artifact-catalog.md` | Generated inventory entry |
| `navigation/source-of-truth-map.md` | Generated inventory entry |
| `architecture/target-architecture.md` | Generated inventory entry |
| `architecture/acceptance-criteria.md` | Generated inventory entry |
| `architecture/implementation-plan.md` | Generated inventory entry |
EOF
}

run_generator_in_fixture() {
  local fixture_root="$1"
  shift
  (
    cd "$fixture_root"
    bash "$GENERATE_SCRIPT" "$@"
  )
}

case_check_passes_for_valid_projection() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p "$fixture_root/.octon/generated"
  touch "$fixture_root/.octon/README.md"
  write_active_architecture_proposal "$fixture_root"
  run_generator_in_fixture "$fixture_root" --write >/dev/null
  run_generator_in_fixture "$fixture_root" --check
}

case_check_fails_on_orphaned_registry_entry() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p "$fixture_root/.octon/generated"
  touch "$fixture_root/.octon/README.md"
  write_active_architecture_proposal "$fixture_root"
  run_generator_in_fixture "$fixture_root" --write >/dev/null
  printf '\n  - id: "manual-only"\n    kind: "architecture"\n    scope: "octon-internal"\n    path: ".octon/inputs/exploratory/proposals/architecture/manual-only"\n    title: "Manual Only"\n    status: "draft"\n    promotion_targets:\n      - ".octon/README.md"\n' >>"$fixture_root/.octon/generated/proposals/registry.yml"
  run_generator_in_fixture "$fixture_root" --check
}

case_check_fails_on_invalid_archive_lineage() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p "$fixture_root/.octon/generated"
  touch "$fixture_root/.octon/README.md"
  write_archived_architecture_proposal "$fixture_root" "proposed" "archived"
  run_generator_in_fixture "$fixture_root" --check
}

case_check_fails_on_archive_path_status_mismatch() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  mkdir -p "$fixture_root/.octon/generated"
  touch "$fixture_root/.octon/README.md"
  write_archived_architecture_proposal "$fixture_root" "accepted" "accepted"
  run_generator_in_fixture "$fixture_root" --check
}

main() {
  assert_success \
    "proposal registry generator reproduces a valid committed projection" \
    case_check_passes_for_valid_projection
  assert_failure_contains \
    "proposal registry generator rejects orphaned manual entries" \
    "proposal registry matches generated projection" \
    case_check_fails_on_orphaned_registry_entry
  assert_failure_contains \
    "proposal registry generator rejects invalid archive lineage" \
    "archived_from_status valid" \
    case_check_fails_on_invalid_archive_lineage
  assert_failure_contains \
    "proposal registry generator rejects archive path and status mismatches" \
    "active proposals stay in active paths" \
    case_check_fails_on_archive_path_status_mismatch

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
