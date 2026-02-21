---
title: Harmony Template Manifest (node-ts)
description: Scoped .harmony/ template for Node.js/TypeScript packages.
---

# Harmony Template: node-ts

A scoped `.harmony/` template for **Node.js/TypeScript packages** (libraries, components, CLI tools).

> **Machine-readable manifest:** See `manifest.json` in this directory for the structured definition used by `/create-harness`.

## Inheritance

This template **extends** the base template at `.harmony/scaffolding/runtime/templates/harmony/`.

### Resolution Order

When creating a harness using this template:

1. Copy all files from `.harmony/scaffolding/runtime/templates/harmony/` (base)
2. Overlay files from this directory (scope-specific overrides)

### Files in This Template

| File | Purpose |
|------|---------|
| `MANIFEST.md` | This file (template metadata) |
| `START.md` | Node.js/TS-specific boot sequence (overrides base) |
| `scope.md` | Package-specific scope template (overrides base) |
| `conventions.md` | TypeScript/React conventions (overrides base) |
| `assurance/practices/complete.md` | Code-specific definition of done (overrides base) |

### Files Inherited from Base

All other files come from `.harmony/scaffolding/runtime/templates/harmony/`:

- `catalog.md`
- `cognition/runtime/context/` (decisions, lessons, glossary, dependencies, constraints)
- `continuity/` (log.md, tasks.json, entities.json)
- `assurance/practices/session-exit.md`
- `capabilities/runtime/commands/`, `scaffolding/governance/patterns/`, `scaffolding/practices/prompts/`, `orchestration/runtime/workflows/`, `scaffolding/runtime/templates/`, `scaffolding/practices/examples/` (README placeholders)

## Usage

This template is used by the `/create-harness` workflow when creating a harness for a Node.js/TypeScript package.

```text
/create-harness @packages/ui --template node-ts
```
