#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
RUNNER="$FRAMEWORK_DIR/engine/runtime/run"
TMP_ROOT="${TMPDIR:-/tmp}/assurance-workflow-tests"

pass_count=0
fail_count=0
declare -a CLEANUP_PATHS=()

cleanup() {
  local path
  for path in "${CLEANUP_PATHS[@]}"; do
    [[ -e "$path" ]] && rm -r "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }
assert_file_exists() { [[ -f "$1" ]]; }
assert_dir_exists() { [[ -d "$1" ]]; }

new_fixture_repo() {
  mkdir -p "$TMP_ROOT"
  local fixture_root
  fixture_root="$(mktemp -d "$TMP_ROOT/proposal-ops.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/assurance/runtime/_ops" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas" \
    "$fixture_root/.octon/framework/engine" \
    "$fixture_root/.octon/framework/capabilities/governance" \
    "$fixture_root/.octon/framework/capabilities/_ops" \
    "$fixture_root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug" \
    "$fixture_root/.octon/generated" \
    "$fixture_root/.octon/instance/cognition/context/shared"
  cp -R "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/"
  cp -R "$REPO_ROOT/.octon/framework/engine/runtime" "$fixture_root/.octon/framework/engine/"
  cp -R "$REPO_ROOT/.octon/framework/capabilities/governance/policy" "$fixture_root/.octon/framework/capabilities/governance/"
  cp -R "$REPO_ROOT/.octon/framework/capabilities/_ops/scripts" "$fixture_root/.octon/framework/capabilities/_ops/"
  cp "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json" \
    "$fixture_root/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
  cp "$REPO_ROOT/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy" \
    "$fixture_root/.octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy"
  cp "$REPO_ROOT/.octon/octon.yml" "$fixture_root/.octon/octon.yml"
  cat >"$fixture_root/.octon/instance/cognition/context/shared/intent.contract.yml" <<'EOF'
intent_id: "intent://test/proposals"
version: "1.0.0"
EOF
  touch "$fixture_root/.octon/README.md"
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
  local status="$2"
  local proposal_dir="$root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal"
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

write_registry_for_active_status() {
  local root="$1"
  local status="$2"
  write_file "$root/.octon/generated/proposals/registry.yml" <<EOF
schema_version: "proposal-registry-v1"
active:
  - id: "fixture-proposal"
    kind: "architecture"
    scope: "octon-internal"
    path: ".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
    title: "Fixture Proposal"
    status: "$status"
    promotion_targets:
      - ".octon/README.md"
archived: []
EOF
}

run_workflow() {
  local fixture_root="$1"
  shift
  (
    cd "$fixture_root"
    "$RUNNER" workflow run "$@"
  )
}

case_validate_passes() {
  local fixture_root output bundle_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "draft"
  write_registry_for_active_status "$fixture_root" "draft"
  output="$(run_workflow "$fixture_root" validate-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
}

case_promote_passes() {
  local fixture_root output bundle_root manifest registry
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "accepted"
  write_registry_for_active_status "$fixture_root" "accepted"
  output="$(run_workflow "$fixture_root" promote-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "promotion_evidence=.octon/README.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  manifest="$fixture_root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal/proposal.yml"
  registry="$fixture_root/.octon/generated/proposals/registry.yml"
  assert_file_exists "$bundle_root/summary.md" || return 1
  [[ "$(yq -r '.status' "$manifest")" == "implemented" ]] || return 1
  grep -Fq 'status: "implemented"' "$registry" || return 1
}

case_promote_rejects_non_accepted_status() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "draft"
  write_registry_for_active_status "$fixture_root" "draft"
  run_workflow "$fixture_root" promote-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "promotion_evidence=.octon/README.md"
}

case_archive_passes() {
  local fixture_root output bundle_root archived_manifest registry
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "implemented"
  write_registry_for_active_status "$fixture_root" "implemented"
  output="$(run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  archived_manifest="$fixture_root/.octon/inputs/exploratory/proposals/.archive/architecture/fixture-proposal/proposal.yml"
  registry="$fixture_root/.octon/generated/proposals/registry.yml"
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$archived_manifest" || return 1
  [[ "$(yq -r '.status' "$archived_manifest")" == "archived" ]] || return 1
  grep -Fq '.archive/architecture/fixture-proposal' "$registry" || return 1
}

case_archive_rejects_non_implemented_disposition() {
  local fixture_root
  fixture_root="$(new_fixture_repo)"
  write_active_architecture_proposal "$fixture_root" "accepted"
  write_registry_for_active_status "$fixture_root" "accepted"
  run_workflow "$fixture_root" archive-proposal --set "proposal_path=.octon/inputs/exploratory/proposals/architecture/fixture-proposal" --set "disposition=implemented" --set "promotion_evidence=.octon/README.md"
}

main() {
  case_validate_passes && pass "validate-proposal workflow validates a proposal and writes bundle receipts" || fail "validate-proposal workflow validates a proposal and writes bundle receipts"
  case_promote_passes && pass "promote-proposal workflow marks an accepted proposal implemented and regenerates registry" || fail "promote-proposal workflow marks an accepted proposal implemented and regenerates registry"
  if ! case_promote_rejects_non_accepted_status >/dev/null 2>&1; then
    pass "promote-proposal rejects proposals that are not accepted"
  else
    fail "promote-proposal rejects proposals that are not accepted"
  fi
  case_archive_passes && pass "archive-proposal workflow archives an implemented proposal and regenerates registry" || fail "archive-proposal workflow archives an implemented proposal and regenerates registry"
  if ! case_archive_rejects_non_implemented_disposition >/dev/null 2>&1; then
    pass "archive-proposal rejects implemented disposition when the proposal is not implemented"
  else
    fail "archive-proposal rejects implemented disposition when the proposal is not implemented"
  fi

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
