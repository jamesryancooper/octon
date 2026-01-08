---
title: Workspace Commands
description: Workspace-scoped atomic operations defined in .workspace/commands/.
---

# Workspace Commands

Workspace commands are **workspace-scoped atomic operations** defined in `.workspace/commands/`. They are deterministic, self-contained procedures that operate on artifacts in the workspace's parent directory.

## Commands vs Prompts

See `.workspace/catalog.md#command-vs-prompt-decision` for the decision logic.

---

## Invocation

Workspace commands can be invoked in two ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the command file | Agent reads `.workspace/commands/validate-frontmatter.md` |
| **Wrapped** | User types a Cursor slash command that delegates to the workspace command | `/validate-frontmatter` triggers `.workspace/commands/validate-frontmatter.md` |

When a workspace command is wrapped by a Cursor command (in `.cursor/commands/`), it gains IDE integration—appearing in autocomplete when the user types `/`.

---

## Frontmatter Requirements

Workspace command files require YAML frontmatter with the following fields:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `human` (has Cursor command wrapper) or `agent` (agent-only) |

---

## Example: Validate Frontmatter

A workspace command for validating YAML frontmatter in markdown files.

> **Note:** This example is illustrative. See the actual implementation in `.workspace/commands/validate-frontmatter.md` for the full specification.

**Location:** `.workspace/commands/validate-frontmatter.md`

```markdown
---
title: Validate Frontmatter
description: Validate YAML frontmatter in markdown files
access: human
---

# Validate Frontmatter

Validate YAML frontmatter in all markdown files in the parent directory.

## Action

1. Find all `*.md` files in the parent directory (recursive)
2. For each file, check that frontmatter exists and contains required fields
3. Report any files with missing or invalid frontmatter

## Output

List of files with validation status:
- ✅ Valid
- ❌ Missing frontmatter
- ⚠️ Missing required field: `<field>`
```

### Direct Invocation

An agent working in the workspace can reference the command directly:

> "Validate frontmatter using `.workspace/commands/validate-frontmatter.md`"

### Wrapped Invocation

To enable `/validate-frontmatter` in Cursor chat, create a wrapper:

**Location:** `.cursor/commands/validate-frontmatter.md`

```markdown
# Validate Frontmatter `/validate-frontmatter`

Validate YAML frontmatter in markdown files.

## Usage

\`\`\`text
/validate-frontmatter @path/to/directory
\`\`\`

## Implementation

Execute `.workspace/commands/validate-frontmatter.md` in the target directory's workspace.
```

---

## Command Examples

| Command | Purpose | Why It's a Command (Not a Prompt) |
|---------|---------|-----------------------------------|
| `validate-frontmatter.md` | Check YAML frontmatter | Deterministic validation rules |
| `recover.md` | Recovery procedures | Fixed steps for known error types |
| `format-for-publication.md` | Apply formatting | Consistent rules, no judgment |
| `lint-conventions.md` | Check style compliance | Objective criteria |

---

## See Also

- [Prompts](./prompts.md) — Context-dependent task templates
- [Workflows](./workflows.md) — Multi-step procedures
- [Taxonomy](./taxonomy.md) — Full classification of artifact types
- [README.md](./README.md) — Canonical workspace structure reference
