# Deterministic Harness Factory and Generic Executor Adapter

This is the draft RP-11 architecture proposal for
`octon-architecture-migration-harness-factory`. It is a temporary,
non-authoritative implementation aid. It does not authorize implementation,
execution, provider access, capability grants, publication, or support
promotion.

## Outcome

Octon gains one deterministic boundary between approved run inputs and a
provider launch:

- a canonical Harness Factory compiles every approved direct and transitive
  input into byte-stable effective manifest bytes;
- a compile receipt records the compiler identity, ordered source manifest,
  source digests, effective manifest digest, and validation outcome;
- canonical authorization and the one-shot launch guard bind and immediately
  revalidate that exact digest before spawn; and
- one generic executor adapter handles `prepare`, `launch`, `observe`,
  `cancel`, `usage`, and `retire` without becoming authority or another
  runtime.

The design extends existing task-harness, route, resolver, context, and
lifecycle-executor primitives. It creates no scheduler, policy engine,
authority source, durable execution store, verifier, recovery controller, or
child-agent implementation.

## Program Position

- logical packet: `RP-11`
- workgroup: `RWG-11`
- parent program: `octon-architecture-migration-program`
- dependencies: RP-01 canonical authority, RP-02 candidate isolation, and
  RP-10 Workspace Projects
- downstream consumers: RP-12 private extension binding, RP-13 bounded child
  mapping, and RP-14 independent integrated proof

RP-11 owns FD-020 and the generic implementation/component-conformance portion
of FD-023. RP-06 retains verifier/publication specialization, RP-08 retains
recovery/effect specialization, RP-13 retains child semantics and mapping, and
RP-14 retains independent integrated promotion proof.

## Promotion Scope

The proposal is `octon-internal`. Every promotion target is under `.octon/**`.
Generated route bundles, effective manifests, compile receipts, and runtime
observations are projections or retained evidence, never authority.

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

The packet remains `draft`. Structural validation does not make it accepted or
implementation-ready. Dependency exits, stable-digest architecture review,
UE-010 and UE-011 dynamic proof, and later implementation receipts remain
future gates.
