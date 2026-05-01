#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

main() {
  if rg -n 'do not become Octon authority|do not become authority|must not claim authority|never become Octon authority' "$PACK_ROOT" >/dev/null; then
    pass "non-authority boundary language is present"
  else
    fail "non-authority boundary language is missing"
  fi

  if rg -n 'support/correction-prompts|support/program-correction-prompts|support/custom-closeout-prompt|resources/source-context' "$PACK_ROOT/prompts" "$PACK_ROOT/context" >/dev/null; then
    pass "packet support artifact placement is documented"
  else
    fail "packet support artifact placement is missing"
  fi

  if rg -n 'GitHub.*do not become|comments.*do not become|labels.*do not become|CI.*do not become' "$PACK_ROOT" >/dev/null; then
    pass "GitHub and CI boundary is documented"
  else
    fail "GitHub and CI boundary is missing"
  fi

  if rg -n '\.octon/inputs/exploratory/proposals/<kind>/<program-proposal-id>/children' "$PACK_ROOT"; then
    pass "invalid nested child path is explicitly documented"
  else
    fail "invalid nested child path is not documented"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
