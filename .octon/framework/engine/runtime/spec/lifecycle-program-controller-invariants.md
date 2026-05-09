# Lifecycle Program Controller Invariants

Status: authored runtime spec

This spec defines the closeout invariants for Lifecycle Autopilot
proposal-program orchestration and Program Controller behavior. It is a
runtime-owned review and validation contract: implementation, schemas,
lifecycle contracts, generated projections, product claims, and tests must
either satisfy these invariants or explicitly document the unsupported portion
with a fail-closed support claim.

These invariants do not create proposal manifest statuses, child packet
authority, or generated-output authority. They define the conditions that must
hold before proposal-program support can be treated as closeout-ready.

## Invariants

| ID | Invariant |
| --- | --- |
| `LA-PC-001` | Single-target compatibility: proposal-program behavior must not change existing single-target lifecycle CLI behavior, checkpoint shape, resume semantics, receipts, approval gates, or terminal outcomes. |
| `LA-PC-002` | No new proposal statuses: program runtime states such as `blocked-unsafe`, `partial`, or `completed` are runtime result states only and must never be introduced as proposal manifest statuses. |
| `LA-PC-003` | Generated-effective discovery: runtime lifecycle discovery must use generated effective projections, not raw additive inputs, roadmap notes, docs, or proposal-local receipts as runtime authority. |
| `LA-PC-004` | Schema/runtime parity: every identifier, enum, path, digest, mode, blocker class, mutation action, scaffold field, event field, and recovery profile accepted by runtime must satisfy the corresponding schema; every schema-rejected unsafe value must be runtime-rejected. |
| `LA-PC-005` | Parent coordinates only: a parent program may coordinate sequence, dependencies, scheduling, recovery, evidence summaries, mutation of its own child registry, and aggregate closeout only. It must not own child lifecycle truth. |
| `LA-PC-006` | Child authority ownership: child manifests, receipts, validation verdicts, promotion targets, archive metadata, acceptance criteria, subtype manifests, and terminal lifecycle outcomes remain child-owned. Parent evidence cannot satisfy or overwrite them. |
| `LA-PC-007` | Receipt integrity: child receipts must be target-local, child-owned, complete, fresh where freshness is declared, and digest-checked against live child state. File existence alone is never sufficient for closeout. |
| `LA-PC-008` | Evidence separation: program evidence may summarize child outcomes, scheduler decisions, recovery attempts, mutations, scaffold output, replay status, and aggregate closeout, but it must never substitute for child receipts or child authority surfaces. |
| `LA-PC-009` | Approval binding: program approval grants must bind to the current run, child id, route id, blocker class where applicable, and current registry digest where practical. Approval consumption must write `program-approved` execution evidence. |
| `LA-PC-010` | Durable mutation approval: durable mutation routes must remain approval-gated. Program approval must not become self-approval, implicit approval, or a bypass for durable mutation authority. |
| `LA-PC-011` | Recovery truthfulness: every declared recovery recipe or handler must be executable as declared or rejected/narrowed. Retry budget, approval requirement, preconditions, idempotency class, dependent handling, replan behavior, and post-attempt validation cannot be documentation-only. |
| `LA-PC-012` | Non-recoverable blockers: `unsafe-resume` and `authority-boundary-ambiguous` are fail-closed and never automatically recoverable. |
| `LA-PC-013` | Event/checkpoint convergence: every control-plane mutation must either append the required event and update checkpoint event metadata, or fail before externally meaningful work proceeds. Replay verification must detect divergence. |
| `LA-PC-014` | Replay fail-closed: verified replay must fail closed on missing offsets, duplicate offsets, hash-chain breaks, impossible transitions, checkpoint/event divergence, registry digest drift, and unsafe resume state. |
| `LA-PC-015` | Lock integrity: every acquired child or program lock must be released or explicitly recorded as stale/unsafe on every exit path, including event append failure, job construction failure, executor error, thread panic, cancellation, and resume failure. |
| `LA-PC-016` | Scheduler safety: parallel execution is allowed only when child target paths, selected routes, locks, and declared write scopes prove independence. Unknown or overlapping write scopes must serialize only when explicitly allowed, otherwise fail closed. |
| `LA-PC-017` | Atomic boundary: `program-atomic` means explicit staged barrier recovery only. It requires v2 registry shape, route-level atomic metadata, all required non-deferred participants, participant locks, stage-all-before-commit, barrier verification, rollback on stage failure, compensation on commit failure, and `blocked-unsafe` for ambiguous partial state. |
| `LA-PC-018` | Mutation control: mutation apply must require current registry digest, safe paths, no dependency cycles, valid identifiers, valid replacements, preserved supersession/replacement evidence, operator reason, and no parent/child authority weakening. |
| `LA-PC-019` | Scaffold safety: scaffold may create parent program surfaces from seed/reference inputs only when paths are safe and non-overwriting, unless an explicit tested overwrite mode exists. It must not create the real Governed Workflow Runtime transition program by implication. |
| `LA-PC-020` | Aggregate closeout completeness: aggregate closeout cannot pass with stale or missing child receipts, unresolved blockers, invalid child terminal outcomes, missing or dangling deferral/supersession/rejection evidence, authority ambiguity, parent-owned child surfaces, or missing aggregate evidence. |
| `LA-PC-021` | Documentation honesty: product docs, roadmap, lifecycle model, lifecycle contracts, schemas, generated projections, CLI help, and tests must describe the same supported behavior and limitations. |
| `LA-PC-022` | Support boundary: no claim may imply external workflow engines, Durable Objects, MCP integration, workflow runtime statecharts, task-specific execution harnesses, agent-node contracts, or universal transactionality unless implemented and validated. |

## Enforcement Contract

Each invariant must have at least one enforcement point and one negative
regression test before it can be marked satisfied for closeout. Valid
enforcement points are:

- runtime checks in the lifecycle program controller;
- lifecycle contract rules;
- JSON Schema constraints;
- assurance scripts or validators;
- focused unit, integration, replay, or acceptance tests;
- product documentation that narrows an intentionally unsupported behavior.

Passing tests alone are not sufficient when schemas, generated projections,
runtime behavior, and support claims disagree. A closeout review must evaluate
the integrated system.

## Closeout Rule

Closeout is blocked when any invariant is violated, untested, or claimed only
in documentation unless the relevant capability is explicitly unsupported,
fails closed at runtime, and the limitation is reflected in product/support
claims.
