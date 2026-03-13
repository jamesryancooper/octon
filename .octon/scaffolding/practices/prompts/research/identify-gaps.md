---
title: Identify Gaps
description: Find holes in current research coverage and prioritize what to explore next.
access: human
---

# Identify Gaps

## Context

Use this prompt periodically during research to assess coverage and identify blind spots. Helps ensure thorough investigation and guides next steps.

## Inputs

- **Project path:** Path to the research project
- **Scope:** (Optional) Specific area to check for gaps, or "comprehensive"

## Instructions

1. **Review research scope**
   - Read `project.md` for goal, scope, and key questions
   - List all key questions and sub-questions
   - Note the defined scope boundaries

2. **Inventory current coverage**
   - For each key question, assess coverage level
   - Check `log.md` for what's been explored
   - Review `findings.md` or notes for depth

3. **Identify gaps**
   - Questions with no or weak coverage
   - Topics mentioned but not explored
   - Assumptions not validated
   - Perspectives not considered
   - Edge cases not examined

4. **Assess gap severity**
   - How critical is this gap to the research goal?
   - Can we proceed without filling it?
   - What's the cost of the gap remaining?

5. **Prioritize and recommend**
   - Rank gaps by importance and effort
   - Suggest specific actions to fill each gap
   - Note any gaps that are acceptable to leave

## Output

```markdown
## Gap Analysis: [Project name]

**Analyzed:** [Date]
**Scope:** [Comprehensive / Specific area]

### Coverage Summary

| Key Question | Coverage | Notes |
|--------------|----------|-------|
| [Question 1] | [Full/Partial/None] | [Brief status] |
| [Question 2] | [Full/Partial/None] | [Brief status] |

### Identified Gaps

#### Critical Gaps (Must Address)

1. **[Gap description]**
   - **Why critical:** [Impact on research goal]
   - **Current state:** [What we know/don't know]
   - **To fill:** [Specific action]
   - **Effort:** [Low/Medium/High]

2. ...

#### Important Gaps (Should Address)

1. **[Gap description]**
   - **Why important:** [Value of filling this]
   - **To fill:** [Specific action]
   - **Effort:** [Low/Medium/High]

#### Minor Gaps (Nice to Have)

1. **[Gap description]**
   - **To fill:** [Specific action]

#### Acceptable Gaps (Out of Scope)

1. **[Gap description]**
   - **Why acceptable:** [Rationale for not pursuing]

### Blind Spots Checked

- [ ] Alternative perspectives considered?
- [ ] Failure modes examined?
- [ ] Edge cases explored?
- [ ] Assumptions validated?
- [ ] Counter-evidence sought?

### Recommended Next Steps

1. **[Action]** — Fills [gap], Effort: [X]
2. **[Action]** — Fills [gap], Effort: [X]
3. **[Action]** — Fills [gap], Effort: [X]
```
