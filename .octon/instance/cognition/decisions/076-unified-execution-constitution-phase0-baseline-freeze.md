# ADR 076: Unified Execution Constitution Phase 0 Baseline Freeze

- Date: 2026-03-28
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/plan.md`
  - `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/`
  - `/.octon/state/evidence/lab/harness-cards/hc-phase0-unified-execution-constitution-baseline-v0-20260328.yml`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

The governing packet defines Phase 0 as a baseline freeze that must:

- produce a baseline internal HarnessCard v0
- inventory live authority, runtime, proof, and evidence surfaces
- freeze the core constitutional inputs needed for Phase 1 extraction

The live repository is already materially beyond the packet's original Phase 0
baseline. It already contains a constitutional kernel, active authority and
runtime contract families, retained run evidence, lab evidence, support-target
declarations, and host/model adapter manifests. Without a durable Phase 0
receipt outside the proposal workspace, later extraction, retirement, and
target-state review work would have to infer baseline facts from scattered live
surfaces and the packet audit instead of one canonical retained bundle.

## Decision

Record Phase 0 as a retrospective baseline freeze against the live repository
state rather than attempting to reconstruct a historical pre-cutover snapshot.

Rules:

1. The Phase 0 inventory must live in canonical migration evidence under
   `/.octon/state/evidence/migration/**`, not in the proposal workspace.
2. The frozen-input manifest must preserve the core constitutional,
   ingress-binding, and still-live interpretive inputs with SHA-256 digests.
3. The baseline HarnessCard v0 must remain explicitly internal and bounded; it
   does not authorize a final unified-execution-constitution claim.
4. The migration and ADR must be discoverable through the canonical cognition
   indexes.

## Consequences

### Benefits

- Phase 1 extraction work now has one durable baseline packet outside
  `inputs/**`.
- Reviewers can inspect the live authority/runtime/proof/evidence baseline and
  frozen inputs without reconstructing repo state manually.
- The retained baseline HarnessCard makes the Phase 0 disclosure requirement
  concrete while keeping the claim tightly bounded.

### Costs

- The Phase 0 record is intentionally retrospective, so it documents a repo
  that already contains later-phase surfaces.
- Later waves must keep the baseline readable as lineage even after the
  inventoried blockers are removed.

## Completion

This decision is complete once:

- the migration plan, ADR, and evidence bundle are registered in canonical
  indexes
- the frozen-input manifest includes the selected live constitutional inputs
  and digests
- the baseline internal HarnessCard v0 exists under retained lab evidence
