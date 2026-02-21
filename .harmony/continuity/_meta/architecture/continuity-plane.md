---
title: Continuity Plane
description: Continuity architecture aligned to the active `.harmony/continuity/` contract (`log.md`, `tasks.json`, `entities.json`, `next.md`).
---

# Continuity Plane

The Continuity Plane preserves operational memory so work can resume safely across sessions, agents, and humans.

## Core Question

What happened, what is active now, and what should happen next?

## Canonical Storage Contract

```text
.harmony/continuity/
├── log.md
├── tasks.json
├── entities.json
└── next.md
```

This contract is authoritative. Continuity artifacts must be represented through these files.

## File Responsibilities

### `.harmony/continuity/log.md`

- Append-first chronological activity history.
- Records: decisions made, commands run, outcomes, blockers, and handoff notes.
- Purpose: auditable timeline and context reconstruction.

### `.harmony/continuity/tasks.json`

- Structured queue of active and deferred work.
- Fields should support deterministic filtering (status, priority, owner, blockers, acceptance criteria).
- Purpose: machine-readable task state for routing and prioritization.

### `.harmony/continuity/entities.json`

- Structured entity index (services, modules, missions, domains, workflows, or other tracked units).
- Includes stable IDs, ownership, lifecycle state, and relevant links.
- Purpose: shared object model for continuity-aware planning.

### `.harmony/continuity/next.md`

- Short, actionable next steps.
- Includes immediate work sequencing and dependencies.
- Purpose: fast handoff surface for the next execution session.

## Lifecycle Rules

| Artifact | Mutability | Rule |
|---|---|---|
| `log.md` | Append-first | Add new entries; avoid destructive edits. |
| `tasks.json` | Mutable | Update status/ownership/blockers as work changes. |
| `entities.json` | Mutable | Keep IDs stable and state consistent. |
| `next.md` | Mutable | Keep concise and executable. |

## Cross-Subsystem Integration

- Cognition provides durable context and decisions consumed during planning.
- Orchestration workflows update continuity state while executing tasks.
- Quality gates validate changes while continuity artifacts preserve execution traceability.

## Operational Expectations

- Every material session should append at least one meaningful `log.md` entry.
- `tasks.json` and `next.md` must be coherent: `next.md` should point to active, unblocked items.
- `entities.json` should reflect ownership and lifecycle before handoff.

## Anti-Patterns

- Storing active work state outside the canonical four-file contract.
- Letting `next.md` diverge from `tasks.json`.
- Backfilling large historical edits into `log.md` without clear correction notes.

## Related Docs

- `.harmony/continuity/_meta/architecture/three-planes-integration.md`
- `.harmony/cognition/runtime/knowledge-plane/knowledge-plane.md`
- `.harmony/cognition/_meta/architecture/content-plane/README.md`
- `.harmony/START.md`
