---
title: Synthesize Findings
description: Consolidate scattered research notes into coherent, structured insights.
access: human
---

# Synthesize Findings

## Context

Use this prompt when you have accumulated research notes across multiple sessions and need to consolidate them into coherent insights. Best used mid-research or when preparing to publish findings.

## Inputs

- **Project path:** Path to the research project (e.g., `projects/auth-patterns/`)
- **Focus area:** (Optional) Specific aspect to synthesize, or "all" for comprehensive synthesis

## Instructions

1. **Gather materials**
   - Read `project.md` for goal, scope, and key questions
   - Read `log.md` for session notes and findings
   - Read any additional files (`findings.md`, `notes/`, `sources.md`)

2. **Identify themes**
   - Group related findings into themes or categories
   - Note which key questions each theme addresses
   - Flag findings that don't fit existing themes

3. **Resolve contradictions**
   - Identify conflicting findings
   - Determine if contradiction is real or apparent
   - Document resolution or flag for further investigation

4. **Synthesize insights**
   - For each theme, write a clear insight statement
   - Support each insight with evidence from notes
   - Note confidence level (high/medium/low)

5. **Update project.md**
   - Add synthesized insights to Findings Summary
   - Update Key Insights section
   - Note any new Open Questions that emerged

## Output

```markdown
## Synthesis: [focus area or "Comprehensive"]

### Themes Identified
1. **[Theme 1]:** [Brief description]
2. **[Theme 2]:** [Brief description]

### Key Insights

#### [Insight 1]
**Statement:** [Clear, actionable insight]
**Evidence:** [Supporting findings from notes]
**Confidence:** [High/Medium/Low]
**Addresses:** [Which key question(s)]

#### [Insight 2]
...

### Contradictions Resolved
- [Contradiction]: [Resolution]

### Gaps Identified
- [Gap that needs more research]

### Recommended Next Steps
1. [Action 1]
2. [Action 2]
```
