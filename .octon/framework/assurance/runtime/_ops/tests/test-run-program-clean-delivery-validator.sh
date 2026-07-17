#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh"
COMMAND_MANIFEST="$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml"
EXTENSION_MANIFEST="$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml"
PROGRAM_CONTRACT="$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

pass=0
fail=0

ok() { printf '[OK] %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '[ERROR] %s\n' "$1" >&2; fail=$((fail + 1)); }

if bash "$VALIDATOR" >"$TMP_DIR/static.log" 2>&1; then
  ok "containment denial chain is statically healthy"
else
  cat "$TMP_DIR/static.log"
  bad "containment denial chain static validation"
fi

printf 'schema_version: proposal-program-delivery-receipt-v1\nactual_outcome: cleaned\n' >"$TMP_DIR/historical.yml"
if bash "$VALIDATOR" --receipt "$TMP_DIR/historical.yml" >"$TMP_DIR/receipt.log" 2>&1; then
  bad "current clean-delivery receipt unexpectedly certified"
elif grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$TMP_DIR/receipt.log"; then
  ok "current clean-delivery certification fails with stable reason"
else
  cat "$TMP_DIR/receipt.log"
  bad "clean-delivery denial omitted stable reason"
fi

if yq -e '.commands[]? | select(.id == "proposal-program-clean-delivery")' "$COMMAND_MANIFEST" >/dev/null 2>&1; then
  bad "native clean-delivery command remains registered"
else
  ok "native clean-delivery command is unregistered"
fi

if yq -e '.commands[]? | select(.id == "octon-proposal-run-program-clean-delivery")' "$EXTENSION_MANIFEST" >/dev/null 2>&1; then
  bad "additive clean-delivery command remains registered"
else
  ok "additive clean-delivery command is unregistered"
fi

if yq -e '.containment_policy.reason_code == "RP00_CONTAINMENT_PUBLICATION_DISABLED" and .containment_policy.publication_effects_enabled == false and .containment_policy.exact_work_preserved == true' "$PROGRAM_CONTRACT" >/dev/null 2>&1; then
  ok "program lifecycle contract declares containment"
else
  bad "program lifecycle contract containment declaration"
fi

if yq -e '(.delivery_modes[] | select(.mode_id == "proposal-program-delivery") | .supported_outcomes | length) == 2 and (.delivery_modes[] | select(.mode_id == "proposal-program-delivery") | .supported_outcomes[0]) == "implemented" and (.delivery_modes[] | select(.mode_id == "proposal-program-delivery") | .supported_outcomes[1]) == "archive-ready" and (.delivery_modes[] | select(.mode_id == "proposal-program-delivery") | .containment.reject_effectful_or_default_requests) == true' "$PROGRAM_CONTRACT" >/dev/null 2>&1; then
  ok "program delivery admits only contained outcomes"
else
  bad "program delivery outcome containment"
fi

if yq -e '(.lifecycle_interactions.emitted_profiles | length) == 0' "$PROGRAM_CONTRACT" >/dev/null 2>&1; then
  ok "program lifecycle emits no publication or cleanup handoff"
else
  bad "program lifecycle still emits a handoff"
fi

printf 'Test summary: pass=%s fail=%s\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
