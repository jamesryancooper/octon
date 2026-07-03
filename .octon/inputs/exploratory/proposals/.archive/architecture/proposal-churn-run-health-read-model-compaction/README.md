# Churn Run Health Read Model Compaction

## Target Surfaces

- `.octon/generated/cognition/projections/materialized/runs/**`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`

## Producer Owner

Run-health read-model generator and validator owner.

## Producer Entrypoint Inventory

Before implementation, enumerate the exact generator, validator, tests, and
all consumers that read `.octon/generated/cognition/projections/materialized/runs/**`.
The inventory must identify any consumer that expects one per-run `health.yml`
file before compact indexes or active/recent windows are introduced.

## Current Problem

The latest audit found about 1010 tracked modified files under generated
run-health materialization. The producer appears to materialize one health file
per retained run, so narrow state changes create broad generated churn.

## Intended Efficiency Improvement

Emit compact indexes, write only changed runs, and optionally materialize only
active/recent windows while preserving source traceability for retained runs.

## Guardrails

- Generated health projections remain non-authoritative.
- Freshness and source metadata remain explicit.
- Retained run evidence is not deleted or compacted by this child.
- Test hermeticity remains owned by `run-program-clean-delivery-test-hermeticity`.
- Support, runtime, policy, and closeout claims cannot be satisfied by generated health projections.

## Consumer Compatibility And Migration

Any implementation must provide a compatibility plan for consumers that depend
on per-run materialized health files. If a compact index or active/recent
window changes the output shape, the child must either migrate the consumer or
retain a compatibility projection with an owner, retirement trigger, and
freshness validation.

## Validation Gates

- Run-health generator fixtures for changed-run-only behavior.
- Run-health validator coverage for compact index and materialized windows.
- Consumer compatibility tests for any reader that expects per-run `health.yml`.
- Negative controls proving generated health projections cannot satisfy runtime, policy, support, or closeout authority.
- Post-test `git status --short -- .octon/generated/cognition/projections/materialized/runs`.

## Measurable Success Criteria

- No-op generation produces zero tracked diffs under run-health projections.
- Changed-file count scales with changed runs.
- Operator freshness checks still pass.
- Generated read models remain forbidden as runtime, policy, support, or authority inputs.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate, dirty-worktree residue count, process runtime,
token budget impact, validation coverage retained, and evidence retrieval
integrity for source run evidence references.

## External Dependencies

- `run-program-clean-delivery-test-hermeticity`: consumed for hermetic test
  behavior and proof that validation does not dirty tracked run-health
  generated files. This child must not duplicate or broaden that packet.
