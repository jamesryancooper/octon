# Validation Plan

## Proposal packet validation

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-target-state-transition`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-target-state-transition`
- `generate-proposal-registry.sh --check` after adding the packet to the live repo

## Structural validation

- `validate-architecture-conformance.sh`
- `validate-architecture-contract-registry.sh`
- `validate-active-doc-hygiene.sh`
- `validate-bootstrap-ingress.sh`
- `validate-operator-boot-surface.sh`

## Runtime validation

- `validate-runtime-resolution.sh`
- `validate-runtime-effective-route-bundle.sh`
- `validate-material-side-effect-inventory.sh`
- `validate-authorization-boundary-coverage.sh`
- `validate-run-lifecycle-transition-coverage.sh`
- `test-authorization-boundary-negative-controls.sh`
- `test-runtime-effective-freshness-hard-gate.sh`

## Publication validation

- `validate-publication-freshness-gates.sh`
- `validate-generated-effective-freshness.sh`
- `validate-capability-publication-state.sh`
- `validate-extension-publication-state.sh`
- `validate-generated-non-authority.sh`

## Support and pack validation

- `validate-support-target-path-normalization.sh`
- `validate-support-target-proofing.sh`
- `validate-support-pack-admission-alignment.sh`
- `test-support-pack-no-widening.sh`

## Extension validation

- `validate-extension-active-state-compactness.sh`
- `validate-extension-publication-state.sh`
- `validate-extension-pack-contract.sh`
- `test-extension-quarantine-hard-gate.sh`

## Evidence and proof validation

- `validate-evidence-completeness.sh`
- `validate-proof-plane-completeness.sh`
- `validate-claim-truth-boundary.sh`
- `validate-claim-surface-generated-only.sh`
- `validate-disclosure-live-roots.sh`

## Aggregate gate

- `octon doctor --architecture`
- `validate-architecture-health.sh`

A 10/10 closure claim is invalid unless every validation group above passes and retained evidence is
written outside this proposal packet.
