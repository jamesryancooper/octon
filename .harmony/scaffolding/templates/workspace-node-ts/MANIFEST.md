---
title: Workspace Template Manifest (node-ts)
description: Scoped workspace template for Node.js/TypeScript packages.
---

# Workspace Template: node-ts

A scoped workspace template for **Node.js/TypeScript packages** (libraries, components, CLI tools).

> **Machine-readable manifest:** See `manifest.json` in this directory for the structured definition used by `/create-workspace`.

## Inheritance

This template **extends** the base workspace template at `.harmony/scaffolding/templates/workspace/`.

### Resolution Order

When creating a workspace using this template:

1. Copy all files from `.harmony/scaffolding/templates/workspace/` (base)
2. Overlay files from this directory (scope-specific overrides)

### Files in This Template

| File | Purpose |
|------|---------|
| `MANIFEST.md` | This file (template metadata) |
| `START.md` | Node.js/TS-specific boot sequence (overrides base) |
| `scope.md` | Package-specific scope template (overrides base) |
| `conventions.md` | TypeScript/React conventions (overrides base) |
| `checklists/complete.md` | Code-specific definition of done (overrides base) |

### Files Inherited from Base

All other files come from `.harmony/scaffolding/templates/workspace/`:

- `catalog.md`
- `context/` (decisions, lessons, glossary, dependencies, constraints)
- `progress/` (log.md, tasks.json, entities.json)
- `checklists/session-exit.md`
- `commands/`, `prompts/`, `workflows/`, `templates/`, `examples/` (README placeholders)

## Usage

This template is used by the `/create-workspace` workflow when creating a workspace for a Node.js/TypeScript package.

```text
/create-workspace @packages/ui --template node-ts
```

