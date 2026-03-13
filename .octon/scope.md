---
title: Scope
description: Boundaries and responsibilities for the root .octon/ harness.
---

# Scope: Root .octon/

## This Harness Covers

The root `.octon/` is the **repo-wide agent harness** for repository-wide operations, decisions, and context.

This harness contains:

- Repository-wide decisions, lessons, and constraints
- Repository-wide principles, methodology, and architecture guidance
- Progress tracking for repo-level work
- Mission tracking for time-bounded sub-projects
- Domain-specific workflows

**Note:** All content is organized by capability within `.octon/`. See `.octon/README.md` for the full structure.

## In Scope

- Repository-wide context (decisions, lessons, glossary, constraints)
- Repository-wide architecture, principles, and methodology docs
- Repo-level progress tracking and session continuity
- Repository-wide workflows
- Managing missions (time-bounded sub-projects)
- Repo-specific conventions and style rules

## Out of Scope

- Domain-specific content (belongs in domain's own `.octon/` harness)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.octon/` usage

## Content Placement Guide

| Content Type | Location | Example |
|--------------|----------|---------|
| **Shared (in `.octon/`)** | | |
| Harness templates | `.octon/scaffolding/runtime/templates/` | `octon/` |
| Generic agents | `.octon/agency/runtime/agents/` | `architect/`, `auditor/` |
| Generic assistants | `.octon/agency/runtime/assistants/` | `reviewer/`, `refactor/`, `docs/` |
| Team compositions | `.octon/agency/runtime/teams/` | `delivery-core/` |
| Harness management workflows | `.octon/orchestration/runtime/workflows/meta/` | `migrate-harness`, `update-harness` |
| Mission management workflows | `.octon/orchestration/runtime/workflows/missions/` | `create-mission`, `complete-mission` |
| Generic skills | `.octon/capabilities/runtime/skills/` | `synthesize-research/` |
| **Repo-wide (in `.octon/`)** | | |
| Repository-wide tool workflows | `.octon/orchestration/runtime/workflows/<tool>/` | _None currently_ |
| Repo-level missions | `.octon/orchestration/runtime/missions/` | `auth-overhaul/`, `billing-v2/` |
| Repo-wide context | `.octon/cognition/runtime/context/` | `decisions.md`, `lessons.md` |
| **Domain-specific** | | |
| Domain workflows | Repo-root `.octon/orchestration/runtime/workflows/` grouped by domain | `docs/`, `packages/`, `services/` concerns represented under the root harness |
| Domain conventions | Repo-root `.octon/cognition/runtime/context/` or domain docs | Package- or area-specific style rules |
| **Harness entry points** | | |
| Cursor command wrappers | `.cursor/commands/` | `evaluate-harness.md`, `update-harness.md` |
| Global Cursor commands | `~/.cursor/commands/` | Git utilities, personal workflows |

## Decision Authority

**Decide locally:**

- File naming within this `.octon/`
- Prompt templates and workflow definitions
- Progress tracking format

**Escalate:**

- Changes to the `.octon/` pattern that affect other harnesses
- New conventions that should apply project-wide

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `.octon/` | Shared foundation — actors, templates, workflows, skills |
| `.octon/scaffolding/runtime/templates/` | Harness scaffolding (base and scoped variants) |
| `.cursor/` | IDE-specific agent configuration (complementary) |
| `.octon/cognition/_meta/architecture/` | Canonical documentation for harness pattern |
