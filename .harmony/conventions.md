---
title: Conventions
description: Style and formatting rules for the root .harmony harness.
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

### Human-Facing Files (in `ideation/scratchpad/` or `docs/`)

- Full prose explanations welcome
- Include rationale and history
- No token budget constraints

## Writing Style

| Do | Don't |
|----|-------|
| Use imperative verbs | Explain why (save for `ideation/scratchpad/` or `docs/`) |
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

**Template:** `.harmony/scaffolding/templates/cursor-command.md`

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

**Immutability rule:** Past entries in `continuity/log.md` are immutable. New sessions append new entries; existing entries are never modified. This preserves historical accuracy across refactors and renames.

## Continuity Artifacts

Continuity artifacts are files that preserve historical context across sessions. They use `mutability: append-only` in frontmatter to signal protection.

### Protected Files

| File | Purpose | Rule |
|------|---------|------|
| `continuity/log.md` | Session history | Append new entries; never modify past entries |
| `cognition/context/decisions.md` | Decision summary | Append new decisions; never update old references |
| `decisions/*.md` | Full ADRs | Append addendums; never modify accepted content |

### Mutability Frontmatter

Files marked with `mutability: append-only` must not have existing content modified:

```yaml
---
title: Progress Log
description: Chronological record of session work and decisions.
mutability: append-only
---
```

### What "Append-Only" Means

| Allowed | Not Allowed |
|---------|-------------|
| Add new log entry | Modify existing log entry |
| Add new decision row | Update old decision text |
| Add ADR addendum section | Change accepted ADR content |
| Fix typos in current session's entry | Fix typos in past session's entry |

### During Refactors

When renaming or moving paths, **do not** update historical references:

- A log entry from 2026-01-13 that says `.scratch/` should forever say `.scratch/`, even after renaming to `.scratchpad/`
- Add a new entry documenting the rename instead

**Rationale:** Historical accuracy is more important than naming consistency. Future readers should see the progression of changes, not a sanitized history.

### See Also

- **Decision:** D014 (Continuity artifact immutability)
- **ADR:** [ADR-004](decisions/004-refactor-workflow.md)
- **Workflow:** `.harmony/orchestration/workflows/refactor/`
