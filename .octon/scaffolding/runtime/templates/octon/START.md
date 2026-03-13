---
title: Start Here
description: Boot sequence and orientation for this harness
---

# .octon: Start Here

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Prerequisites

{{PREREQUISITES or "None required"}}

## Structure

```text
.octon/
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
│   ├── runtime/workflows/  ← Multi-step procedures (add as needed)
│   └── runtime/missions/   ← Time-bounded sub-projects (add as needed)
│
├── capabilities/
│   └── runtime/commands/   ← Atomic operations (add as needed)
│
├── agency/
│   ├── manifest.yml    ← Actor discovery and routing metadata
│   ├── governance/     ← Cross-agent contracts (constitution, delegation, memory)
│   ├── runtime/
│   │   ├── agents/     ← Autonomous supervisors
│   │   ├── assistants/ ← Focused specialists (@mention invocation)
│   │   └── teams/      ← Reusable multi-actor compositions
│   └── practices/      ← Collaboration and delivery practices
│
├── scaffolding/
│   ├── runtime/bootstrap/      ← Canonical bootstrap assets for /init
│   ├── runtime/templates/      ← Reusable templates (add as needed)
│   ├── runtime/_ops/scripts/   ← Stable wrapper scripts
│   ├── governance/patterns/    ← Reusable governance patterns
│   ├── practices/prompts/      ← Task templates (add as needed)
│   └── practices/examples/     ← Reference examples
│
└── ideation/
    ├── scratchpad/    ← Human-led zone (HUMAN-LED ONLY)
    │   ├── inbox/     ← Temporary staging
    │   └── archive/   ← Deprecated content
    └── projects/      ← Research projects
```

## Boot Sequence

0. **If root `AGENTS.md`, `.octon/AGENTS.md`, or `.octon/OBJECTIVE.md` is missing:** run `/init` (or `.octon/scaffolding/runtime/_ops/scripts/init-project.sh`) first; add `--list-objectives` to inspect common use cases, `--objective <id>` for non-interactive selection, `--with-boot-files` if `BOOT.md` and `BOOTSTRAP.md` compatibility files are needed, and `--with-agent-platform-adapters` for opt-in adapter bootstrap config
1. **Read `AGENTS.md`** → Root ingress adapter to the canonical `.octon/AGENTS.md`
2. **Read `.octon/OBJECTIVE.md`** → Know the active workspace objective
3. **Read `scope.md`** → Know boundaries
4. **Read `conventions.md`** → Know style rules
5. **Scan `catalog.md`** → Know available operations
6. **Read `continuity/log.md`** → Know what's been done
7. **Read `continuity/tasks.json`** → Know current priorities and goal
8. **Begin** highest-priority unblocked task
9. **Before finishing:** Complete `assurance/practices/session-exit.md`, verify against `assurance/practices/complete.md`

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `ideation/scratchpad/` | **Human-led only** | Human-led zone (thinking, staging, archives) |

Subdirectories: `inbox/` (staging), `archive/` (deprecated).

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check `continuity/tasks.json` for blocked items
- Check `cognition/runtime/context/lessons.md` for anti-patterns to avoid
- Check `cognition/runtime/context/decisions.md` for relevant past decisions
- Review parent harness for patterns
- Document blocker in `continuity/log.md` and stop
