# Cutover Plan

## Start State — SI-04

The only legal start state is a verified supervised RP-04 broker with:

- one authenticated, same-user-resistant IPC boundary;
- one credential custodian;
- one RP-03 store writer;
- exact operation-handle validation;
- automatic restart and reconciliation scaffolding;
- one bounded non-production effect;
- no production Class B publication.

If any property is missing, RP-05 remains stage-only.

## Cutover Sequence

1. Freeze the RP-03 operation/attempt API and RP-04 broker interface.
2. Install the Git adapter without a production route or credential.
3. Prove independent broker Git state and non-executing object import.
4. Pass the hostile Git extension matrix.
5. Enroll a scratch-only provider credential through RP-04.
6. Execute expected-old fast-forward and race fixtures against disposable refs.
7. Exercise lost response, concurrent actor, restart, and outage behavior.
8. Publish an RP-06-consumable Git primitive interface receipt.
9. Convert legacy hosted mutation helpers to broker-only facades or disable
   them atomically with caller migration.
10. Re-run the physical writer inventory and prove no ambient effect path.
11. Stop at the Git portion of SI-05; do not enable production landing.

## Safe Intermediate States

### RP05-S0 — Adapter Installed, No Credential

- Permitted: static validation, object import fixtures, hostile config tests.
- Prohibited: any remote mutation.
- Rollback: remove or disable the inactive adapter.

### RP05-S1 — Scratch Credential, No Production Ref

- Permitted: effects against a pinned disposable repository and scratch refs.
- Prohibited: main, release, protected, support-claimed, or production refs.
- Rollback: revoke scratch credential and disable adapter.

### RP05-S2 — Primitive Proven, Production Route Disabled

- Required: PO-FD-009 and UE-005 pass; ambient writers are disabled; RP-06
  receives the stable interface.
- Permitted: fixture publication on disposable refs and a separately
  policy-selected protected PR outside RP-05 ownership.
- Prohibited: autonomous production landing until RP-06, RP-07, and RP-08
  complete.
- Rollback: restore only the previous certified adapter behind the same broker
  boundary or disable the route.

## Prohibited Intermediate States

- dual ambient and broker Git writers;
- candidate checkout, attributes, or configuration under broker identity;
- candidate-held provider credential;
- linked-worktree-only isolation;
- check-then-push represented as atomic expected-old binding;
- generic force or lease behavior able to write non-fast-forward;
- blind retry after an unknown response;
- broker self-verification as final verdict;
- provider or GitHub state used as authority;
- production Class B before signed evidence and recovery proof.

## Compatibility

RP-05 has no route fallback. Invalid, stale, forged, revoked, wrong-SHA,
wrong-scope, collided, or unknown effects preserve work and require denial,
reconciliation, or a fresh tuple. No ambient Git compatibility bridge is
allowed. Scratch cutover exercises source-ref create/update, target CAS,
expected-tip delete, and mirror primitives before production remains disabled.

## Cutover Completion

Cutover completion means the adapter primitive is proven and the old ambient
effect path is absent. It does not mean production Class B, support admission,
or program completion.
