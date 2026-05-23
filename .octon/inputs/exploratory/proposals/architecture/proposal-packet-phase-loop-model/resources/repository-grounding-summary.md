# Repository Grounding Summary

## Constitutional And Proposal Boundaries

Repository ingress and constitutional files require authored authority to stay
under `framework/**` and `instance/**`, generated outputs to stay derived-only,
and raw `inputs/**` to avoid becoming runtime or policy authority. Proposal
packets are temporary implementation aids. This packet therefore proposes
future durable changes but does not implement them.

## Lifecycle Autopilot Findings

`lifecycle-autopilot.md` describes a generic lifecycle runner and lifecycle
executor adapter that can plan, gate, execute, observe receipts, checkpoint,
resume, and continue until terminal or blocked outcomes. It also explicitly
states that the runner owns orchestration, while the executor adapter owns route
execution.

The feature note confirms:

- proposal packet lifecycle is the first concrete single-target pilot;
- proposal-program lifecycle coordinates child packets while preserving child
  authority;
- raw additive inputs are authoring inputs only;
- generated effective projections are runtime-discovered handles;
- proposal-local receipts are evidence only;
- fallback or manual paths require retained run evidence before closeout.

## Proposal Packet Lifecycle Contract Findings

`lifecycle.contract.yml` currently declares:

- `execution_strategy: route-progression`;
- allowed proposal statuses without additional loop statuses;
- validators for proposal standard, readiness, and review gates;
- gates for implementation-grade readiness and implementation authorization;
- receipts for creation, review, implementation-grade completeness,
  implementation run, conformance, post-implementation drift, and closeout;
- one review/revision loop with `max_iterations: 5`;
- routes for create, review, revise, implementation prompt generation,
  implementation, promotion, verification/correction, closeout, and archive.

The contract already has most ingredients for phase-loop execution, but they
are not grouped under first-class phase declarations.

## Lifecycle Model Findings

`lifecycle-model.md` confirms that:

- review and revision are receipt-driven loops, not proposal statuses;
- runner orchestration and executor route invocation are separate;
- non-execute handoffs do not consume loop iterations;
- executed routes consume bounded loop attempts;
- packet runs write hash-chained `lifecycle-events.ndjson`;
- event logs do not replace checkpoints, manifests, receipts, promotion
  evidence, or closeout evidence;
- cancellation is durable and prevents later dispatch.

## Schema Findings

`extension-lifecycle-contract.schema.json` currently supports lifecycle
identity, execution strategy, target manifest, states, terminal outcomes,
validators, gates, receipts, loops, program declarations, routes, route
delegation contracts, and route completion conditions. It does not yet model
phase entry, phase exit, phase-scoped loop policy, checkpoint obligations, or
event obligations as first-class schema concepts.

`lifecycle-run-event.schema.json` supports hash-chained packet event records
with lifecycle id, execution strategy, target, event index, event type,
category, step details, route id, final verdict, and string data. Current
event categories are lifecycle, planning, handoff, dispatch, status, budget,
and control. Phase entry, phase exit, loop iteration, and checkpoint
convergence can be represented only indirectly today.

## Change Closeout Findings

`change-closeout-state-machine.md` already declares a route-neutral phase loop
with phase modes, exit evidence, stop or escalation behavior, evidence gates,
cleanup safety, receipt evidence, and final verification. It preserves route
selection in the default work-unit policy and does not create a competing route
authority. This is a strong local precedent for phase-loop vocabulary, but it
is not yet reusable lifecycle substrate.

## Skill Findings

`octon-proposal-lifecycle/SKILL.md` requires proposal packets to remain
temporary and non-canonical. It requires implementation-grade completeness
before presenting a packet as final or implementation-ready, and it forbids
implementation prompt generation or promotion without a fresh accepted review
receipt.

`octon-proposal-lifecycle-run-packet-lifecycle/SKILL.md` confirms the runner
resolves `proposal-packet` from published effective extension catalog output,
reconstructs state from `proposal.yml` and support receipts, writes run
evidence and a checkpoint, and stops at route-ready unless execute-routes is
requested.

## Runtime Implementation Findings

`lifecycle.rs` currently models execution strategy, stop classes, step budget,
run event structure, plan result, receipt state, gate result, and run result.
`lifecycle_driver.rs` runs a plan-execute-replan loop with step budget,
dispatch events, max-step stops, and route execution through the shared
executor. The executor adapter validates request paths, observes manifest
status and receipts, checks cancellation, checks required inputs, performs
authorization before dispatch, preflights executor availability, and writes a
structured route execution result.

These surfaces support the layered target because they already separate
planning, authorization, dispatch, observation, checkpointing, and evidence.
