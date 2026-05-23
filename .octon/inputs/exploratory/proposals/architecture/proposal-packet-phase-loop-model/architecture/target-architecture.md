# Target Architecture

## Decision

Adopt a layered Proposal Packet Phase-Loop Model.

The generic lifecycle substrate should define a reusable phase-loop execution
contract. The proposal lifecycle extension should bind that generic contract to
proposal packet phases, routes, receipts, gates, and operator documentation.

This is a clean-break target for later implementation. No transitional live
dual model should remain after cutover. Compatibility may exist only inside the
implementation branch until all validators, publication receipts, and generated
projection refresh steps pass.

## Model Vocabulary

`phase`: A named lifecycle segment with entry evidence, allowed route set,
required gates, exit evidence, stop classes, checkpoint obligations, and
event-log obligations.

`phase loop`: A bounded repeat policy attached to a phase or phase pair. It
records the receipt or condition that repeats the phase, terminal values that
exit the loop, iteration or dispatch limits, and fail-closed behavior when the
limit is exhausted.

`route`: A proposal-extension or workflow operation that may execute inside a
phase only when its declared entry conditions and gates pass.

`gate`: A validator-backed or receipt-backed condition required before a route
or phase exit.

`receipt`: A structured evidence artifact with required fields, verdicts, and
freshness rules. Proposal-local receipts are packet evidence only.

`checkpoint`: Durable runner control state that records current phase, selected
route, gate results, receipt state, event-log head, stop class, and resume
instructions.

`event`: A hash-chained record of planning, handoff, dispatch, status, budget,
control, phase entry, phase exit, loop iteration, cancellation, or fail-closed
stop behavior.

`self-regulating`: The lifecycle evaluates durable state, detects stale or
incomplete evidence, selects the next legal route, enforces loop bounds, and
blocks or escalates.

`self-operating`: The lifecycle may dispatch eligible routes through the
runner/executor when authority, receipts, gates, scope, and delegation proof
are present.

`not self-authorizing`: The lifecycle never mints authority, widens scope,
bypasses human-only boundaries, or treats proposal-local receipts, generated
projections, GitHub/CI, chat, browser state, tools, or model memory as
authority.

## Phase Set

The proposal packet lifecycle should express these phases without adding
proposal manifest statuses:

| Phase | Owner | Exit Evidence | Loop/Backtrack |
| --- | --- | --- | --- |
| `target-binding-and-lifecycle-discovery` | substrate/runner | effective lifecycle handle, target or source input, run inputs, authority envelope | stop on missing handle, invalid input, stale projection |
| `packet-creation` | proposal extension/executor | `proposal.yml`, source lineage, `support/proposal-creation.md` | back to binding if source is missing or invalid |
| `structural-validation` | validator/runner | base and subtype validators pass | back to creation when packet files are incomplete; otherwise block |
| `implementation-grade-completeness` | proposal extension/validator | completeness receipt passes with zero unresolved questions | revise packet until bound |
| `review-and-revision` | proposal extension/human governance where needed | fresh accepted or rejected review receipt | `revision-required` -> revise -> review, bounded |
| `implementation-authorization` | validator/runner | strict review gate, fresh digest, implementation authorized | stale or missing review -> review |
| `implementation-prompt-generation` | proposal extension/executor | executable implementation prompt | back to completeness or review if prompt readiness fails |
| `implementation-execution` | executor/proposal extension | implementation-run receipt and durable evidence refs | retry bounded; scope change -> revision |
| `promotion` | workflow/runner | manifest becomes `implemented` from valid implementation evidence | stop on missing authority, stale receipt, or generated-source drift |
| `verification-and-correction` | proposal extension/validator | implementation conformance and post-implementation drift receipts pass | correction -> verify; packet error -> revision |
| `closeout-and-hygiene` | proposal extension/validator | proposal-closeout receipt passes and hygiene is clear or blocker is recorded | hygiene blocker -> handoff or escalate |
| `archival` | workflow/runner | manifest becomes `archived` | terminal |
| `terminal-explanation-reporting` | runner | final verdict, phase, receipts, blockers, and next route | no mutation |

No new proposal statuses are justified. These phases belong in contract,
checkpoint, and event state, not in `proposal.yml#status`.

## Contract Model

The target contract model is `schema_version:
octon-extension-lifecycle-contract-v2` with a generic `phase_loop` primitive.
The primitive references existing `routes`, `receipts`, `gates`,
`validators`, `loops`, and `terminal_outcomes`; it must not duplicate route
predicates or become a proposal-specific schema.

