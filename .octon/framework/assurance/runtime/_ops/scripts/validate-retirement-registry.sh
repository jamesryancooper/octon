#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

GATE="$OCTON_DIR/instance/governance/retirement/claim-gate.yml"
REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
REVIEW_SET="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
TODAY="${RETIREMENT_REVIEW_DATE_OVERRIDE:-$(date -u +%F)}"

fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing ${1#$ROOT_DIR/}"
}

require_status() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 || fail "$label"
}

main() {
  require_file "$GATE"
  require_file "$REGISTRY"
  require_file "$REVIEW_SET"

  current_review_ref="$(yq -r '.current_governance_review_ref // ""' "$GATE")"
  latest_packet_ref="$(yq -r '.latest_review_packet // ""' "$REVIEW_SET")"
  [[ -n "$current_review_ref" && "$current_review_ref" != "null" ]] || fail "retirement claim gate does not publish current_governance_review_ref"
  [[ -n "$latest_packet_ref" && "$latest_packet_ref" != "null" ]] || fail "closeout reviews contract does not publish latest_review_packet"

  current_review="$ROOT_DIR/$current_review_ref"
  latest_packet="$ROOT_DIR/$latest_packet_ref"
  drift_review="$latest_packet/drift-review.yml"
  support_target_review="$latest_packet/support-target-review.yml"
  adapter_review="$latest_packet/adapter-review.yml"
  retirement_review="$latest_packet/retirement-review.yml"
  ablation_receipt="$latest_packet/ablation-deletion-receipt.yml"

  require_file "$current_review"
  require_file "$drift_review"
  require_file "$support_target_review"
  require_file "$adapter_review"
  require_file "$retirement_review"
  require_file "$ablation_receipt"

  require_status "$drift_review" '.status == "approved"' "drift review is not approved"
  require_status "$support_target_review" '.status == "approved"' "support-target review is not approved"
  require_status "$adapter_review" '.status == "approved"' "adapter review is not approved"
  require_status "$retirement_review" '.status == "approved"' "retirement review is not approved"
  require_status "$ablation_receipt" '.status == "completed"' "ablation receipt is not completed"
  require_status "$current_review" '.claim_ready == true and .claim_blocking_count == 0' "governance retirement claim review reports open blockers"

  while IFS=$'\t' read -r target_id status review_date; do
    [[ -n "$target_id" ]] || continue
    owner_ref="$(yq -r ".entries[] | select(.target_id == \"$target_id\") | .owner_ref // \"\"" "$REGISTRY")"
    retirement_path="$(yq -r ".entries[] | select(.target_id == \"$target_id\") | .retirement_path // \"\"" "$REGISTRY")"
    trigger_count="$(yq -r ".entries[] | select(.target_id == \"$target_id\") | (.retirement_trigger // []) | length" "$REGISTRY")"
    ablation_count="$(yq -r ".entries[] | select(.target_id == \"$target_id\") | (.required_ablation_suite // []) | length" "$REGISTRY")"
    evidence_count="$(yq -r ".entries[] | select(.target_id == \"$target_id\") | (.evidence_requirements // []) | length" "$REGISTRY")"

    [[ -n "$owner_ref" ]] || fail "$target_id is missing owner_ref"
    [[ -n "$review_date" && "$review_date" != "null" ]] || fail "$target_id is missing review_date"
    [[ -n "$retirement_path" ]] || fail "$target_id is missing retirement_path"
    [[ "$trigger_count" != "0" ]] || fail "$target_id has no retirement_trigger"
    [[ "$ablation_count" != "0" ]] || fail "$target_id has no required_ablation_suite"
    [[ "$evidence_count" != "0" ]] || fail "$target_id has no evidence_requirements"

    if [[ "$review_date" < "$TODAY" ]]; then
      fail "$target_id is overdue on review_date $review_date"
    fi

    yq -e ".nonblocking_statuses[] | select(. == \"$status\")" "$GATE" >/dev/null 2>&1 \
      || fail "$target_id has claim-blocking status $status"

    yq -e ".entries[] | select(.target_id == \"$target_id\" and .claim_blocking == false)" "$current_review" >/dev/null 2>&1 \
      || fail "$target_id is missing a nonblocking governance review entry"

    yq -e ".targets_evaluated[] | select(.target_id == \"$target_id\")" "$ablation_receipt" >/dev/null 2>&1 \
      || fail "$target_id is missing from the current ablation receipt"
  done < <(yq -r '.entries[] | select(.status != "retired") | [.target_id, .status, .review_date] | @tsv' "$REGISTRY")
}

main "$@"
