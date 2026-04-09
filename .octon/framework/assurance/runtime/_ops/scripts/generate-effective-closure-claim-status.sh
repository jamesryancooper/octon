#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

release_id="$(resolve_release_id "${1:-}")"
release_root_path="$(release_root "$release_id")"
gate_status="$release_root_path/closure/gate-status.yml"
summary="$release_root_path/closure/closure-summary.yml"
effective_root="$(effective_closure_root)"
effective_status="$effective_root/claim-status.yml"
blocker_ledger="$effective_root/blocker-ledger.yml"
preclaim_blockers="$OCTON_DIR/instance/governance/closure/preclaim-blockers.yml"

mkdir -p "$effective_root"

gate_blocker_count="$(yq -r '[.gates[] | select(.status != "green")] | length' "$gate_status")"
blocker_count="$(yq -r '.open_blocker_count // 0' "$blocker_ledger")"
claim_status="$(yq -r '.claim_status' "$summary")"
if [[ "$claim_status" == "complete" && "$blocker_count" == "0" && "$gate_blocker_count" == "0" ]]; then
  final_verdict="claim_complete"
  ready="true"
else
  final_verdict="preclaim_blocked"
  ready="false"
fi

{
  echo "schema_version: effective-closure-claim-status-v1"
  echo "claim_id: unified-execution-constitution"
  echo "claim_phrase: fully unified execution constitution"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "profile_selection_receipt_ref: $(migration_plan_ref_for_release "$release_id")"
  echo "truth_conditions_ref: .octon/framework/constitution/claim-truth-conditions.yml"
  echo "active_release_refs:"
  echo "  harness_card: .octon/state/evidence/disclosure/releases/$release_id/harness-card.yml"
  echo "  gate_status: .octon/state/evidence/disclosure/releases/$release_id/closure/gate-status.yml"
  echo "  closure_summary: .octon/state/evidence/disclosure/releases/$release_id/closure/closure-summary.yml"
  echo "  closure_certificate: .octon/state/evidence/disclosure/releases/$release_id/closure/closure-certificate.yml"
  echo "  recertification_status: .octon/state/evidence/disclosure/releases/$release_id/closure/recertification-status.yml"
  echo "  support_universe_coverage: .octon/state/evidence/disclosure/releases/$release_id/closure/support-universe-coverage.yml"
  echo "  proof_plane_coverage: .octon/state/evidence/disclosure/releases/$release_id/closure/proof-plane-coverage.yml"
  echo "  cross_artifact_consistency: .octon/state/evidence/disclosure/releases/$release_id/closure/cross-artifact-consistency.yml"
  echo "summary:"
  echo "  claim_status: $claim_status"
  echo "  final_verdict: $final_verdict"
  echo "  blocker_count: $blocker_count"
  echo "  ready_for_final_completion_claim: $ready"
  echo "  support_universe_mode: global-complete-finite"
  echo "  claim_scope: admitted-live-support-universe"
  echo "  blocked_by:"
  yq -r '.blocked_by[]' "$summary" 2>/dev/null | sed 's/^/    - /'
  if [[ "$blocker_count" != "0" ]]; then
    yq -r '.open_blockers[].blocker_id' "$blocker_ledger" 2>/dev/null | sed 's/^/    - blocker-/'
  fi
  echo "blockers:"
  while IFS=$'\t' read -r gate_id title; do
    [[ -n "$gate_id" ]] || continue
    ac="AC-unknown"
    blocker_id="closure-blocker-${gate_id,,}"
    reason="This gate remains red and continues to block the full-attainment claim."
    evidence_ref=".octon/state/evidence/disclosure/releases/$release_id/closure/gate-status.yml"
    case "$gate_id" in
      G13)
        ac="AC-11"
        blocker_id="closure-blocker-build-to-delete-open"
        reason="Retirement and build-to-delete governance is still active, so the full-attainment claim cannot be made honestly."
        evidence_ref=".octon/instance/governance/contracts/retirement-registry.yml"
        ;;
      G14)
        ac="AC-1"
        blocker_id="closure-blocker-truth-boundary"
        reason="Claim truth is still depending on an untrusted boundary and must not be treated as full attainment."
        evidence_ref=".octon/framework/constitution/claim-truth-conditions.yml"
        ;;
    esac
    echo "  - blocker_id: $blocker_id"
    echo "    gate_id: $gate_id"
    echo "    acceptance_criterion: $ac"
    echo "    title: $title"
    echo "    status: open"
    echo "    reason: >-"
    printf '      %s\n' "$reason"
    echo "    evidence_ref: $evidence_ref"
  done < <(
    while IFS= read -r gate_id; do
      [[ -n "$gate_id" ]] || continue
      title="$(yq -r ".gates[] | select(.gate_id == \"$gate_id\") | .title" "$gate_status")"
      printf '%s\t%s\n' "$gate_id" "$title"
    done < <(yq -r '.blocked_by[]' "$summary" 2>/dev/null)
  )
  if [[ "$blocker_count" != "0" ]]; then
    yq -P '.open_blockers' "$blocker_ledger" | sed 's/^/  /'
  fi
} >"$effective_status"

{
  echo "schema_version: preclaim-blockers-v1"
  echo "updated_at: \"$(deterministic_generated_at)\""
  echo "summary:"
  echo "  open_count: $blocker_count"
  echo "  closure_ready: $( [[ "$blocker_count" == "0" && "$gate_blocker_count" == "0" ]] && echo true || echo false )"
  if [[ "$blocker_count" == "0" ]]; then
    echo "blockers: []"
  else
    echo "blockers:"
    yq -P '.blockers' "$effective_status" | sed 's/^/  /'
  fi
} >"$preclaim_blockers"
