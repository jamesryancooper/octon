# Current-State Gap Map

## Current State

Governed lifecycle orchestration already separates planning and route
execution. The Lifecycle Runner plans from declared lifecycle contracts,
evaluates gates, records checkpoint and event evidence, and refuses to self
approve, widen scope, or treat generated/proposal/host/chat/model surfaces as
authority. The Lifecycle Executor Adapter executes a selected route and
validates delegation proof; it does not select lifecycle routes.

The proposal-packet lifecycle already models phase-loop state as lifecycle
local context. Phase ids are not proposal manifest statuses and do not create
authority. Proposal-local receipts are evidence only. Implementation,
promotion, closeout, and archive remain gated by fresh validators and route
receipts.

Change Closeout, Worktree Closeout, and Repo Hygiene already use target-owned
policy, receipts, validation, rollback posture, and hosted controls. They
explicitly refuse to treat proposal-local paths, generated outputs, host state,
or chat/model/tool availability as closeout authority.

## Gaps

1. A lifecycle can discover follow-on work owned by another lifecycle, but the
   repository lacks a typed durable request receipt for that dependency.
2. Existing prose handoff and next-route fields are useful but not sufficient
   for schema validation, evidence digest checks, target capability matching,
   idempotent runner visibility, or return evidence.
3. There is no typed return receipt proving that the target lifecycle acted,
   blocked, deferred, or left residue.
4. The runner can record route handoff evidence but cannot yet expose a
   validated interaction request as non-authorizing context.
5. Lifecycle contracts cannot yet declare accepted or emitted interaction
   profiles without ad hoc prose.
6. Validators do not yet test dangling evidence refs, stale evidence refs,
   scope widening, forbidden authority transfer, or attempted gate satisfaction
   by interaction request.

## Required Shape

The gap is not solved by allowing one lifecycle to run another. It is solved by
durably recording the dependency and expected return evidence while target
lifecycles independently evaluate their own scope, authority, freshness,
rollback, receipts, gates, hosted controls, and delegation proof.
