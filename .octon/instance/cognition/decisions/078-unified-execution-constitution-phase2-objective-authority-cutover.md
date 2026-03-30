# ADR 078: Unified Execution Constitution Phase 2 Objective And Authority Cutover

- Date: 2026-03-28
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

Phase 1 left Octon with a singular constitutional kernel, but Phase 2 remained
unfinished in the exact places the packet and audit called out:

- workspace authority still resolved through the bootstrap/cognition pair
- canonical approval/grant roots existed but were not populated
- GitHub auto-merge and AI gate behavior still treated labels as operational
  control signals

Without Phase 2, Octon would still describe a target-state authority model
while keeping the old workspace binding and label-gated host behavior in the
live path.

## Decision

Execute Phase 2 as an atomic objective-and-authority cutover.

Rules:

1. `instance/charter/**` becomes the canonical workspace charter pair.
2. The bootstrap/cognition pair remains only as compatibility shims.
3. Canonical approvals, grants, leases, and revocations must exist as real
   artifacts, not empty roots only.
4. GitHub workflows may still project labels and checks, but merge authority
   may not be sourced from those labels.

## Consequences

### Benefits

- Workspace authority is now cleanly instance-owned instead of mis-bounded to
  bootstrap plus cognition.
- Canonical authority artifacts are exercised in the live repo rather than only
  declared in schema.
- GitHub label state becomes projection-only, aligning host behavior with the
  constitutional authority model.

### Costs

- GitHub workflow logic becomes more explicit because it must compute or write
  canonical control artifacts instead of relying on labels.
- Bootstrap and validation surfaces must carry both the new canonical
  `instance/charter/**` path and the old shim pair.

## Completion

This decision is complete once:

- the canonical workspace charter pair lives under `instance/charter/**`
- runtime and run-contract bindings point at the new pair
- canonical approval/grant/lease/revocation artifacts exist and are exercised
- GitHub labels are projection-only rather than merge authority
