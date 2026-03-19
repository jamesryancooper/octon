#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd "$OCTON_DIR/.." && pwd)"
RUNNER="$OCTON_DIR/engine/runtime/run"
TMP_ROOT="$ROOT_DIR/.octon/generated/.tmp/assurance-workflow-tests"

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

new_fixture_proposal() {
  mkdir -p "$TMP_ROOT"
  local fixture_root proposal_root
  fixture_root="$(mktemp -d "$TMP_ROOT/audit-architecture-proposal.XXXXXX")"
  CLEANUP_PATHS+=("$fixture_root")
  proposal_root="$fixture_root/.octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  mkdir -p "$proposal_root/navigation" "$proposal_root/architecture"
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops"
  cp -R "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/"
  cat >"$proposal_root/README.md" <<'EOF'
# Fixture Architecture Proposal
EOF
  cat >"$proposal_root/proposal.yml" <<'EOF'
schema_version: "proposal-v1"
proposal_id: "fixture-proposal"
title: "Fixture Architecture Proposal"
summary: "Fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/example.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$proposal_root/architecture-proposal.yml" <<'EOF'
schema_version: "architecture-proposal-v1"
architecture_scope: "repo-architecture"
decision_type: "boundary-change"
EOF
  cat >"$proposal_root/navigation/artifact-catalog.md" <<'EOF'
# Catalog
EOF
  cat >"$proposal_root/navigation/source-of-truth-map.md" <<'EOF'
# Sources
EOF
  cat >"$proposal_root/architecture/target-architecture.md" <<'EOF'
# Target Architecture
EOF
  cat >"$proposal_root/architecture/acceptance-criteria.md" <<'EOF'
# Acceptance Criteria
EOF
  cat >"$proposal_root/architecture/implementation-plan.md" <<'EOF'
# Implementation Plan
EOF
  mkdir -p "$fixture_root/.octon"
  cat >"$fixture_root/.octon/generated/proposals/registry.yml" <<'EOF'
schema_version: "proposal-registry-v1"
active:
  - id: "fixture-proposal"
    kind: "architecture"
    scope: "octon-internal"
    path: ".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
    title: "Fixture Architecture Proposal"
    status: "draft"
    promotion_targets:
      - ".octon/example.md"
archived: []
EOF
  mkdir -p "$fixture_root/.octon"
  printf '%s\n' "$fixture_root"
}

case_audit_passes() {
  local fixture_root fixture_rel output bundle_root summary_report
  fixture_root="$(new_fixture_proposal)"
  fixture_rel=".octon/inputs/exploratory/proposals/architecture/fixture-proposal"
  output="$(cd "$fixture_root" && "$RUNNER" workflow run audit-architecture-proposal --set "proposal_path=$fixture_rel")"
  bundle_root="$(printf '%s\n' "$output" | sed -n 's/^bundle_root: //p' | tail -n 1)"
  summary_report="$(printf '%s\n' "$output" | sed -n 's/^summary_report: //p' | tail -n 1)"
  assert_dir_exists "$bundle_root" || return 1
  assert_file_exists "$summary_report" || return 1
  assert_file_exists "$bundle_root/bundle.yml" || return 1
  assert_file_exists "$bundle_root/summary.md" || return 1
  assert_file_exists "$bundle_root/commands.md" || return 1
  assert_file_exists "$bundle_root/inventory.md" || return 1
  assert_file_exists "$bundle_root/validation.md" || return 1
  assert_file_exists "$bundle_root/standard-validator.log" || return 1
}

main() {
  case_audit_passes && pass "audit-architecture-proposal validates a architecture proposal and writes bundle receipts" || fail "audit-architecture-proposal validates a architecture proposal and writes bundle receipts"
  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
