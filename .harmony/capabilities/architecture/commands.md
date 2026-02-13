---
title: Harness Commands
description: Harness-scoped atomic operations defined in .harmony/capabilities/commands/.
---

# Harness Commands

Harness commands are **harness-scoped atomic operations** defined in `.harmony/capabilities/commands/`. They are deterministic, self-contained procedures that operate on artifacts in the harness's parent directory.

## Commands vs Prompts

See `.harmony/catalog.md#command-vs-prompt-decision` for the decision logic.

---

## Invocation

Harness commands can be invoked in multiple ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the command file | Agent reads `.harmony/capabilities/commands/validate-frontmatter.md` |
| **Wrapped (Cursor)** | User types `/command` in Cursor | Via `.cursor/commands/` wrapper |
| **Wrapped (Claude Code)** | User types `/command` in Claude Code | Via `.claude/commands/` wrapper |
| **Wrapped (Any Harness)** | Harness-specific entry point | Via `.<harness>/commands/` wrapper |

When wrapped by a harness entry point, the command gains that harness's integration features.

> **Universal Harness-Agnostic Pattern:** Harness commands are the source of truth. Harness entry points (`.cursor/commands/`, `.claude/commands/`, etc.) are thin wrappers. See [workflows.md](./workflows.md) for the full pattern.

---

## Frontmatter Requirements

Harness command files require YAML frontmatter with the following fields:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `human` (has Cursor command wrapper) or `agent` (agent-only) |

---

## Example: Validate Frontmatter

A harness command for validating YAML frontmatter in markdown files.

> **Note:** This example is illustrative. See the actual implementation in `.harmony/capabilities/commands/validate-frontmatter.md` for the full specification.

**Location:** `.harmony/capabilities/commands/validate-frontmatter.md`

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

An agent working in the harness can reference the command directly:

> "Validate frontmatter using `.harmony/capabilities/commands/validate-frontmatter.md`"

### Wrapped Invocation

To enable `/validate-frontmatter` in any harness, create a thin wrapper:

**Location:** `.<harness>/commands/validate-frontmatter.md` (e.g., `.cursor/commands/`, `.claude/commands/`)

```markdown
# Validate Frontmatter `/validate-frontmatter`

Validate YAML frontmatter in markdown files.

See `.harmony/capabilities/commands/validate-frontmatter.md` for full implementation.

## Usage

\`\`\`text
/validate-frontmatter @path/to/directory
\`\`\`

## Implementation

Execute `.harmony/capabilities/commands/validate-frontmatter.md` in the target directory's harness.
```

> **Note:** The same wrapper pattern works for any harness. Create equivalent files in `.cursor/commands/`, `.claude/commands/`, `.codex/commands/`, etc.

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
- [README.md](./README.md) — Canonical harness structure reference
