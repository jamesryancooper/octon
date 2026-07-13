# Immutable Verification and Adaptive Publication

This is the draft RP-06 / RWG-06 child of
octon-architecture-migration-program. It is temporary, non-authoritative, and
not implementation or publication authorization.

## Purpose

Create one candidate-immutable exact-SHA verifier and one immutable route
predicate. Eligible Class B uses RP-05's exact broker Git primitive; valid work
requiring review uses protected PR; invalid, stale, revoked, raced, or
wrong-scope authority denies and cannot be laundered through PR.

## Dependencies

- RP-01: canonical authority and exact launch guards
- RP-03: transactional runtime store and attempt identity
- RP-05: sanitized expected-old fast-forward Git primitive

## Separation

The verifier has read and verdict/check-emission authority but no merge,
content-write, or durable mutation credential. The publisher consumes a
verdict and broker authorization but cannot issue or alter a verdict. Context
name alone is never verifier identity.

## Reading Order

1. proposal.yml
2. architecture-proposal.yml
3. navigation/source-of-truth-map.md
4. resources/packet-contract.yml
5. architecture/target-architecture.md
6. architecture/current-state-gap-map.md
7. architecture/acceptance-criteria.md
8. architecture/implementation-plan.md
9. architecture/file-change-map.md
10. architecture/validation-plan.md
11. architecture/cutover-plan.md
12. architecture/rollback-and-recovery.md
13. architecture/operator-experience-and-disclosure.md
14. resources/traceability.yml
15. support/implementation-grade-completeness-review.md

## Target-Family Blocker

Current live inventories identify .github/workflows/pr-auto-merge.yml as a
protected-CI side-effect owner, and reconciliation requires disposition of
candidate writer/verifier workflows. This octon-internal packet cannot target
.github/**. Workflow projection work remains blocked until an accepted
authored .octon source or generator owns those projections and can refresh them
with receipts. No unlisted child or mixed target is authorized.

## Exit

The packet stops at SI-05: sanitized Git plus immutable verification.
Production autonomous Class B remains disabled until RP-07 evidence and RP-08
recovery complete. The generated proposal registry is not edited here.