Required shape:

```yaml
schema_version: octon-extension-lifecycle-contract-v2
phase_loop:
  model_version: phase-loop-v1
  phases:
    - phase_id: review-and-revision
      mode: loop
      owner_layer: proposal-extension
      route_refs: [review-packet, revise-packet]
      receipt_refs: [proposal-review]
      gate_refs: []
      entry_when: { ...conditionSet... }
      exit_when: { ...conditionSet... }
      exit_evidence_refs: [proposal-review]
      re_entry_triggers: [receipt-stale, revision-required]
      backward_transitions:
        - to_phase_id: structural-validation
          when: { ...conditionSet... }
      loop_bounds:
        max_phase_iterations: 5
        max_route_dispatches: 5
      stop_conditions:
        - stop_class: blocked-human
          when: { ...conditionSet... }
      authority_boundaries: [scope-expansion, stale-evidence-acceptance]
```

Every phase id, route ref, receipt ref, gate ref, validator ref, loop ref,
terminal ref, and backward-transition target must resolve. Terminal phases must
not dispatch routes. Phase loop bounds must be finite.

## Substrate Responsibilities

The generic lifecycle substrate should own:

- phase declaration parsing and validation;
- phase entry, phase exit, and loop evaluation;
- route selection inside the current phase;
- current phase evaluation from durable manifest, receipt, gate, checkpoint,
  and event evidence;
- allowed transition and backward-transition enforcement;
- gate evaluation and stale receipt detection;
- dispatch and iteration budgets;
- phase attempt counts and route dispatch counts;
- fail-closed stop class normalization;
- checkpoint shape and resume validation;
- cancellation handling;
- hash-chained event-log append and replay validation;
- separation of runner orchestration from executor route invocation;
- proof that generated projections are runtime discovery handles only.

The substrate must not own proposal semantics such as packet status meaning,
review verdict vocabulary, implementation-grade completeness criteria, archive
disposition, or child packet authority.

## Proposal-Extension Responsibilities

The proposal lifecycle extension should own:

- the concrete proposal packet phase list;
- mapping phases to existing routes and receipts;
- completeness, review, implementation, conformance, drift, closeout, hygiene,
  and archive receipt requirements;
- readiness validator ownership;
- revision-required semantics;
- implementation-allowed semantics;
- correction-versus-revision semantics;
- review and revision loop policy;
- implementation authorization gates;
- implementation, promotion, verification, closeout, and archive route
  prerequisites;
- packet-local receipt fields and freshness rules;
- proposal packet creation and review prompt bundle behavior;
- user-facing command and skill documentation;
- proposal lifecycle acceptance scenarios;
- explicit non-authority notices for proposal-local and generated surfaces.

The extension must not grant authority, bypass runner gates, or make proposal
receipts substitute for retained run evidence.

## Runner And Executor Boundary

The runner owns the plan-evaluate-checkpoint-observe loop. It selects one
phase and one route, evaluates gates and receipts, writes checkpoints and
events, and stops at a handoff unless explicit route execution is requested and
authorized.

The executor adapter owns actual route invocation and completion observation.
It receives a bounded request with route, target, input bindings, receipt
specs, delegation contract, timeout, cancellation token, and invocation
authority. It returns a structured result. It does not select phases, change
lifecycle authority, waive gates, or infer proposal acceptance.

Self-operating execution means governed execution through these approved
runner and executor mechanisms. It does not mean self-authorization.

## Checkpoint And Event Model

Runner checkpoints must record:

- `current_phase`;
- `phase_counts`;
- `last_phase_transition`;
- `phase_blockers`;
- selected route;
- receipt freshness;
- gate results;
- event-log head;
- final or current stop class;
- resume command or refusal reason.

Packet event logs must append hash-chained records for:

- `phase-entered`;
- `phase-exited`;
- `phase-backtracked`;
- `phase-blocked`;
- route dispatch start and finish;
- stale receipt detection;
- budget exhaustion;
- cancellation;
- fail-closed blocker classification.

The event schema must include `phase_id` and `transition_id` when the event is
phase-scoped. Replay must verify event chain integrity, checkpoint/event-head
convergence, legal transition order, loop-bound adherence, and impossible
transition denial.

## Authority Boundary

Implementation, promotion, closeout, and archival remain gated by fresh
receipts, validators, scope checks, authority-boundary checks, and retained
evidence. When any required proof is missing, stale, contradictory, out of
scope, or authority-ambiguous, the lifecycle fails closed with a preserved
checkpoint and an operator-visible blocker.
