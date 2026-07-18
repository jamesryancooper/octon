# Credentialless Native Candidate Isolation

This is the in-review RP-02 architecture proposal for
`octon-architecture-migration-candidate-isolation`. It is temporary,
non-authoritative, and does not authorize or perform candidate execution.

## Purpose

Make primary-provider model work useful without giving the candidate access to
durable credentials, canonical Git state, the canonical checkout, inherited
parent descriptors, or undeclared host capabilities. The minimum target is a
native macOS boundary and independent disposable repository, not a VM or a
second execution runtime.

## Lifecycle State

- status: `in-review`
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- change profile: `atomic`
- release state: `pre-1.0`
- parent program: `octon-architecture-migration-program`
- dependency: `octon-architecture-migration-containment`

The packet selects ED-001's exact engineering default in
`resources/engineering-disposition-ed001.yml`: arm64 macOS 26/Darwin 25,
root-owned `/usr/bin/sandbox-exec` with a digest-bound default-deny SBPL profile,
an exact-digest OpenAI Codex CLI, and a launcher-owned one-run loopback
capability relay. An unavailable or unproved tuple denies without ambient
credentials, direct provider egress, or effect-broker fallback. The design is
ready for independent re-review, not implementation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `resources/engineering-disposition-ed001.yml`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/implementation-plan.md`
10. `architecture/validation-plan.md`
11. `architecture/cutover-plan.md`
12. `architecture/rollback-and-recovery.md`
13. `architecture/operator-disclosure.md`
14. `resources/traceability.yml`
15. `support/implementation-grade-completeness-review.md`

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
