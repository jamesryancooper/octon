# Implementation Plan

This plan describes later implementation. It does not authorize it.

## Workstream 0 — Freeze Entry Interfaces

1. Verify RP-01 exit and record the authority/guard interface version.
2. Refresh the Profile, engagement, mission, continuity, and Harness consumer
   inventory at the exact implementation commit.
3. Confirm exclusive RP-10 symbol/entry ownership in shared files.

Exit: no open authority ownership or target-family ambiguity.

## Workstream 1 — Contracts and Durable Records

1. Add strict runtime and constitutional Workspace Project schemas.
2. Register the contract and path roles in the runtime, constitutional, and
   topology registries.
3. Add the instance project registry, path-safe active pointer, immutable
   project revisions, and immutable Profile revisions.
4. Clarify Project Profile binding and whitelisted projection semantics.

Exit: positive and negative schema fixtures pass; records cannot encode
authority or unsafe paths.

## Workstream 2 — Adoption, Inference, and Repair

1. Extend engagement start to resolve or prepare a Workspace Project candidate.
2. Adopt the current singleton Profile as the first project's selected Profile
   without rewriting its evidence facts.
3. Implement deterministic inference, relocation, staleness, correction, and
   scoped repair receipts.
4. Implement the rebuildable location index as a non-authoritative read model.

Exit: two-project adoption, relocation, correction persistence, and scoped
ambiguity behavior pass.

## Workstream 3 — Frozen Run and Harness Inputs

1. Record exact project revision/Profile refs and digests when a new run is
   prepared.
2. Prove active snapshots do not follow refreshes.
3. Expose the exact, non-authoritative project binding interface consumed by
   RP-11 without modifying RP-11 compilation logic.
4. Reject every metadata-to-authority widening attempt.

Exit: RP10-AC-005 and RP10-AC-006 pass.

## Workstream 4 — Cross-Project Mission Inbox

1. Add project identity to mission continuity/read-model records while leaving
   mission authority and control schemas unchanged unless a separately owned
   interface change is explicitly approved.
2. Add the read-only `octon mission inbox` command.
3. Prove status/resume guidance is exact and the command causes no control
   mutation.

Exit: RP10-AC-007 passes for two projects and all mission terminal states.

## Workstream 5 — Cutover, Proof, and Retirement

1. Execute the cutover stages and rollback rehearsals.
2. Retire direct singleton selection only after every consumer is accounted
   for.
3. Run the complete validation matrix and retain evidence.
4. Run independent pre-integration architecture review, implementation
   conformance review, and post-implementation drift/churn review.
5. Hand exact project/Profile bindings to RP-11 and keep UE-010 open until
   RP-11's compile/launch proof passes.

## Change Sizing

Implementation should use coherent Changes ordered as contracts, records,
inference/repair, frozen binding, inbox, and cutover/proof. No Change may
redefine RP-01 semantics, add a broker/writer, or combine RP-11 Harness source
ownership into RP-10 for convenience.

## Completion Refusal

Refuse implementation closeout if any project metadata widens authority, any
active run follows a refresh, overlap is silently resolved, relocation changes
identity, the inbox mutates control state, a promotion target is uncovered, or
required conformance/drift receipts do not pass.
