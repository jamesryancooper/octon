---
title: Analyze Sources
description: Systematically extract insights from source materials for research.
access: human
---

# Analyze Sources

## Context

Use this prompt when you have source materials (documentation, articles, code, etc.) that need systematic analysis. Helps ensure consistent, thorough extraction of relevant information.

## Inputs

- **Source:** The material to analyze (URL, file path, or inline content)
- **Research context:** Path to project or brief description of research goal
- **Focus questions:** (Optional) Specific questions to answer from this source

## Instructions

1. **Establish context**
   - Review the research project's goal and key questions
   - Understand what you're looking for in this source

2. **Initial scan**
   - Skim the source for structure and scope
   - Identify sections most relevant to research questions
   - Note the source's authority/credibility

3. **Deep analysis**
   - Extract facts, claims, and data points
   - Note the evidence supporting each claim
   - Identify opinions vs. facts
   - Capture direct quotes for important points

4. **Relate to research**
   - Map findings to research key questions
   - Note how this source confirms, contradicts, or extends existing findings
   - Identify new questions raised

5. **Document in project**
   - Add entry to `sources.md` (or create if needed)
   - Add relevant findings to `log.md`
   - Update `project.md` if significant insights emerged

## Output

```markdown
## Source Analysis: [Source title/name]

**Source:** [URL or path]
**Analyzed:** [Date]
**Credibility:** [High/Medium/Low] — [Brief rationale]

### Summary
[2-3 sentence summary of the source]

### Key Extracts

#### [Topic 1]
- **Finding:** [What the source says]
- **Evidence:** [Supporting data/quotes]
- **Relevance:** [How it relates to research questions]

#### [Topic 2]
...

### Relation to Existing Research
- **Confirms:** [What existing findings this supports]
- **Contradicts:** [What existing findings this challenges]
- **Extends:** [New information not previously found]

### Questions Raised
- [New question 1]
- [New question 2]

### Source Entry (for sources.md)
- **[Source Title]** — [URL/path] — [1-line description of value]
```
