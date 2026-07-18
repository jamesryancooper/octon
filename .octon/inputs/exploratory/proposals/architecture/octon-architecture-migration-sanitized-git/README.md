# Sanitized Privileged Git Adapter

This is the in-review RP-05 architecture child of
octon-architecture-migration-program. It is a temporary, non-authoritative
implementation aid. It does not implement, authorize, or promote Git effects.

## Purpose

- logical packet: RP-05
- workgroup: RWG-05
- promotion scope: octon-internal
- change profile: atomic
- release state: pre-1.0
- dependency: RP-04, octon-architecture-migration-local-broker

The packet defines the smallest Git effect primitive that can safely sit
inside the supervised local broker: exact request binding, non-executing
candidate-object transfer, closed Git behavior, pinned repository identity,
and server-observed expected-old fast-forward execution.

The preferred lifecycle term is `brokered-class-b-no-pr`. RP-05 exposes only a
sealed ref-operation family: expected-absent/expected-tip source-ref
create/update, target `O -> S` CAS, conditional expected-tip deletion, and a
fast-forward-only local mirror primitive. Every call is separately bound to an
RP-03 operation/attempt. RP-05 never selects a route, interprets a verdict,
authorizes cleanup, implements PR policy, or becomes a generic Git service.

## Boundary

RP-05 owns no authority issuer, credential enrollment, store transition,
verifier verdict, route policy, support claim, or GitHub workflow. The broker
consumes authority issued elsewhere. RP-06 separately authenticates the exact
candidate and decides no-PR versus protected-PR publication.

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

## Safe Resting Point

The packet advances only from SI-04, a supervised broker with one
non-production effect, to the Git half of SI-05. Until RP-06 verification,
RP-07 evidence, and RP-08 recovery have passed, the adapter may target only
disposable scratch refs. Production publication remains disabled; a protected
PR is available only when RP-06 selected it before effect.

## Exit

Implementation and archival remain blocked until child-owned review,
dependency, proof, conformance, and drift/churn gates pass. The generated
proposal registry is deliberately not edited by this child-authoring task.
