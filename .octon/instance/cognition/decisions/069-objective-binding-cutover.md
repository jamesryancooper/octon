# ADR 069: Objective Binding Cutover

- Date: 2026-03-26
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-26-objective-binding-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-26-objective-binding-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`
  - `/.octon/instance/cognition/decisions/063-mission-scoped-reversible-autonomy-atomic-cutover.md`
  - `/.octon/instance/cognition/decisions/067-mission-scoped-reversible-autonomy-final-closeout-cutover.md`
  - `/.octon/instance/cognition/decisions/068-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`

## Context

Wave 0 established the constitutional kernel and reserved the objective
contract family, but Octon still operated with an implicit split:

- the workspace objective pair existed only as bootstrap authority
- mission authority carried both continuity semantics and de facto execution
  identity for long-running autonomy
- no constitutional run-contract family or canonical run-control root existed
  yet under `state/control/execution/runs/**`

That left the repo with no durable constitutional statement that mission is the
continuity container while per-run contracts become the atomic execution unit.

## Decision

Promote Wave 1 as a pre-1.0 transitional cutover.

Rules:

1. The existing workspace objective pair remains active and is ratified as the
   constitutional workspace-charter pair.
2. Mission authority remains under `instance/orchestration/missions/**` and
   continues to own continuity, overlap policy, ownership, and long-horizon
   autonomy.
3. The constitutional objective family is now published under
   `framework/constitution/contracts/objective/**`.
4. Per-run objective binding is defined by `run-contract-v1` under
   `state/control/execution/runs/<run-id>/run-contract.yml`.
5. Stage attempts are subordinate to the bound run root under
   `state/control/execution/runs/<run-id>/stage-attempts/**`.
6. Mission-only execution assumptions are legal only as explicit transitional
   compatibility with retirement metadata.
7. Current mission-backed flows remain valid until a later lifecycle cutover
   moves primary execution-time state to run roots.

## Consequences

### Benefits

- Objective binding now has one constitutional family rather than an implied
  collection of bootstrap and mission surfaces.
- Workspace, mission, and run responsibilities are explicit and validator-backed.
- The repo gains canonical run-control roots without breaking the current
  mission-backed operating path.

### Costs

- Transitional coexistence remains in place until a later runtime lifecycle
  wave completes.
- More authority metadata and validation surfaces are committed.
- Some older orchestration-facing run projections still need later alignment
  with the new constitutional model.

### Follow-on Work

1. Move primary execution-time lifecycle state into run roots during Wave 3.
2. Retire mission-only execution assumptions once run-root lifecycle state is
   complete and backfilled.
3. Align older orchestration-facing run projections to the new source-of-truth
   rules or retire them behind the same cutover.
