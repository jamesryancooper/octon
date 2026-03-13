---
description: Context for creating, updating, or evaluating .octon directories
globs:
  - "**/.octon/**"
alwaysApply: false
---

# Harness

A `.octon` directory is a **localized agent harness** that drives the creation of artifacts in its parent directory—code, docs, configs, or any deliverables.

---

## Canonical References

| Topic | Canonical Source |
|-------|------------------|
| **Harness structure** | `.octon/START.md` |
| **Artifact taxonomy** | `.octon/cognition/_meta/architecture/taxonomy.md` |
| **Commands** | `.octon/capabilities/_meta/architecture/commands.md` |
| **Workflows** | `.octon/orchestration/_meta/architecture/workflows.md` |
| **Prompts** | `.octon/scaffolding/_meta/architecture/prompts.md` |
| **Scripts** | `.octon/capabilities/services/README.md` |

---

## Frontmatter Requirements

All markdown files in `.octon/` require YAML frontmatter. See the table below for field requirements by file type.

### Required Fields by File Type

| File Type | `title` | `description` | `access` |
|-----------|---------|---------------|----------|
| Root files (`START.md`, `scope.md`, etc.) | ✅ | ✅ | — |
| Commands (`capabilities/commands/*.md`) | ✅ | ✅ | ✅ |
| Workflow overviews (`orchestration/workflows/**/00-overview.md`) | ✅ | ✅ | ✅ |
| Prompts (`scaffolding/prompts/*.md`) | ✅ | ✅ | ✅ |
| Checklists (`assurance/*.md`) | ✅ | ✅ | — |
| Context files (`cognition/context/*.md`) | ✅ | ✅ | — |

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

See `.octon/catalog.md#ide-integration-decision` for detailed decision guidance.

---

## When This Rule Applies

This rule provides context when working with `.octon` files.

**Decision guidance:** See `.octon/catalog.md#decision-guidance`

**This harness's operations:** See `.octon/catalog.md`

---

## Canonical Structure

See `.octon/START.md` for the full structure reference, including:

- Required files and directories
- Agent-ignored (dot-prefixed) directories
- Token budget guidelines

**Templates:**

| Template | Path | Use For |
|----------|------|---------|
| Base harness | `.octon/scaffolding/templates/octon/` | Repo-root harness bootstrap |
| Cursor command | `.octon/scaffolding/templates/cursor-command.md` | Cursor command wrappers (local) |
| Document | `.octon/scaffolding/templates/document.md` | General documents (local) |

> **Note:** Base templates live in `.octon/` (shared). Project-specific templates stay in `.octon/scaffolding/templates/`.

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
| `ideation/scratchpad/` | **Human-led only** | Agents access ONLY when human explicitly directs to specific files |
| `.inbox/` | **Human-led only** | Agents access ONLY when human explicitly directs to specific files |
| `.archive/` | **Never access** | Agents MUST NOT read, write, or reference |

### Human-Led Collaboration

For `ideation/scratchpad/` and `.inbox/`, agents MAY assist when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `ideation/scratchpad/ideas/auth.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X")
3. Agent's work stays within the referenced files

**During autonomous operation:** Treat `ideation/scratchpad/` and `.inbox/` as if they do not exist. No scanning, no retrieval, no "helpful" edits.

See `.octon/START.md` for full documentation.

---

## Token Budget Guidelines

For agent-facing content (everything without dot prefix):

### Aggregate Budgets

| Scope | Target | Max |
|-------|--------|-----|
| Total harness | ~2,000 | ~5,000 |
| Single file | ~300 | ~500 |
| START.md (boot) | ~200 | ~300 |

### Per-File Budgets (cognition/context/)

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

## Context When Editing Harness Files

For operational instructions when editing harness files, see the harness's own `START.md` boot sequence, which covers:

- Following conventions in `conventions.md`
- Staying within scope defined in `scope.md`
- Updating `continuity/log.md` when making changes
- Verifying against `assurance/complete.md` before completing work
