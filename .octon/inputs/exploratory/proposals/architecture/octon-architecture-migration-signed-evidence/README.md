# Signed Bounded Evidence, Capacity, and Retention

This is the in-review RP-07 architecture proposal for
`octon-architecture-migration-signed-evidence`. It is a temporary,
non-authoritative implementation aid. It does not authorize implementation,
key creation, provider access, effect execution, publication, support
promotion, or evidence deletion.

## Outcome

Octon gains one bounded local evidence plane whose proof cannot be rewritten by
the candidate it evaluates:

- broker and verifier identities sign their own direct observations;
- signed range and terminal checkpoints bind ordered observations, prior head,
  key epoch, pins, completeness, and terminal outcome;
- a candidate-inaccessible compare-and-advance head rejects rechains, forks,
  and restoration of an older otherwise-valid snapshot;
- RP-03's transaction reserves logical terminal capacity while RP-07 supplies
  a fault-proven physical reserve for denial, failure, revocation, rollback,
  and closeout records; and
- quotas, pins, and verify-checkpoint-anchor-delete compaction bound raw local
  evidence while only minimal signed checkpoints and pointers are eligible for
  project Git.

There is no unsigned fallback, no Git-as-signature substitute, no standalone
capacity lease service, and no second evidence control plane.

## Program Position

- logical packet: `RP-07`
- workgroup: `RWG-07`
- parent program: `octon-architecture-migration-program`
- dependencies: RP-03 transactional runtime store, RP-04 local broker, and
  RP-06 verification/publication
- downstream consumer: RP-08 recovery and complete Class B vertical

RP-03 owns the SQLite/WAL store schema, operation transitions, `runtime_bus`,
and frozen outbox/capacity API. RP-07 consumes that interface and owns evidence
envelopes, signed checkpoints, monotonic-head behavior, physical reserve,
retention, compaction, and minimal projection rules. RP-04 and RP-06 retain
broker and verifier behavior outside the exact evidence integration modules.

## Promotion Scope

The proposal is `octon-internal`; every promotion target is under
`.octon/**`. Raw payloads remain bounded operator-local evidence outside
project Git. Git may retain a signed checkpoint or pointer, but history alone
never authenticates a direct observation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `resources/traceability.yml`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/file-change-map.md`
9. `architecture/cutover-plan.md`
10. `architecture/rollback-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `architecture/implementation-plan.md`
14. `architecture/operator-disclosure.md`
15. `support/implementation-grade-completeness-review.md`

## Current Gate

The packet is `in-review`. Structural validation does not make it accepted or
implementation-ready. ROD-001 is operator-accepted; binding its invariants and
recording/proving conservative reversible engineering defaults, dependency
exits, strict architecture review, UE-008 adversarial proof, parent integration,
and post-implementation receipts remain future gates.

The brokered publication evidence profile covers both
`brokered-class-b-no-pr` and policy-selected protected PR. RP-07 authenticates
and anchors grant/verdict, operation/attempt, direct provider observation,
landed SHA, historical target transition, reconciliation, preserved-work,
mirror, and cleanup status. It neither issues authority nor selects, executes,
classifies, reconciles, or cleans a route.
