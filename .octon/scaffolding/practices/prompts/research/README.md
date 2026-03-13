# Research Prompts

Prompts for governance-owned research projects in `projects/`.

## Available Prompts

| Prompt | Purpose | When to Use |
|--------|---------|-------------|
| `analyze-sources.md` | Extract insights from source materials | When reviewing documentation, articles, code |
| `synthesize-findings.md` | Consolidate notes into coherent insights | Mid-research or before publishing |
| `compare-alternatives.md` | Evaluate options against criteria | When choosing between approaches |
| `identify-gaps.md` | Find holes in research coverage | Periodically during research |
| `prepare-promotion.md` | Ready findings for context publication | When research is mature |

## Usage

These prompts are designed for directed use within research projects. Point the agent to a prompt when you need structured help:

```text
Human: "Use .octon/scaffolding/practices/prompts/research/synthesize-findings.md to consolidate
        my notes in projects/auth-patterns/"
```

## Research Workflow

A typical research flow might use these prompts in sequence:

```
┌─────────────────┐
│ analyze-sources │ ← As you review materials
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ identify-gaps   │ ← Periodically check coverage
└────────┬────────┘
         │
         ▼
┌────────────────────┐
│ synthesize-findings│ ← Consolidate what you've learned
└────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│ compare-alternatives│ ← If evaluating options
└────────┬────────────┘
         │
         ▼
┌──────────────────┐
│ prepare-promotion│ ← When ready to publish
└──────────────────┘
```

## See Also

- [Projects](/.octon/ideation/_meta/architecture/projects.md) — Full project documentation
- [Scratchpad](/.octon/ideation/_meta/architecture/scratchpad.md) — Human-led thinking space and idea funnel
