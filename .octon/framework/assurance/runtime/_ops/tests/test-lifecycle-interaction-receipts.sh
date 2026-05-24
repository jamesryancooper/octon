#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh"
PROPOSAL_LIFECYCLE="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

main() {
  if bash "$VALIDATOR" --self-test; then
    pass "lifecycle interaction validator self-test covers valid and negative receipts"
  else
    fail "lifecycle interaction validator self-test covers valid and negative receipts"
  fi

  local expected actual
  expected=$'accepted\narchived\ndraft\nimplemented\nin-review\nrejected'
  actual="$(yq -r '.target.allowed_statuses[]' "$PROPOSAL_LIFECYCLE" | LC_ALL=C sort)"
  if [[ "$actual" == "$expected" ]]; then
    pass "proposal lifecycle statuses remain unchanged"
  else
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$actual" >&2
    fail "proposal lifecycle statuses remain unchanged"
  fi

  if yq -e '.lifecycle_interactions.emitted_profiles[] | select(.profile_id == "handoff" and .non_authorizing == true and .target_gate_policy == "target-owned-independent-validation")' "$PROPOSAL_LIFECYCLE" >/dev/null; then
    pass "proposal lifecycle declares non-authorizing handoff profile"
  else
    fail "proposal lifecycle declares non-authorizing handoff profile"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
