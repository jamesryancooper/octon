---
title: Harness Progress Tracking
description: Session continuity via continuity/log.md, tasks.json, and entities.json
---

# Harness Progress Tracking

The `continuity/` directory maintains **session-to-session continuity**. It's how agents "remember" what happened in previous sessions.

## Location

```text
.harmony/continuity/
├── log.md        # Append-only session log
├── tasks.json    # Structured task list with goal and status
└── entities.json # Entity state tracking (optional)
```

---

## `log.md`

An **append-only log** of completed work and decisions.

### Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]
- [task 2]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```

### Log Rules

- MUST append only (never edit previous entries)
- MUST include date header for each session
- SHOULD be updated before ending any session
- MAY include blockers and decisions

---

## `tasks.json`

A **structured task list** with goal tracking and status.

### Tasks Format

```json
{
  "schema_version": "1.1",
  "goal": "High-level objective this harness serves",
  "tasks": [
    {
      "id": "task-001",
      "description": "Implement feature X",
      "status": "in_progress",
      "priority": 1,
      "blockers": [],
      "goal_contribution": "Advances the main goal by..."
    },
    {
      "id": "task-002", 
      "description": "Review documentation",
      "status": "pending",
      "priority": 2,
      "blockers": ["task-001"]
    }
  ]
}
```

### Goal Field

The `goal` field captures **intent** that spans multiple sessions. This helps agents understand *why* work is being done, not just *what* tasks to complete.

- MUST be a single sentence describing the harness's objective
- SHOULD be referenced when prioritizing tasks
- MAY be updated if the harness's purpose evolves

### Tasks Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not started |
| `in_progress` | Currently working on |
| `blocked` | Cannot proceed; see `blockers` array |
| `completed` | Done |
| `cancelled` | No longer needed |

### Tasks Rules

- MUST update status when task state changes
- MUST set only one task to `in_progress` at a time
- SHOULD include `blockers` array for blocked tasks
- MAY include `priority` for ordering

---

## `entities.json`

**Entity state tracking** for artifacts being actively worked on. More granular than tasks.

### Entities Format

```json
{
  "schema_version": "1.0",
  "description": "Tracks state of specific artifacts being actively worked on",
  "entities": {
    "src/api/auth.ts": {
      "type": "file",
      "status": "in_progress",
      "last_modified": "2024-01-15",
      "notes": "Refactoring auth flow, step 2 of 4 complete"
    },
    "docs/api/": {
      "type": "directory",
      "status": "stable",
      "last_modified": "2024-01-14",
      "notes": "Documentation complete"
    }
  }
}
```

### Entity Status Values

| Status | Meaning |
|--------|---------|
| `stable` | Not currently being modified |
| `in_progress` | Active work happening |
| `blocked` | Cannot proceed |
| `needs_review` | Work complete, awaiting review |

### When to Use

- Track **in-flight changes** that aren't yet committed
- Record **partial progress** on file modifications
- Note **relationships** between entities being modified together

---

## Boot Sequence Integration

In `START.md`, the boot sequence includes:

1. Read `continuity/log.md` → Know what's been done
2. Read `continuity/tasks.json` → Know current priorities and goal
3. Begin highest-priority unblocked task

This ensures agents pick up where previous sessions left off.

---

## See Also

- [Checklists](./checklists.md) — Quality gates before completion
- [Context](./context.md) — Decisions and lessons learned
- [README.md](./README.md) — Canonical harness structure
