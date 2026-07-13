# Containment, Baseline, and Claim Correction

This is the draft RP-00 architecture proposal for
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

## Lifecycle State

- status: `draft`
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- change profile: `atomic`
- release state: `pre-1.0`
- parent program: `octon-architecture-migration-program`
- dependencies: none

The packet is ready for operator reading, not implementation. ROD-006 is
accepted; required proposal review receipts remain unresolved.

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
