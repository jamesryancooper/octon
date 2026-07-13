# Cutover Plan

## Start State

Cutover starts only after RP-01, RP-03, and RP-05 have verified exits and
frozen interfaces. The accepted rules retained through settled/retired ROD-002
lineage must be durably encoded as the immutable autonomy/PR predicate; no new
operator vote is required. ED-004 must remain feasible, a scratch provider must
exist, and production autonomous Class B must remain disabled.

## Cutover Sequence

1. Freeze authority, operation/attempt, and expected-old Git interfaces.
2. Define the exact verdict and route-decision schemas without a live route.
3. Install the protected verifier identity in shadow mode with no provider
   required check and no publication credential.
4. Run candidate-mutation, duplicate-context, wrong-identity, wrong-SHA,
   expiry, revocation, and policy-digest fixtures.
5. Bind an authenticated check only in a scratch or non-production provider
   target and observe provider identity and ruleset behavior.
6. Install the immutable route predicate with all production Class B effects
   disabled; prove deny, protected-PR, and exact RP-05 request selection.
7. Prove verifier and publisher permission separation, including
   same-credential and self-verification negatives.
8. Establish and validate the .octon-authored workflow source/generator,
   output digest, publisher identity, and freshness receipt.
9. Classify existing candidate writer/verifier workflows as keep, merge,
   project, or retire; refresh projections only through that source.
10. Re-run provider observations and the physical effect-owner inventory.
11. Publish the frozen route predicate and provider specialization receipts
    for RP-07, RP-08, and RP-14 consumption.
12. Stop at SI-05 with production autonomous Class B still disabled.

## Safe Intermediate States

### RP06-S0 — Shadow Verifier, No Required Check

- Permitted: schema validation, local fixtures, shadow verdict comparison.
- Prohibited: provider gate, broker request, or production route change.
- Rollback: disable the shadow verifier and retain comparison evidence.

### RP06-S1 — Authenticated Check In Scratch Only

- Permitted: non-production required-check binding and adversarial provider
  tests.
- Prohibited: production branch protection, merge, release, or Class B
  publication.
- Rollback: remove the scratch requirement and revoke narrow test identity.

### RP06-S2 — SI-05 Immutable Verification, Production Effect Disabled

- Required: PO-FD-007 when the optional worker exists, PO-FD-010,
  PO-FD-011, UE-006, UE-015, projection ownership, and route UX pass.
- Permitted: exact scratch no-PR effects and protected PR selected by the
  immutable policy.
- Prohibited: production autonomous Class B until RP-07 and RP-08 exit.
- Rollback: disable autonomous publication and preserve every frozen candidate;
  PR remains only when independently selected before effect.

## Prohibited Intermediate States

- verifier and publisher sharing an identity, credential, or mutable code;
- candidate-controlled code producing the only accepted verdict;
- context name treated as authenticated verifier identity;
- ambiguous, duplicate, or conflicting checks accepted;
- invalid authority converted into a PR route;
- direct-main, ambient publication credentials, or provider
  self-authorization;
- route policy changed by the candidate it evaluates;
- production Class B before signed evidence and recovery proof;
- direct .github promotion or an unreceipted projection refresh;
- provider configuration mutation used to make conformance pass.

## Compatibility

Protected PR is a policy-selected route only, not a compatibility or recovery
fallback. Invalid, stale, forged, revoked, raced, wrong-SHA, wrong-target,
wrong-scope, collided, `ATTEMPTING`, or `UNKNOWN` tuples deny/reconcile and
require fresh authority for any new attempt. Cutover proves the complete no-PR
and PR paths on disposable refs, freezes route before T1, then proves post-land
verification, mirror, and cleanup handoff. There is no candidate-verifier,
ambiguous-context, direct-main, or route-switch bridge.

## Cutover Completion

RP-06 cutover completes when immutable verification, deterministic routing,
provider specialization, zero-prompt status, and projection ownership are
proven at SI-05. It does not enable production Class B, recovery, trust-root
activation, generic provider support, or the program support claim.
