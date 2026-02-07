---
title: ARE Loop - Document Set Analysis
description: Multi-document analysis for related documentation collections
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./01-are-analyze-single-doc.md
  - ./00-are-overview.md
tags:
  - documentation
  - methodology
  - documentation-sets
---

# ARE Loop - Document Set Analysis

When improving multiple related documents, add these analyses to identify cross-document issues that single-document analysis misses.

---

## When to Use This Prompt

- Documentation set has **5+ related documents**
- Multiple contributors have worked on the docs
- Users report confusion navigating between docs
- You're onboarding new team members with a doc collection
- Planning a major documentation restructure

---

## Terminology Consistency

Inconsistent terminology confuses readers and creates maintenance burden.

| Term | Variant A | Variant B | Preferred | Inconsistent Docs |
|------|-----------|-----------|-----------|-------------------|
| | | | | |

### How to Identify

1. List key concepts in the documentation set
2. Search for each term across all docs
3. Note variations in spelling, capitalization, phrasing
4. Decide on canonical term

### Common Inconsistencies

- Capitalization (e.g., "API key" vs "api key" vs "Api Key")
- Synonyms (e.g., "user" vs "customer" vs "account holder")
- Abbreviations (e.g., "config" vs "configuration")
- British vs American spelling

---

## Duplication Analysis

Duplication creates maintenance burden and risks contradictory information.

| Content | Doc A | Doc B | Intentional? | Consolidate? |
|---------|-------|-------|--------------|--------------|
| | | | Yes/No | Yes/No |

### Intentional vs Accidental Duplication

| Type | Example | Action |
|------|---------|--------|
| **Intentional** | Quick reference that duplicates detailed guide | Keep; ensure sync mechanism |
| **Accidental** | Same setup steps in two unrelated docs | Consolidate into single source |
| **Drift** | Was intentional, now contradicts | Reconcile and consolidate |

### Consolidation Decision

- **Consolidate** if: Content is identical, maintained separately, no clear reason for duplication
- **Keep separate** if: Audiences are different, content is intentionally tailored, or cross-linking is impractical

---

## Cross-Reference Check

Verify links between documents work and are bidirectional where appropriate.

| Source Doc | Reference | Target Doc | Valid? | Bidirectional? |
|------------|-----------|------------|--------|----------------|
| | | | Yes/No | Yes/No/N/A |

### Cross-Reference Principles

