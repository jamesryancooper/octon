---
title: Workspace Templates
description: Boilerplate files for creating new content stored in .workspace/templates/
---

# Workspace Templates

Templates are **boilerplate files** stored in `.workspace/templates/`. They provide starting points for creating new content within the workspace's domain.

## Location

```text
.workspace/templates/
├── cursor-command.md       # Template for Cursor commands
├── document.md             # Template for new documents
├── workspace/              # Base workspace template
│   ├── START.md
│   ├── scope.md
│   ├── conventions.md
│   ├── catalog.md
│   ├── commands/
│   ├── workflows/
│   ├── prompts/
│   ├── context/
│   ├── progress/
│   ├── checklists/
│   ├── templates/
│   └── examples/
├── workspace-docs/         # Scoped template for documentation areas
│   ├── MANIFEST.md         # Inheritance metadata
│   ├── START.md            # Overrides base
│   ├── scope.md            # Overrides base
│   ├── conventions.md      # Overrides base
│   ├── checklists/complete.md  # Overrides base
│   └── workflows/are/      # Docs-specific workflows
└── workspace-node-ts/      # Scoped template for Node.js/TypeScript
    ├── MANIFEST.md         # Inheritance metadata
    ├── START.md            # Overrides base
    ├── scope.md            # Overrides base
    ├── conventions.md      # Overrides base
    └── checklists/complete.md  # Overrides base
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

A JSON schema is available at `.workspace/templates/manifest.schema.json`.

---

## Template Inheritance

Scoped workspace templates **extend** the base `workspace/` template:

| Template | Inherits From | Adds/Overrides |
|----------|---------------|----------------|
| `workspace/` | — | Base structure for all workspaces |
| `workspace-docs/` | `workspace/` | Docs conventions, ARE workflows |
| `workspace-node-ts/` | `workspace/` | TypeScript/React conventions |

### Resolution Order

When creating a workspace with a scoped template:

1. Copy all files from `workspace/` (base)
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

Templates are typically used by workflows (e.g., `/create-workspace` copies from `.workspace/templates/workspace/`).

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
| **Template** | Starting point to copy and customize | `.workspace/templates/` |
| **Example** | Reference to study and learn from | `.workspace/examples/` |

Templates are *scaffolds*. Examples are *references*.

---

## See Also

- [Examples](./examples.md) — Reference patterns
- [Workflows](./workflows.md) — Procedures that use templates
- [README.md](./README.md) — Canonical workspace structure
