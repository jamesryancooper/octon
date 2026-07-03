#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-run-program-clean-delivery.sh [--receipt <proposal-program-delivery-receipt.yml>]

Without --receipt, validates that the clean-delivery validator chain is present
and statically healthy. With --receipt, also requires a validated
proposal-program-delivery receipt whose actual outcome is cleaned.
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

need_tool yq

run_static_validator() {
  local label="$1" script="$2"
  if bash "$script" >/tmp/octon-clean-delivery-"${label//[^A-Za-z0-9_.-]/_}".log 2>&1; then
    pass "$label static validation passes"
  else
    cat /tmp/octon-clean-delivery-"${label//[^A-Za-z0-9_.-]/_}".log
    fail "$label static validation passes"
  fi
}

require_script() {
  local rel="$1"
  if [[ -x "$ROOT_DIR/$rel" || -f "$ROOT_DIR/$rel" ]]; then
    pass "validator present: $rel"
  else
    fail "validator missing: $rel"
  fi
}

scalar() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
}

abs_path() {
  python3 - "$1" <<'PY'
import pathlib
import sys

print(pathlib.Path(sys.argv[1]).resolve())
PY
}

receipt_root() {
  python3 - "$1" "$ROOT_DIR" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1]).resolve()
fallback = pathlib.Path(sys.argv[2]).resolve()
parts = path.parts
if ".octon" in parts:
    index = parts.index(".octon")
    print(pathlib.Path(*parts[:index]) if index else pathlib.Path("/"))
else:
    print(fallback)
PY
}

