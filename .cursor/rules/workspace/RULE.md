---
description: Context for creating, updating, or evaluating .workspace directories
globs:
  - "**/.workspace/**"
alwaysApply: false
---

# Workspace

A `.workspace` directory is a **localized agent harness** that drives the creation of artifacts in its parent directory—code, docs, configs, or any deliverables.

---

## Canonical References

| Topic | Canonical Source |
|-------|------------------|
| **Workspace structure** | `docs/architecture/workspaces/README.md` |
| **Artifact taxonomy** | `docs/architecture/workspaces/taxonomy.md` |
| **Commands** | `docs/architecture/workspaces/commands.md` |
| **Workflows** | `docs/architecture/workspaces/workflows.md` |
| **Prompts** | `docs/architecture/workspaces/prompts.md` |
| **Scripts** | `docs/architecture/workspaces/scripts.md` |

---

## Frontmatter Requirements

All markdown files in `.harmony/` require YAML frontmatter. See the table below for field requirements by file type.

### Required Fields by File Type

| File Type | `title` | `description` | `access` |
|-----------|---------|---------------|----------|
| Root files (`START.md`, `scope.md`, etc.) | ✅ | ✅ | — |
| Commands (`commands/*.md`) | ✅ | ✅ | ✅ |
| Workflow overviews (`workflows/**/00-overview.md`) | ✅ | ✅ | ✅ |
| Prompts (`prompts/*.md`) | ✅ | ✅ | ✅ |
| Checklists (`checklists/*.md`) | ✅ | ✅ | — |
| Context files (`context/*.md`) | ✅ | ✅ | — |

### Field Specifications

| Field | Description | Constraints |
|-------|-------------|-------------|
| `title` | Document title | Required for all files |
| `description` | Brief summary | Max 160 characters; end with a period |
| `access` | IDE integration level | `human` (has Cursor command) or `agent` (agent-only) |

### Access Values

| Value | Meaning | When to Use |
|-------|---------|-------------|
| `human` | Has Cursor command wrapper in `.cursor/commands/` | Humans frequently trigger directly |
| `agent` | Agent-only; no IDE integration | Only used as sub-procedures |

See `.harmony/catalog.md#ide-integration-decision` for detailed decision guidance.

---

## When This Rule Applies

This rule provides context when working with `.workspace` files.

**Decision guidance:** See `.harmony/catalog.md#decision-guidance`

**This workspace's operations:** See `.harmony/catalog.md`

---

## Canonical Structure

See `docs/architecture/workspaces/README.md` for the full structure reference, including:

- Required files and directories
- Agent-ignored (dot-prefixed) directories
- Token budget guidelines

**Templates:**

| Template | Path | Use For |
|----------|------|---------|
| Base workspace | `.harmony/scaffolding/templates/harmony/` | All workspaces inherit from this |
| Docs workspace | `.harmony/scaffolding/templates/harmony-docs/` | Documentation areas |
| Node.js/TS workspace | `.harmony/scaffolding/templates/harmony-node-ts/` | TypeScript packages |
| Cursor command | `.harmony/scaffolding/templates/cursor-command.md` | Cursor command wrappers (local) |
| Document | `.harmony/scaffolding/templates/document.md` | General documents (local) |

> **Note:** Base templates live in `.harmony/` (shared). Project-specific templates stay in `.harmony/scaffolding/templates/`.

---

## Key Principles

1. **Locality** — Guidance lives close to where it's needed
2. **Agent-first** — Content is actionable, not explanatory
3. **Dot-prefix = off-limits** — See autonomy rules below
4. **Token budget** — Stay within limits below

---

## Autonomy Rules for Dot-Prefixed Directories

| Directory | Autonomy Level | Description |
|-----------|----------------|-------------|
| `.humans/` | **Never access** | Agents MUST NOT read, write, or reference |
| `.scratchpad/` | **Human-led only** | Agents access ONLY when human explicitly directs to specific files |
| `.inbox/` | **Human-led only** | Agents access ONLY when human explicitly directs to specific files |
| `.archive/` | **Never access** | Agents MUST NOT read, write, or reference |

### Human-Led Collaboration

For `.scratchpad/` and `.inbox/`, agents MAY assist when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `.scratchpad/ideas/auth.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X")
3. Agent's work stays within the referenced files

**During autonomous operation:** Treat `.scratchpad/` and `.inbox/` as if they do not exist. No scanning, no retrieval, no "helpful" edits.

See `docs/architecture/workspaces/dot-files.md` for full documentation.

---

## Token Budget Guidelines

For agent-facing content (everything without dot prefix):

### Aggregate Budgets

| Scope | Target | Max |
|-------|--------|-----|
| Total harness | ~2,000 | ~5,000 |
| Single file | ~300 | ~500 |
| START.md (boot) | ~200 | ~300 |

### Per-File Budgets (context/)

| File | Target | Max |
|------|--------|-----|
| decisions.md | ~150 | ~300 |
| lessons.md | ~150 | ~300 |
| glossary.md | ~100 | ~200 |
| dependencies.md | ~150 | ~300 |
| constraints.md | ~100 | ~200 |
| compaction.md | ~100 | ~200 |
| tools.md | ~150 | ~300 |

**Rationale:** A compact harness leaves maximum context window for actual work.

> **Note:** Per-file budgets are **included in** the aggregate totals, not additional. A typical session loads START.md + scope.md + catalog.md + 1-2 context files (~800-1,200 tokens). Loading all files simultaneously would exceed the ~2,000 token target.

---

## Context When Editing Workspace Files

For operational instructions when editing workspace files, see the workspace's own `START.md` boot sequence, which covers:

- Following conventions in `conventions.md`
- Staying within scope defined in `scope.md`
- Updating `progress/log.md` when making changes
- Verifying against `checklists/complete.md` before completing work
