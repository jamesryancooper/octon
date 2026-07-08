#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

assert_retrieval_metrics() {
  local index="$1"
  python3 - "$index" <<'PY'
import json
import pathlib
import sys

index = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
metrics = index.get("retrieval_metrics") or {}
if metrics.get("metric_authority") != "evidence-only":
    raise SystemExit("retrieval metrics are not evidence-only")
if metrics.get("indexed_ref_count", 0) <= 0:
    raise SystemExit("indexed_ref_count is missing or empty")
if metrics.get("terminal_evidence_ref_count", 0) <= 0:
    raise SystemExit("terminal_evidence_ref_count is missing or empty")
PY
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

make_child_fixture() {
  local root="$1"
  local package="${2:-.octon/inputs/exploratory/proposals/architecture/test-child}"
  local implementation_run_verdict="${3-pass}"
  local package_status="${4:-implemented}"
  mkdir -p "$root/$package/support" "$root/$package/navigation" "$root/$package/architecture"
  local proposal_lines=(
    'schema_version: "proposal-v1"' \
    'proposal_id: "test-child"' \
    'title: "Test Child"' \
    'summary: "Fixture child."' \
    'proposal_kind: "architecture"' \
    'promotion_scope: "octon-internal"' \
    'promotion_targets:' \
    '  - ".octon/framework/test-child.md"' \
    "status: \"$package_status\"" \
  )
  if [[ "$package_status" == "archived" ]]; then
    proposal_lines+=(
      'archive:'
      '  archived_at: "2026-06-18"'
      '  archived_from_status: "implemented"'
      '  disposition: "implemented"'
      '  original_path: ".octon/inputs/exploratory/proposals/architecture/test-child"'
      '  promotion_evidence:'
      '    - ".octon/framework/test-child.md"'
    )
  fi
  proposal_lines+=(
    'change_profile: "atomic"' \
    'lifecycle:' \
    '  temporary: true' \
    '  exit_expectation: "Fixture."'
  )
  write_file "$root/$package/proposal.yml" \
    "${proposal_lines[@]}"
  write_file "$root/$package/support/proposal-review.md" \
    "# Proposal Review Receipt" \
    "verdict: accepted" \
    "implementation_prompt_authorized: yes" \
    "open_blocking_findings_count: 0"
  write_file "$root/$package/support/implementation-run.md" \
    "# Implementation Run" \
    "verdict: $implementation_run_verdict"
  write_file "$root/$package/support/implementation-conformance-review.md" \
    "# Implementation Conformance Review" \
    "verdict: pass"
  write_file "$root/$package/support/post-implementation-drift-churn-review.md" \
    "# Post-Implementation Drift Churn Review" \
    "verdict: pass"
  write_file "$root/$package/support/validation.md" \
    "# Validation" \
    "verdict: pass"
  write_file "$root/$package/support/pre-integration-architecture-review.yml" \
    'schema_version: "architectural-review-support-receipt-v1"' \
    'verdict: "pass"'
  write_file "$root/$package/support/executable-implementation-prompt.md" \
    "# Executable Implementation Prompt"
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  local valid_root="$tmp/valid"
  make_child_fixture "$valid_root" ".octon/inputs/exploratory/proposals/architecture/test-child" pass implemented
  assert_success "valid implemented packet materializes an index" \
    bash "$GENERATOR" \
      --root "$valid_root" \
      --package ".octon/inputs/exploratory/proposals/architecture/test-child" \
      --run-id "test-child-retained-index" \
      --generated-at "2026-06-18T00:00:00Z" \
      --write
  assert_success "materialized retained index validates" \
    bash "$VALIDATOR" \
      --root "$valid_root" \
      --index ".octon/state/evidence/runs/test-child-retained-index/retained-run-evidence-index.yml"
  assert_success "materialized retained index reports retrieval metrics" \
    assert_retrieval_metrics "$valid_root/.octon/state/evidence/runs/test-child-retained-index/retained-run-evidence-index.yml"

  local archived_root="$tmp/archived"
  make_child_fixture "$archived_root" ".octon/inputs/exploratory/proposals/.archive/architecture/test-child" pass archived
  assert_success "valid archived implemented packet materializes an index" \
    bash "$GENERATOR" \
      --root "$archived_root" \
      --package ".octon/inputs/exploratory/proposals/.archive/architecture/test-child" \
      --run-id "test-child-archived-retained-index" \
      --generated-at "2026-06-18T00:00:00Z" \
      --write
  assert_success "materialized archived retained index validates" \
    bash "$VALIDATOR" \
      --root "$archived_root" \
      --index ".octon/state/evidence/runs/test-child-archived-retained-index/retained-run-evidence-index.yml"

  local missing_verdict_root="$tmp/missing-verdict"
  make_child_fixture "$missing_verdict_root" ".octon/inputs/exploratory/proposals/architecture/test-child" "" implemented
  assert_failure "implementation run without verdict pass fails closed" \
    bash "$GENERATOR" \
      --root "$missing_verdict_root" \
      --package ".octon/inputs/exploratory/proposals/architecture/test-child" \
      --run-id "test-child-missing-verdict" \
      --generated-at "2026-06-18T00:00:00Z" \
      --write

  local stale_root="$tmp/stale"
  make_child_fixture "$stale_root" ".octon/inputs/exploratory/proposals/architecture/test-child" pass implemented
  bash "$GENERATOR" \
    --root "$stale_root" \
    --package ".octon/inputs/exploratory/proposals/architecture/test-child" \
    --run-id "test-child-stale-source" \
    --generated-at "2026-06-18T00:00:00Z" \
    --write >/dev/null
  printf 'tampered: true\n' >>"$stale_root/.octon/inputs/exploratory/proposals/architecture/test-child/support/validation.md"
  assert_failure "source digest drift fails retained index validation" \
    bash "$VALIDATOR" \
      --root "$stale_root" \
      --index ".octon/state/evidence/runs/test-child-stale-source/retained-run-evidence-index.yml"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
