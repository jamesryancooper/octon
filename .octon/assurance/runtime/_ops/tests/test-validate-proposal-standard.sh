#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
VALIDATE_SCRIPT=".octon/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"

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

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-standard.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/assurance/runtime/_ops/scripts"
  cp "$REPO_ROOT/.octon/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
    "$fixture_root/.octon/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  printf '%s\n' "$fixture_root"
}

create_shared_id_registry_fixture() {
  local fixture_root="$1"
  local proposal_dir="$fixture_root/.proposals/policy/shared-id"
  mkdir -p "$proposal_dir"

  cat >"$proposal_dir/proposal.yml" <<'EOF'
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

  cat >"$fixture_root/.proposals/registry.yml" <<'EOF'
schema_version: "proposal-registry-v1"
active:
  - id: "shared-id"
    kind: "migration"
    scope: "repo-local"
    path: ".proposals/migration/shared-id"
    title: "Shared Migration"
    status: "draft"
    promotion_targets:
      - "docs/migration.md"
  - id: "shared-id"
    kind: "policy"
    scope: "repo-local"
    path: ".proposals/policy/shared-id"
    title: "Shared Policy"
    status: "draft"
    promotion_targets:
      - "docs/policy.md"
archived: []
EOF
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
  create_shared_id_registry_fixture "$fixture_root"
  run_validator_in_fixture "$fixture_root" ".proposals/policy/shared-id"
}

main() {
  assert_success \
    "proposal standard validator resolves registry entries by kind and id" \
    case_registry_lookup_uses_kind_and_id

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
