# Containment, Baseline, and Claim Correction

This is the accepted RP-00 architecture proposal for
`octon-architecture-migration-containment`. It is a temporary,
non-authoritative implementation aid. It does not authorize or perform the
architecture migration.

## Purpose

Create the safe, observable, and truthful SI-00 resting state before any later
packet performs privileged implementation. RP-00 removes unsafe autonomous
routes from the admitted path, inventories every physical trust-sensitive
surface, narrows claims to direct proof, and captures the current maintenance
burden. It does not build the target broker, store, isolation, publication, or
trust-activation mechanisms.

Containment has no autonomous production publication bridge. It disables
candidate-head privileged writers, every Octon `direct-main` route, current
checkout-held no-PR effects, and destructive cleanup of unlanded work. Eligible
no-PR work remains classified, blocked, and preserved. Protected PR is available
only when an independent immutable predicate selected review and its writer
boundary has itself been proved safe; the current `pull_request_target` workflow
is not presumed to satisfy that condition.

## Lifecycle State

- status: `accepted`
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- change profile: `atomic`
- release state: `pre-1.0`
- parent program: `octon-architecture-migration-program`
- dependencies: none

The packet is ready for digest-bound implementation prompt generation, not
itself implemented. ROD-006 is bound, and the proposal and pre-integration
architecture reviews pass at the accepted-state digest. Acceptance performs no
provider, publication, promotion, support-claim, or durable-target effect.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `architecture/current-state-gap-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`
9. `architecture/validation-plan.md`
10. `architecture/cutover-plan.md`
11. `architecture/rollback-and-recovery.md`
12. `architecture/operator-disclosure.md`
13. `resources/traceability.yml`
14. `support/implementation-grade-completeness-review.md`
15. `support/pre-integration-architecture-review.yml`
16. `support/proposal-review.md`

## Promotion Boundary

All promotion targets are under `.octon/**`. `.github/**` files are affected
host projections and provider configuration is affected external state; neither
is an `octon-internal` promotion target. Any later evidence that a durable
authored target outside `.octon/**` is required blocks implementation and
routes to a target-family split rather than widening this packet.

## Exit Path

After acceptance, RP-00 must reach SI-00 with direct retained proof, pass
conformance and drift/churn review, and promote its durable targets before it
can close. Until then, later packets may be designed, but none may perform a
privileged change.
