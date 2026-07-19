# Target Architecture

## Decision

Use one candidate-immutable verifier identity and version to produce exact-SHA
verdicts, and one immutable deterministic predicate to select denial, default
`brokered-class-b-no-pr` for eligible Class B, protected PR, or stronger Class C control. Verification
and publication identities remain distinct.

## Exact Verdict

An accepted verdict binds at least:

- repository identity;
- authenticated source producer identity/ref and exact candidate `S`;
- target ref and exact target pre-SHA `O`;
- run, request, grant issuer, operation, and consequence identity;
- harness, route-policy, history-shape, and validation-input digests;
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
broker effect, or provider-write credential. Its only signing capability is the
RP-07-governed non-exportable role-bound evidence-attestation key for its own
direct observations; RP-06 does not own signing policy, checkpoints, or anchors.

The publisher consumes RP-01 authority, RP-03 attempt state, the exact
verdict, and RP-05's Git primitive. It cannot issue, edit, reinterpret, or
self-satisfy the verdict. RP-05 holds the effect primitive and operation-scoped
credential through RP-04, not RP-06 verifier code.

FD-007's optional provider worker is excluded from brokered Git publication:
it receives no Git publication credential, ref request, state, retry path, or
callable publication interface. The sole RP-04 broker hosts the RP-05 effect.
Any later non-Git FD-007 claim remains separately gated and cannot constitute a
second broker or publication control plane.

## Deterministic Route

The immutable policy consumes typed facts, never model judgment:

1. Missing, forged, stale, revoked, raced, wrong-SHA, wrong-target, or
   wrong-scope authority: deny and require fresh authorization.
2. Valid admitted Class B satisfying the no-PR predicate and exact verdict:
   invoke the RP-05 broker primitive.
3. Valid work requiring review under ROD-002 protected-scope, consequence, or
   deterministically preclassified stable high-contention facts: route to
   protected PR before effect.
4. Class C or prohibited work: stronger control or denial; never downgrade to
   PR merely to obtain an effect.
5. Class A candidate work: remain local and credentialless without publication
   ceremony.

The policy is versioned and digest-bound before RP-08 reproduces it. Candidate
code cannot change the policy used to judge that candidate.

An actual expected-old collision, source/base/head movement, `ATTEMPTING`, or
`UNKNOWN` is not a PR predicate. It invalidates or freezes the tuple and requires
RP-08 reconciliation plus fresh authority/verification before any new attempt.

## Exact `O`, `S`, `V`, `Q` Lifecycle

1. A credentialless candidate workspace pins `S` and reconciles it against
   exact hosted target `O`; `O` must be an ancestor of `S`.
2. Before `V`, RP-06 freezes history shape: one curated delivery commit is the
   automatic default; a bounded `O..S` range is allowed only when policy admits
   and validates the complete series.
3. RP-01 supplies one grant binding repository, source identity/ref, `S`, target
   ref, `O`, route-policy digest, operation, issuer, expiry, revocation state,
   and consequence scope. The verifier emits `V` over that complete tuple and
   authenticated producer/deployment/harness/results/evidence provenance.
4. Before T1, the RP-06-owned verdict/route gate authenticates `V`'s
   RP-07-governed role signature, producer/deployment identity, expiry,
   revocation, complete tuple, and immutable policy digest, then freezes a
   sealed route decision. RP-03 commits that authenticated tuple digest,
   authority consumption, operation/attempt/idempotency, terminal reserve,
   `ATTEMPTING`, and outbox before RP-04 dispatches any closed effect.
5. For no-PR, RP-04 invokes the RP-05 non-executing exact-object adapter for one
   true server-observed `O -> S` CAS. RP-08 classifies/reconciles the result.
6. A non-broker verifier immediately confirms landed `S`; RP-07 signs the
   terminal chain outside project Git.
