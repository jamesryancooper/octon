# Target Architecture

## Authority Separation

| Category | Meaning for this revision |
| --- | --- |
| Current authority | Accepted repository contracts, active runtime behavior, and live provider controls continue to govern. This proposal changes none of them. |
| Planned architecture | This parent and its fifteen draft children coordinate a possible migration. Their statements are non-authoritative until separately accepted, implemented, verified, and promoted. |
| Recommended target | One candidate-first publication control plane in which eligible Class B defaults to `brokered-class-b-no-pr`, protected PR is selected only by immutable policy, and every invalid or raced tuple denies while preserving work. |

The parent remains a lightweight gated-parallel coordinator. It is not a
scheduler, authority issuer, transactional writer, broker, verifier, signer,
evidence producer, or implementation work unit. The target keeps exactly one
candidate-immutable issuer, one transactional writer, one supervised sole effect
broker, one independent verifier identity, and one publication policy.

## Exact Brokered Class B No-PR Lifecycle

Let `O` be the exact hosted target pre-SHA, `S` the immutable candidate SHA, `V`
the candidate-immutable verifier verdict, and `Q` the landed squash SHA when the
protected-PR route is selected.

1. A credentialless independent candidate workspace produces and pins `S`.
2. The final candidate is reconciled against exact `O`, and `O` must be an
   ancestor of `S`.
3. Before verification, immutable RP-06 policy selects history shape: one
   curated delivery commit is the automatic default; a bounded `O..S` series is
   allowed only when explicitly admitted and the complete range is validated.
4. The sole RP-01 issuer supplies one bounded grant binding repository, source
   identity/ref, `S`, target ref, `O`, route-policy digest, operation, issuer,
   expiry, revocation state, and consequence scope.
5. The candidate-immutable RP-06 verifier emits `V`, binding that tuple,
   authenticated producer identity, verifier version/deployment, harness and
   policy digests, validation inputs/results, evidence head, issue/expiry and
   revocation state, and protected-scope facts. It has no provider-write, merge,
   release, broker, or general signing credential; its only signing capability
   is the RP-07-governed non-exportable role-bound evidence-attestation key for
   its own direct observations.
6. Before T1, the RP-06-owned verdict/route gate authenticates `V`'s
   RP-07-governed role signature, producer and deployment identity, expiry and
   revocation state, complete tuple, and immutable policy digest. It then
   freezes a sealed route decision: Class A remains local; eligible admitted
   Class B selects `brokered-class-b-no-pr`; valid review or stable pre-route
   high-contention predicates select protected PR; Class C selects stronger
   control or denial. Invalid authority denies. An actual collision or
   `UNKNOWN` never changes the route.
7. Before a provider call, RP-03 atomically consumes authority and commits the
   operation/attempt identity, idempotency state, terminal-evidence reservation,
   complete tuple digest, `ATTEMPTING`, and outbox record.
8. The sole RP-04 broker revalidates RP-01 guard freshness and byte/digest
   equality of repository, refs, `O`, `S`, grant, sealed policy/route decision,
   `V`, history, operation, attempt, and evidence bindings against the
   pre-T1-authenticated tuple, then invokes only the closed RP-05 adapter. It
   never reinterprets RP-06 policy or `V`, checks out candidate code, or executes
   candidate code.
9. RP-05 imports only the exact object closure into broker-owned minimal Git
   state. Hooks, repository configuration, helpers, filters, attributes,
   alternates, external transports, signing tools, editors, pagers, submodule
   execution, candidate configuration, and ambient credentials are unreachable.
10. RP-05 independently proves ancestry and requests one server-observed
    expected-old compare-and-swap fast-forward `O -> S`. Force,
    non-fast-forward, bypass, and check-then-push substitution are unreachable.
11. RP-08 records and reconciles exactly one of `attempt_performed`,
    `state_satisfied`, `not_performed`, `failed`, `unknown`, or
    `manual_intervention`; no attempt retries while `UNKNOWN`.
12. A verifier identity independent of the broker directly confirms the
    immediate landed SHA and publication result. RP-07 signs and anchors the
    terminal chain outside project Git.
13. After landed proof, RP-06 orchestrates hosted-`main` fetch and a
    fast-forward-only update of canonical local `main` as a downstream mirror,
    never an integration or authorization authority.
14. RP-08 authorizes and records cleanup only after route-specific landed proof;
    RP-05 may perform only a conditional expected-tip ref primitive. Otherwise
    the honest result is `landed/cleanup-deferred`. Rejection, collision, outage,
    failed publication, unmerged PR, recovery, and cleanup failure preserve `S`.

## Deterministic Protected-PR Branch

Protected PR is a pre-effect policy selection, never a technical fallback. RP-06
owns policy-bound source-ref request semantics while RP-05 alone owns the
conditional ref-mutation primitive. RP-06 also owns idempotent PR create/update
and merge semantics, expected base and head SHA, checks, requested changes, unresolved
conversations, draft state, conflicts, mergeability, review requirements, and
freshness. Base or head movement invalidates the tuple and requires fresh
authority before another attempt. Each source-ref, PR mutation, and merge call
uses its own RP-03 attempt and RP-08 reconciliation. When squash is selected,
the independent verifier proves provider association and tree/patch equivalence
from checked `S` to landed `Q`; ancestry alone is insufficient. Cleanup never
deletes a closed-unmerged or otherwise unlanded source ref.

Automated merge is enabled only when a provider primitive or mandatory
protection atomically enforces the expected head, expected base (or exact tested
merge-result/merge-group SHA), and required review/check state at effect time.
A read/check-then-merge substitute is prohibited; if the provider cannot prove
this capability, automated merge stays disabled and `S` is preserved.

If the provider cannot supply true expected-old CAS under mandatory protections
without bypass, production no-PR publication remains disabled and work is
preserved. The adapter must not widen into a generic Git service.

The migration rests only in SI-00 through SI-08. No Octon-owned human or agent
`direct-main`, credentialed candidate, candidate-head privileged execution,
second issuer/writer/broker/control plane, universal PR mandate, universal
exactly-once claim, same-change self-certification, or proposal-as-authority is
introduced.
