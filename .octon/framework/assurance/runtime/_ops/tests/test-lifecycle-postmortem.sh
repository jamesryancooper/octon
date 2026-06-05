#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/lifecycle-postmortem"

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

positive_passes() {
  bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/positive/evaluation.yml" \
    --report "$FIXTURE_ROOT/positive/report.md" \
    --review-findings "$FIXTURE_ROOT/positive/review-findings.ndjson" >/dev/null
}

negative_structured_fails() {
  local case_id="$1"
  ! bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/negative/$case_id/evaluation.yml" >/dev/null 2>&1
}

negative_report_fails() {
  local case_id="$1"
  ! bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/positive/evaluation.yml" \
    --report "$FIXTURE_ROOT/negative/$case_id/report.md" >/dev/null 2>&1
}

main() {
  assert_success "positive lifecycle postmortem fixture passes" positive_passes
  assert_success "generated authority fixture fails" negative_structured_fails generated-authority
  assert_success "raw input authority fixture fails" negative_structured_fails raw-input-authority
  assert_success "unresolved evidence ref fixture fails" negative_structured_fails unresolved-ref
  assert_success "invalid final judgment fixture fails" negative_structured_fails invalid-final-judgment
  assert_success "missing patch-versus-redesign report fixture fails" negative_report_fails missing-patch-redesign
  assert_success "missing invariant compliance fixture fails" negative_structured_fails missing-invariant-compliance
  assert_success "Unknown-as-Pass fixture fails" negative_structured_fails unknown-as-pass
  assert_success "missing invariant evidence gap fixture fails" negative_structured_fails missing-invariant-gap
  assert_success "missing blocking correction fixture fails" negative_structured_fails missing-blocking-correction
  assert_success "missing invariant validity/evolution fixture fails" negative_structured_fails missing-invariant-validity-evolution
  assert_success "invalid invariant recommendation category fixture fails" negative_structured_fails invalid-recommendation-category
  assert_success "missing invariant required change fixture fails" negative_structured_fails missing-required-change
  assert_success "weak invariant change-control bar fixture fails" negative_structured_fails weak-change-control-bar
  assert_success "invariant change approved fixture fails" negative_structured_fails invariant-change-approved

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
