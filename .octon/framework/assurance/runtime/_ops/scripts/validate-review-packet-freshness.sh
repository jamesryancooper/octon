#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CLOSEOUT="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
ABLATION="$ROOT_DIR/.octon/state/evidence/disclosure/releases/2026-04-09-uec-bounded-hardening-closure/closure/ablation-review-report.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Review Packet Freshness Validation =="
latest="$(yq -r '.latest_review_packet' "$CLOSEOUT")"
if [[ "$latest" =~ ^\.octon/state/evidence/validation/publication/build-to-delete/[0-9]{4}-[0-9]{2}-[0-9]{2}([-/][A-Za-z0-9._-]+)?$ ]]; then
  pass "closeout reviews publish a canonical latest review packet"
else
  fail "closeout reviews latest review packet is not canonical"
fi

if [[ -d "$ROOT_DIR/${latest#./}" ]]; then
  pass "latest review packet directory exists"
else
  fail "latest review packet directory missing"
fi

ablation_ref="$(yq -r '.review_packet_ref' "$ABLATION")"
if [[ "$ablation_ref" =~ ^\.octon/state/evidence/validation/publication/build-to-delete/[0-9]{4}-[0-9]{2}-[0-9]{2}([-/][A-Za-z0-9._-]+)?$ && -d "$ROOT_DIR/${ablation_ref#./}" ]]; then
  pass "ablation review report points at a retained build-to-delete packet"
else
  fail "ablation review report does not point at a retained build-to-delete packet"
fi

if [[ "$ablation_ref" == "$latest" ]]; then
  pass "ablation review report matches the latest packet"
else
  pass "ablation review report remains a retained historical packet"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
