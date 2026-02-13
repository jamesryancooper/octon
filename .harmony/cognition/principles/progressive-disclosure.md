---
title: Progressive Disclosure
description: Load information in layers — summary first, details on demand — to optimize cognitive load and token efficiency.
pillar: Focus
status: Active
---

# Progressive Disclosure

> Load information in layers: start with what's needed, reveal details only when required.

## What This Means

Progressive disclosure is an information architecture principle that presents content in graduated layers of detail. Rather than overwhelming with everything upfront, it provides a minimal summary first, then allows drilling deeper as needed.

In Harmony, this principle applies at multiple levels:

- **Human cognition**: Reduce cognitive load by surfacing relevant information first
- **AI context**: Optimize token usage by loading only what's needed for the current task
- **Documentation**: Structure content so readers can stop at the depth they need

## Why It Matters

### Pillar Alignment: Focus through Absorbed Complexity

Progressive disclosure directly implements the Focus pillar's goal of "freeing cognitive bandwidth for what matters." By structuring information in layers:

- Developers scan summaries to find relevance before investing in details
- AI agents load minimal context first, expanding only when necessary
- Documentation remains navigable regardless of total volume

### Token Efficiency

In agentic workflows, context window is a finite resource. Progressive disclosure enables:

- **Tier 1**: ~50-100 tokens to discover if something is relevant
- **Tier 2**: ~500 tokens to understand the interface
- **Tier 3**: ~5000 tokens for full implementation details
- **Tier 4**: On-demand loading for references and examples

Without this structure, agents must load entire documents to determine relevance — a pattern that scales poorly.

## In Practice

### The Four-Tier Model

Harmony's skill system implements progressive disclosure through four tiers:

| Tier | Artifact | Token Budget | Purpose |
|------|----------|--------------|---------|
| 1 | `manifest.yml` | ~50/entry | Discovery index — name, summary, triggers |
| 1.5 | `registry.yml` | ~50/entry | Extended metadata — commands, requirements |
| 2 | `SKILL.md` | <5000 total | Full instructions for execution |
| 3 | `references/` | On demand | Detailed docs, examples, scripts |

> **Token Budget Note:** The [agentskills.io specification](https://agentskills.io/specification) recommends ~100 tokens for SKILL.md frontmatter (name + description). Harmony's manifest provides an additional optimization layer with ~50 tokens/entry for routing, keeping SKILL.md frontmatter budget at ~100 tokens. Combined Tier 1 + 1.5 budget is ~100 tokens/skill, matching the spec's discovery guidance.

### ✅ Do

**Structure manifests for fast scanning:**

```yaml
# .harmony/capabilities/skills/manifest.yml
skills:
  - id: synthesize-research
    name: Synthesize Research
    summary: Synthesize research documents into structured insights
    triggers:
      - "synthesize research"
      - "/synthesize"
```

**Separate discovery from execution:**

```
skill/
├── manifest.yml      # Tier 1: "What is this?"
├── registry.yml      # Tier 1.5: "What does it need?"
├── SKILL.md          # Tier 2: "How do I use it?"
└── references/       # Tier 3: "Show me more"
    ├── examples.md
    └── edge-cases.md
```

**Use expandable sections in documentation:**

```markdown
## Quick Start

One-paragraph summary of how to use this.

<details>
<summary>Advanced Configuration</summary>

Detailed configuration options that most users won't need...

</details>
```

### ❌ Don't

**Don't require full context for simple queries:**

```yaml
# Bad: Everything in one file that must be fully loaded
skills:
  - id: synthesize-research
    name: Synthesize Research
    summary: Synthesize research...
    full_instructions: |
      [5000 tokens of instructions]
    examples: |
      [3000 tokens of examples]
```

**Don't hide critical information too deep:**

```markdown
# Bad: Buried prerequisites
## Overview
...
## Installation
...
## Configuration
...
## Advanced
### Prerequisites  # <-- Should be near the top
```

**Don't create artificial tiers:**

If content is naturally flat (e.g., a glossary), don't force it into arbitrary layers. Progressive disclosure serves comprehension, not structure for its own sake.

## Implementation Patterns

### Documentation Structure

```markdown
# Title

> One-sentence summary (Tier 0)

## Overview
2-3 paragraphs of context (Tier 1)

## Quick Start
Minimal working example (Tier 2)

## API Reference
Complete interface (Tier 2)

## Advanced Topics
<details> blocks or links (Tier 3)

## Appendix
Reference material (Tier 4)
```

### Harness Boot Sequence

The `.harmony/START.md` pattern implements progressive disclosure for harness orientation:

1. **Immediate context**: Scope, current state
2. **Navigation**: Links to relevant files
3. **Deep context**: Loaded only if needed

### Skill Discovery Flow

```
Agent receives task
        ↓
Read manifest.yml (~50 tokens)
        ↓
Match found? → Read SKILL.md (~5000 tokens)
        ↓
Need examples? → Read references/ (on demand)
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Simplicity Over Complexity | Progressive disclosure enables simplicity by hiding complexity until needed |
| Single Source of Truth | Each tier references the same source, not duplicates at different detail levels |
| Documentation is Code | Tier structure is enforced, not aspirational |

## Enforcement

- **Skill validation**: Manifests must include id, name, summary, triggers
- **Token budgets**: SKILL.md files should target <5000 tokens
- **Harness linting**: START.md required for harness directories

## Exceptions

Progressive disclosure may be skipped when:

- The total content fits in a single screen (~300 tokens)
- The audience always needs full detail (e.g., incident runbooks)
- Sequential reading is the expected pattern (e.g., tutorials)

## Related Documentation

- [Harness Architecture](../architecture/harness/README.md) — Progressive disclosure in harness design
- [Skills Specification](../architecture/harness/skills/specification.md) — Four-tier skill structure
- [Focus Pillar](../pillars/focus.md) — The pillar this principle implements
