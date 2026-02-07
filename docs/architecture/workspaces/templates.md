---
title: Workspace Templates
description: Boilerplate files for creating new content stored in .harmony/scaffolding/templates/
---

# Workspace Templates

Templates are **boilerplate files** stored in `.harmony/scaffolding/templates/`. They provide starting points for creating new content within the workspace's domain.

## Location

```text
.harmony/scaffolding/templates/
├── cursor-command.md       # Template for Cursor commands
├── document.md             # Template for new documents
├── harmony/                # Base .harmony/ template
│   ├── START.md
│   ├── scope.md
│   ├── conventions.md
│   ├── catalog.md
│   ├── capabilities/commands/
│   ├── orchestration/workflows/
│   ├── scaffolding/prompts/
│   ├── cognition/context/
│   ├── continuity/
│   ├── quality/
│   ├── scaffolding/templates/
│   └── scaffolding/examples/
├── harmony-docs/           # Scoped template for documentation areas
│   ├── MANIFEST.md         # Inheritance metadata
│   ├── START.md            # Overrides base
│   ├── scope.md            # Overrides base
│   ├── conventions.md      # Overrides base
│   ├── quality/done.md     # Overrides base
│   └── orchestration/workflows/are/  # Docs-specific workflows
└── harmony-node-ts/        # Scoped template for Node.js/TypeScript
    ├── MANIFEST.md         # Inheritance metadata
    ├── START.md            # Overrides base
    ├── scope.md            # Overrides base
    ├── conventions.md      # Overrides base
    └── quality/done.md     # Overrides base
```

---

## Template Manifests

Each template directory contains two manifest files:

| File | Format | Purpose |
|------|--------|---------|
| `manifest.json` | JSON | Machine-readable; used by `/create-workspace` workflow |
| `MANIFEST.md` | Markdown | Human-readable; detailed documentation and examples |

### manifest.json Structure

The `manifest.json` file defines:

| Field | Description |
|-------|-------------|
| `name` | Template identifier |
| `description` | Brief description |
| `inherits` | Parent template name (or `null` for base) |
| `files` | Required files and directories (base template only) |
| `contents` | Map of file paths to descriptions (base template only) |
| `overrides` | Files from parent that this template replaces |
| `additions` | New directories and files added by this template |
| `usage` | Example command to use this template |

### How `/create-workspace` Uses Manifests

1. Read the target template's `manifest.json`
2. If `inherits` is set, first copy all files from the parent template
3. Overlay files listed in `overrides` from the scoped template
4. Copy additional directories and files from `additions`

A JSON schema is available at `.harmony/scaffolding/templates/manifest.schema.json`.

---

## Template Inheritance

Scoped templates **extend** the base `harmony/` template:

| Template | Inherits From | Adds/Overrides |
|----------|---------------|----------------|
| `harmony/` | — | Base structure for all workspaces |
| `harmony-docs/` | `harmony/` | Docs conventions, ARE workflows |
| `harmony-node-ts/` | `harmony/` | TypeScript/React conventions |

### Resolution Order

When creating a workspace with a scoped template:

1. Copy all files from `harmony/` (base)
2. Overlay files from the scoped template (overrides)
3. Copy any scope-specific directories (e.g., `workflows/are/`)

See each template's `MANIFEST.md` for human-readable details or `manifest.json` for machine-readable structure.

---

## When to Use Templates

| Situation | Use Templates |
|-----------|---------------|
| Creating new workspaces | ✅ Yes |
| Adding new documents of a standard type | ✅ Yes |
| One-off content creation | ❌ No (write directly) |
| Content with no standard structure | ❌ No |

---

## Template Principles

1. **Minimal viable content** — Include only what's required; users fill in specifics
2. **Placeholder markers** — Use `{{PLACEHOLDER}}` for content that must be customized
3. **Comments for guidance** — Include brief inline comments explaining sections
4. **Valid structure** — Templates should pass validation as-is (except placeholders)

---

## Using Templates

Templates are typically used by workflows (e.g., `/create-workspace` copies from `.harmony/scaffolding/templates/harmony/`).

### With Scoped Templates

```text
/create-workspace @docs/api-reference --template docs
/create-workspace @packages/ui --template node-ts
```

### Manual Usage

1. Copy base template to target location
2. If using a scoped template, overlay its files
3. Replace all `{{PLACEHOLDER}}` markers
4. Remove any guidance comments
5. Verify against workspace conventions

---

## Template vs Example

| Type | Purpose | Location |
|------|---------|----------|
| **Template** | Starting point to copy and customize | `.harmony/scaffolding/templates/` |
| **Example** | Reference to study and learn from | `.harmony/scaffolding/examples/` |

Templates are *scaffolds*. Examples are *references*.

---

## See Also

- [Examples](./examples.md) — Reference patterns
- [Workflows](./workflows.md) — Procedures that use templates
- [README.md](./README.md) — Canonical workspace structure
