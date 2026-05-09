# Lifecycle Autopilot: End-To-End Lifecycle Automation Loop

Lifecycle Autopilot is the generic lifecycle orchestration and execution
mechanism for extension-declared lifecycle contracts. It combines the lifecycle
runner with the lifecycle executor adapter so a declared lifecycle can plan,
gate, execute, observe receipts, checkpoint, resume, and continue until a
terminal outcome or explicit block.

The proposal packet lifecycle is the first concrete single-target pilot. It
exercises packet creation, review, revision, re-review, acceptance or rejection,
implementation prompt generation, implementation, promotion,
verification/correction, closeout, and archival without adding new proposal
manifest statuses.

Lifecycle Autopilot also supports proposal-program lifecycles for parent
program packets that coordinate multiple child proposal packets. Program runs
plan child targets from a structured parent-owned child registry, schedule
sequential, gated-parallel, approval-gated, proven-independent parallel, or
explicit-opt-in `program-atomic` batches, retain program evidence separately
from child receipts, checkpoint target-level state, replay durable program
events, verify replay from hash-chained v2 event logs, render non-authoritative
status read models, apply digest-guarded parent registry mutations, scaffold
safe parent programs from seed/reference inputs, and resume idempotently. Child
packets keep their own lifecycle truth, subtype manifests, receipts, promotion
targets, validation verdicts, and archive metadata.

## Boundary

The lifecycle runner owns orchestration: planning, route selection, gates,
receipt freshness and completeness, stale receipt detection, loop bounds,
evidence, checkpoints, resume, and idempotency.

The lifecycle executor adapter owns route execution: prompt or workflow
invocation, generic input binding, completion observation, approval pauses,
timeouts, cancellation, retries, and structured execution results.

Lifecycle Autopilot uses generated effective projections as runtime discovery
authority. Raw additive extension inputs are authoring inputs only, and
proposal-local receipts remain evidence only.

Proposal-program closeout readiness is governed by
`.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`.
The invariant spec is the review contract for keeping runtime behavior,
schemas, lifecycle contracts, generated projections, tests, and support claims
aligned.

Program-level runtime result states are execution state only. They do not add
proposal manifest statuses, and parent program evidence cannot satisfy child
packet receipts. Executable `program-atomic` runs require v2 child registries,
declared write scopes, explicit route-level stage/commit/rollback or
compensation metadata, barrier verification, and approval-compliant recovery
behavior. Atomic support is barrier recovery, not universal transactionality;
ambiguous committed state or missing compensation remains `blocked-unsafe`.
Program approval grants are retained as program evidence and consumed on
`retry`/`resume` as `program-approved` route approval evidence; durable mutation
routes still require explicit operator approval and never self-approve. Program
mutation apply requires an operator reason and a current child registry digest,
validates registry drift, dependency cycles, parent/child path ambiguity,
supersession evidence, and authority-boundary weakening. Program scaffold
support generates parent-program surfaces only, refuses to overwrite existing
parent files, and does not create the Governed Workflow Runtime transition
program.

## Operator Entry Points

- `octon lifecycle plan --lifecycle <id> --target <path>`
- `octon lifecycle run --lifecycle <id> --target <path>`
- `octon lifecycle run --lifecycle proposal-program --target <parent-program-packet> --max-child-concurrency <n>`
- `octon lifecycle resume --run-id <id>`
- `octon lifecycle program inspect --run-id <id>`
- `octon lifecycle program replay --run-id <id> [--verify]`
- `octon lifecycle program status --run-id <id> [--format json|text]`
- `octon lifecycle program explain-blockers --run-id <id>`
- `octon lifecycle program approve --run-id <id> --child <id> --route <id> --reason <text>`
- `octon lifecycle program retry --run-id <id> [--child <id>]`
- `octon lifecycle program cancel --run-id <id> --reason <text>`
- `octon lifecycle program propose-mutation --run-id <id> --spec <path>`
- `octon lifecycle program apply-mutation --run-id <id> --spec <path> --reason <text>`
- `octon lifecycle program scaffold --target <parent-program-packet> --spec <path> [--dry-run]`
- `/octon-proposal-packet-run-lifecycle`
- `octon-proposal-packet-lifecycle-run-lifecycle`

## Validation

Focused validation lives in the lifecycle runner, lifecycle executor adapter,
lifecycle contract, and proposal lifecycle acceptance tests referenced by the
product feature catalog.

## Roadmap

Follow-up work is tracked in
`.octon/framework/product/roadmap/lifecycle-autopilot.md`. The end-to-end
lifecycle automation loop itself is implemented; roadmap entries capture future
improvements only.
