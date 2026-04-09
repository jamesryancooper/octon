#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out_root="$(release_root "$release_id")/closure"
mkdir -p "$out_root"
bash "$SCRIPT_DIR/generate-support-target-matrix.sh"
bash "$SCRIPT_DIR/generate-support-universe-coverage.sh" "$release_id"
bash "$SCRIPT_DIR/verify-support-dossier-parity.sh" "$release_id"
bash "$SCRIPT_DIR/verify-lab-reference-integrity.sh" "$release_id"
bash "$SCRIPT_DIR/verify-host-authority-purity.sh" "$release_id"
bash "$SCRIPT_DIR/verify-runtime-family-depth.sh" "$release_id"
bash "$SCRIPT_DIR/verify-continuity-linkage.sh" "$release_id"
bash "$SCRIPT_DIR/verify-retirement-rationale.sh" "$release_id"
bash "$SCRIPT_DIR/verify-release-known-limits.sh" "$release_id"
bash "$SCRIPT_DIR/generate-blocker-ledger.sh"
bash "$SCRIPT_DIR/generate-proof-plane-coverage-report.sh" "$release_id"
bash "$SCRIPT_DIR/generate-cross-artifact-consistency-report.sh" "$release_id"
bash "$SCRIPT_DIR/generate-claim-drift-report.sh" "$release_id"
bash "$SCRIPT_DIR/generate-recertification-status.sh" "$release_id"
gate_status="$out_root/gate-status.yml"
summary="$out_root/closure-summary.yml"
certificate="$out_root/closure-certificate.yml"
gate_failures=0
{
  echo "schema_version: octon-closure-gate-report-v1"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "gates:"
  for pair in \
    "G0:single-canonical-run-contract-family:validate-single-canonical-run-contract-family.sh" \
    "G1:mission-charter-bindings:validate-mission-charter-bindings.sh" \
    "G2:stage-attempt-family:validate-stage-attempt-family.sh" \
    "G3:run-bundle-completeness:validate-run-bundle-completeness.sh" \
    "G4:evidence-classification:validate-evidence-classification-nonempty.sh" \
    "G5:support-tuple-consistency:validate-cross-artifact-support-tuple-consistency.sh" \
    "G5A:support-target-canonicality:../../../scripts/validate-support-target-canonicality.sh" \
    "G6:capability-pack-consistency:validate-cross-artifact-capability-pack-consistency.sh" \
    "G7:route-consistency:validate-cross-artifact-route-consistency.sh" \
    "G7A:run-contract-support-binding:verify-run-contract-support-binding.sh" \
    "G8:quorum-bindings:validate-quorum-policy-bindings.sh" \
    "G9:host-non-authority:validate-host-projection-non-authority.sh" \
    "G9A:canonical-authority-purity:../../../scripts/validate-canonical-authority-purity.sh" \
    "G9B:host-authority-purity:verify-host-authority-purity.sh" \
    "G10:proof-plane-completeness:validate-proof-plane-completeness.sh" \
    "G10A:lab-reference-integrity:verify-lab-reference-integrity.sh" \
    "G11:wording-coherence:validate-disclosure-wording-coherence.sh" \
    "G11A:stage-attempt-disclosure-separation:../../../scripts/validate-stage-attempt-disclosure-separation.sh" \
    "G11B:known-limits-coherence:../../../scripts/validate-known-limits-coherence.sh" \
    "G11C:claim-calibrated-disclosure:../../../scripts/validate-claim-calibrated-disclosure.sh" \
    "G11D:runtime-family-depth:verify-runtime-family-depth.sh" \
    "G11E:continuity-linkage:verify-continuity-linkage.sh" \
    "G12:legacy-active-path:validate-no-legacy-active-path.sh" \
    "G13:retirement-and-drift:validate-retirement-registry.sh" \
    "G13A:retirement-rationale:verify-retirement-rationale.sh" \
    "G14:claim-truth-boundary:validate-claim-truth-boundary.sh" \
    "G15:recertification-discipline:validate-recertification-status.sh" \
    "G16:blocker-ledger-zero:validate-blocker-ledger-zero.sh"; do
    gate_id="${pair%%:*}"
    rest="${pair#*:}"
    title="${rest%%:*}"
    script_name="${rest##*:}"
    status="green"
    bash "$SCRIPT_DIR/$script_name" "$release_id" >/dev/null 2>&1 || status="red"
    [[ "$status" == "green" ]] || gate_failures=$((gate_failures + 1))
    echo "  - gate_id: $gate_id"
    echo "    title: $title"
    echo "    status: $status"
  done
} >"$gate_status"
{
  echo "schema_version: closure-summary-v2"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "claim_status: $( [[ $gate_failures -eq 0 ]] && [[ "$(yq -r '.open_blocker_count' "$(effective_closure_root)/blocker-ledger.yml")" == "0" ]] && echo complete || echo incomplete )"
  echo "support_universe_mode: global-complete-finite"
  echo "preclaim_blockers_open: $(yq -r '.open_blocker_count' "$(effective_closure_root)/blocker-ledger.yml")"
  echo "green_gates:"
  yq -r '.gates[] | select(.status == "green") | .gate_id' "$gate_status" | sed 's/^/  - /'
  echo "blocked_by:"
  yq -r '.gates[] | select(.status != "green") | .gate_id' "$gate_status" | sed 's/^/  - /'
  echo "notes:"
  echo "  - Stable mirrors are generated from the active release bundle only."
  if [[ $gate_failures -gt 0 ]]; then
    echo "  - Full attainment remains blocked until every red gate closes."
  else
    echo "  - The admitted live support universe is evidenced in this release without widening beyond the bounded claim."
  fi
} >"$summary"
{
  echo "schema_version: closure-certificate-v2"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "status: $( [[ $gate_failures -eq 0 ]] && echo certified || echo uncertified )"
  echo "proof_bundle_refs:"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/gate-status.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/closure-summary.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/recertification-status.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/support-universe-coverage.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/proof-plane-coverage.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/cross-artifact-consistency.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/claim-drift-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/residual-ledger.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/disclosure-calibration-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/lab-reference-integrity-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/host-authority-purity-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/runtime-family-depth-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/replay-integrity.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/continuity-linkage-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/contamination-retry-depth-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/support-universe-evidence-depth-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/retirement-rationale-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/ablation-review-report.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/hardening-delta.yml"
  echo "certification_mode: equally-strong-recertification-rule"
  echo "recertification_status_ref: .octon/state/evidence/disclosure/releases/$release_id/closure/recertification-status.yml"
} >"$certificate"
