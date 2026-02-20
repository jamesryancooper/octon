---
title: Scope
description: Boundaries and responsibilities for the root .harmony/ harness.
---

# Scope: Root .harmony/

## This Harness Covers

The root `.harmony/` is the **repo-wide agent harness** for repository-wide operations, decisions, and context.

This harness contains:

- Repository-wide decisions, lessons, and constraints
- Repository-wide principles, methodology, and architecture guidance
- Progress tracking for repo-level work
- Mission tracking for time-bounded sub-projects
- Domain-specific workflows

**Note:** All content is organized by capability within `.harmony/`. See `.harmony/README.md` for the full structure.

## In Scope

- Repository-wide context (decisions, lessons, glossary, constraints)
- Repository-wide architecture, principles, and methodology docs
- Repo-level progress tracking and session continuity
- Repository-wide workflows
- Managing missions (time-bounded sub-projects)
- Repo-specific conventions and style rules

## Out of Scope

- Domain-specific content (belongs in domain's own `.harmony/` harness)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.harmony/` usage

## Content Placement Guide

| Content Type | Location | Example |
|--------------|----------|---------|
| **Shared (in `.harmony/`)** | | |
| Harness templates | `.harmony/scaffolding/templates/` | `harmony/`, `harmony-docs/` |
| Generic agents | `.harmony/agency/actors/agents/` | `architect/`, `auditor/` |
| Generic assistants | `.harmony/agency/actors/assistants/` | `reviewer/`, `refactor/`, `docs/` |
| Team compositions | `.harmony/agency/actors/teams/` | `delivery-core/` |
| Harness management workflows | `.harmony/orchestration/runtime/workflows/meta/` | `create-harness`, `migrate-harness` |
| Mission management workflows | `.harmony/orchestration/runtime/workflows/missions/` | `create-mission`, `complete-mission` |
| Generic skills | `.harmony/capabilities/runtime/skills/` | `synthesize-research/` |
| **Repo-wide (in `.harmony/`)** | | |
| Repository-wide tool workflows | `.harmony/orchestration/runtime/workflows/<tool>/` | _None currently_ |
| Repo-level missions | `.harmony/orchestration/runtime/missions/` | `auth-overhaul/`, `billing-v2/` |
| Repo-wide context | `.harmony/cognition/context/` | `decisions.md`, `lessons.md` |
| **Domain-specific** | | |
| Domain workflows | Domain's `.harmony/orchestration/runtime/workflows/` | `docs/api/.harmony/orchestration/runtime/workflows/` |
| Domain conventions | Domain's `.harmony/conventions.md` | Package-specific style rules |
| **Harness entry points** | | |
| Cursor command wrappers | `.cursor/commands/` | `create-harness.md`, `evaluate-harness.md` |
| Global Cursor commands | `~/.cursor/commands/` | Git utilities, personal workflows |

## Decision Authority

**Decide locally:**

- File naming within this `.harmony/`
- Prompt templates and workflow definitions
- Progress tracking format

**Escalate:**

- Changes to the `.harmony/` pattern that affect other harnesses
- New conventions that should apply project-wide

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `.harmony/` | Shared foundation — actors, templates, workflows, skills |
| `.harmony/scaffolding/templates/` | Harness scaffolding (base and scoped variants) |
| `.cursor/` | IDE-specific agent configuration (complementary) |
| `.harmony/cognition/_meta/architecture/` | Canonical documentation for harness pattern |
