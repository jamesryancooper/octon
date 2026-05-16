# Agent Node v1

Agent Node v1 defines the runtime contract for admitting model-backed work as a
typed activity node inside an existing task-specific execution harness and
Workflow Statechart v1 overlay.

An agent node is a bounded activity record. It is not a queue, scheduler,
approval, grant, effect token, policy source, support-target admission, workflow
transition authority, or run closeout artifact.

## Canonical Binding

A valid agent node must bind to:

- a Run Lifecycle v1 run root under `/.octon/state/control/execution/runs/<run-id>`;
- a Workflow Statechart v1 state reconstructed from the canonical run journal;
- a Task-Specific Execution Harness v1 record;
- the Context Pack Builder v1 evidence used for model-visible context;
- Execution Authorization v1 and Authorized Effect Token v1 for any material
  effect the surrounding run may perform;
- support-target, model-adapter, capability-pack, and connector posture by
  reference only; and
- retained run evidence for receipts, model-visible context, cost/usage, output
  validation, replay, and terminal outcome.

The node may prepare or record an activity decision inside a governed run. It
does not authorize that run, mutate workflow state, mint grants, consume effect
tokens by itself, admit connectors, widen support claims, or close the run.
An agent node does not authorize execution and does not own workflow state.

## Required Record

The machine-checkable contract is:

- `agent-node-v1.schema.json`

Every record must include:

- node identity, run id, run root ref, harness ref, and workflow state ref;
- model-call policy ref and model-call receipt refs;
- input refs, output schema ref, and output validation evidence refs;
- context, token, cost, retry, fallback, timeout, and revocation policy refs;
- tool allowlist and connector refs as posture references only;
- terminal state and fail-closed routing for incomplete or invalid activity;
- retained evidence refs outside raw inputs and generated projections; and
- authority-boundary booleans fixed to false for execution authority,
  workflow-state ownership, transition authority, scheduling, queueing,
  grant minting, effect-token consumption, policy mutation, support widening,
  connector admission, and run closeout.

## Terminal States

Agent nodes may terminate only as:

- `succeeded`
- `failed`
- `denied`
- `stage_only`
- `revoked`
- `timed_out`
- `fallback_exhausted`
- `validation_failed`

Terminal state does not advance Run Lifecycle v1 by itself. Any lifecycle
movement still requires the canonical Run Journal append path.

## Fail-Closed Conditions

The node must fail closed when any required binding is missing, stale,
unverifiable, or mismatched, including:

- missing run root, harness binding, workflow state binding, or context-pack
  binding;
- stale or mismatched model-visible context digest;
- missing model-routing policy, model eligibility, model adapter, support
  tuple, budget, fallback, retry, cost/usage, output validation, or replay
  evidence;
- generated projections or raw inputs used as runtime, policy, control,
  support, or closeout authority;
- agent output claiming workflow transition, queue, schedule, closeout, grant,
  effect-token, policy, support, connector-admission, or runtime-cutover
  authority; and
- any activity that would require a connector, MCP permission, external
  workflow engine, generated/effective publication, support-target widening, or
  runtime crate behavior outside separately authorized routes.

## Relationship To Existing Contracts

Run Lifecycle v1, Workflow Statechart v1, Task-Specific Execution Harness v1,
Execution Authorization v1, Context Pack Builder v1, Authorized Effect Token v1,
Evidence Store v1, Policy Interface v1, support-target declarations, connector
admission posture, capability-pack governance, model-adapter declarations, and
fail-closed obligations remain canonical. Agent Node v1 references those
contracts and narrows model-backed activity; it does not replace them.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/agent-node-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/model-call-receipt-v1.md`
- `/.octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/workflow-statechart-v1.md`
- `/.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/instance/governance/policies/model-call-routing.yml`
