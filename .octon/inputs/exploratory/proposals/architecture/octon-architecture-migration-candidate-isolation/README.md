# Credentialless Native Candidate Isolation

This is the draft RP-02 architecture proposal for
`octon-architecture-migration-candidate-isolation`. It is temporary,
non-authoritative, and does not authorize or perform candidate execution.

## Purpose

Make primary-provider model work useful without giving the candidate access to
durable credentials, canonical Git state, the canonical checkout, inherited
parent descriptors, or undeclared host capabilities. The minimum target is a
native macOS boundary and independent disposable repository, not a VM or a
second execution runtime.

## Lifecycle State

- status: `draft`
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- change profile: `atomic`
- release state: `pre-1.0`
- parent program: `octon-architecture-migration-program`
- dependency: `octon-architecture-migration-containment`

The packet is ready for operator reading, not implementation. The exact ED-001
session/sandbox mechanism, independent architecture review, and proposal
acceptance remain future gates.

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

## Boundary Summary

RP-01 owns canonical authority, exact guard semantics, and the structural
guard-owning launch API. RP-02 owns candidate workspace construction,
environment and descriptor scrubbing, native sandbox application, independent
Git state, provider-session attachment, and non-executing commit export behind
that API. RP-11 owns the generic executor-adapter interface; RP-02 must not
redefine it.

## Exit Path

After accepted implementation and direct proof, RP-02 may close only when a
useful primary-provider task succeeds and every durable-credential,
canonical-Git, parent-FD, filesystem, network, and process escape test denies.
Candidate work must remain exportable if automated launch is disabled.
