---
title: Agents
description: Accountable execution roles for planning, orchestration, and independent verification.
---

# Agents

Agents are the accountable execution roles in the agency subsystem.

## Responsibilities

- Keep one explicit accountable owner for default execution
- Plan and sequence work within granted scope
- Delegate only when bounded context isolation, concurrency, or independence helps
- Escalate one-way-door decisions to humans
- Keep memory and execution discipline grounded in runtime artifacts, not persona prose

## Discovery

Use `registry.yml` for actor routing metadata and `AGENT.md` for execution
contracts. Legacy `SOUL.md` overlays are out of the scaffolded path and are
ignored by the kernel execution order.

## Contract Layers

Each agent directory requires one execution contract. Legacy identity overlays
are historical only and are not scaffolded by default:

| File | Responsibility |
|---|---|
| `AGENT.md` | Operational policy: scope, delegation, escalation, output contract |
Supporting overlays in `agency/governance/`:

- `governance/DELEGATION.md`
- `governance/MEMORY.md`
- `governance/CONSTITUTION.md` (historical shim only)

Agency kernel path: `framework/constitution/**` -> `instance/ingress/AGENTS.md` -> agent `AGENT.md`.

## Layout

```text
agents/
├── registry.yml
├── _scaffold/template/AGENT.md
└── <id>/
    └── AGENT.md
```
