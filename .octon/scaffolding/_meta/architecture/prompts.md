---
title: Harness Prompts
description: Reusable task templates stored in .octon/scaffolding/practices/prompts/
---

# Harness Prompts

Prompts are **reusable task templates** stored in `.octon/scaffolding/practices/prompts/`. They guide agents through context-dependent tasks that require judgment or parameterization.

## Location

```text
.octon/scaffolding/practices/prompts/
├── audit-content.md
├── improve-clarity.md
└── verify-completeness.md
```

---

## Prompts vs Commands

See `.octon/catalog.md#command-vs-prompt-decision` for the decision logic.

---

## When to Use Prompts

| Situation | Use Prompts |
|-----------|-------------|
| Task requires user-provided context | ✅ Yes |
| Output depends on agent judgment | ✅ Yes |
| Same task, different inputs each time | ✅ Yes |
| Deterministic validation or check | ❌ No (use command) |
| Fixed procedure, same every time | ❌ No (use command or workflow) |

---

## Frontmatter Requirements

Prompt files require YAML frontmatter with the following fields:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Prompt title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `human` (has Cursor command wrapper) or `agent` (agent-only) |

---

## Prompt Structure

```markdown
---
title: [Action]-[Target]
description: Brief summary of what this prompt accomplishes.
access: human
---

# [Title]

## Context

[1-2 sentences describing when to use this prompt]

## Inputs (optional)

[What the user/agent must provide — parameters, context, targets]

## Instructions

1. [Step one]
2. [Step two]
3. [Step three]

## Output

[What the agent should produce]

## Example (optional)

[Concrete example of input/output]
```

### Required vs Optional Sections

| Section | Required | Notes |
|---------|----------|-------|
| `## Context` | Yes | 1-2 sentences describing when to use |
| `## Inputs` | No | Include when prompt requires explicit parameters |
| `## Instructions` | Yes | Numbered steps for the agent to follow |
| `## Output` | Yes | What the agent should produce |
| `## Example` | No | Include for complex or non-obvious prompts |

---

## Prompt Examples

| Prompt | Purpose | Why It's a Prompt (Not a Command) |
|--------|---------|-----------------------------------|
| `audit-content.md` | Review content for issues | Criteria vary; requires judgment |
| `improve-clarity.md` | Enhance readability | "Clarity" is subjective |
| `summarize-changes.md` | Summarize recent work | Output depends on context |
| `propose-refactor.md` | Suggest code improvements | Requires domain understanding |

---

## Naming Convention

Use `{action}-{target}.md`:

- `audit-content.md`
- `improve-clarity.md`
- `verify-completeness.md`
- `generate-summary.md`

---

## See Also

- [Commands](../../../capabilities/_meta/architecture/commands.md) — Deterministic atomic operations
- [Workflows](../../../orchestration/_meta/architecture/workflows.md) — Multi-step procedures
- [Taxonomy](../../../cognition/_meta/architecture/taxonomy.md) — Full classification of artifact types
- [README.md](./README.md) — Canonical harness structure
