#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    if [[ -f "$path" ]]; then
      rm -f -- "$path"
    elif [[ -d "$path" ]]; then
      rm -rf -- "$path"
    fi
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then fail "$label"; else pass "$label"; fi
}

fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-terminal-freshness-root.XXXXXX")"
cleanup_paths+=("$fixture_root")
proposal_rel=".octon/inputs/exploratory/proposals/architecture/terminal-freshness-fixture"
proposal_dir="$fixture_root/$proposal_rel"
mkdir -p "$proposal_dir"
cat >"$proposal_dir/proposal.yml" <<'YAML'
schema_version: proposal-v1
proposal_id: terminal-freshness-fixture
title: Terminal Freshness Fixture
proposal_kind: architecture
promotion_scope: octon-internal
release_state: pre-1.0
change_profile: atomic
promotion_targets: []
status: draft
owner:
  role: Octon test fixture
created_date: "2026-06-12"
YAML
cat >"$proposal_dir/architecture-proposal.yml" <<'YAML'
schema_version: architecture-proposal-v1
proposal_id: terminal-freshness-fixture
architecture_decision: test fixture
YAML

bash "$GENERATOR" --root "$fixture_root" --proposal "$proposal_rel" --write >/dev/null

children_file="$(mktemp "${TMPDIR:-/tmp}/octon-terminal-freshness-children.XXXXXX")"
cleanup_paths+=("$children_file")
printf '%s\n' "$proposal_rel" >"$children_file"

assert_success "terminal freshness validates scoped packet" "$VALIDATOR" --root "$fixture_root" --proposal "$proposal_rel"
assert_failure "scoped child validation without registry freshness fails" "$VALIDATOR" --root "$fixture_root" --proposal "$proposal_rel" --children-file "$children_file"
assert_failure "missing proposal fails terminal freshness" "$VALIDATOR" --root "$fixture_root" --proposal ".octon/inputs/exploratory/proposals/architecture/missing-terminal-freshness-fixture"

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
