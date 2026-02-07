---
title: ARE Loop - Refine Phase
description: Ideate solutions and implement changes into a testable version
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./01-are-analyze-single-doc.md
  - ./04-are-evaluate.md
tags:
  - documentation
  - methodology
  - implementation
---

# ARE Loop - Refine Phase

**Purpose**: Ideate solutions and implement changes into a testable version. This phase combines creative exploration with disciplined execution.

**Time Allocation**: 45% of cycle budget

| Tier | Time Budget |
|------|-------------|
| ARE-Lite | 10-15 min |
| ARE-Standard | 50-70 min |
| ARE-Full | 90-120 min |

**Sub-allocation**:
- Ideation: 15% of phase
- Implementation: 25% of phase  
- Quick Validation: 5% of phase

---

## Step 1: Prioritize

1. Sort gaps by severity × impact
2. Group related gaps that can be fixed together
3. Set a scope limit: address top N gaps this cycle

---

## Step 2a: Ideate (15% of phase)

### Research Parallels

- Benchmark against industry exemplars (e.g., Stripe API docs, Tailwind docs)
- Review competitor documentation for patterns

### Generate Options

- Brainstorm 3-5 potential solutions per major gap
- Use prioritization matrix (Impact vs. Effort)
- Select top 1-2 ideas for implementation

### Create Lightweight Prototypes

- Sketched sections, wireframes, or outline revisions
- Quick mockups for visual/structural changes

---

## Step 2b: Implement (25% of phase)

For each prioritized gap:

1. **Plan the fix**: What specific change addresses this gap?
2. **Make the change**: Edit with minimal disruption to surrounding content
3. **Verify locally**: Does the fix address the gap without creating new issues?

### Implementation Details

1. **Draft Revisions**
   - Implement selected ideas from ideation
   - Follow existing style guides and conventions
   - Document changes inline (e.g., "Added per Gap #1")

2. **Quick Feedback Loops**
   - Share draft with 1-2 peers for spot-checks
   - Incorporate immediate feedback

3. **Polish for Consistency**
   - Align with style guide (tone, formatting, terminology)
   - Run automated checks (linting, spell-check, link validation)

---

## Step 2c: Quick Validation (5% of phase)

1. **Self-Review Against Criteria**
   - Check changes against this cycle's criteria weights
   - Verify gaps are addressed (not just modified)

2. **Smoke Test**
   - Read through as a new user would
   - Verify navigation and cross-references work

---

## Change Types

| Type | Description | Risk Level |
|------|-------------|------------|
| **Add** | New content where none exists | Medium |
| **Update** | Modify existing content | Low-Medium |
| **Remove** | Delete obsolete/redundant content | Medium |
| **Restructure** | Reorganize sections or hierarchy | High |
| **Consolidate** | Merge duplicated content | Medium-High |

---

## Step 3: Document Changes

| Gap ID | Change Type | What Changed | Rationale |
|--------|-------------|--------------|-----------|
| G1 | | | |
| G2 | | | |

---

## Refine Inputs

| Input | Source | Required |
|-------|--------|----------|
| Gap Analysis Summary | Analyze phase | Yes |
| Criteria Document | Analyze phase | Yes |
| Style guide | Repository | Yes |
| Benchmark examples | Research | Recommended |

---

## Refine Outputs

| Output | Description | Template |
|--------|-------------|----------|
| Revised Document | Versioned (e.g., v2.1) | N/A |
| Change Log | What changed and why | See below |
| Ideation Record | Ideas considered, selected, deferred | See below |

---

## Refine Pitfalls

| Pitfall | Mitigation |
|---------|------------|
| **Scope creep** | Stick to Gap Analysis scope; defer new discoveries to next cycle |
| **Perfectionism** | Ship "good enough"; perfection is the enemy of done |
| **No ideas generated** | Bring in fresh perspective; benchmark more; pivot to smaller scope |
| **Implementation regresses quality** | Revert to prior version; tighten scope; pair with reviewer |
| **Over-editing** | Make the minimum effective change |
| **Style drift** | Match existing document style unless style is the problem |
| **Breaking references** | Check all links and cross-references after restructuring |

---

## Template: Change Log

```markdown
# Change Log: [Document Name]

**Cycle**: N  
**Date**: YYYY-MM-DD  
**Author**: [Name]

## Summary

[1-2 sentence summary of changes]

## Changes by Gap

### Gap #1: [Description]

- **Section(s) Modified**: [List]
- **What Changed**: [Description]
- **Why**: [Link to Gap Analysis]
- **Reviewer**: [Name] | Self-reviewed

### Gap #2: [Description]

- **Section(s) Modified**: 
- **What Changed**: 
- **Why**: 
- **Reviewer**: 

## Deferred Items

| Item | Reason | Target Cycle |
|------|--------|--------------|
| | | |

## Automated Check Results

- [ ] Linting passed
- [ ] Links validated
- [ ] Readability score: ___
```

---

## Template: Ideation Record

```markdown
# Ideation Record: [Document Name]

**Cycle**: N  
**Date**: YYYY-MM-DD  
**Participants**: [Names]

## Gap Being Addressed

[Description from Gap Analysis]

## Ideas Generated

| # | Idea | Effort (1-5) | Impact (1-5) | Score (I/E) | Notes |
|---|------|--------------|--------------|-------------|-------|
| 1 | [Description] | 2 | 4 | 2.0 | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

## Selected Ideas

- **Primary**: Idea #___ 
  - Rationale: [Why this one?]
- **Secondary** (if applicable): Idea #___
  - Rationale: 

## Deferred Ideas

| Idea | Reason Deferred | Revisit When? |
|------|-----------------|---------------|
| #___ | [Reason] | Cycle N+1 / Never / If X |

## Benchmarks Reviewed

| Source | What We Learned | Applied? |
|--------|-----------------|----------|
| [e.g., Stripe docs] | [Insight] | Yes/No |
```

---

## Next Steps

After completing Refine:

→ Proceed to [04-are-evaluate.md](./04-are-evaluate.md)

---

*This prompt covers the Refine phase. Ensure Gap Analysis and Criteria Document from Analyze phase are available before starting.*
