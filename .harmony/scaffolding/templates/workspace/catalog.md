---
title: Workspace Catalog
description: Index of available commands and workflows in this workspace.
---

# Workspace Catalog

Available operations in this workspace.

## Commands

Atomic operations in `commands/`:

| Command | Access | Description |
|---------|--------|-------------|
| _None yet_ | — | — |

## Workflows

Multi-step procedures in `workflows/`:

| Workflow | Access | Description |
|----------|--------|-------------|
| _None yet_ | — | — |

### Repo-Wide Workflows

The root `.workspace` provides shared workflows available to all workspaces:

| Workflow | Access | Description |
|----------|--------|-------------|
| [run-flow](/.workspace/workflows/flowkit/run-flow/00-overview.md) | human | Execute FlowKit LangGraph flows via `/run-flow @packages/workflows/<flowId>/config.flow.json` |

> **Tip:** Use `/run-flow` from any workspace to run repo-wide FlowKit flows. See [FlowKit Guide](/docs/kits/planning-and-orchestration/flowkit/guide.md) for details.

## Prompts

Task templates in `prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| _None yet_ | — | — |

## Context

Background knowledge in `context/`:

| File | Description |
|------|-------------|
| [decisions.md](./context/decisions.md) | Agent-readable decision summaries. |
| [lessons.md](./context/lessons.md) | Anti-patterns and failures to avoid. |
| [glossary.md](./context/glossary.md) | Domain-specific terminology. |
| [dependencies.md](./context/dependencies.md) | External systems and references. |
| [constraints.md](./context/constraints.md) | Technical and business rules. |

## Access Key

| Value | Meaning |
|-------|---------|
| `human` | Has a Cursor command wrapper in `.cursor/commands/` |
| `agent` | Agent-only; no IDE integration |
