# Governed Incoming Intake Routing

Governed Incoming Intake Routing is the additive `.incoming/<intake-id>`
admission layer inside `process-incoming-intake`. It accepts one explicitly
provided raw additive intake unit, invokes the existing intake envelope
validator as the first gate, classifies the intake deterministically, selects
exactly one target-owned route or fails closed, and records replayable evidence
without letting raw intake become authority.

The mature route set is intentionally small:

- `single-work-unit-handoff` for straightforward extension packs, core skills,
  or coherent single-surface additions that should enter proposal packet
  admission.
- `coordinated-program-handoff` for multi-surface, staged, dependent,
  migration, cutover, or governance-plus-runtime additions that should enter
  proposal program admission.
- `target-owned-direct-handoff` for future non-proposal targets with explicit
  target-owned intake admission contracts. This route is disabled until those
  contracts exist.
- `blocked-rejected-deferred` for malformed, unsafe, ambiguous, unsupported,
  unverifiable, low-value, deferred, stale, or authority-confused intake.

## Boundary

Incoming intake routing owns explicit intake binding, envelope validation
invocation, deterministic classification, route decision evidence, denial
evidence, advisory handoff packaging, target invocation bookkeeping, and target
return references.

It does not own raw-intake authority, proposal packet or program authority,
Change implementation authority, Git mutation, branch cleanup, worktree
cleanup, repo hygiene deletion, promotion, archival, target lifecycle state, or
target completion claims.

Proposal packet and proposal program admission are target-owned. The intake
workflow may request admission through a non-authorizing handoff, but proposal
lifecycle surfaces own packet or program creation receipts, review/revision,
implementation readiness, implementation routing, verification/correction,
proposal closeout, archival, and proposal-local receipt boundaries.

Governed Lifecycle Orchestration may plan, gate, dispatch, observe,
checkpoint, resume, and fail closed for proposal lifecycles after target-owned
admission. It does not make the intake workflow a lifecycle bus. Change
closeout, closeout-worktree, and repo-hygiene cleanup remain separate
target-owned follow-on routes with their own validation, authority, mutation,
receipts, and returns.

Raw intake, proposal packets, generated outputs, host state, chat history,
model memory, tool availability, and lifecycle interaction receipts are not
runtime, policy, closeout, cleanup, or retained-evidence authority.

## Evidence Model

Route decisions retain the envelope digest, meaningful payload inventory,
payload inventory digest, excluded noise, classification facts, selected route,
rejected routes, requested-route handling, rationale, and denial evidence.

Handoffs retain advisory target context, source intake digest, scope digest,
forbidden authority transfers, target admission contract references, expected
target return evidence, target-owned preflight result references, route
execution request/result references, and target return references when present.

Reclassification is idempotent for the same explicit intake, authoritative
state, and payload digest. Re-running after target creation must resume or
reference a digest-compatible target-owned run; it must not create duplicate
proposal packets or proposal programs.

## Operator Entry Points

- `/process-incoming-intake <intake-id>`
- `/process-incoming-intake <intake-id> --stop-after-classification`
- `/process-incoming-intake <intake-id> --execute-handoff`
- `/process-incoming-intake <intake-id> --requested-route <route>`

Default execution validates, classifies, creates target-owned handoff context
when eligible, and stops when target dispatch is unavailable. Mutating handoff
requires a valid target-owned admission contract and later runtime support.

## Validation

Focused validation lives in the incoming intake envelope validator, Governed
Incoming Intake Routing fixture validator, target admission contract schemas,
lifecycle interaction receipt validators, lifecycle contract validator, and
product feature catalog validator.

The current implementation is stage-only: contracts, workflow documentation,
fixtures, and validators exist, but real proposal creation, GLO dispatch,
extension installation, Change closeout, worktree cleanup, repo hygiene
deletion, and intake archival are not performed by the routing validator.
