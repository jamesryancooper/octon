---
title: Workspace Workflows
description: Workspace-scoped multi-step procedures defined in .workspace/workflows/.
---

# Workspace Workflows

Workspace workflows are **workspace-scoped multi-step procedures** defined in `.workspace/workflows/`. They operate on artifacts in the workspace's parent directory.

> **Not FlowKit flows:** `packages/workflows/<flowId>/` contains **FlowKit flow assets** (config + manifest + prompts) executed by FlowKit + the LangGraph runtime. `.workspace/workflows/**` contains **procedures** an agent follows. The seam is `/run-flow`, which delegates to `.workspace/workflows/flowkit/run-flow/*` and runs `@packages/workflows/<flowId>/config.flow.json`.

## Invocation

Workspace workflows can be invoked in two ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the workflow | Agent reads `.workspace/workflows/publish-to-docs/00-overview.md` |
| **Wrapped** | User types a Cursor slash command that delegates to the workflow | `/create-workspace` triggers `.workspace/workflows/workspace/create-workspace/` |

When a workspace workflow is wrapped by a Cursor command (in `.cursor/commands/`), it gains IDE integration—appearing in autocomplete when the user types `/`.

---

## Structure

Simple workflows can be single files. Complex workflows use subdirectories with numbered step files:

```text
.workspace/workflows/my-workflow/
├── 00-overview.md
├── 01-first-step.md
├── 02-second-step.md
└── 03-final-step.md
```

The `00-overview.md` file should contain:

- Purpose description
- Target specification
- Prerequisites
- Failure conditions
- Step list with links
- References

### Frontmatter Requirements

Workflow overview files (`00-overview.md`) require YAML frontmatter:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Workflow title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `human` (has Cursor command wrapper) or `agent` (agent-only) |

> This frontmatter contract applies to `.workspace/workflows/**` only. FlowKit canonical prompts under `packages/workflows/**` intentionally keep frontmatter minimal; wiring and semantics live in `config.flow.json` and `manifest.yaml`.

---

## Example: Workspace Management Workflows

The workspace management commands demonstrate the **Cursor Command → Workflow** pattern:

| Cursor Command | Delegates To | Purpose |
|----------------|--------------|---------|
| `/create-workspace` | `.workspace/workflows/workspace/create-workspace/` | Scaffold a new `.workspace` directory |
| `/update-workspace` | `.workspace/workflows/workspace/update-workspace/` | Align with canonical definition |
| `/evaluate-workspace` | `.workspace/workflows/workspace/evaluate-workspace/` | Assess token efficiency |

Each workflow subdirectory contains numbered step files for the agent to follow sequentially.

### Architecture

| Layer | Location | Purpose |
|-------|----------|---------|
| **Entry point** | `.cursor/commands/*.md` | User-facing syntax, triggers `/command` in chat |
| **Implementation** | `.workspace/workflows/workspace/<name>/` | Multi-step procedure the agent executes |
| **Templates** | `.workspace/templates/workspace/` | Boilerplate for new workspaces |

### Usage Examples

**Create a new workspace:**

```text
/create-workspace @path/to/target/directory
```

**Update an existing workspace:**

```text
/update-workspace @path/to/.workspace
```

Or for the root workspace:

```text
/update-workspace @.workspace
```

**Evaluate a workspace (read-only):**

```text
/evaluate-workspace @.workspace
```

Or for a nested workspace:

```text
/evaluate-workspace @docs/my-feature/.workspace
```

> **Note:** Workspace management uses the **Cursor Command → Workflow** pattern (no intermediate Workspace Commands). This is because workspace management is a repo-wide concern requiring IDE integration, not a workspace-specific atomic operation.

---

## See Also

- [Taxonomy](./taxonomy.md) — Cursor commands vs workspace commands vs workspace workflows
- [Workspace Commands](./commands.md) — Workspace-scoped atomic operations
- [README.md](./README.md) — Canonical workspace structure reference
