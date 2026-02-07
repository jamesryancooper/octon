---
title: Start Here
description: Boot sequence and orientation for this workspace
---

# .harmony: Start Here

## Prerequisites

{{PREREQUISITES or "None required"}}

## Structure

```text
.harmony/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── cognition/
│   └── context/    ← Decisions, lessons, glossary
├── continuity/     ← log.md, tasks.json, entities.json
├── quality/        ← complete.md, session-exit.md
│
├── orchestration/
│   ├── workflows/  ← Multi-step procedures (add as needed)
│   └── missions/   ← Time-bounded sub-projects (add as needed)
│
├── capabilities/
│   └── commands/   ← Atomic operations (add as needed)
│
├── scaffolding/
│   └── prompts/    ← Task templates (add as needed)
│
└── ideation/
    ├── scratchpad/    ← Human-led zone (HUMAN-LED ONLY)
    │   ├── inbox/     ← Temporary staging
    │   └── archive/   ← Deprecated content
    └── projects/      ← Research projects
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Scan `catalog.md`** → Know available operations
4. **Read `continuity/log.md`** → Know what's been done
5. **Read `continuity/tasks.json`** → Know current priorities and goal
6. **Begin** highest-priority unblocked task
7. **Before finishing:** Complete `quality/session-exit.md`, verify against `quality/complete.md`

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `ideation/scratchpad/` | **Human-led only** | Human-led zone (thinking, staging, archives) |

Subdirectories: `inbox/` (staging), `archive/` (deprecated).

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check `continuity/tasks.json` for blocked items
- Check `cognition/context/lessons.md` for anti-patterns to avoid
- Check `cognition/context/decisions.md` for relevant past decisions
- Review parent workspace for patterns
- Document blocker in `continuity/log.md` and stop
