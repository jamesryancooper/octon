---
title: Harness Progress Tracking
description: Session continuity via log, tasks, entities, and next-action coherence.
---

# Harness Progress Tracking

The `continuity/` directory maintains session-to-session operational memory.

## Location

```text
.octon/state/continuity/repo/
├── log.md        # Append-only session history
├── tasks.json    # Structured active/deferred work queue
├── entities.json # Structured entity state linked to tasks
└── next.md       # Immediate next actions linked to active tasks
```

## `log.md`

Append-only historical timeline of sessions, outcomes, blockers, and decisions.

Rules:

- MUST append only (no destructive rewrites).
- MUST include enough context to explain task/entity transitions.
- SHOULD include blockers and handoff context when work is incomplete.

## `tasks.json`

Machine-readable task state for routing and prioritization.

Canonical root contract:

```json
{
  "schema_version": "1.2",
  "goal": "High-level objective this harness serves",
  "tasks": []
}
```

Canonical status values:

| Status | Meaning |
|---|---|
| `pending` | Not started but actionable |
| `in_progress` | Actively being executed |
| `blocked` | Cannot proceed due to blockers |
| `completed` | Done and verified |
| `cancelled` | Intentionally retired |

Active task requirements (`pending`, `in_progress`, `blocked`):

- `owner`
- `blockers` (array; use `external:<id>` for non-task blockers)
- `acceptance_criteria` (non-empty array)
- `knowledge_links` with at least one reference across `specs`, `contracts`, `decisions`, `evidence`

Additional invariants:

- At most one task MAY be `in_progress`.
- Legacy `blocked_by` MUST NOT be used; canonical field is `blockers`.
- `completed` tasks MUST include `completed_at` (`YYYY-MM-DD`).

## `entities.json`

Structured state for actively relevant entities and their linkage to tasks.

Canonical root contract:

```json
{
  "schema_version": "1.1",
  "description": "Tracks state of entities relevant to continuity planning",
  "entities": {}
}
```

Entity minimum fields:

- `type`
- `status`
- `last_modified`
- `owner`

For non-stable entities (`in_progress`, `blocked`, `needs_review`):

- `related_tasks` (non-empty array)
- `knowledge_links` (at least one reference)

## `next.md`

Immediate execution surface for the next session.

Rules:

- `## Current` MUST contain actionable list items when active unblocked tasks exist.
- Current list items SHOULD reference task IDs from `tasks.json`.
- Placeholder-only content is invalid when actionable work exists.

## Runs Evidence

`continuity/runs/` contains append-oriented run evidence.

- Retention policy: `/.octon/state/evidence/runs/retention.json`
- Lifecycle contract: `runs-retention.md`
- Not a source of active task state

## Validation

Canonical continuity validation is enforced by:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

This validator enforces schema shape, status/field invariants, cross-file coherence (`tasks`/`entities`/`next`), and `runs/` retention policy conformance.

## Boot Sequence Integration

In `START.md`, continuity loading is:

1. Read `/.octon/state/continuity/repo/log.md` for recent history.
2. Read `/.octon/state/continuity/repo/tasks.json` for priorities/blockers.
3. Read `/.octon/state/continuity/repo/next.md` for immediate execution order.
