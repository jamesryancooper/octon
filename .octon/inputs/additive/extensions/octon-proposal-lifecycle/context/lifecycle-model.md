# Lifecycle Model

## Packet Route/Receipt Lifecycle Flow

This flow describes proposal-owned route and receipt progression. It is not the
Change closeout state machine and does not own target-lifecycle route
selection, cleanup, landing, receipt, or final outcome authority.

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

## Execution Strategies

Lifecycle identity names the lifecycle contract, route contracts name the
eligible route surfaces, and `execution_strategy` names the runner shape. The
proposal packet lifecycle declares `route-progression`: one target plans the
next selected route, optionally dispatches it through the lifecycle executor
adapter, and replans from packet-owned manifests and receipts. The proposal
program lifecycle declares `orchestrated-replan-loop`: one parent orchestration
target repeatedly plans from live state, dispatches one selected parent route
or runnable child batch, replans from child-owned manifests and receipts, and
stops only at terminal, blocked, approval-paused, failure, cancellation, or
max-step exhaustion states.

`loops:` remains packet receipt-loop policy inside route progression.
`program.supported_execution_modes` remains program scheduler policy for child
batch selection. Neither field is interchangeable with `execution_strategy`.

Proposal review and revision are receipt-driven loops, not extra manifest
statuses. `support/proposal-review.md` records `accepted`,
`revision-required`, or `rejected`; `support/revisions/<revision-id>.md`
records packet-local revision passes. Implementation prompt generation,
implementation execution, and promotion require a fresh accepted review receipt
validated with strict implementation authorization.

Later lifecycle handoffs are also receipt-driven.
`run-packet-implementation` writes `support/implementation-run.md` and leaves
`proposal.yml#status` as `accepted`; `promote-proposal` consumes that receipt
and owns the rewrite to `implemented`. `closeout-packet` writes
`support/proposal-closeout.md`; `archive-proposal` consumes that receipt and
owns archival.

The generic lifecycle runner owns orchestration, gate evaluation, stale receipt
detection, loop bounds, evidence, checkpoints, and resume. By default, it stops
at a gated `route-ready` handoff. When invoked with `--execute-routes`, it
delegates selected routes to the shared lifecycle executor adapter, which owns
`mock`, `auto`, `codex`, and `claude` route execution outside the lifecycle
runner. Routes declare a required `delegation_contract`; durable routes execute
unattended only after invocation authority, evidence gates, scope checks,
authority-zone checks, replay class, and required before-dispatch receipts
produce a retained delegation proof. `--invocation-authority unattended` authorizes only proof-gated delegated execution.
Non-execute handoffs do not consume loop iterations; executed routes do consume
bounded loop attempts.

## Proposal Packet Phase Loop

The proposal packet lifecycle contract uses `schema_version:
octon-extension-lifecycle-contract-v2` and declares `phase_loop.model_version:
phase-loop-v1`. Phase ids are lifecycle phase context, not `proposal.yml`
statuses. The proposal manifest status set remains limited to the contract's
declared `target.allowed_statuses`; review and revision still live in receipts.

The packet phase loop binds these governed phases to existing routes,
receipts, gates, validators, loops, and terminal outcomes:

1. `target-binding-and-lifecycle-discovery`
2. `packet-creation`
3. `structural-validation`
4. `implementation-grade-completeness`
5. `review-and-revision`
6. `implementation-authorization`
7. `implementation-prompt-generation`
8. `implementation-execution`
9. `promotion`
10. `verification-and-correction`
11. `closeout-and-hygiene`
12. `archival`
13. `terminal-explanation-reporting`

`closeout-and-hygiene` is a proposal-owned handoff and evidence phase only.
It may record proposal closeout evidence and non-authorizing lifecycle
interaction requests, but it never owns Git or worktree cleanup, branch
cleanup, hosted landing, Change receipt completion, or repo-hygiene deletion.
Those authorities remain with the target lifecycle, Change closeout,
repo-hygiene cleanup, or the relevant archival route.

The substrate validates phase references, finite phase and route-dispatch
bounds, backward transitions, terminal phases, and status separation. At
runtime the runner reports `current_phase`, phase counts, phase blockers, and
phase transition events in plans, checkpoints, summaries, and
`lifecycle-events.ndjson`. The runner does not use phases to mint authority or
reinterpret route semantics; source lifecycle route selection remains governed
by existing proposal route conditions, receipts, gates, and delegation proof.

Executor requests and results may carry `phase_id` as context. The executor
must not select phases, advance phases, or treat phase context as approval.
Generated effective projections remain runtime discovery handles only and are
refreshed from authored extension inputs.

