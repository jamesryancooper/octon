# Continuity Plane Documentation

This directory defines the continuity model used by the active `.harmony/` harness.

## Core Question

What happened, what is in progress, and what should happen next?

## Canonical Continuity Contract

Continuity is represented by four canonical files:

```text
.harmony/continuity/
├── log.md        # Chronological activity log (append-first history)
├── tasks.json    # Structured active work queue
├── entities.json # Structured tracked entities and ownership/state metadata
└── next.md       # Immediate next actions and handoff-ready priorities
```

## Document Map

| Document | Description |
|---|---|
| `continuity-plane.md` | Continuity model, data contracts, and lifecycle rules |
| `three-planes-integration.md` | Integration points across cognition, orchestration, and continuity |

## Lifecycle Rules

| Artifact | Mutability | Rule |
|---|---|---|
| `.harmony/continuity/log.md` | Append-first | Add entries; do not rewrite history except to correct factual errors. |
| `.harmony/continuity/tasks.json` | Mutable | Keep machine-readable task state current with blockers and ownership. |
| `.harmony/continuity/entities.json` | Mutable | Keep tracked entities current; preserve stable IDs and ownership semantics. |
| `.harmony/continuity/next.md` | Mutable | Keep focused and short; must be executable without extra context. |

## Related Docs

- `.harmony/cognition/knowledge-plane/knowledge-plane.md`
- `.harmony/cognition/architecture/content-plane/README.md`
- `.harmony/START.md`
