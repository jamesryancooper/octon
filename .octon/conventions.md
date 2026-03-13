---
title: Conventions
description: Style and formatting rules for the root .octon harness.
---

# Conventions

## File Naming

- Lowercase with hyphens: `my-prompt.md`
- Commands: `{verb}-{noun}.md` (e.g., `validate-frontmatter.md`)
- Prompts: `{action}-{target}.md` (e.g., `audit-content.md`)
- Workflows: `{verb}-{noun}/` directory (e.g., `create-workflow/`)
- Skills & Workflows: Use verbs from the [Verb Vocabulary](/.octon/capabilities/practices/design-conventions.md#verb-vocabulary)

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

## Visual Communication Standards

Use visuals to reduce ambiguity and improve comprehension, not for decoration.

### When to Use Visuals

- Use **tables** for comparisons, tradeoffs, precedence, and contract boundaries.
- Use **Mermaid diagrams** for non-trivial flows, orchestration, state transitions, or branching logic.
- Prefer plain lists/prose when the structure is simple and unambiguous.

### Anti-Drift Rules

- Every visual must have a functional purpose (decision clarity, flow clarity, or scope clarity).
- Do not add decorative visuals, stylistic ornamentation, or duplicate a structure already clear in prose.
- Prefer the smallest visual that communicates the model.

### Maintenance Rules

- Keep visuals source-of-truth adjacent to the policy they represent.
- Update visuals in the same change that modifies the underlying behavior/contract.
- If a visual and prose diverge, align the visual immediately or remove it.

## Version Control Standards

- Follow `.octon/agency/practices/commits.md` for commit message format, branch naming,
  and commit discipline.
- Enforcement values are defined in
  `.octon/agency/practices/standards/commit-pr-standards.json`.
- Use Conventional Commits with explicit scope:
  `<type>(<scope>): <summary>`.
- Keep commit summaries outcome-focused and <=72 characters.

## Repository Naming Conventions

- Scoped components and slices: `<scope>/<slice-name>/...` (kebab-case).
- Feature flags: `feature.<slice>.<capability>` (default OFF, fail-closed).
- Kill switches: `kill.<area>.<toggle>`.
- Environment variables: `SCREAMING_SNAKE_CASE`.
- Identifiers: prefer ULID/UUIDv7 over sequential IDs for external-facing entities.
- Error codes: `ERR_<AREA>_<CONDITION>` with a stable machine code and human-readable message.

## API and Contract Conventions

- Design contract-first with OpenAPI/JSON Schema.
- Use noun-based resources and verb-based actions when needed
  (for example, `/orders`, `/orders/{id}/cancel`).
- Require `Idempotency-Key` on mutating endpoints where retries are possible.
- Use a consistent error envelope shape:
  `{ "error": { "code": "...", "message": "...", "details": ... } }`.

## Documentation Metadata Conventions

- Markdown documents should include frontmatter with at least:
  - `title`
  - `description`
- Use relative links where possible for intra-repo references.
- Prefer Mermaid for non-trivial architecture and flow diagrams.

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
| `Command:` | Delegating to a harness command (atomic) |
| `Workflow:` | Delegating to a harness workflow (multi-step) |
| `Prompt:` | Delegating to a harness prompt (template) |

**Template:** `.octon/scaffolding/runtime/templates/cursor-command.md`

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
| `cognition/runtime/context/decisions.md` | Decision summary | Append new decisions; never update old references |
| `cognition/runtime/decisions/*.md` | Full ADRs | Append addendums; never modify accepted content |

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
- **ADR:** [ADR-004](cognition/runtime/decisions/004-refactor-workflow.md)
- **Workflow:** `.octon/orchestration/runtime/workflows/refactor/refactor/`
