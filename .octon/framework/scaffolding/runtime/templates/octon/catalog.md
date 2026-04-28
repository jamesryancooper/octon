---
title: Harness Catalog
description: Index of available commands and workflows in this harness.
---

# Harness Catalog

Available operations in this harness.

## Execution Roles

Execution-role configuration in `framework/execution-roles/`:

| Artifact | Description |
|----------|-------------|
| `framework/execution-roles/manifest.yml` | Execution-role discovery and routing metadata |
| `framework/execution-roles/governance/` | Delegation and memory governance contracts |
| `framework/execution-roles/runtime/orchestrator/ROLE.md` | Default accountable execution-role contract |
| `framework/execution-roles/runtime/specialists/registry.yml` | Specialist aliases and escalation policy |
| `framework/execution-roles/runtime/composition-profiles/registry.yml` | Reusable execution-role compositions |

## Commands

Atomic operations in `capabilities/runtime/commands/`:

| Command | Access | Description |
|---------|--------|-------------|
| _None yet_ | — | — |

## Workflows

Multi-step procedures in `orchestration/runtime/workflows/`:

| Workflow | Access | Description |
|----------|--------|-------------|
| _None yet_ | — | — |

### Repo-Wide Workflows

The root `.octon` provides shared workflows available to all harnesses:

| Workflow | Access | Description |
|----------|--------|-------------|
| _None currently_ | — | — |

## Prompts

Task templates in `scaffolding/practices/prompts/`:

| Prompt | Access | Description |
|--------|--------|-------------|
| _None yet_ | — | — |

## Context

Background knowledge in `instance/cognition/context/shared/` and generated
cognition summaries:

| File | Description |
|------|-------------|
| [decisions/README.md](/.octon/instance/cognition/decisions/README.md) | ADR authority and discovery guidance. |
| [lessons.md](/.octon/instance/cognition/context/shared/lessons.md) | Anti-patterns and failures to avoid. |
| [glossary.md](/.octon/instance/cognition/context/shared/glossary.md) | Domain-specific terminology. |
| [dependencies.md](/.octon/instance/cognition/context/shared/dependencies.md) | External systems and references. |
| [constraints.md](/.octon/instance/cognition/context/shared/constraints.md) | Technical and business rules. |

## Access Key

| Value | Meaning |
|-------|---------|
| `human` | Has a Cursor command wrapper in `.cursor/commands/` |
| `execution-role` | Execution-role only; no IDE integration |