resolve_ref() {
  local root="$1" ref="$2"
  if [[ "$ref" == /* ]]; then
    printf '%s\n' "$ref"
  else
    printf '%s/%s\n' "$root" "$ref"
  fi
}

require_receipt_value() {
  local expr="$1" expected="$2" label="$3" value
  value="$(scalar "$expr")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

required_validators=(
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh"
)

for validator in "${required_validators[@]}"; do
  require_script "$validator"
done

run_static_validator "proposal-program-delivery-profile" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
run_static_validator "proposal-program-delivery-receipt" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
run_static_validator "proposal-program-delivery-evidence-index" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
run_static_validator "change-closeout-state-machine" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
run_static_validator "change-closeout-lifecycle-alignment" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
run_static_validator "hosted-no-pr-landing" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
run_static_validator "evidence-disclosure-tiers" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh"

if [[ -n "$RECEIPT_PATH" ]]; then
  if [[ -f "$RECEIPT_PATH" ]]; then
    pass "delivery receipt exists"
  else
    fail "delivery receipt missing: $RECEIPT_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh" --receipt "$RECEIPT_PATH"; then
    pass "delivery receipt validator passes"
  else
    fail "delivery receipt validator passes"
  fi

  require_receipt_value '.actual_outcome' 'cleaned' "actual outcome"
  require_receipt_value '.terminal_current_state_proof.verdict' 'pass' "terminal current-state proof verdict"
  require_receipt_value '.terminal_current_state_proof.fresh_after_last_mutation' 'true' "terminal proof freshness"
  require_receipt_value '.worktree_hygiene.verdict' 'pass' "worktree hygiene verdict"
  require_receipt_value '.worktree_hygiene.dirty_worktree' 'false' "worktree dirty flag"
  require_receipt_value '.final_sync.main_origin_landed_ref_equal' 'true' "main/origin/landed ref equality"
  require_receipt_value '.target_owned_evidence_policy.target_owned_receipts_required' 'true' "target-owned receipts required"
  require_receipt_value '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' 'false' "aggregate receipt replacement"
  require_receipt_value '.delivery_evidence_index.schema_version' 'proposal-program-delivery-evidence-index-v1' "delivery evidence index schema_version"
  require_receipt_value '.delivery_evidence_index.validator_ref' '.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh' "delivery evidence index validator_ref"
  require_receipt_value '.delivery_evidence_index.validator_verdict' 'pass' "delivery evidence index validator verdict"
  require_receipt_value '.delivery_evidence_index.evidence_only' 'true' "delivery evidence index evidence-only"
  require_receipt_value '.delivery_evidence_index.source_receipt_digest_bound' 'true' "delivery evidence index source receipt digest bound"
  require_receipt_value '.delivery_evidence_index.circular_digest_required' 'false' "delivery evidence index circular digest required"

  open_blockers="$(yq -r '[.blockers[]? | select(.status == "open")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$open_blockers" == "0" ]] && pass "cleaned receipt has no open blockers" || fail "cleaned receipt must not have open blockers"

  receipt_abs="$(abs_path "$RECEIPT_PATH")"
  evidence_root="$(receipt_root "$RECEIPT_PATH")"

  if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh" --root "$evidence_root"; then
    pass "evidence disclosure validator passes for delivery evidence root"
  else
    fail "evidence disclosure validator passes for delivery evidence root"
  fi

  index_ref="$(scalar '.delivery_evidence_index.ref')"
  if [[ -n "$index_ref" && "$index_ref" != "null" ]]; then
    pass "delivery evidence index ref declared"
    index_path="$(resolve_ref "$evidence_root" "$index_ref")"
  else
    fail "delivery evidence index ref missing"
    index_path=""
  fi

  if [[ -n "$index_path" && -f "$index_path" ]]; then
    pass "delivery evidence index exists"
  else
    fail "delivery evidence index missing: ${index_path:-<unset>}"
  fi

  if [[ -n "$index_path" && -f "$index_path" ]]; then
    if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh" --root "$evidence_root" --index "$index_path"; then
      pass "delivery evidence index validator passes"
    else
      fail "delivery evidence index validator passes"
    fi

    index_source_ref="$(yq -r '.source_receipt.ref // ""' "$index_path" 2>/dev/null || true)"
    index_source_path="$(resolve_ref "$evidence_root" "$index_source_ref")"
    if [[ -n "$index_source_ref" && "$(abs_path "$index_source_path")" == "$receipt_abs" ]]; then
      pass "delivery evidence index source receipt matches supplied receipt"
    else
      fail "delivery evidence index source receipt must match supplied receipt"
    fi

    index_outcome="$(yq -r '.actual_outcome // ""' "$index_path" 2>/dev/null || true)"
    [[ "$index_outcome" == "cleaned" ]] && pass "delivery evidence index actual outcome is cleaned" || fail "delivery evidence index actual outcome must be cleaned"

    index_target_owned_required="$(yq -r '.target_owned_evidence_policy.target_owned_receipts_required' "$index_path" 2>/dev/null || true)"
    [[ "$index_target_owned_required" == "true" ]] && pass "delivery evidence index requires target-owned receipts" || fail "delivery evidence index must require target-owned receipts"

    index_replacement="$(yq -r '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' "$index_path" 2>/dev/null || true)"
    [[ "$index_replacement" == "false" ]] && pass "delivery evidence index preserves child-owned receipts" || fail "delivery evidence index must not replace child-owned receipts"

    for policy_path in \
      '.evidence_policy.authorizes_delivery' \
      '.evidence_policy.authorizes_archive' \
      '.evidence_policy.authorizes_landing' \
      '.evidence_policy.authorizes_cleanup' \
      '.evidence_policy.satisfies_child_receipts' \
      '.evidence_policy.generated_outputs_are_authority' \
      '.outcome_authority.index_replaces_delivery_receipt' \
      '.outcome_authority.archive_evidence_claims_delivery' \
      '.outcome_authority.child_delivery_claimed_by_archive_only'; do
      policy_value="$(yq -r "$policy_path" "$index_path" 2>/dev/null || true)"
      [[ "$policy_value" == "false" ]] && pass "delivery evidence index denies ${policy_path#.}" || fail "delivery evidence index must deny ${policy_path#.}"
    done
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
