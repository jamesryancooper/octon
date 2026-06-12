#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
REVIEW_GATE="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"
ARCH_STANDARD="$ROOT_DIR/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

rg -Fq 'pre-integration-architecture-review' "$REVIEW_GATE" && pass "proposal review gate checks pre-integration architecture review" || fail "proposal review gate checks pre-integration architecture review"
rg -Fq 'validate-architectural-review-receipts.sh' "$REVIEW_GATE" && pass "proposal review gate invokes strict receipt validator" || fail "proposal review gate invokes strict receipt validator"
rg -Fq 'architecture proposal acceptance and implementation authorization require Pre-Integration Architecture Review' "$ARCH_STANDARD" && pass "architecture proposal standard declares mandatory pre-integration review" || fail "architecture proposal standard declares mandatory pre-integration review"

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
