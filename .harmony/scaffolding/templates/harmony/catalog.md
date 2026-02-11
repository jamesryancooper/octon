---
title: Harness Catalog
description: Index of available commands and workflows in this harness.
---

# Harness Catalog

Available operations in this harness.

## Agency

Actor configuration in `agency/`:

| Artifact | Description |
|----------|-------------|
| `agency/manifest.yml` | Actor discovery and routing metadata |
| `agency/agents/registry.yml` | Supervisor definitions and delegation policy |
| `agency/assistants/registry.yml` | Assistant aliases and escalation policy |
| `agency/teams/registry.yml` | Reusable multi-actor compositions |

## Commands

Atomic operations in `capabilities/commands/`:

| Command | Access | Description |
|---------|--------|-------------|
| _None yet_ | — | — |

## Workflows

Multi-step procedures in `orchestration/workflows/`:

| Workflow | Access | Description |
|----------|--------|-------------|
| _None yet_ | — | — |

### Repo-Wide Workflows

The root `.harmony` provides shared workflows available to all harnesses:

| Workflow | Access | Description |
|----------|--------|-------------|
| [run-flow](/.harmony/orchestration/workflows/flowkit/run-flow/00-overview.md) | human | Execute FlowKit LangGraph flows via `/run-flow @packages/workflows/<flowId>/config.flow.json` |

> **Tip:** Use `/run-flow` from any harness to run repo-wide FlowKit flows. See [FlowKit Guide](/docs/kits/planning-and-orchestration/flowkit/guide.md) for details.

## Prompts

Task templates in `scaffolding/prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| _None yet_ | — | — |

## Context

Background knowledge in `cognition/context/`:

| File | Description |
|------|-------------|
| [decisions.md](./cognition/context/decisions.md) | Agent-readable decision summaries. |
| [lessons.md](./cognition/context/lessons.md) | Anti-patterns and failures to avoid. |
| [glossary.md](./cognition/context/glossary.md) | Domain-specific terminology. |
| [dependencies.md](./cognition/context/dependencies.md) | External systems and references. |
| [constraints.md](./cognition/context/constraints.md) | Technical and business rules. |

## Access Key

| Value | Meaning |
|-------|---------|
| `human` | Has a Cursor command wrapper in `.cursor/commands/` |
| `agent` | Agent-only; no IDE integration |
