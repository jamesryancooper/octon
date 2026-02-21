---
title: Harmony Template Manifest (docs)
description: Scoped .harmony/ template for documentation areas.
---

# Harmony Template: docs

A scoped `.harmony/` template for **documentation areas** (API docs, guides, reference docs).

> **Machine-readable manifest:** See `manifest.json` in this directory for the structured definition used by `/create-harness`.

## Inheritance

This template **extends** the base template at `.harmony/scaffolding/runtime/templates/harmony/`.

### Resolution Order

When creating a harness using this template:

1. Copy all files from `.harmony/scaffolding/runtime/templates/harmony/` (base)
2. Overlay files from this directory (scope-specific overrides)
3. Copy `orchestration/runtime/workflows/are/` for document improvement workflows

### Files in This Template

| File | Purpose |
|------|---------|
| `MANIFEST.md` | This file (template metadata) |
| `START.md` | Docs-specific boot sequence (overrides base) |
| `scope.md` | Docs-specific scope template (overrides base) |
| `conventions.md` | Docs-specific conventions (overrides base) |
| `assurance/practices/complete.md` | Docs-specific definition of done (overrides base) |
| `orchestration/runtime/workflows/are/` | Analyze-Refine-Evaluate workflows for document improvement |

### Files Inherited from Base

All other files come from `.harmony/scaffolding/runtime/templates/harmony/`:

- `catalog.md`
- `cognition/runtime/context/` (decisions, lessons, glossary, dependencies, constraints)
- `continuity/` (log.md, tasks.json, entities.json)
- `assurance/practices/session-exit.md`
- `capabilities/runtime/commands/`, `scaffolding/governance/patterns/`, `scaffolding/practices/prompts/`, `scaffolding/runtime/templates/`, `scaffolding/practices/examples/` (README placeholders)

## Usage

This template is used by the `/create-harness` workflow when creating a harness for a documentation area.

```text
/create-harness @docs/api-reference --template docs
```
