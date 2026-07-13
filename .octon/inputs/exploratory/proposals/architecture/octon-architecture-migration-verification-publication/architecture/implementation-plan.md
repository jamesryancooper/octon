# Implementation Plan

This plan remains inactive while the proposal is draft.

## Preconditions

1. RP-01, RP-03, and RP-05 exit with frozen authority, attempt, and Git
   interfaces.
2. Settled/retired ROD-002 lineage is encoded as the accepted deterministic
   protected-scope, consequence, Class-B-to-PR, and irreducible-ambiguity-only
   policy without another operator vote.
3. ED-004 selects a provider-native App or protected external verifier identity
   unless proof forces architecture repair.
4. Provider configuration is refreshed read-only under UE-015.
5. An authored .octon projection source/generator is accepted before any
   .github workflow change.
6. Production autonomous publication remains disabled.

## Workstream 1 — Exact Verdict Contract

- Add exact-sha-verdict and route-decision schemas.
- Bind every decision-relevant identity and digest.
- Define expiry, revocation, duplicate, conflict, and supersession behavior.
- Make context names non-authoritative.

## Workstream 2 — Protected Verifier Identity

- Deploy verifier code and policy outside candidate control.
- Grant only required read and check-emission permissions.
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

- Inventory candidate writer/verifier workflows and classify keep, merge,
  project, or retire.
- Establish templates or generation inputs under the declared .octon host
  adapter target.
- Bind source and output digests, publisher identity, receipt, and drift check.
- Do not directly promote .github files through this packet.
- If an authored source/generator cannot own required changes, stop on the
  target-family-split blocker.

## Workstream 6 — Proof And Handoff

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
