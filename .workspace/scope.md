---
title: Scope
description: Boundaries and responsibilities for the root .workspace harness.
---

# Scope: Root .workspace

## This Workspace Covers

The root `.workspace` serves a dual purpose:

1. **Meta-documentation** — Defines the `.workspace` harness pattern itself
2. **Repo-wide agent harness** — A fully functional workspace for repository-wide operations

This workspace contains:

- Templates for creating new `.workspace` directories (base and scoped variants)
- Workflows for workspace management (create, update, evaluate, migrate)
- Workflows for FlowKit integration (run-flow)
- Workflows for mission management (create-mission, complete-mission)
- Agent prompts for workspace evaluation and refinement
- Assistants for focused, delegatable tasks (reviewer, refactor, docs)
- Mission tracking for time-bounded sub-projects

## In Scope

- Defining the `.workspace` structure and conventions
- Creating reusable prompts for workspace operations
- Documenting best practices for agent harnesses
- Maintaining token-efficient, actionable content
- Repository-wide workflows (e.g., FlowKit execution)
- Defining and maintaining assistants (focused specialists)
- Managing missions (time-bounded sub-projects)

## Out of Scope

- Domain-specific content (belongs in domain's own `.workspace`)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.workspace` usage

## Content Placement Guide

| Content Type | Location | Example |
|--------------|----------|---------|
| Workspace management workflows | Root `.workspace/workflows/workspace/` | `create-workspace`, `migrate-workspace` |
| Mission management workflows | Root `.workspace/workflows/missions/` | `create-mission`, `complete-mission` |
| Repository-wide tool workflows | Root `.workspace/workflows/<tool>/` | `flowkit/run-flow` |
| Domain-specific workflows | Domain's `.workspace/workflows/` | `docs/api/.workspace/workflows/` |
| Workspace templates | Root `.workspace/templates/` | `workspace/`, `workspace-docs/` |
| Assistants (focused specialists) | Root `.workspace/assistants/` | `reviewer/`, `refactor/`, `docs/` |
| Missions (sub-projects) | Root `.workspace/missions/` | `auth-overhaul/`, `billing-v2/` |
| Cursor command wrappers | `.cursor/commands/` | `create-workspace.md`, `run-flow.md` |
| Global Cursor commands | `~/.cursor/commands/` | Git utilities, personal workflows |
| Domain conventions | Domain's `.workspace/conventions.md` | Package-specific style rules |

## Decision Authority

**Decide locally:**

- File naming within this `.workspace`
- Prompt templates and workflow definitions
- Progress tracking format

**Escalate:**

- Changes to the `.workspace` pattern that affect other workspaces
- New conventions that should apply project-wide

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `.workspace/templates/workspace-docs/` | Scoped template for documentation areas |
| `.workspace/templates/workspace-node-ts/` | Scoped template for Node.js/TypeScript packages |
| `.cursor/` | IDE-specific agent configuration (complementary) |
| `docs/architecture/workspaces/` | Canonical documentation for workspace pattern |
