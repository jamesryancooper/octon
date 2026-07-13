# Target Architecture

## Decision

Use one candidate-immutable verifier identity and version to produce exact-SHA
verdicts, and one immutable deterministic predicate to select denial,
brokered no-PR Class B, protected PR, or stronger Class C control. Verification
and publication identities remain distinct.

## Exact Verdict

An accepted verdict binds at least:

- repository identity;
- source SHA and target ref;
- target pre-SHA;
- run, request, grant, and operation identity;
- harness and policy digest;
- verifier identity, version, and deployment provenance;
- validation inputs and result digests;
- evidence/checkpoint head;
- issue time, expiry, and revocation state;
- route-relevant protected-scope and consequence facts.

The provider check binds this complete tuple to an authenticated producer.
Context text is display metadata, not identity. Duplicate, conflicting, stale,
expired, revoked, wrong-event, wrong-repository, wrong-target, or incomplete
verdicts deny.

## Identity Separation

The verifier may read exact candidate and provider metadata and emit a verdict
or narrowly scoped check. It has no merge, content-write, ref-write, release,
or broker effect credential.

The publisher consumes RP-01 authority, RP-03 attempt state, the exact
verdict, and RP-05's Git primitive. It cannot issue, edit, reinterpret, or
self-satisfy the verdict. RP-05 holds the effect primitive and operation-scoped
credential through RP-04, not RP-06 verifier code.

An optional provider worker under FD-007 may perform only an exact
broker-authorized operation after local-path proof. It owns no canonical state,
route policy, or authority and cannot mint or alter an operation.

## Deterministic Route

The immutable policy consumes typed facts, never model judgment:

1. Missing, forged, stale, revoked, raced, wrong-SHA, wrong-target, or
   wrong-scope authority: deny and require fresh authorization.
2. Valid admitted Class B satisfying the no-PR predicate and exact verdict:
   invoke the RP-05 broker primitive.
3. Valid work requiring review under ROD-002 protected-scope, consequence, or
   uncertainty thresholds: route to protected PR.
4. Class C or prohibited work: stronger control or denial; never downgrade to
   PR merely to obtain an effect.
5. Class A candidate work: remain local and credentialless without publication
   ceremony.

The policy is versioned and digest-bound before RP-08 reproduces it. Candidate
code cannot change the policy used to judge that candidate.

## Provider Boundary

ED-004 defaults to a provider-native GitHub App or protected external verifier
identity with narrow read/check permissions. No custom verifier daemon is
introduced unless candidate immutability, identity, or conformance proof shows
the default infeasible and architecture is explicitly reopened.

Provider rules, required checks, App identity/permissions, Actions defaults,
environments, secret consumers, and relevant audit evidence are refreshed at
implementation and promotion time under UE-015.

## Workflow Projection Source

The durable source for provider workflow projections must live under the
declared .octon host-adapter target family. It owns projection templates or
generation inputs, verifier/publisher identity references, source digests,
publisher identity, and freshness receipts. Directly authored .github workflow
files cannot be the source of truth for this packet.

Until that source or generator is accepted and validated, candidate
writer/verifier workflow retirement is a target-family-split blocker.

## Safe Failure

Verifier or provider unavailability blocks only the publication transition.
Candidate work remains available, safe Class A continues, and valid work may
use protected PR only when the immutable policy selects it. There is no
fallback to candidate verification, ambiguous contexts, ambient credentials,
or broker self-verification.

## Unsupported Remainder

RP-06 does not implement a generic executor adapter, store, broker, Git
primitive, recovery loop, trust activation, or support claim. A live secondary
provider is required only for a separate secondary-provider claim. Production
Class B remains disabled until RP-07 and RP-08 proof.
