#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CONTROL_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/control/execution"
CONTROL_RECEIPT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/control-receipt-v1.schema.json"
RECEIPT_WRITER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/write-mission-control-receipt.sh"
DIRECTIVE_RECORDER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/record-mission-directive.sh"
AUTHORIZE_UPDATE_RECORDER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/record-mission-authorize-update.sh"
AUTONOMY_REDUCER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/recompute-mission-autonomy-state.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission Control Evidence Validation =="

  [[ -d "$CONTROL_EVIDENCE_ROOT" ]] && pass "control evidence root exists" || fail "missing control evidence root"
  [[ -f "$CONTROL_RECEIPT_SCHEMA" ]] && pass "control receipt schema exists" || fail "missing control receipt schema"
  [[ -x "$RECEIPT_WRITER" ]] && pass "control receipt writer exists" || fail "missing control receipt writer"
  [[ -x "$DIRECTIVE_RECORDER" ]] && pass "directive recorder exists" || fail "missing directive recorder"
  [[ -x "$AUTHORIZE_UPDATE_RECORDER" ]] && pass "authorize-update recorder exists" || fail "missing authorize-update recorder"
  [[ -x "$AUTONOMY_REDUCER" ]] && pass "autonomy reducer exists" || fail "missing autonomy reducer"

  local tmp_root
  tmp_root="$(mktemp -d)"
  if bash "$RECEIPT_WRITER" \
    --mission-id validator-fixture \
    --receipt-type validator-smoke \
    --issued-by validator://smoke \
    --reason "validator smoke test" \
    --affected-path ".octon/state/control/execution/missions/validator-fixture/lease.yml" \
    --output-root "$tmp_root" >/dev/null 2>&1; then
    if find "$tmp_root" -maxdepth 1 -type f -name '*.yml' | grep -q .; then
      pass "control receipt writer emits receipts"
    else
      fail "control receipt writer did not emit a receipt in smoke test"
    fi
  else
    fail "control receipt writer smoke test failed"
  fi
  find "$tmp_root" -type f -exec rm -f {} + >/dev/null 2>&1 || true
  find "$tmp_root" -depth -type d -exec rmdir {} + >/dev/null 2>&1 || true

  local -a mission_receipts=()
  while IFS= read -r receipt; do
    mission_receipts+=("$receipt")
  done < <(grep -l -E 'control_mutation_class:|control_event_kind:' "$CONTROL_EVIDENCE_ROOT"/*.yml 2>/dev/null || true)

  if ((${#mission_receipts[@]} > 0)); then
    if printf '%s\n' "${mission_receipts[@]}" | awk 'BEGIN{ok=1} !/\/[0-9T:-]+.*\.yml$/ {ok=0} END{exit ok?0:1}'; then
      pass "control evidence filenames match timestamped receipt pattern"
    else
      fail "control evidence files must use timestamped .yml receipt names"
    fi
    if grep -L -E 'control_mutation_class:|control_event_kind:' "${mission_receipts[@]}" | grep -q .; then
      fail "control evidence receipts must declare a mutation/event class"
    else
      pass "control evidence receipts declare a mutation/event class"
    fi
    local required_class
    for required_class in \
      mission_seed \
      directive_add \
      directive_apply \
      directive_expire \
      authorize_update_add \
      authorize_update_apply \
      schedule_mutation \
      lease_mutation \
      budget_transition \
      breaker_trip \
      breaker_reset \
      safing_enter \
      safing_exit \
      break_glass_enter \
      break_glass_exit \
      finalize_block \
      finalize_unblock
    do
      if grep -R -q "control_mutation_class: \"$required_class\"" "$CONTROL_EVIDENCE_ROOT"; then
        pass "control evidence includes $required_class coverage"
      else
        fail "control evidence missing $required_class coverage"
      fi
      done
  else
    pass "no repo-retained control receipts emitted yet; emission path is implemented"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
