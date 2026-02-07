---
title: Harmony Template Manifest (docs)
description: Scoped .harmony/ template for documentation areas.
---

# Harmony Template: docs

A scoped `.harmony/` template for **documentation areas** (API docs, guides, reference docs).

> **Machine-readable manifest:** See `manifest.json` in this directory for the structured definition used by `/create-workspace`.

## Inheritance

This template **extends** the base template at `.harmony/scaffolding/templates/harmony/`.

### Resolution Order

When creating a workspace using this template:

1. Copy all files from `.harmony/scaffolding/templates/harmony/` (base)
2. Overlay files from this directory (scope-specific overrides)
3. Copy `workflows/are/` for document improvement workflows

### Files in This Template

| File | Purpose |
|------|---------|
| `MANIFEST.md` | This file (template metadata) |
| `START.md` | Docs-specific boot sequence (overrides base) |
| `scope.md` | Docs-specific scope template (overrides base) |
| `conventions.md` | Docs-specific conventions (overrides base) |
| `quality/done.md` | Docs-specific definition of done (overrides base) |
| `orchestration/workflows/are/` | Analyze-Refine-Evaluate workflows for document improvement |

### Files Inherited from Base

All other files come from `.harmony/scaffolding/templates/harmony/`:

- `catalog.md`
- `cognition/context/` (decisions, lessons, glossary, dependencies, constraints)
- `continuity/` (log.md, tasks.json, entities.json)
- `quality/session-exit.md`
- `capabilities/commands/`, `scaffolding/prompts/`, `scaffolding/templates/`, `scaffolding/examples/` (README placeholders)

## Usage

This template is used by the `/create-workspace` workflow when creating a workspace for a documentation area.

```text
/create-workspace @docs/api-reference --template docs
```

