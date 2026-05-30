#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

if [[ "${1:-}" == "--root" ]]; then
  REPO_ROOT="$(cd -- "$2" && pwd)"
  shift 2
fi

TERM="Lifecycle Autopilot"
PROPOSAL_ROOT=".octon/inputs/exploratory/proposals/architecture"
RETIREMENT_GUARDRAILS_PACKET="retired-terminology-guardrails"
MECHANISM_PROGRAM="governed-cross-surface-mechanisms-documentation-architecture"
MECHANISM_VALIDATOR_PACKET="mechanism-index-validator-guards"
errors=0

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  errors=$((errors + 1))
}

pass() {
  printf '[OK] %s\n' "$1"
}

line_is_retirement_context() {
  local text="$1"
  [[ "$text" =~ [Rr]etir|[Cc]ompatib|[Hh]istorical|[Ll]egacy ]]
}

allowed_occurrence() {
  local file="$1" text="$2"
  local mechanism_program_root="$PROPOSAL_ROOT/$MECHANISM_PROGRAM"
  local retirement_packet_root="$PROPOSAL_ROOT/$RETIREMENT_GUARDRAILS_PACKET"
  local validator_packet_root="$PROPOSAL_ROOT/$MECHANISM_VALIDATOR_PACKET"

  if [[ "$file" == "$retirement_packet_root/"* ]]; then
    return 0
  fi
  if [[ "$file" == "$mechanism_program_root/resources/child-packet-index.yml" ]]; then
    return 0
  fi
  if [[ "$file" == "$mechanism_program_root/"* || "$file" == "$validator_packet_root/"* ]]; then
    line_is_retirement_context "$text" && return 0
  fi

  case "$file" in
    .octon/state/evidence/*|.octon/generated/*|.octon/inputs/exploratory/proposals/.archive/*)
      return 0
      ;;
    .octon/framework/product/features/lifecycle-autopilot.md|.octon/framework/product/roadmap/lifecycle-autopilot.md)
      return 0
      ;;
    .octon/framework/assurance/runtime/_ops/scripts/validate-retired-terminology-guardrails.sh|.octon/framework/assurance/runtime/_ops/tests/test-validate-retired-terminology-guardrails.sh)
      return 0
      ;;
  esac
  return 1
}

scan_roots=()
for candidate in .octon .codex .claude .cursor; do
  [[ -e "$REPO_ROOT/$candidate" ]] && scan_roots+=("$candidate")
done

if [[ "${#scan_roots[@]}" -eq 0 ]]; then
  fail "no scan roots found"
else
  while IFS=: read -r file line text; do
    [[ -z "${file:-}" ]] && continue
    if allowed_occurrence "$file" "$text"; then
      continue
    fi
    fail "retired term '$TERM' is not allowed at $file:$line"
  done < <(
    cd "$REPO_ROOT"
    rg -n --fixed-strings "$TERM" "${scan_roots[@]}" \
      -g '!**/target/**' \
      -g '!**/.git/**' || true
  )
fi

if [[ "$errors" -eq 0 ]]; then
  pass "retired terminology guardrails passed"
else
  printf 'Retired terminology guardrails failed with %d error(s).\n' "$errors" >&2
  exit 1
fi
