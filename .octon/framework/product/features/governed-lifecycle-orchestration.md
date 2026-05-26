# Governed Lifecycle Orchestration

Governed Lifecycle Orchestration is the product capability for
extension-declared lifecycle contracts. It combines the Lifecycle Runner with
the Lifecycle Executor Adapter so a declared lifecycle can plan, gate, dispatch
eligible routes, observe receipts, checkpoint, resume, and continue until a
terminal outcome or explicit block.

Governed means self-operating execution is allowed only through approved
Lifecycle Runner and Lifecycle Executor Adapter mechanisms. It must never
self-approve; it does not mint authority, widen scope, bypass human-only
boundaries, or treat generated outputs, proposal-local receipts, host state,
chat state, tool availability, or model memory as authority.

The proposal packet lifecycle is the first concrete single-target pilot. It
exercises packet creation, review, revision, re-review, acceptance or rejection,
implementation prompt generation, implementation, promotion,
verification/correction, closeout, and archival without adding new proposal
manifest statuses.

Proposal packet route progression is phase-aware through lifecycle contract v2.
The Lifecycle Phase-Loop Model uses the contract's generic `phase_loop`
primitive to supply validated phase ids, route/receipt/gate/validator/loop/
terminal references, backward transitions, finite loop bounds, and terminal
stop classes. The Lifecycle Runner records
`current_phase`, phase counts, phase blockers, and phase transition events in
durable run plans, checkpoints, summaries, and hash-chained packet lifecycle
event logs. Phase context never authorizes execution; implementation,
promotion, closeout, and archival still require fresh receipts, validators,
scope checks, authority-boundary checks, and route delegation proof.

Governed Lifecycle Orchestration also supports proposal-program lifecycles for
parent program packets that coordinate multiple child proposal packets. Program
runs plan child targets from a structured parent-owned child registry, schedule
sequential, gated-parallel, approval-gated, proven-independent parallel, or
explicit-opt-in `program-atomic` batches, retain program evidence separately
from child receipts, checkpoint target-level state, replay durable program
events, verify replay from hash-chained v2 event logs, render non-authoritative
status read models, apply digest-guarded parent registry mutations, scaffold
safe parent programs from seed/reference inputs, and resume idempotently. Child
packets keep their own lifecycle truth, subtype manifests, receipts, promotion
targets, validation verdicts, and archive metadata.

## Boundary

The Lifecycle Runner owns governed lifecycle orchestration for the source
extension lifecycle: planning, source lifecycle route selection within
extension-declared lifecycle contracts, gates, receipt freshness and
completeness, stale receipt detection, loop bounds, phase evaluation, evidence,
checkpoints, resume, and idempotency. It does not select routes for target
lifecycles named by interaction receipts; Change closeout route authority
remains with the default-work-unit policy.

The Lifecycle Executor Adapter owns route execution: prompt or workflow
invocation, generic input binding, completion observation, approval pauses,
timeouts, cancellation, retries, and structured execution results.

Governed Lifecycle Orchestration uses generated effective projections as
runtime-discovered handles. Raw additive extension inputs are authoring inputs
only, and proposal-local receipts remain evidence only.
Generated projections may expose `phase_loop` to the runner, but they remain
derived publications and do not become source authority.

Effective catalog lifecycle discovery treats an absent `lifecycle_contracts`
field and an explicit empty `lifecycle_contracts: []` list as "no lifecycle
contracts." A non-empty lifecycle contract declaration requires the
`lifecycle-contract` capability profile and a valid generated lifecycle contract
projection. Missing projections, malformed non-empty declarations, or non-empty
declarations without the required capability profile fail closed.

When a lifecycle route is unavailable and an operator uses a fallback/manual
creation path, the fallback must be retained as run evidence under
`.octon/state/evidence/runs/<run-id>/receipts/**` or another
validator-checked receipt contract before closeout. A proposal-local receipt may
disclose fallback use, but it is not proof that Governed Lifecycle
Orchestration executed the route.

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

Program implementation prompt generation is fail-closed behind the program
child-readiness gate. Required, non-deferred child packets must declare required
metadata including `change_profile`, pass their child-owned
implementation-grade completeness review, pass an accepted proposal-review gate
with a fresh packet digest, satisfy declared packet-specific readiness
requirements from source lineage or parent child-packet contracts, and satisfy
declared predecessor/successor and cutover constraints. This is a proposal
readiness gate only; it does not require implementation receipts or prove that
durable implementation exists.

## Lifecycle Interaction Receipts

Lifecycle-to-lifecycle dependency handling is modeled as durable interaction
receipts, not as a lifecycle bus. A source lifecycle may emit a
`lifecycle-interaction-request-v1` receipt when it discovers follow-on work
owned by another lifecycle. The request carries scoped context, evidence refs,
expected return evidence, and explicit forbidden authority-transfer rules. It
does not authorize the target lifecycle, widen scope, satisfy target gates, or
transfer Git, hosted-provider, promotion, archive, cleanup, or closeout
authority.

The target lifecycle may use the request as advisory context only. It must
independently validate scope, authority, freshness, rollback posture, receipts,
gates, hosted controls, delegation proof, and target-owned policy before any
effectful route action. The Lifecycle Runner may record validated interaction
request and return refs in checkpoints, event logs, and route execution
requests so operators can see dependency context. The Lifecycle Executor
Adapter receives those refs as non-authorizing context and must still enforce
the selected route's delegation contract and required receipts.

Closeout-facing interactions follow the same boundary. A proposal lifecycle
request to Change closeout, closeout-worktree, or repo-hygiene cleanup is
advisory context only; target lifecycle ownership remains with the target
lifecycle. Proposal phases, proposal-local receipts, generated projections,
host state, and lifecycle events do not grant route selection, hosted landing,
branch cleanup, cleanup deletion, receipt completion, or evidence-gate
authority.

`handoff` is one interaction profile within this receipt model. It is not the
whole abstraction. Source lifecycles cannot claim that an interaction
dependency is resolved until a valid `lifecycle-interaction-return-v1` receipt
cites fresh return evidence from the consumer lifecycle. Missing, stale,
dangling, ambiguous, unsafe, or out-of-scope interaction evidence fails closed.

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
- `/octon-proposal-run-packet-lifecycle`
- `octon-proposal-lifecycle-run-packet-lifecycle`
- `/octon-proposal-run-program-lifecycle`
- `octon-proposal-lifecycle-run-program-lifecycle`

## Validation

Focused validation lives in the Lifecycle Runner, Lifecycle Executor Adapter,
lifecycle contract, and proposal lifecycle acceptance tests referenced by the
product feature catalog. The Governed Lifecycle Control Loop is explanatory
prose for this evidence-driven plan, gate, dispatch, observe, checkpoint,
resume, and fail-closed behavior; it is not a component name.

## Roadmap

Follow-up work is tracked in
`.octon/framework/product/roadmap/governed-lifecycle-orchestration.md`. The
end-to-end governed lifecycle loop itself is implemented; roadmap entries
capture future improvements only.
