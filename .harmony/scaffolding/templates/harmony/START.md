---
title: Start Here
description: Boot sequence and orientation for this harness
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
├── assurance/        ← complete.md, session-exit.md
│
├── orchestration/
│   ├── workflows/  ← Multi-step procedures (add as needed)
│   └── missions/   ← Time-bounded sub-projects (add as needed)
│
├── capabilities/
│   └── commands/   ← Atomic operations (add as needed)
│
├── agency/
│   ├── manifest.yml    ← Actor discovery and routing metadata
│   ├── governance/     ← Cross-agent contracts (constitution, delegation, memory)
│   ├── actors/
│   │   ├── agents/     ← Autonomous supervisors
│   │   ├── assistants/ ← Focused specialists (@mention invocation)
│   │   └── teams/      ← Reusable multi-actor compositions
│   └── practices/      ← Collaboration and delivery practices
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

0. **If `AGENTS.md` is missing at repo root:** run `/init` (or `.harmony/scaffolding/_ops/scripts/init-project.sh`) first; add `--with-boot-files` if `BOOT.md` and `BOOTSTRAP.md` compatibility files are needed; add `--with-agent-platform-adapters` for opt-in adapter bootstrap config
1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Scan `catalog.md`** → Know available operations
4. **Read `continuity/log.md`** → Know what's been done
5. **Read `continuity/tasks.json`** → Know current priorities and goal
6. **Begin** highest-priority unblocked task
7. **Before finishing:** Complete `assurance/practices/session-exit.md`, verify against `assurance/practices/complete.md`

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
- Review parent harness for patterns
- Document blocker in `continuity/log.md` and stop
