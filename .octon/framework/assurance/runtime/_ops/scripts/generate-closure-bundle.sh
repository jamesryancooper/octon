#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out_root="$(release_root "$release_id")/closure"
mkdir -p "$out_root"
bash "$SCRIPT_DIR/generate-support-universe-coverage.sh" "$release_id"
bash "$SCRIPT_DIR/generate-proof-plane-coverage-report.sh" "$release_id"
bash "$SCRIPT_DIR/generate-cross-artifact-consistency-report.sh" "$release_id"
bash "$SCRIPT_DIR/generate-claim-drift-report.sh" "$release_id"
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
    "G6:capability-pack-consistency:validate-cross-artifact-capability-pack-consistency.sh" \
    "G7:route-consistency:validate-cross-artifact-route-consistency.sh" \
    "G8:quorum-bindings:validate-quorum-policy-bindings.sh" \
    "G9:host-non-authority:validate-host-projection-non-authority.sh" \
    "G10:proof-plane-completeness:validate-proof-plane-completeness.sh" \
    "G11:wording-coherence:validate-disclosure-wording-coherence.sh" \
    "G12:legacy-active-path:validate-no-legacy-active-path.sh" \
    "G13:retirement-and-drift:validate-retirement-registry.sh"; do
    gate_id="${pair%%:*}"
    rest="${pair#*:}"
    title="${rest%%:*}"
    script_name="${rest##*:}"
    status="green"
    bash "$SCRIPT_DIR/$script_name" >/dev/null 2>&1 || status="red"
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
  echo "claim_status: $( [[ $gate_failures -eq 0 ]] && echo complete || echo incomplete )"
  echo "support_universe_mode: bounded-admitted-finite"
  echo "preclaim_blockers_open: $gate_failures"
  echo "green_gates:"
  yq -r '.gates[] | select(.status == "green") | .gate_id' "$gate_status" | sed 's/^/  - /'
  echo "notes:"
  echo "  - Stable mirrors are generated from the active release bundle only."
  echo "  - Stage-only surfaces remain explicit and excluded from the live claim."
} >"$summary"
{
  echo "schema_version: closure-certificate-v2"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "status: $( [[ $gate_failures -eq 0 ]] && echo certified || echo uncertified )"
  echo "proof_bundle_refs:"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/gate-status.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/closure-summary.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/support-universe-coverage.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/proof-plane-coverage.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/cross-artifact-consistency.yml"
  echo "  - .octon/state/evidence/disclosure/releases/$release_id/closure/claim-drift-report.yml"
} >"$certificate"
