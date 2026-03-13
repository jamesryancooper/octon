---
title: Continuity Plane
description: Continuity architecture aligned to the active `.octon/continuity/` contract (`log.md`, `tasks.json`, `entities.json`, `next.md`).
---

# Continuity Plane

The Continuity Plane preserves operational memory so work can resume safely across sessions, agents, and humans.
It supports reliable agent execution by preserving deterministic evidence, maintaining observability for debugging, and keeping handoffs evolvable as the system changes.

## Core Question

What happened, what is active now, and what should happen next?

## Canonical Storage Contract

```text
.octon/continuity/
├── log.md
├── tasks.json
├── entities.json
├── next.md
├── decisions/
└── runs/
```

The four top-level files are the authoritative handoff contract for active
continuity state. `decisions/` and `runs/` are authoritative append-oriented
evidence surfaces.

## File Responsibilities

### `.octon/continuity/log.md`

- Append-first chronological activity history.
- Records: decisions made, commands run, outcomes, blockers, and handoff notes.
- Purpose: auditable timeline and context reconstruction.

### `.octon/continuity/tasks.json`

- Structured queue of active and deferred work.
- Canonical statuses: `pending`, `in_progress`, `blocked`, `completed`, `cancelled`.
- Active work (`pending`, `in_progress`, `blocked`) requires ownership, blocker state, acceptance criteria, and knowledge links.
- Purpose: machine-readable task state for routing and prioritization.

### `.octon/continuity/entities.json`

- Structured entity index (services, modules, missions, domains, workflows, or other tracked units).
- Includes ownership, lifecycle state, related tasks, and knowledge links.
- Purpose: shared object model for continuity-aware planning.

### `.octon/continuity/next.md`

- Short, actionable next steps.
- Must reference active unblocked task IDs from `tasks.json`.
- Purpose: fast handoff surface for the next execution session.

### `.octon/continuity/decisions/`

- Append-oriented routing, authority, and prerequisite decision evidence.
- Canonical home for orchestration `allow`, `block`, and `escalate` records.
- Lifecycle governed by `/.octon/continuity/decisions/retention.json`.
- Not a source of active task state.

### `.octon/continuity/runs/`

- Append-oriented run evidence artifacts (receipts, digests, policy traces).
- Material-run evidence includes:
  - instruction-layer manifests (`instruction-layer-manifest.json`)
  - receipt telemetry fields (`instruction_layers`, `context_acquisition`, `context_overhead_ratio`)
- Lifecycle governed by `/.octon/continuity/runs/retention.json`.
- Not a source of active task state.

## Lifecycle Rules

| Artifact | Mutability | Rule |
|---|---|---|
| `log.md` | Append-first | Add new entries; avoid destructive edits. |
| `tasks.json` | Mutable | Update status/ownership/blockers and knowledge links as work changes. |
| `entities.json` | Mutable | Keep IDs stable; align owner/related_tasks with task state. |
| `next.md` | Mutable | Keep concise, executable, and coherent with active unblocked tasks. |
| `decisions/` | Append-oriented evidence | Apply retention classes and lifecycle actions from `decisions/retention.json`. |
| `runs/` | Append-oriented evidence | Apply retention classes and lifecycle actions from `runs/retention.json`. |

## Cross-Subsystem Integration

- Cognition provides durable context and decisions consumed during planning.
- Orchestration workflows update continuity state while executing tasks.
- Quality gates validate changes while continuity artifacts preserve execution traceability.

## Operational Expectations

- Every material session should append at least one meaningful `log.md` entry.
- `tasks.json` and `next.md` must be coherent: `next.md` should point to active, unblocked items.
- `entities.json` should reflect ownership and lifecycle before handoff.
- Continuity JSON artifacts must satisfy canonical schema contracts under `_meta/architecture/schemas/`.
- Decision evidence directories under `decisions/` must map to a declared retention class.
- Run evidence directories under `runs/` must map to a declared retention class.
- Post-cutover run evidence should support context-overhead classification (`within-target`, `warn`, `soft-fail`, `hard-fail`).

## Anti-Patterns

- Storing active work state outside the canonical four-file contract.
- Treating `decisions/` or `runs/` as mutable task state.
- Letting `next.md` diverge from `tasks.json`.
- Backfilling large historical edits into `log.md` without clear correction notes.
- Using legacy task fields such as `blocked_by` instead of canonical `blockers`.
- Leaving `next.md` in placeholder state while active unblocked tasks exist.

## Related Docs

- `.octon/continuity/_meta/architecture/three-planes-integration.md`
- `.octon/cognition/runtime/knowledge/knowledge.md`
- `.octon/cognition/governance/README.md`
- `.octon/cognition/practices/README.md`
- `.octon/START.md`
