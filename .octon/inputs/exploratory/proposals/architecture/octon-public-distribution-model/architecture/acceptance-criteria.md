# Program Acceptance Criteria

## AC-01: Decision Coverage

Every adopted first-release decision in
`resources/decision-to-packet-traceability.yml` has one primary child owner,
objective acceptance test, evidence reference, and explicit manual gate where
applicable.

## AC-02: Blocker Coverage

All six blocker groups in `resources/first-release-blocker-map.yml` have one
non-conflicting primary owner, prerequisites, negative controls, and objective
unblock tests.

## AC-03: Child Independence

All ten children are canonical sibling packets with independent promotion
targets, completeness receipts, validation, rollback, review, implementation,
and closeout authority.

## AC-04: Dependency Integrity

The child dependency graph is acyclic. Parallel work never bypasses a required
verification gate or the external repository setup barrier.

## AC-05: Publication Boundary

No child can publish workspace history, include strict excluded roots, or treat
Git ignore, generated output, raw input, or private hosting as publication
clearance.

## AC-06: Human Authority

Exposure disposition, credential action, ambiguous rights acceptance, name
conflict acceptance, original repository-name reuse and residual stale-clone
risk, backup key custody, evidence deletion, API apply, first public push,
Tier 1 demotion, and final publication remain maintainer gates.

## AC-07: Solo-Maintainer Burden

First-release controls use deterministic tooling, GitHub-native facilities, and
one deliberate publication action. Deferred organization, app, independent key,
hosted evidence, compaction service, vendoring, mirror, and migration controls
remain out of scope.

## AC-08: Implementation Closure

Truthful evidence semantics are dependency-closed across active schemas,
producers, consumers, validators, and tests; downstream locks have a
machine-readable schema; hosted exposure inventory covers every enabled
surface; and forward migration prevents re-tracking every local-only state,
generated, evidence, host, and input subtype.

## AC-09: Review-Run Safety

Program review changes only parent and child proposal artifacts plus the
canonical generated proposal-discovery projection. No architecture
implementation, runtime state, Git setting, remote, credential, repository,
release, or evidence disposition changes occur.
