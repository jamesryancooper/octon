---
title: Conventions
description: Style and formatting rules for the root .workspace harness.
---

# Conventions

## File Naming

- Lowercase with hyphens: `my-prompt.md`
- Commands: `{verb}-{noun}.md` (e.g., `validate-frontmatter.md`)
- Prompts: `{action}-{target}.md` (e.g., `audit-content.md`)
- Workflows: `{verb}-{noun}/` directory (e.g., `create-workspace/`)

## Command vs Prompt Decision

See `catalog.md#command-vs-prompt-decision` for the canonical decision logic, flowchart, and examples.

## Document Structure

### Agent-Facing Files

```markdown
# Title (action-oriented)

## Context (1-2 sentences max)

## Instructions (numbered list)

## Output (what to produce)
```

### Human-Facing Files (in `.humans/`)

- Full prose explanations welcome
- Include rationale and history
- No token budget constraints

## Writing Style

| Do | Don't |
|----|-------|
| Use imperative verbs | Explain why (save for `.humans/`) |
| Use lists over prose | Write paragraphs |
| Be specific and concrete | Use vague language |
| Include examples when non-obvious | Over-document obvious patterns |
| End frontmatter `description` with a period | Omit punctuation in descriptions |

## Cursor Command Structure

Cursor commands in `.cursor/commands/` follow this **minimum structure**. Additional sections (e.g., `## Parameters`, `## Available Templates`) are permitted as needed.

```markdown
# [Command Title] `/[command-name]`

[One-line description.]

See `[reference]` for full details.

## Usage

\`\`\`text
/[command-name] @[target]
\`\`\`

## Implementation

[What gets executed.]

## References

- **Canonical:** `[path to docs]`
- **[Command|Workflow]:** `[path to implementation]`
```

### Reference Labels

| Label | Use When |
|-------|----------|
| `Command:` | Delegating to a workspace command (atomic) |
| `Workflow:` | Delegating to a workspace workflow (multi-step) |
| `Prompt:` | Delegating to a workspace prompt (template) |

**Template:** `.workspace/templates/cursor-command.md`

## Progress Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]
- [task 2]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```
