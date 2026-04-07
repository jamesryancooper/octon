#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
truth_conditions="$OCTON_DIR/framework/constitution/claim-truth-conditions.yml"
release_card="$(release_root "$release_id")/harness-card.yml"
yq -e '.status_ref == ".octon/generated/effective/closure/claim-status.yml"' "$truth_conditions" >/dev/null
! yq -r '.conditions[].evidence_ref' "$truth_conditions" | rg '^\.octon/instance/governance/closure/' >/dev/null 2>&1
if [[ -f "$release_card" ]]; then
  ! yq -r '.proof_bundle_refs[]' "$release_card" | rg '^\.octon/instance/governance/closure/' >/dev/null 2>&1
  while IFS= read -r ref; do
    [[ "$ref" =~ ^\.octon/state/evidence/disclosure/runs/.+/run-card\.yml$ ]] || continue
    yq -e '.claim_status == "supported"' "$ROOT_DIR/$ref" >/dev/null
  done < <(yq -r '.proof_bundle_refs[]' "$release_card")
fi
