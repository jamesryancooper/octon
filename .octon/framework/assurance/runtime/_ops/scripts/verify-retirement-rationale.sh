#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
report_path="$(closure_report_path "$release_id" "retirement-rationale-report.yml")"
ablation_path="$(closure_report_path "$release_id" "ablation-review-report.yml")"
mkdir -p "$(dirname "$report_path")"

errors=0
entries_checked=0
latest_packet="$(yq -r '.latest_review_packet // ""' "$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml")"

while IFS= read -r _; do
  entries_checked=$((entries_checked + 1))
done < <(yq -r '.entries[].surface' "$RETIREMENT_DISCLOSURE_PATH")

for expr in \
  '.entries[] | select((.status // "") == "" or (.disposition // "") == "" or (.rationale // "") == "" or (.review_artifact_ref // "") == "" or (.next_review_due // "") == "")' \
  '.entries[] | select(.claim_adjacent == true and .status == "retained_with_rationale" and ((.paths // []) | length == 0))'; do
  if yq -e "$expr" "$RETIREMENT_DISCLOSURE_PATH" >/dev/null 2>&1; then
    errors=$((errors + 1))
  fi
done

for file in drift-review.yml support-target-review.yml adapter-review.yml retirement-review.yml ablation-deletion-receipt.yml; do
  [[ -f "$ROOT_DIR/$latest_packet/$file" ]] || errors=$((errors + 1))
done

{
  echo "schema_version: octon-retirement-rationale-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$errors" == "0" ]] && echo pass || echo fail )"
  echo "summary:"
  echo "  entries_checked: $entries_checked"
  echo "  unresolved_entries: $errors"
  echo "  latest_review_packet: $latest_packet"
} >"$report_path"

{
  echo "schema_version: octon-ablation-review-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$errors" == "0" ]] && echo pass || echo fail )"
  echo "review_packet_ref: $latest_packet"
  echo "required_receipts:"
  echo "  - $latest_packet/drift-review.yml"
  echo "  - $latest_packet/support-target-review.yml"
  echo "  - $latest_packet/adapter-review.yml"
  echo "  - $latest_packet/retirement-review.yml"
  echo "  - $latest_packet/ablation-deletion-receipt.yml"
} >"$ablation_path"

[[ "$errors" == "0" ]]
