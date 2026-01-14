# Research Synthesizer Skill

Synthesize scattered research notes into a coherent findings document.

## Quick Start

```text
/synthesize-research <research-folder>
```

**Example:**
```text
/synthesize-research projects/auth-patterns/
```

## What It Does

Transforms dispersed research notes into a structured synthesis document:

1. **Gathers** all `.md` files from input folder
2. **Extracts** findings, insights, and conclusions
3. **Identifies** 3-7 key themes
4. **Synthesizes** into coherent document
5. **Logs** execution for auditability

## Input

| Parameter | Type | Description |
|-----------|------|-------------|
| `research-folder` | folder | Path to folder containing research notes |

**Expected input structure:**
```text
<research-folder>/
├── project.md      # Research goal and scope (optional)
├── log.md          # Session progress notes (optional)
├── findings.md     # Detailed findings (optional)
├── sources.md      # References (optional)
└── notes/          # Additional notes (optional)
```

The skill reads any `.md` files present—none are strictly required.

## Output

**Synthesis document:**
```text
.workspace/skills/outputs/drafts/<topic>-synthesis.md
```

**Run log:**
```text
.workspace/skills/logs/runs/<timestamp>-research-synthesizer.md
```

### Output Format

```markdown
# Research Synthesis: [Topic]

**Generated:** [timestamp]
**Source:** [input folder path]

## Executive Summary
[3-5 sentence overview]

## Key Themes

### Theme 1: [Name]
**Insight:** [Statement]
**Evidence:** [Supporting points]
**Confidence:** High/Medium/Low

## Contradictions & Resolutions
[Table of conflicting findings and how resolved]

## Open Questions
[Remaining gaps and unanswered questions]

## Sources Reviewed
[List of files processed]
```

## Invocation Options

**Direct command:**
```text
/synthesize-research projects/my-research/
```

**Generic skill invocation:**
```text
/use-skill research-synthesizer projects/my-research/
```

**Explicit pattern:**
```text
use skill: research-synthesizer
```

**Natural language (trigger matching):**
```text
"synthesize my research in projects/my-research/"
"consolidate findings from projects/api-design/"
```

## Safety

- **Read-only** on input folder (never modifies source)
- **Write scope** limited to `.workspace/skills/outputs/` and `.workspace/skills/logs/`
- **No destructive actions** — creates new files only
- **Audit trail** — every run logged

## When to Use

| Scenario | Use This Skill? |
|----------|-----------------|
| Mid-research consolidation | Yes |
| Before publishing findings | Yes |
| Quick status check | No (too heavy) |
| Single-file summary | No (use prompt instead) |

## Limitations

- Does not fabricate findings beyond source material
- Cannot resolve contradictions requiring domain expertise
- Requires at least one `.md` file in input folder

## See Also

- [Skill Definition](./SKILL.md) — Full technical specification
- [Skills Documentation](../../../docs/architecture/workspaces/skills.md) — How skills work
- [Research Prompts](../../prompts/research/) — Lighter-weight alternatives
