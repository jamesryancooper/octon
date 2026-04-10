#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CLOSEOUT="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
ABLATION="$ROOT_DIR/.octon/state/evidence/disclosure/releases/2026-04-09-uec-bounded-hardening-closure/closure/ablation-review-report.yml"
EXPECTED_PACKET=".octon/state/evidence/validation/publication/build-to-delete/2026-04-09-bounded-uec-hardening"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Review Packet Freshness Validation =="
latest="$(yq -r '.latest_review_packet' "$CLOSEOUT")"
[[ "$latest" == "$EXPECTED_PACKET" ]] && pass "closeout reviews point at the fresh bounded hardening packet" || fail "closeout reviews still point at stale review packet"

ablation_ref="$(yq -r '.review_packet_ref' "$ABLATION")"
[[ "$ablation_ref" == "$EXPECTED_PACKET" ]] && pass "ablation review report points at the fresh bounded hardening packet" || fail "ablation review report does not point at the fresh packet"

[[ -d "$ROOT_DIR/$EXPECTED_PACKET" ]] && pass "fresh review packet directory exists" || fail "fresh review packet directory missing"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