7. RP-06 then orchestrates hosted-main fetch and fast-forward-only canonical
   local-main synchronization as a downstream mirror. RP-08 owns cleanup
   eligibility/status and may invoke only RP-05's expected-tip primitive after
   route-specific landed proof; otherwise status is `landed/cleanup-deferred`.

## Complete Protected-PR Semantics

RP-06 owns policy-bound source-ref request semantics; RP-05 alone owns the
conditional ref-mutation primitive. RP-06 owns the provider specialization for
idempotent PR create/update and merge. Every source-ref, PR mutation, and merge
call is a separately T1-bound effect. The frozen gate binds expected base and
head SHA, check identities/results, requested changes, unresolved conversations,
draft state, conflicts, mergeability, review requirements, freshness, policy,
and evidence. Base/head movement requires a fresh tuple; it cannot silently
update or merge.

The merge effect may execute only when a provider primitive or mandatory
protection atomically enforces expected head, expected base (or the exact tested
merge-result/merge-group SHA), and required review/check state at effect time.
Check-then-merge is not an atomic substitute. If the provider cannot prove this
capability, automated merge remains disabled and the candidate is preserved.

For squash, checked `S` yields landed `Q`. An independent verifier must prove
provider association and tree/patch equivalence between `S` and `Q`; source
ancestry is insufficient. A closed-unmerged source ref is never cleanup-eligible.
Lost source-ref, PR, or merge responses enter RP-08 `UNKNOWN` reconciliation
without retry or route switching.

## Substantive Validation and Inherited Red

Required checks must substantively validate the exact candidate/integrated
result before `main` moves; context-name/static alignment and post-main guard
success are insufficient. A deterministic correction lane for inherited red
uses the same harness/policy on `O` and `S`, binds both result-set digests,
requires no new failure identities, strict reduction of the baseline failure
set, and passing changed-scope checks. It never waives candidate-introduced red.

## Provider Boundary

ED-004 defaults to a provider-native GitHub App or protected external verifier
identity with narrow read/check permissions. No custom verifier daemon is
introduced unless candidate immutability, identity, or conformance proof shows
the default infeasible and architecture is explicitly reopened.

Provider rules, required checks, App identity/permissions, Actions defaults,
environments, secret consumers, and relevant audit evidence are refreshed at
implementation and promotion time under UE-015.

`resources/verification-publication-design-and-dependency-receipt.yml` selects
the exact mechanism. A default-branch-owned generated workflow handles
`pull_request_target` and `merge_group`. A fresh secretless macOS compute job
uses RP-02 to treat `S` as hostile data and emits one bounded canonical JSON
result. A separate fresh emitter runner never checks out or executes `S`; only
after schema/size/digest validation does it mint a one-operation token for the
checks-only `octon-verifier` App. Rulesets accept `octon/exact-verdict` only
from that exact App/installation. The distinct publisher App has PR-write but
no checks-write or verifier-secret access.

Protected PR uses GitHub's merge queue, not a direct merge API. Enqueue binds
`expectedHeadOid=S`; the queue is required, ALLGREEN, squash-only, one entry per
group, no bypass, and requires the exact App-produced verdict plus substantive
checks on the `merge_group` SHA. GitHub integrates only a checked group against
the current base. Queue removal, head/base/check/review drift, unavailable
features, or configuration mismatch requires a fresh tuple. There is no
check-then-merge fallback.

## Workflow Projection Source

The exact durable source lives at
`.octon/framework/engine/runtime/adapters/host/github-control-plane/projections/`.
It contains a manifest, two templates, token-gated publisher, validator, and
receipt schema. It may atomically publish only
`.github/workflows/octon-exact-verifier.yml` and
`.github/workflows/octon-protected-publication.yml`, with source/output digests
and publisher identity in retained evidence. The exhaustive 42-workflow census
defines replace/merge/preserve dispositions. Any census drift, direct output
edit, unreceipted output, or unexpected path disables the route.

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
