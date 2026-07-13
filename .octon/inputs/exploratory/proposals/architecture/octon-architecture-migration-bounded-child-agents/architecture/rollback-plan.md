# Rollback Plan

## Prepared Before Activation

- retain the last certified child policy, admitted-mapping set, contract and
  generic-adapter versions, exact dependency receipts, and implementation
  digest;
- provide one canonical disable for new child admission while preserving the
  parent mission and the RP-11 single-agent route;
- retain exact active child, provider task/process, guard, candidate/session,
  cancellation, output, unknown/reconciliation, and retirement identities;
- prove cancellation and retirement can run while new launch is disabled;
- preserve candidate output/evidence before any candidate cleanup; and
- prohibit restoring credentials, canonical-Git access, depth, identity reuse,
  unsupported hard-limit claims, or a second scheduler as rollback.

## Rollback by Stage

| Stage | Action | Preserved data |
| --- | --- | --- |
| Contracts/policy only | Leave launch disabled and repair strict contracts, mirrors, registry entries, or templates. | Existing missions and single-agent execution |
| Dry intersection only | Disable the dry path if incorrect and discard non-authoritative fixture output. | Policy/contract evidence and parent state |
| Staged guard/isolation | Revoke the unconsumed guard, retire the staged session/candidate identity, and record cleanup evidence. | No provider task; exact staged-resource lineage |
| Fake mapping | Remove fake admission from the operational route and retire test child resources. | Scheduler baseline and test receipts |
| Primary shadow | Keep live policy disabled; cancel/reconcile/retire every shadow child and quarantine the mapping evidence if suspect. | Child output/evidence and single-agent route |
| Post-activation defect | Disable new admission, target every active child for cancel/reconcile/retire, then continue parent work through RP-11 if authorized. | Parent progress, child candidates/output, terminal evidence |

## Active-Child Disable Procedure

1. Atomically deny new MissionChildRun admission and guard issuance/consumption
   for child launch.
2. Inventory active children by exact parent/mission/child/attempt, guard,
   candidate/session, provider task/process, cancellation, and budget identity.
3. Request cancellation through the child mapping and terminate the exact
   process group through RP-11 primitives.
4. Observe a causally attributable terminal result or mark the outcome
   `unknown`; hand every unknown to RP-08 without blind retry or replacement.
5. Preserve typed output/candidate/evidence and let the parent reconciler
   decide whether any candidate material is usable.
6. Revoke/release the guard, session, provider task, process, locks, and
   candidate ownership; write the child/attempt tombstone.
7. Verify every retired identity/resource rejects resume, retry, recruitment,
   or reuse.
8. Resume the parent through the single-agent RP-11 route where its existing
   authority permits.

Failure at a step keeps the child blocked in `unknown` or
`retirement_blocked`; it never permits a success claim, deletion of needed
evidence, new child launch, or identity reuse.

## Recovery Procedures

- Interrupted before guard consumption: revoke the guard and retire staged
  session/candidate resources; no provider task may be inferred.
- Lost launch response: observe exact provider/process/session identities and
  use RP-08 reconciliation; do not launch a replacement.
- Cancel/kill failure: retain cancellation intent, continue exact observation,
  isolate output, and remain unknown until RP-08 resolves causation.
- Restart during reconciliation: reconstruct from canonical parent control,
  guard/Harness/provider observations, candidate/session state, and retained
  evidence; desired state alone proves nothing.
- Interrupted retirement: rerun idempotent revocation/release steps and verify
  tombstone plus reuse denial before `retired`.
- Corrupt/missing output: preserve remaining evidence and report loss; do not
  mutate parent success or fabricate terminal proof.
- Invalid mapping or limit posture: remove mapping admission and retain the
  single-agent fallback until a new exact conformance result exists.

## Replacement Rule

A replacement is permitted only after the predecessor is terminally
reconciled and retired. It receives a new child/attempt identity, guard,
candidate repository, provider session/task, cancellation identity, and budget
slice while retaining predecessor lineage. No old resource can be resumed or
rebound.

## Rollback Invariant

Rollback may disable bounded children and reduce parallelism. It may not lose
parent/candidate work, broaden scope, expose credentials or canonical Git,
restore a child or session identity, infer an unknown outcome, change RP-08 or
RP-11 semantics, or create an alternative scheduler/control plane.
