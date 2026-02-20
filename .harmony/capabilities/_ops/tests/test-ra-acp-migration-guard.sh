#!/usr/bin/env bash
# test-ra-acp-migration-guard.sh - Regression tests for RA+ACP migration guard behavior.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CAPABILITIES_DIR="$(cd "$OPS_DIR/.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"

pass_count=0
fail_count=0

declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -rf "$dir"
  done
  return 0
}
trap cleanup EXIT

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    echo "PASS: $name"
    pass_count=$((pass_count + 1))
  else
    echo "FAIL: $name" >&2
    fail_count=$((fail_count + 1))
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    echo "PASS: $name"
    pass_count=$((pass_count + 1))
    return 0
  fi

  echo "FAIL: $name" >&2
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  fail_count=$((fail_count + 1))
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/ra-acp-guard.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")

  local -a required_files=(
    ".harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh"
    ".harmony/capabilities/_ops/policy/deny-by-default.v2.yml"
    ".harmony/capabilities/_ops/policy/acp-operation-classes.md"
    ".harmony/capabilities/_ops/scripts/policy-receipt-write.sh"
    ".harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh"
    ".harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh"
    ".harmony/capabilities/services/execution/agent/impl/agent.sh"
  )

  local rel
  for rel in "${required_files[@]}"; do
    mkdir -p "$fixture_root/$(dirname "$rel")"
    cp "$REPO_ROOT/$rel" "$fixture_root/$rel"
  done

  (
    cd "$fixture_root"
    git init -q
    git config user.email "guard-test@example.local"
    git config user.name "Guard Test"
    git add .
    git commit -qm "fixture"
  )

  printf '%s\n' "$fixture_root"
}

run_guard_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash ".harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh"
  )
}

case_baseline_passes() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_guard_in_fixture "$fixture_root"
}

case_detects_affirmative_legacy_terms() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"

  mkdir -p "$fixture_root/.harmony/cognition/principles"
  cat > "$fixture_root/.harmony/cognition/principles/deny-by-default.md" <<'EOF'
Legacy governance required human approval at runtime.
All production promotions must be approved before release.
EOF

  run_guard_in_fixture "$fixture_root"
}

case_allows_explicit_negation_terms() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"

  mkdir -p "$fixture_root/.harmony/cognition/principles"
  cat > "$fixture_root/.harmony/cognition/principles/autonomous-control-points.md" <<'EOF'
Promotion does not require standing human approvals.
Agents promote through ACP evidence and quorum rules.
EOF

  run_guard_in_fixture "$fixture_root"
}

case_detects_tracked_temp_artifacts() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"

  mkdir -p "$fixture_root/.harmony/output/reports/.tmp"
  printf 'temp artifact\n' > "$fixture_root/.harmony/output/reports/.tmp/fixture.tmp"
  (
    cd "$fixture_root"
    git add ".harmony/output/reports/.tmp/fixture.tmp"
  )

  run_guard_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "ra-acp migration guard passes on clean fixture" \
    case_baseline_passes

  assert_failure_contains \
    "ra-acp migration guard rejects legacy HITL language" \
    "stale legacy HITL language remains on active .harmony surfaces" \
    case_detects_affirmative_legacy_terms

  assert_success \
    "ra-acp migration guard allows explicit negation language" \
    case_allows_explicit_negation_terms

  assert_failure_contains \
    "ra-acp migration guard rejects tracked temp artifacts" \
    "tracked temp artifacts detected" \
    case_detects_tracked_temp_artifacts

  echo ""
  echo "RA+ACP migration guard tests complete: $pass_count passed, $fail_count failed"

  if (( fail_count > 0 )); then
    exit 1
  else
    exit 0
  fi
}

main "$@"