Lifecycle stop evidence uses a shared vocabulary across packet and program
runs: planned handoff, adapter-dispatched route or child batch, terminal
completion, `blocked-human`, `blocked-recoverable`, `blocked-unsafe`,
`blocked-max-steps`, `failed`, `timed-out`, and `cancelled`. Packet
route-progression writes hash-chained `lifecycle-events.ndjson` traces;
program orchestration keeps its hash-chained `program-events.ndjson` replay
log. These traces improve observability but do not replace checkpoints,
manifests, receipts, promotion evidence, or closeout evidence.

Cancellation is a durable lifecycle stop condition. `octon lifecycle cancel
--run-id <run> --reason <text>` writes a retained cancellation marker and
updates the checkpoint to `final_verdict: cancelled`; `octon lifecycle program
cancel` remains a compatibility alias. Resume, retry, and execute-routes
checks must return `cancelled` with `route_execution_mode: none` once the
marker exists. Program child human-boundary blocks should route operators
through typed human exception grant controls while preserving adapter-level
delegation proof enforcement.

## Completion Invariants

- A route may complete only from route-specific evidence: expected receipt
  completeness, expected path existence, expected manifest status, target
  digest change, terminal outcome, or an explicit idempotent no-op.
- Existing unrelated receipts never satisfy route completion.
- Durable repository mutation must be proof-gated by `delegation_contract`,
  invocation authority, evidence, scope, authority-zone, replay, and receipt
  checks. Generated outputs and proposal-local receipts can satisfy evidence
  gates but never grant authority.
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
  -> program-review
  -> program-revision-needed
  -> program-revised
  -> program-review
  -> program-accepted
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

The generic program lifecycle runner follows the same executor boundary as the
packet runner. By default, `octon lifecycle run --lifecycle proposal-program`
plans the next runnable parent or child route, writes evidence and a checkpoint,
and stops at `program-route-handoff`. It does not execute child implementation.
When invoked with `--execute-routes`, it runs a bounded plan-execute-replan
loop: plan from live repository state, dispatch one selected parent route or
one runnable child batch through the shared lifecycle executor adapter, replan
from child-owned manifests and receipts, and continue until terminal
completion, blocked state, approval pause, failure, timeout, cancellation, or
max-step exhaustion. `--max-steps` counts adapter dispatch attempts, not pure
planning; one child batch is one step regardless of
`--max-child-concurrency`.

Parent program review and revision are receipt-driven loops, not extra
manifest statuses. `support/proposal-review.md` records `accepted`,
`revision-required`, or `rejected`; `support/revisions/<revision-id>.md`
records parent-local coordination revisions. The review may update only the
parent manifest status to `accepted`, `rejected`, or `in-review`; revision may
change only parent-local coordination files and must route back to
`review-program`.

Program implementation prompt generation requires a fresh accepted parent
review receipt validated by `validate-proposal-review-gate.sh`. It also has a
separate child-readiness gate. For every required, non-deferred child, the
child-readiness gate requires required child metadata including
`change_profile`, a passing implementation-grade completeness review, an
accepted fresh proposal-review digest, declared packet-specific completeness
coverage, coherent predecessor/successor constraints, and satisfied declared
cutover constraints. The child-readiness gate authorizes prompt generation
only; it does not prove durable implementation has completed.

Parent program promotion and archival use the existing `promote-proposal` and
`archive-proposal` workflow ids. Promotion is allowed only after an accepted
fresh parent review, generated program implementation prompt, and parent-local
`support/implementation-run.md` with `verdict: pass` and
`child_authority_preserved: yes`. Archival is allowed only after parent
`implemented` status and parent-local `support/proposal-closeout.md` with
`verdict: pass`, `archive_authorized: yes`, and
`child_authority_preserved: yes`.

Program controller runs also retain a parent-owned execution record: a
hash-chained v2 event log, checkpoint, scheduler decision, recovery evidence,
optional mutation evidence, optional scaffold evidence, and aggregate closeout
receipt. These surfaces coordinate and explain the parent program only. They do
not satisfy child receipts or rewrite child lifecycle authority.

Program human exception grants are parent-run control evidence for typed
non-machine-provable boundaries. A grant only unblocks the named child route in
that program run; route execution records grant-consumption evidence before
dispatch, then writes and re-reads the delegation proof, and child receipts
remain child-owned. Recovery recipes are bounded by blocker class, retry budget,
preconditions, post-attempt validation, and live replanning. `unsafe-resume` and
`authority-boundary-ambiguous` remain fail-closed.

`program-atomic` is explicit opt-in and means staged barrier coordination with
declared stage, commit, rollback, or compensation routes. It is not universal
transactionality. Interrupted barriers are resumed from the event log; ambiguous
committed state or missing compensation fails closed as `blocked-unsafe`.
