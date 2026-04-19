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
| `agency/governance/` | Cross-agent governance contracts and precedence overlays |
| `agency/runtime/agents/registry.yml` | Supervisor definitions and delegation policy |
| `agency/runtime/specialists/registry.yml` | Assistant aliases and escalation policy |
| `agency/runtime/composition-profiles/registry.yml` | Reusable multi-actor compositions |

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
| `agent` | Agent-only; no IDE integration |
