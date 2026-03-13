---
title: Harness Templates
description: Boilerplate files for creating new content stored in .octon/scaffolding/runtime/templates/
---

# Harness Templates

Templates are **boilerplate files** stored in `.octon/scaffolding/runtime/templates/`. They provide starting points for creating new reusable content within the harness's domain.

Bootstrap assets used by `/init` are not part of this surface. They live under `.octon/scaffolding/runtime/bootstrap/`.

## Location

```text
.octon/scaffolding/runtime/templates/
├── README.md               # Reusable templates overview
├── cursor-command.md       # Template for Cursor commands
├── document.md             # Template for new documents
├── octon/                # Base .octon/ template
│   ├── START.md
│   ├── scope.md
│   ├── conventions.md
│   ├── catalog.md
│   ├── capabilities/runtime/commands/
│   ├── orchestration/runtime/workflows/
│   ├── scaffolding/practices/prompts/
│   ├── scaffolding/governance/patterns/
│   ├── cognition/runtime/context/
│   ├── continuity/
│   ├── assurance/
│   ├── scaffolding/runtime/bootstrap/
│   │   ├── AGENTS.md       # Included canonical .octon/AGENTS.md source
│   │   ├── BOOT.md         # Included optional BOOT template
│   │   ├── BOOTSTRAP.md    # Included optional BOOTSTRAP template
│   │   └── objectives/     # Included objective packs for /init
│   ├── scaffolding/runtime/templates/
│   │   └── README.md       # Included reusable template placeholder
│   ├── scaffolding/runtime/_ops/scripts/
│   │   └── init-project.sh # Project bootstrap generator
│   └── scaffolding/practices/examples/
└── proposal-*/             # Proposal/support templates
```

---

## Template Manifests

Each harness template directory contains a manifest file:

| File | Format | Purpose |
|------|--------|---------|
| `manifest.json` | JSON | Machine-readable template metadata |

### manifest.json Structure

The `manifest.json` file defines:

| Field | Description |
|-------|-------------|
| `name` | Template identifier |
| `description` | Brief description |
| `inherits` | Parent template name (or `null` for base/support template) |
| `files` | Required files and directories (base template only) |
| `contents` | Map of file paths to descriptions (base template only) |
| `usage` | Example command to use this template |

### How Template Metadata Is Used

1. Read the target template's `manifest.json`
2. Copy the base `octon/` template for the target repository root
3. Customize the copied files to the repository context

A JSON schema is available at `.octon/scaffolding/runtime/templates/manifest.schema.json`.

---

## Supported Harness Template

Octon supports one harness template for one supported harness shape:

| Template | Purpose |
|----------|---------|
| `octon/` | Base structure for the repo-root harness |

---

## When to Use Templates

| Situation | Use Templates |
|-----------|---------------|
| Creating new harnesses | ✅ Yes |
| Initializing project-level agent bootstrap files | ✅ Yes (`runtime/bootstrap/AGENTS.md` via `/init`) |
| Initializing workspace objective contracts | ✅ Yes (`runtime/bootstrap/objectives/` via `/init`) |
| Initializing optional BOOT compatibility files | ✅ Optional (`runtime/bootstrap/BOOT.md`, `runtime/bootstrap/BOOTSTRAP.md` via `/init --with-boot-files`) |
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

Templates are used as reusable scaffolding assets. The base `octon` template also carries a projected copy of the canonical bootstrap bundle under `scaffolding/runtime/bootstrap/`.

### Manual Usage

1. Copy base template to target location
2. Replace all `{{PLACEHOLDER}}` markers
3. Remove any guidance comments
4. Verify against harness conventions

---

## Template vs Example

| Type | Purpose | Location |
|------|---------|----------|
| **Template** | Starting point to copy and customize | `.octon/scaffolding/runtime/templates/` |
| **Example** | Reference to study and learn from | `.octon/scaffolding/practices/examples/` |

Templates are *scaffolds*. Examples are *references*.

---

## See Also

- [Examples](./examples.md) — Reference patterns
- [Workflows](../../../orchestration/_meta/architecture/workflows.md) — Procedures that use templates
- [README.md](./README.md) — Canonical harness structure
