---
title: Agents
description: Autonomous supervisors that reason, plan, orchestrate, and own mission lifecycle.
---

# Agents

Agents are persistent supervisors in the agency subsystem.

## Responsibilities

- Reason about goals and constraints
- Plan and sequence work
- Delegate scoped tasks to assistants
- Own mission lifecycle and completion criteria
- Escalate one-way-door decisions to humans

## Discovery

Use `registry.yml` for actor routing metadata, `AGENT.md` for execution contracts, and `SOUL.md` for identity contracts.

## Contract Layers

Each agent directory uses a two-file contract split:

| File | Responsibility |
|---|---|
| `AGENT.md` | Operational policy: scope, delegation, escalation, output contract |
| `SOUL.md` | Identity policy: values, tone, boundaries in ambiguous situations |

Cross-agent overlays in `agency/governance/`:

- `governance/CONSTITUTION.md`
- `governance/DELEGATION.md`
- `governance/MEMORY.md`

Precedence: root `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> agent `AGENT.md` -> agent `SOUL.md`.

## Layout

```text
agents/
├── registry.yml
├── _scaffold/template/AGENT.md
├── _scaffold/template/SOUL.md
└── <id>/
    ├── AGENT.md
    └── SOUL.md
```
