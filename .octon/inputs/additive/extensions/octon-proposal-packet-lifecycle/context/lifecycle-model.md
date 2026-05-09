# Lifecycle Model

## Packet State Machine

```text
source-context
  -> packet-created
  -> packet-validated
  -> proposal-review
  -> revision-needed
  -> revised
  -> proposal-review
  -> accepted
  -> implementation-prompt-generated
  -> implementation-run
  -> implemented
  -> verification-prompt-generated
  -> verified
  -> corrections-needed
  -> corrected
  -> clean
  -> closeout-prompt-generated
  -> closeout-ready
  -> archived
```

Fail-closed or pause report outcomes:

- `blocked`
- `needs-packet-revision`
- `superseded`
- `explicitly-deferred`

Routes must refuse jumps that skip required packet validation, implementation
grounding, proposal review, revision, verification, correction, or closeout
gates. `blocked`,
`needs-packet-revision`, `superseded`, and `explicitly-deferred` are reported
outcomes for a lifecycle gate or route decision; they are not additional
proposal statuses.

Proposal review and revision are receipt-driven loops, not extra manifest
statuses. `support/proposal-review.md` records `accepted`,
`revision-required`, or `rejected`; `support/revisions/<revision-id>.md`
records packet-local revision passes. Implementation prompt generation,
implementation execution, and promotion require a fresh accepted review receipt
validated with strict implementation authorization.

Later lifecycle handoffs are also receipt-driven. `run-implementation` writes
`support/implementation-run.md` and leaves `proposal.yml#status` as `accepted`;
`promote-proposal` consumes that receipt and owns the rewrite to
`implemented`. `closeout-proposal-packet` writes `support/proposal-closeout.md`;
`archive-proposal` consumes that receipt and owns archival.

The generic lifecycle runner owns orchestration, gate evaluation, stale receipt
detection, loop bounds, evidence, checkpoints, and resume. By default, it stops
at a gated `route-ready` handoff. When invoked with `--execute-routes`, it
delegates selected routes to the shared lifecycle executor adapter, which owns
`mock`, `auto`, `codex`, and `claude` route execution outside the lifecycle
runner. Durable routes declare approval metadata in the lifecycle contract and
pause for explicit, resumable approval by default. `--approval-policy
unattended` is an explicit operator override for one-run automation; the adapter
records approval override evidence before executing an approval-gated route
under that policy. Non-execute handoffs do not consume loop iterations; executed
routes do consume bounded loop attempts.

## Completion Invariants

- A route may complete only from route-specific evidence: expected receipt
  completeness, expected path existence, expected manifest status, target
  digest change, terminal outcome, or an explicit idempotent no-op.
- Existing unrelated receipts never satisfy route completion.
- Durable repository mutation must be approval-gated by default or explicitly
  authorized by a tested lifecycle contract exception. Unattended execution is
  recorded as an operator override, not as implicit durable authority.
- Stale or incomplete receipts must not unlock implementation, promotion,
  closeout, archive, or terminal success.
- Landing blockers are confined to concrete failures that can cause unsafe
  mutation, stale or incomplete evidence to unlock progress, runtime discovery
  from non-authoritative sources, route execution or resume corruption, failed
  required validation, or breach of the runner/adapter boundary.
- Deferred work is limited to improvements outside those blocker classes, such
  as richer diagnostics, live provider smoke tests, multi-target programs, and
  broader UX polish.

## Program State Machine

```text
program-source-context
  -> program-created
  -> child-packets-planned
  -> child-packets-created
  -> child-packets-validated
  -> program-implementation-prompt-generated
  -> children-implemented
  -> program-verification-prompt-generated
  -> program-verified
  -> child-corrections-needed
  -> child-corrections-resolved
  -> program-closeout-prompt-generated
  -> program-closeout-ready
  -> children-closed
  -> program-archived
```

Program routes coordinate child packets. They do not own child lifecycle truth,
child subtype manifest truth, child promotion targets, child validation
verdicts, or child archive metadata.

Program controller runs also retain a parent-owned execution record: a
hash-chained v2 event log, checkpoint, scheduler decision, recovery evidence,
optional mutation evidence, optional scaffold evidence, and aggregate closeout
receipt. These surfaces coordinate and explain the parent program only. They do
not satisfy child receipts or rewrite child lifecycle authority.

Program approval grants are parent-run control evidence. A grant only unblocks
the named child route in that program run; route execution records
`program-approved` approval evidence before proceeding, and child receipts
remain child-owned. Recovery recipes are bounded by blocker class, retry budget,
preconditions, post-attempt validation, and live replanning. `unsafe-resume` and
`authority-boundary-ambiguous` remain fail-closed.

`program-atomic` is explicit opt-in and means staged barrier coordination with
declared stage, commit, rollback, or compensation routes. It is not universal
transactionality. Interrupted barriers are resumed from the event log; ambiguous
committed state or missing compensation fails closed as `blocked-unsafe`.
