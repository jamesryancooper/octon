# Proof-State Vocabulary Validation

- proposal_id: `run-health-proof-state-read-models`
- run_id: `20260609T205424Z`
- schema_ref: `.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json`
- validator_ref: `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- fixture_ref: `.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/fixture-set.yml`

## Schema Coverage

The schema requires `authorization.proof_state` and
`authorization.human_boundary_state` on every run-health read model. The enum
values are documented in `operator-read-models-v1.md` and enforced by the
schema and fallback validator.

## Fixture Coverage

The fixture set declares expected proof and human-boundary states for:

- healthy proof
- denied proof
- stale proof
- revoked proof
- approval-required missing proof
- review-required runtime disagreement
- scope-mismatched proof
- contradictory proof
- evidence, rollback, intervention, disclosure, and closure cases

## Negative Controls

The run-health validator records fail-closed negative controls for:

- missing non-authority classification
- authority widening
- source digest drift
- fixture status mismatch
- missing proof state
- approval boundary erasure

The implementation therefore rejects missing proof-state fields and rejects
erasure of typed approval boundaries from authority-ambiguity cases.
