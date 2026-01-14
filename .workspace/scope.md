---
title: Scope
description: Boundaries and responsibilities for the root .workspace harness.
---

# Scope: Root .workspace

## This Workspace Covers

The root `.workspace` is the **repo-wide agent harness** — a functional workspace for repository-wide operations, decisions, and context.

This workspace contains:

- Repository-wide decisions, lessons, and constraints
- Progress tracking for repo-level work
- Mission tracking for time-bounded sub-projects
- Domain-specific workflows (e.g., FlowKit integration)

**Note:** Workspace pattern definitions, templates, generic assistants, and shared components live in `.harmony/`, not here. See `.harmony/README.md`.

## In Scope

- Repository-wide context (decisions, lessons, glossary, constraints)
- Repo-level progress tracking and session continuity
- Repository-wide workflows (e.g., FlowKit execution)
- Managing missions (time-bounded sub-projects)
- Repo-specific conventions and style rules

## Out of Scope

- Domain-specific content (belongs in domain's own `.workspace`)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.workspace` usage

## Content Placement Guide

| Content Type | Location | Example |
|--------------|----------|---------|
| **Shared (in `.harmony/`)** | | |
| Workspace templates | `.harmony/templates/` | `workspace/`, `workspace-docs/` |
| Generic assistants | `.harmony/assistants/` | `reviewer/`, `refactor/`, `docs/` |
| Workspace management workflows | `.harmony/workflows/workspace/` | `create-workspace`, `migrate-workspace` |
| Mission management workflows | `.harmony/workflows/missions/` | `create-mission`, `complete-mission` |
| Generic skills | `.harmony/skills/` | `research-synthesizer/` |
| **Repo-wide (in `.workspace/`)** | | |
| Repository-wide tool workflows | `.workspace/workflows/<tool>/` | `flowkit/run-flow` |
| Repo-level missions | `.workspace/missions/` | `auth-overhaul/`, `billing-v2/` |
| Repo-wide context | `.workspace/context/` | `decisions.md`, `lessons.md` |
| **Domain-specific** | | |
| Domain workflows | Domain's `.workspace/workflows/` | `docs/api/.workspace/workflows/` |
| Domain conventions | Domain's `.workspace/conventions.md` | Package-specific style rules |
| **Harness entry points** | | |
| Cursor command wrappers | `.cursor/commands/` | `create-workspace.md`, `run-flow.md` |
| Global Cursor commands | `~/.cursor/commands/` | Git utilities, personal workflows |

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
| `.harmony/` | Shared foundation — templates, assistants, workflows, skills |
| `.harmony/templates/` | Workspace scaffolding (base and scoped variants) |
| `.cursor/` | IDE-specific agent configuration (complementary) |
| `docs/architecture/workspaces/` | Canonical documentation for workspace pattern |
