# Cutover Checklist

## Pre-cutover

- [ ] Confirm remediation branch is not weakening constitutional invariants.
- [ ] Confirm proposal packet is non-authoritative and excluded from runtime/policy resolution.
- [ ] Inventory active topology statements in README, specification, bootstrap, ingress, manifests, and support docs.
- [ ] Inventory material execution path families.
- [ ] Inventory evidence roots and current evidence producers.
- [ ] Inventory support-target admissions and dossiers.
- [ ] Inventory generated/effective publication paths.
- [ ] Inventory promotion/publication paths from inputs/generated.

## Registry cutover

- [ ] Expand `contract-registry.yml`.
- [ ] Register class roots and path families.
- [ ] Register validators and generated doc targets.
- [ ] Generate or registry-check active docs.
- [ ] Run `validate-architecture-contract-registry.sh`.
- [ ] Retain registry validation evidence.

## Authorization coverage cutover

- [ ] Create `authorization-boundary-coverage-v1.md`.
- [ ] Map every material path to authorization binding.
- [ ] Add negative bypass tests.
- [ ] Run coverage validator in report mode.
- [ ] Fix missing paths.
- [ ] Enable validator as fail-closed gate.
- [ ] Retain coverage evidence.

## Authority engine cutover

- [ ] Extract modules.
- [ ] Preserve API compatibility.
- [ ] Add fixture tests.
- [ ] Reduce or remove monolithic implementation.
- [ ] Run runtime tests.
- [ ] Retain module coverage evidence.

## Evidence-store cutover

- [ ] Create evidence-store schema/spec.
- [ ] Distinguish CI transport from retained evidence.
- [ ] Add evidence completeness validator.
- [ ] Run sample allow/stage/deny/closeout fixtures.
- [ ] Enable evidence completeness for consequential closeout.
- [ ] Retain conformance evidence.

## Promotion cutover

- [ ] Create promotion receipt schema/policy.
- [ ] Replace direct project-finding publication language.
- [ ] Add promotion validator.
- [ ] Retain promotion receipt examples.
- [ ] Enable fail-closed behavior for missing receipts.

## Support-target proofing cutover

- [ ] Define support proof bundle schema.
- [ ] Add per-tuple proof bundle requirements.
- [ ] Validate existing admitted tuples.
- [ ] Regenerate support-target matrix.
- [ ] Retain support proof evidence.

## Operator read-model cutover

- [ ] Define operator-read-model contract.
- [ ] Generate mission/run/grant/evidence/support/readiness views.
- [ ] Add trace metadata.
- [ ] Validate generated views are non-authoritative.
- [ ] Expose CLI/TUI/Studio read-only views.

## Documentation simplification

- [ ] Move historical wave/cutover content to decision records or migration evidence.
- [ ] Keep active docs steady-state-first.
- [ ] Remove duplicated topology truth after generated replacements pass.

## Final signoff

- [ ] All validators pass locally.
- [ ] All validators pass in CI.
- [ ] All required decision records are present.
- [ ] Closure evidence retained.
- [ ] Proposal packet archived.
- [ ] Final architecture score re-evaluation records target-state-grade status.
