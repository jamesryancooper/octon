#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
EXT="$ROOT_DIR/.octon/inputs/additive/extensions/octon-concept-integration"
METHOD="$EXT/prompts/shared/architecture-review-method.md"
CONTRACT="$EXT/prompts/shared/architecture-revision-contract.md"
ROUTING="$EXT/context/routing.contract.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$METHOD" ]] && pass "extension architecture-review method reference exists" || fail "extension architecture-review method reference exists"
[[ -f "$CONTRACT" ]] && pass "extension architecture revision contract exists" || fail "extension architecture revision contract exists"
[[ -f "$ROUTING" ]] && pass "extension routing contract exists" || fail "extension routing contract exists"

if [[ -f "$METHOD" ]]; then
  rg -Fq '/.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md' "$METHOD" && pass "extension method points to native doctrine" || fail "extension method points to native doctrine"
  rg -Fq 'packetization reference only' "$METHOD" && pass "extension method declares packetization-only role" || fail "extension method declares packetization-only role"
  rg -Fq 'Extension outputs are non-authoritative inputs' "$METHOD" && pass "extension method preserves non-authority boundary" || fail "extension method preserves non-authority boundary"
fi

if [[ -f "$CONTRACT" ]]; then
  rg -Fq '/.octon/framework/cognition/practices/methodology/architectural-review/' "$CONTRACT" && pass "revision contract references native review doctrine" || fail "revision contract references native review doctrine"
  rg -Fq 'does not satisfy native proposal lifecycle acceptance' "$CONTRACT" && pass "revision contract blocks lifecycle-gate substitution" || fail "revision contract blocks lifecycle-gate substitution"
fi

if [[ -f "$ROUTING" ]]; then
  yq -e '.dispatchers[]?.routes[]? | select(.route_id == "architecture-revision-packet")' "$ROUTING" >/dev/null 2>&1 && pass "Architecture Revision Packet route remains extension-owned" || fail "Architecture Revision Packet route remains extension-owned"
fi

if rg -n 'audit-architecture-readiness' "$EXT" >/tmp/architectural-review-extension-legacy.txt 2>/dev/null; then
  cat /tmp/architectural-review-extension-legacy.txt >&2
  fail "extension contains no legacy architecture-readiness alias"
else
  pass "extension contains no legacy architecture-readiness alias"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
