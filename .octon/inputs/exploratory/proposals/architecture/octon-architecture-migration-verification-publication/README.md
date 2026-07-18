# Immutable Verification and Adaptive Publication

This is the in-review RP-06 / RWG-06 child of
octon-architecture-migration-program. It is temporary, non-authoritative, and
not implementation or publication authorization.

## Purpose

Create one candidate-immutable exact-SHA verifier and one immutable route
predicate. Deterministically eligible Class B defaults to
`brokered-class-b-no-pr`; valid review-required or stable pre-route
high-contention work uses protected PR. Invalid, stale, revoked, mismatched,
collided, or `UNKNOWN` authority/effects deny or reconcile without PR laundering.

RP-06 also owns history shape, substantive exact-candidate validation,
complete expected-base/head/review PR semantics, `S -> Q` squash-result proof,
independent post-land verification, and hosted-main to local-main mirror
orchestration. RP-08 owns provider-result classification, `UNKNOWN`
reconciliation, and conditional cleanup lifecycle/status.

## Dependencies

- RP-01: canonical authority and exact launch guards
- RP-03: transactional runtime store and attempt identity
- RP-05: sanitized expected-old fast-forward Git primitive

## Separation

The verifier has read and verdict/check-emission authority but no provider
write, merge, release, broker, general signing, content-write, or durable
mutation credential. Its only signing capability is the RP-07-governed,
non-exportable, role-bound evidence-attestation key for its own direct
observations. The publisher consumes a
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

## Corrected Provider And Projection Design

The corrected packet selects a two-job base-owned verifier, distinct Checks and
publisher Apps, an App-bound required check, an ALLGREEN single-entry squash
merge queue, and an RP-01-token-gated `.octon` projection generator. The
42-workflow census freezes every current disposition. These are design choices
only: no workflow, App, secret, ruleset, queue, check, PR, or provider state has
been created or changed.

## Exit

The packet stops at SI-05: sanitized Git plus immutable verification.
Production autonomous Class B remains disabled until RP-07 evidence and RP-08
recovery complete. The generated proposal registry is not edited here.
