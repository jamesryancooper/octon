# Implementation Plan (Program Level)

Program "implementation" is child lifecycle orchestration; the parent itself
implements nothing.

1. **Program review and acceptance** through the proposal lifecycle (parent
   packet review → acceptance of the coordination structure).
2. **Phase-0 child creation** (three packets, parallel): create
   `retirement-register-compatibility-refresh`,
   `runtime-spec-directory-index`, and
   `retained-evidence-operability-contract` as sibling packets via the
   governed create-packet route, each citing the retained review evidence
   and its registry charter.
3. **Child lifecycles run child-owned**: create → review → accept →
   implement → verify → close, per child, with child-local receipts. The
   parent tracks dispositions only.
4. **Phase-1 creation** when pacing allows; `evidence-classification-v2-
   migration` may not begin implementation until
   `retained-evidence-operability-contract` passes verification (registry
   dependency gate).
5. **Phase-2 creation**; `governance-quorum-revisit-trigger` is created only
   if durable action is justified, else routed to no-action at closeout.
6. **Program closeout** per `program-closeout-plan.md` with aggregate
   evidence retained under the declared program evidence root, then archive.

Rollback posture: the parent is coordination-only — "rollback" of the parent
is archival with rationale; child rollbacks are child-owned and declared per
child (registry `rollback_posture: manual` marks that every child must define
its own before implementation).

No executor implementation prompts are created at this stage; prompt
generation for children happens through the lifecycle's generate-prompt
routes after child acceptance.
