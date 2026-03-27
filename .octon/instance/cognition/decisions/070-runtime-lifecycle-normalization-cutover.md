# ADR 070: Runtime Lifecycle Normalization Cutover

- Date: 2026-03-27
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-27-runtime-lifecycle-normalization-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-27-runtime-lifecycle-normalization-cutover/`
  - `/.octon/inputs/exploratory/proposals/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`
  - `/.octon/instance/cognition/decisions/069-objective-binding-cutover.md`

## Context

Wave 1 defined run contracts and stage-attempt roots, but primary execution-time
state still depended on a looser mix of run evidence roots, mission-backed
continuity, and orchestration-facing projections.

That left three gaps:

- consequential stages could still reach side effects before the canonical run
  lifecycle files were fully bound
- runtime-state, rollback posture, checkpoints, and replay pointers were not
  yet normalized under one constitutional runtime family
- mission continuity and generated mission views still pointed at generic run
  evidence roots instead of consuming per-run evidence directly

## Decision

Promote Wave 3 as a pre-1.0 transitional cutover.

Rules:

1. `framework/constitution/contracts/runtime/**` is now the constitutional
   runtime-lifecycle contract family.
2. Consequential execution must bind the canonical run control and run evidence
   roots before approval materialization, policy receipts, or other
   consequential side effects occur.
3. Canonical mutable runtime lifecycle state lives under
   `state/control/execution/runs/<run-id>/**`.
4. Canonical retained runtime evidence lives under
   `state/evidence/runs/<run-id>/**`.
5. Mission continuity remains active, but mission continuity and generated
   mission views consume per-run evidence rather than substituting for it.
6. Compatibility root-level run evidence artifacts remain legal only as
   explicit transitional support while the canonical family is backfilled.

## Consequences

### Benefits

- Run roots become the defined execution-time unit of truth for lifecycle
  state, checkpoints, rollback posture, and replay pointers.
- Mission-backed flows remain intact while generated read models start
  consuming per-run evidence directly.
- Docs, validators, and runtime writers agree on the same canonical run-root
  lifecycle families.

### Costs

- Transitional compatibility artifacts remain in place for some existing
  receipt paths.
- More runtime bookkeeping lands under the canonical run roots.
- Some workflow-stage completion flows still need later cleanup before every
  compatibility artifact can be retired.

### Follow-on Work

1. Retire root-level compatibility evidence artifacts once canonical receipts
   and replay families fully replace them.
2. Expand functional checkpoint, resume, and replay workflows beyond the new
   baseline lifecycle files.
3. Continue decommissioning mission-only execution assumptions in later waves.
