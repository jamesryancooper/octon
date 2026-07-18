# Implementation Plan

This plan remains inactive until accepted review authorizes the exact design.

## Preconditions

1. Accepted review authorizes creation of only the selected design.
2. RP-01, RP-03, and RP-05 implementation verification freezes authority,
   attempt, and Git interfaces before source entry.
3. The exact GitHub features, two Apps/permissions, environment, ruleset,
   merge queue, Actions runner/tool/action pins, RP-02 runner feasibility, and
   disposable provider target pass preflight before source entry.
4. Settled ROD-002 lineage is encoded only during the authorized implementation
   as the exact typed policy selected by the design receipt; no vote reopens.
5. Provider configuration is refreshed read-only under UE-015 during
   implementation and again at promotion.
6. Production autonomous publication remains disabled.

## Workstream 1 — Exact Verdict Contract

- Add exact-sha-verdict and route-decision schemas.
- Bind every decision-relevant identity and digest.
- Define expiry, revocation, duplicate, conflict, and supersession behavior.
- Make context names non-authoritative.

## Workstream 2 — Protected Verifier Identity

- Generate the exact base-owned `pull_request_target`/`merge_group` projection
  from the `.octon` source; candidate content runs only in the secretless RP-02
  compute job and the fresh emitter job never checks out or executes it.
- Grant the verifier App only metadata/content/check/read permissions and bind
  the required check to its exact App/installation identity.
- Schema/size/digest-bind the one JSON handoff; deny archives, extra files,
  cache, shared runners, candidate artifacts/actions, and context-only trust.
- Prove candidate changes cannot alter the verifier used for that candidate.
- Prove verifier cannot publish or call RP-05 with a mutation credential.

## Workstream 3 — Immutable Route Policy

- Encode the accepted ROD-002 lineage as typed deterministic predicates.
- Version and digest the sole A/B/C and Class-B/PR policy.
- Authenticate the RP-07-governed verdict signature, producer/deployment,
  complete tuple, expiry, and revocation before admitting any T1 request.
- Bind it into request construction and immediate route evaluation.
- Deny invalid authority and distinguish valid pre-effect PR selection.
- Add one-screen route and blocker output with zero routine prompts.

## Workstream 4 — Publication Specialization

- Consume RP-03 attempt identity, exact verdict, and RP-05 Git primitive.
- Keep publication identity separate from verifier.
- Keep FD-007's optional provider worker unreachable from brokered Git
  publication and credentialless for that target; any non-Git claim remains a
  separate gated projection after the sole local effect path passes.
- Normalize provider observations for RP-08 without claiming recovery.

## Workstream 5 — Workflow Projection Ownership

- Consume the exhaustive 42-workflow census and fail if it drifts.
- Implement only the exact manifest/templates/publisher/validator/receipt
  schema selected under the declared `.octon` host-adapter target.
- Bind source and output digests, publisher identity, receipt, and drift check.
- Require an RP-01 publication token bound to repository, commit, source digest,
  output allowlist/digests, publisher, and expiry; atomically write only the two
  allowlisted outputs and prune only prior receipted outputs.
- Do not directly promote or edit `.github` files through this packet.

## Workstream 6 — Protected-PR Merge Queue

- Create/update the PR with the distinct publisher App, then enqueue only with
  `expectedHeadOid=S` and `jump=false`.
- Require an ALLGREEN, single-entry, squash queue, no bypass actors, App-bound
  exact-verdict and substantive checks on every `merge_group` SHA.
- Keep direct merge APIs unreachable. Provider capability/configuration drift
  disables automated merge and preserves candidate work.
- Independently bind the final `Q` to the provider entry and prove `S -> Q`
  tree/patch equivalence before landed facts leave RP-06.

## Workstream 7 — Proof And Handoff

- Execute PO-FD-007, PO-FD-010, PO-FD-011, UE-006, and UE-015.
- Produce FD-023 specialization conformance for RP-14.
- Freeze the predicate digest for RP-08 consumption.
- Retain provider configuration, route, identity, rollback, and projection
  evidence.
- Run conformance and drift/churn gates.

## Parallelization

Verifier and projection-source work may proceed in parallel only when physical
write scopes do not overlap. Candidate implementation cannot modify the only
verifier or policy judging it. RP-06 cannot edit RP-05 Git behavior, RP-03
transitions, or RP-11 generic adapter semantics.

## Completion Refusal

Stop if provider identity cannot be authenticated, verifier and publisher
permissions cannot be separated, exact verdict binding is unavailable, route
policy still depends on candidate code or model judgment, or required workflow
changes lack an accepted .octon source/generator. Do not add a verifier daemon,
second authority plane, or mixed target family as a shortcut.

## Brokered Publication Workstreams Added by Revision

- Shape and freeze the final candidate history before `V`; default to one
  curated commit and validate every commit in any admitted bounded series.
- Implement the exact `O/S/V` grant/verdict tuple, authenticated producer
  provenance, substantive pre-effect validation, and the deterministic
  inherited-red correction lane.
- Implement policy-selected PR source-ref/create-update/merge requests with
  exact base/head/review state and `S -> Q` proof; consume RP-05 primitives and
  never absorb Git credential custody.
- Add independent post-land verification, fast-forward local-main mirror
  orchestration, and the route-specific landed facts RP-08 needs for cleanup.
- Atomically migrate final publication classification to
  `.octon/instance/governance/policies/change-publication.yml`; the RP-00
  containment slice of `default-work-unit.{yml,md}` becomes a validated
  projection/consumer, never a duplicated classifier.
