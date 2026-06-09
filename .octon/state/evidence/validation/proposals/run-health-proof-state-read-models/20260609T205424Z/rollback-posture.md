# Rollback Posture

- proposal_id: `run-health-proof-state-read-models`
- run_id: `20260609T205424Z`
- rollback_scope: schema, operator contract, generator, validator, fixture, and generated run-health projection changes

## Revert Set

Rollback is bounded to the touched run-health surfaces:

- `.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/fixture-set.yml`
- `.octon/generated/cognition/projections/materialized/runs/**`
- `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/generation.yml`

## Recovery Steps

1. Revert the durable schema, spec, generator, validator, and fixture edits.
2. Rerun `generate-run-health-read-model.sh --all-runs` from the reverted
   source state.
3. Rerun `validate-run-health-read-model.sh` and touched proposal validators.
4. Retire proposal-specific evidence created solely for the failed attempt.

## Safety Boundary

Generated projections remain non-authoritative during rollback. A reverted or
stale projection set cannot authorize execution, widen support, satisfy
retained evidence gates, or become dispatch control truth.
