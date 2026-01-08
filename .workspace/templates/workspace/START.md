---
title: Start Here
description: Boot sequence and orientation for this workspace
---

# .workspace: Start Here

## Prerequisites

{{PREREQUISITES or "None required"}}

## Structure

```text
.workspace/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── prompts/        ← Task templates (add as needed)
├── workflows/      ← Multi-step procedures (add as needed)
├── commands/       ← Atomic operations (add as needed)
├── context/        ← Decisions, lessons, glossary
├── progress/       ← log.md, tasks.json, entities.json
├── checklists/     ← complete.md, session-exit.md
│
├── .humans/        ← Human docs (NEVER ACCESS)
├── .scratch/       ← Human thinking (HUMAN-LED ONLY)
├── .inbox/         ← Human staging (HUMAN-LED ONLY)
└── .archive/       ← Deprecated (NEVER ACCESS)
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Scan `catalog.md`** → Know available operations
4. **Read `progress/log.md`** → Know what's been done
5. **Read `progress/tasks.json`** → Know current priorities and goal
6. **Begin** highest-priority unblocked task
7. **Before finishing:** Complete `checklists/session-exit.md`, verify against `checklists/complete.md`

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `.humans/` | **Never access** | Human documentation |
| `.scratch/` | **Human-led only** | Persistent thinking/research |
| `.inbox/` | **Human-led only** | Temporary staging for imports |
| `.archive/` | **Never access** | Deprecated content |

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check `progress/tasks.json` for blocked items
- Check `context/lessons.md` for anti-patterns to avoid
- Check `context/decisions.md` for relevant past decisions
- Review parent workspace for patterns
- Document blocker in `progress/log.md` and stop
