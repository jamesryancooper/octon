# Mature Harmony Orchestration Model

## North Star

Harmony's mature orchestration model should optimize for:

- AI-native execution
- system-governed autonomy
- deterministic evidence
- bounded, inspectable runtime behavior
- explicit human authority over policy, exceptions, and escalation

The target state is not "the system acts without humans." The target state is
"the system acts autonomously inside explicit authority and evidence
boundaries."

## Core Thesis

A mature orchestration system should separate:

- why work exists,
- what work should happen,
- when work should run,
- how work runs,
- what happened during execution,
- what happens when normal execution fails.

Those concerns map cleanly to distinct surfaces:

| Concern | Surface |
|---|---|
| Strategic objective | `campaigns` |
| Bounded initiative | `missions` |
| Bounded procedure | `workflows` |
| Recurrence and trigger policy | `automations` |
| Event detection | `watchers` |
| Buffered intake | `queue` |
| Execution instance and evidence | `runs` |
| Exception and containment flow | `incidents` |

## Mature-Core Versus Scale Surfaces

### Mature-Core Surfaces

These are the surfaces that matter most to a robust Harmony runtime:

- `workflows`
- `missions`
- `runs`

They are sufficient to support:

- bounded procedure execution,
- bounded multi-session initiatives,
- trustworthy execution evidence and replay/debug context.

### Autonomy Layer

These surfaces extend the core with unattended operation:

- `automations`

### Event-Driven Scale Layer

These surfaces become useful when Harmony starts reacting to more signals or
handling more asynchronous load:

- `watchers`
- `queue`

### Operational Override Layer

This surface handles abnormal conditions and controlled recovery:

- `incidents`

### Strategic Coordination Layer

This surface is optional and helps when multiple missions need shared planning:

- `campaigns`

## Design Principles

1. One surface, one primary job.
2. Runtime autonomy must stay policy-bounded.
3. Evidence must be first-class for any material autonomous action.
4. Long-lived state must be explicit, not inferred from logs or ad hoc files.
5. Workflow definitions must stay bounded and reusable.
6. Recurrence belongs in launch surfaces, not procedure surfaces.
7. Incident handling must stay visible and controllable.
8. Portfolio coordination is optional and should not complicate the core model.

## Canonical Boundaries

### What `workflows` should not become

- schedulers
- daemons
- alert listeners
- long-lived controllers
- portfolio containers

### What `missions` should not become

- an all-purpose task tracker for everything
- an incident-response ledger
- a workflow registry
- a strategic portfolio surface

### What `runs` should not become

- the place where new intent is defined
- a replacement for mission state
- a dumping ground for general notes

## Recommended Position

Harmony should frame the orchestration system as:

`AI-native, highly autonomous, and system-governed`

That phrase aligns better with Harmony's explicit goal than `fully autonomous`,
because Harmony's actual doctrine preserves human control over policy,
exceptions, and escalation.
