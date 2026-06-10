# Implementation Run

verdict: pass
run_id: 20260609T205424Z
implemented_at: 2026-06-09T20:54:24Z
promotion_evidence_count: 17
proposal_id: run-health-proof-state-read-models
lifecycle_skill: octon-proposal-lifecycle-run-packet-implementation
implementation_profile: atomic
package_status_after_run: accepted
durable_evidence_root: .octon/state/evidence/validation/proposals/run-health-proof-state-read-models/20260609T205424Z/

## Implemented Changes

This run promoted the accepted architecture packet into durable run-health
read-model specification, generation, validation, fixture, and generated
projection surfaces without marking generated projections as authority.

- Added `authorization.proof_state` and
  `authorization.human_boundary_state` as required fields in the run-health
  read-model schema.
- Documented proof-first authorization vocabulary and typed human-boundary
  reporting in the operator read-model contract.
- Updated `generate-run-health-read-model.sh` to derive proof validity,
  missing proof, failed proof, stale proof, contradictory proof, and
  proof-scope mismatch separately from human-boundary states.
- Reclassified legacy generic approval-required reporting into
  `proof-missing` plus `approval-required`, surfaced as
  `authority-ambiguity`.
- Added fail-closed generator diagnostics for proof-scope mismatch and
  contradictory proof.
- Strengthened `validate-run-health-read-model.sh` to require proof-state and
  human-boundary fields and to reject boundary erasure through negative
  controls.
- Expanded fixture coverage with expected proof and human-boundary states,
  including scope-mismatch and contradictory-proof cases.
- Regenerated materialized run-health projections and the compact manifest
  through `generate-run-health-read-model.sh --all-runs`.

## Promotion Targets Covered

All proposal promotion targets were covered:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

Additional fixture coverage under
`.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/` was
updated to prove the validator and generator behavior for the promoted
surfaces.

## Exclusions

Authority-engine grant semantics, mission runtime dispatch, connector
authorization, workflow classification, proposal lifecycle status, generated
effective prompt projections, host/provider state, branch state, and PR state
were not changed. Generated run-health files remain generated-only
observational projections.

## Rollback Posture

Rollback is file-scoped: revert the schema, operator contract, generator,
validator, fixture, and regenerated run-health projection changes, then rerun
`generate-run-health-read-model.sh --all-runs` and
`validate-run-health-read-model.sh` from the reverted source state. Evidence
created solely for a failed attempt can be retired from the proposal evidence
root without changing durable authority.