- Links should resolve (not 404)
- Major relationships should be bidirectional
- Anchor links (#section) should target existing anchors
- Consider reader journey: can they get back?

---

## Concern Distribution Analysis

Each topic should have clear ownership to prevent gaps and overlaps.

| Concern/Topic | Primary Doc | Secondary Doc(s) | Overlap Risk | Action Needed |
|---------------|-------------|------------------|--------------|---------------|
| | | | None / Minor / Major | |

### Ownership Principles

- Each concern should have **one primary document** that is authoritative
- Secondary documents may reference but should not duplicate
- **Major overlap** → Consolidate or explicitly designate authority
- **No owner** → Gap; create content or designate existing doc

> **Note**: This analysis is most valuable for doc sets with 5+ documents or multiple contributors.

---

## Entry Point and Navigation Analysis

| Question | Answer | If No, Action Needed |
|----------|--------|---------------------|
| Is there a single "start here" document? | Yes/No | Create or designate one |
| Is the recommended reading order clear? | Yes/No | Add reading path guidance |
| Can a new reader understand core concepts in 30 minutes? | Yes/No | Create quick-start summary |
| Are prerequisites explicitly stated? | Yes/No | Document assumed knowledge |
| Is there a navigation index/TOC spanning all docs? | Yes/No | Create master index |

### Prerequisite Knowledge Check

| Assumed Knowledge | Explicitly Stated? | Resources Linked? | Action if Missing |
|-------------------|-------------------|-------------------|-------------------|
| | Yes / No / Partial | Yes / No | |

> **Tip**: If you find yourself thinking "the reader should already know X," verify X is explicitly stated or linked. Common unstated assumptions: Git basics, specific frameworks, domain knowledge, company context.

---

## Minimum Viable Documentation (MVD)

Define the minimum content needed for Day 1 success:

| Document | Purpose | Time to Read | Day 1 Essential? | If Missing, Impact |
|----------|---------|--------------|------------------|-------------------|
| | | min | Yes/No | Critical/High/Med/Low |

### MVD Principles

- A new reader should be able to consume all Day 1 Essential content in **≤1 hour**
- Day 1 docs should enable the reader to **do something useful** immediately
- Non-essential content can exist but should be clearly marked as "advanced" or "reference"

### MVD Quality Check

| Question | Answer | If No, Action |
|----------|--------|---------------|
| Can you list all Day 1 docs in 30 seconds? | Yes/No | Reduce to ≤5 docs |
| Is the total Day 1 reading time ≤1 hour? | Yes/No | Summarize or split |
| Does Day 1 content enable immediate action? | Yes/No | Add quickstart/tutorial |
| Is the boundary between Day 1 and "later" clear? | Yes/No | Add explicit labels |

> **Tip**: If you can't define MVD, your doc set may have scope problems. Consider restructuring.

### Minimum Viable Reading List Template

| Document | Purpose | Time | Audience | Required for Day 1? |
|----------|---------|------|----------|---------------------|
| | | min | | Yes/No |
| | | min | | Yes/No |

> **Goal**: A new reader should be able to identify and consume the Day 1 minimum in under 1 hour.

---

## Visual Artifacts Checklist

Complex documentation often benefits from visual aids. For doc sets, verify key visuals exist:

| Artifact Type | Purpose | Present? | Quality (1-5) | Action |
|---------------|---------|----------|---------------|--------|
| **Architecture/Flow Diagram** | Shows system/process overview | Yes/No | | |
| **Decision Tree/Flowchart** | Guides conditional choices | Yes/No | | |
| **Quick Reference Card** | One-page summary for daily use | Yes/No | | |
| **Comparison Table** | Compares options/alternatives | Yes/No | | |
| **Timeline/Sequence Diagram** | Shows process order | Yes/No | | |
| **Hierarchy/Structure Diagram** | Shows relationships | Yes/No | | |

### When to Create Visuals

| Condition | Recommended Visual |
|-----------|-------------------|
| Process has >3 steps | Flowchart |
| Decision has >2 branches | Decision tree |
| Concept has >4 components | Architecture diagram |
| Reference info used daily | Quick reference card |
| Comparing >2 options | Comparison table |

> **Note**: Not every doc needs visuals. Use this checklist when readers report confusion about structure, flow, or relationships.

---

## Document Set Health Summary

After completing analysis, summarize overall health:

| Dimension | Status | Notes |
|-----------|--------|-------|
| Terminology consistency | ✅ / ⚠️ / ❌ | |
| Duplication managed | ✅ / ⚠️ / ❌ | |
| Cross-references valid | ✅ / ⚠️ / ❌ | |
| Concern ownership clear | ✅ / ⚠️ / ❌ | |
| Entry points defined | ✅ / ⚠️ / ❌ | |
| MVD achievable in ≤1hr | ✅ / ⚠️ / ❌ | |
| Visual aids adequate | ✅ / ⚠️ / ❌ | |

---

## Document Set Gap Analysis Template

```markdown
# Document Set Analysis: [Set Name]

**Date**: YYYY-MM-DD
**Analyst**: [Name]
**Documents in Set**: [Count]

## Document Inventory

| # | Document | Purpose | Last Updated | Owner |
|---|----------|---------|--------------|-------|
| 1 | | | | |
| 2 | | | | |

## Terminology Issues

| Term | Variants Found | Preferred | Docs to Update |
|------|----------------|-----------|----------------|
| | | | |

## Duplication Issues

| Content | Found In | Action | Priority |
|---------|----------|--------|----------|
| | | Consolidate / Keep / Reconcile | H/M/L |

## Cross-Reference Issues

| Issue | Source | Target | Fix Required |
|-------|--------|--------|--------------|
| Broken link | | | |
| Missing backlink | | | |

## Ownership Gaps

| Topic | Current State | Recommended Owner | Action |
|-------|---------------|-------------------|--------|
| | No owner / Multiple | | |

## Navigation Issues

| Issue | Impact | Fix |
|-------|--------|-----|
| | | |

## MVD Assessment

- Day 1 Essential Docs: [List]
- Total Read Time: ___ min
- Achievable in ≤1hr: Yes/No

## Visual Artifact Gaps

| Missing Artifact | Why Needed | Priority |
|------------------|------------|----------|
| | | H/M/L |

## Recommended Actions

### Immediate (This Cycle)
1. [Action]

### Short-Term (Next 2-3 Cycles)
1. [Action]

### Strategic (Future)
1. [Action]
```

---

## Integration with ARE Loop

Document Set Analysis adds to the standard ARE phases:

### During Analyze
1. Complete single-doc analysis for each document
2. Then run Document Set Analysis across the collection
3. Add set-level gaps to overall Gap Analysis

### During Refine
1. Prioritize set-level issues (terminology, duplication) alongside doc-level
2. Consider consolidation as a change type
3. Update cross-references when restructuring

### During Evaluate
1. Re-run Document Set Analysis
2. Verify set-level issues resolved
3. Check that fixes didn't create new cross-doc problems

---

*Document Set Analysis identifies issues invisible to single-document review. Use for collections of 5+ related documents.*
