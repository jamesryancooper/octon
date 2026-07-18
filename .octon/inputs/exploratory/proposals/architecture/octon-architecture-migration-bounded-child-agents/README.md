# Bounded Mission Child Agents

This is the in-review RP-13 architecture proposal for
`octon-architecture-migration-bounded-child-agents`. It is a temporary,
non-authoritative implementation aid. It does not authorize child launch,
provider access, credentials, concurrency, spend, capability grants, mission
transitions, publication, persistence, or a support claim.

## Outcome

Octon gains a narrowly bounded optional parallel-work primitive:

- each child is a new temporary `MissionChildRun`, not a persistent agent or
  proposal-program packet;
- effective scope is the strict intersection of parent run, mission, Workspace
  Project, child Harness, role template, isolation boundary, and remaining
  budget;
- a one-shot exact guard binds child identity, parent/mission/project, Harness,
  isolated candidate repository/session, provider mapping, and limits;
- the existing scheduler enforces concurrency, steps, attempts/retries, and
  timeout; token/cost limits are called hard only when enforceable, otherwise
  child admission denies;
- provider-native child behavior is a child-specific mapping over the RP-11
  generic adapter, not a second adapter or scheduler;
- cancellation combines provider cancel and process-group termination with
  RP-08 unknown-outcome reconciliation; and
- terminal retirement preserves output/evidence then revokes guard, session,
  provider task, candidate area, and identity so none can be reused.

Initial support is credentialless, depth one, candidate-only, and cannot spawn
children, touch canonical Git, access siblings, or perform durable external
effects.

## Program Position

- logical packet: `RP-13`
- workgroup: `RWG-12`
- parent program: `octon-architecture-migration-program`
- dependencies: RP-08 recovery/Class B and RP-11 Harness/generic adapter
- parallel sibling: RP-12 private signed extensions, with no shared semantic
  source

RP-13 owns FD-022 and only the child-mapping specialization of FD-023. RP-11
retains the generic adapter interface/conformance; RP-14 retains independent
integrated provider proof.

## Promotion Scope

The proposal is `octon-internal`; all promotion targets are under `.octon/**`.
Child control/evidence instances are runtime outputs, not proposal authority or
persistent agent records.

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

The packet is `in-review` at its frozen digest. Exact provisional ROD-005
limits, complete identity/retirement transactions, and non-circular dependency
and implementation-evidence ordering require correction. No operator
disposition remains open. Child launch remains disabled.
