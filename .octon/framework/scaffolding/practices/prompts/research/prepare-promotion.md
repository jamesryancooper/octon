---
title: Prepare Promotion
description: Ready research findings for publication to agent-facing harness locations.
access: human
---

# Prepare Promotion

## Context

Use this prompt when research is mature enough to publish findings to agent-facing harness locations. Ensures findings are properly distilled and formatted for their destinations.

## Inputs

- **Project path:** Path to the research project
- **Publication targets:** (Optional) Specific destinations, or derive from `project.md` Outputs checklist

## Instructions

1. **Assess readiness**
   - Review Findings Summary in `project.md`
   - Check that key questions are adequately answered
   - Verify no critical gaps remain (use `identify-gaps.md` if unsure)
   - Confirm findings are stable (not likely to change)

2. **Review outputs checklist**
   - Check the Outputs checklist in `project.md`
   - Identify which destinations apply
   - Note any destinations not originally planned

3. **Prepare content for each destination**

   **For `cognition/runtime/context/decisions.md`:**
   - Extract decision statements with rationale
   - Format as: Decision → Rationale → Date → Source
   - Keep concise; link to project for details

   **For `cognition/runtime/context/lessons.md`:**
   - Extract anti-patterns and pitfalls discovered
   - Format as: What to avoid → Why → What to do instead
   - Focus on actionable guidance

   **For `cognition/runtime/context/glossary.md`:**
   - Extract new terminology defined during research
   - Format as: Term → Definition → Context
   - Ensure consistency with existing glossary

   **For missions:**
   - Identify actionable work that emerged
   - Draft mission goal and success criteria
   - Note dependencies and suggested owner

4. **Distill, don't copy**
   - Summarize; don't paste raw notes
   - Remove research-specific context
   - Make content standalone and useful to agents

5. **Prepare publication summary**
   - List what goes where
   - Draft the content for review
   - Note what stays in the project (reference only)

## Output

```markdown
## Publication Preparation: [Project name]

**Status:** [Ready / Needs work]
**Date:** [Date]

### Readiness Check

- [x] Key questions answered
- [x] No critical gaps
- [x] Findings stable
- [ ] [Any blockers]

### Publication Plan

#### → cognition/runtime/context/decisions.md

**Content to add:**

```markdown
### [Decision Title]

**Decision:** [Clear statement of what was decided]

**Rationale:** [Why this decision was made]

**Date:** [YYYY-MM-DD]

**Source:** Project: [project-slug]
```

#### → cognition/runtime/context/lessons.md

**Content to add:**

```markdown
### [Lesson Title]

**Avoid:** [What not to do]

**Why:** [What goes wrong]

**Instead:** [What to do]

**Source:** Project: [project-slug]
```

#### → cognition/runtime/context/glossary.md

**Terms to add:**

| Term | Definition |
|------|------------|
| [Term 1] | [Definition] |

#### → orchestration/runtime/missions/ (if applicable)

**Mission to create:**

- **Slug:** [suggested-slug]
- **Goal:** [What needs to be done]
- **Success criteria:** [How we know it's done]
- **Suggested owner:** [Who should do this]

### Content Remaining in Project

The following stays in `projects/[slug]/` for reference:
- Raw research notes
- Detailed source analysis
- Full comparison matrices
- Session logs

### Post-Publication Checklist

- [ ] Add content to each destination
- [ ] Update project status to "Completed" in `project.md`
- [ ] Move registry entry to "Completed" table
- [ ] Note outcomes in registry
```
