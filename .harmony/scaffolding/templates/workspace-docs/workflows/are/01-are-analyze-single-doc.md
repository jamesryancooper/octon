---
title: ARE Loop - Analyze Phase (Single Document)
description: Gap identification, classification, and criteria setting for individual documents
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./00-are-overview.md
  - ./02-are-analyze-audits.md
  - ./03-are-refine.md
tags:
  - documentation
  - methodology
  - analysis
---

# ARE Loop - Analyze Phase (Single Document)

**Purpose**: Establish a baseline by identifying current strengths, weaknesses, and opportunities. This phase is *formative*—focus on gathering data to inform action, not judging success.

**Time Allocation**: 25% of cycle budget

| Tier | Time Budget |
|------|-------------|
| ARE-Lite | 15-20 min |
| ARE-Standard | 60-90 min |
| ARE-Full | 90-120 min |

---

## Step 1: Read and Understand

1. Read the entire document without editing
2. Note first impressions: What's confusing? What's missing? What's excellent?
3. Identify the document's stated purpose and target audience

---

## Step 2: Gap Identification

Scan for gaps systematically:

- [ ] Missing information users need
- [ ] Outdated content (dates, versions, deprecated features)
- [ ] Broken or missing links
- [ ] Unclear explanations or jargon without definition
- [ ] Missing examples or incomplete examples
- [ ] Inconsistent terminology or formatting
- [ ] Missing anti-patterns ("what NOT to do" guidance for common mistakes)
- [ ] Unsubstantiated claims or guarantees
- [ ] Missing differentiation (if doc claims to be different from alternatives)
- [ ] No clear entry point or reading path for new users
- [ ] No failure mode documentation (what happens when things go wrong?)
- [ ] No "when NOT to use" guidance (boundaries and limitations unstated)
- [ ] Assumed prerequisite knowledge not explicitly stated

### Data Sources

- [ ] Analytics review (source: ___)
- [ ] User feedback (n=___ data points)
- [ ] Expert review
- [ ] Automated checks (linting, links, readability)

### Validation Methods

Each gap should be supported by at least one validation method:

| Method | Best For | Minimum Viable |
|--------|----------|----------------|
| **Document walkthrough** | Structural issues, flow problems | Always |
| **Scenario testing** | Usability gaps, missing instructions | ARE-Standard+ |
| **User interview/test** | Audience fit, comprehension gaps | 3+ data points |
| **Cross-reference audit** | Referential integrity, dead links | Automated + spot-check |
| **Competitive benchmark** | Best-practice gaps | 1-2 exemplars |

> **Rule**: If you can't point to evidence for a gap, reconsider whether it's real or opinion.

---

## Gap Classification

Classify gaps using both **category** and **dimension**:

### Categories (What type of issue)

- **Content**: Missing, outdated, or inaccurate information
- **Structure**: Navigation, hierarchy, flow problems
- **Style**: Readability, tone, consistency issues
- **Technical**: Code examples, accuracy, tooling

### Assessment Dimensions (How to evaluate severity)

| Dimension | What It Assesses | Score (1-5) |
|-----------|------------------|-------------|
| **Clarity** | Purpose obvious, self-explanatory, audience appropriate | |
| **Alignment** | Serves stated goals, fits organizational context | |
| **Leanness** | No unnecessary content, value justified | |
| **Implementability** | Actionable, dependencies clear, examples work | |
| **Coherence** | Internally consistent, accurate references, no duplication | |

---

## Scoring Rubric

Use this rubric for subjective gap severity and dimension ratings:

| Score | Meaning | Criteria |
|-------|---------|----------|
| **5** | Excellent | Clear, complete, actionable, no issues |
| **4** | Good | Minor gaps or clarifications needed |
| **3** | Adequate | Functional but improvements possible |
| **2** | Weak | Significant gaps affecting usability |
| **1** | Poor | Major issues, needs substantial rework |

---

## Exploration Framework

Beyond identified gaps, explore:

| Exploration Type | Questions to Ask |
|------------------|------------------|
| **Gap Exploration** | What's missing that should exist? |
| **Expansion Exploration** | What's covered but needs more depth? |
| **Simplification Exploration** | What's over-engineered or unnecessary? |

Document findings in Gap Analysis with tag: `[GAP]`, `[EXPAND]`, or `[SIMPLIFY]`

---

## Step 3: Gap Analysis Table

| ID | Category | Dimension | Description | Severity (1-5) | Tag | Priority |
|----|----------|-----------|-------------|----------------|-----|----------|
| G1 | | | | | | |
| G2 | | | | | | |

---

## Step 4: Criteria Setting/Adjustment

- For Cycle 0: Use baseline criteria (see Cycle Zero section below)
- For subsequent cycles: Import Criteria Evolution Log from prior Evaluate phase
- Adjust weights based on prior cycle learnings

---

## Cycle Zero: First-Time Initialization

For documents without prior ARE cycles, use this initialization process:

### Default Baseline Criteria

| Criterion | Weight | Target | Measurement |
|-----------|--------|--------|-------------|
| Accuracy | 30% | 100% factual correctness | Expert review, automated link checks |
| Completeness | 25% | All required topics covered | Checklist against scope |
| Readability | 25% | Flesch score ≥65 | Automated tooling |
| Usability | 20% | Task completion ≥80% | User testing (sample of 3-5) |

### Cycle Zero Checklist

- [ ] Document current state (version, last update, known issues)
- [ ] Run automated checks (links, readability score, linting)
- [ ] Gather initial user feedback (minimum 3 data points)
- [ ] Create initial Gap Analysis using baseline criteria
- [ ] Initialize Criteria Evolution Log with baseline values

---

## Analyze Inputs

| Input | Source | Required |
|-------|--------|----------|
| Current document version | Repository | Yes |
| Prior Criteria Evolution Log | Last Evaluate phase | Yes (except Cycle 0) |
| Analytics data | GA, Plausible, etc. | Recommended |
| User feedback | Surveys, tickets, interviews | Recommended |

---

## Analyze Outputs

| Output | Description | Template |
|--------|-------------|----------|
| Gap Analysis Summary | Prioritized list of issues | See below |
| Updated Criteria Document | Weighted criteria for this cycle | See below |
| Cycle Scope | What will/won't be addressed | Inline in Gap Analysis |

---

## Analyze Pitfalls

| Pitfall | Mitigation |
|---------|------------|
| **Over-analysis paralysis** | Timebox to 25% of cycle; ship imperfect analysis |
| **Static criteria** | Always check Criteria Evolution Log; flag unchanged criteria for 2+ cycles |
| **Missing user voice** | Require minimum 3 user data points before proceeding |
| **Scope creep** | Stay within the document's purpose; don't propose a rewrite |
| **Confirmation bias** | Look for what's wrong, not what you expected to find |

---

## Template: Gap Analysis Summary

```markdown
# Gap Analysis: [Document Name]

**Date**: YYYY-MM-DD  
**Cycle**: N  
**Tier**: ARE-Lite | ARE-Standard | ARE-Full  
**Analyst**: [Name]

## Summary

- Total gaps identified: ___
- Critical (severity 5): ___
- High (severity 4): ___
- Medium (severity 3): ___
- Low (severity 1-2): ___

## Current State

- **Version**: [e.g., v1.2]
- **Last Updated**: [Date]
- **Known Issues**: [Brief summary]

## Data Sources

- [ ] Analytics review (source: ___)
- [ ] User feedback (n=___ data points)
- [ ] Expert review
- [ ] Automated checks (linting, links, readability)

## Identified Gaps

| # | Gap Description | Category | Dimension | Severity | Tag | In Scope? |
|---|-----------------|----------|-----------|----------|-----|-----------|
| 1 | [Description] | Content/Structure/Style/Technical | Clarity/Alignment/etc. | High/Med/Low | [GAP]/[EXPAND]/[SIMPLIFY] | Yes/No |
| 2 | | | | | | |
| 3 | | | | | | |

## Cycle Scope

**In Scope**: Gaps #___  
**Deferred**: Gaps #___ (reason: ___)

## Criteria for This Cycle

| Criterion | Weight | Target | Measurement Method |
|-----------|--------|--------|-------------------|
| Accuracy | __% | | |
| Completeness | __% | | |
| Readability | __% | Flesch ≥__ | |
| Usability | __% | Task completion ≥__% | |
| [Custom] | __% | | |
| **Total** | **100%** | | |
```

---

## Template: Criteria Document

```markdown
# Criteria Document: [Document Name]

**Cycle**: N  
**Date**: YYYY-MM-DD  
**Based on**: Cycle N-1 Evaluation | Baseline (if Cycle 0)

## Active Criteria

| Criterion | Weight | Target | Measurement | Rationale for Weight |
|-----------|--------|--------|-------------|---------------------|
| Accuracy | 30% | 100% correct | Expert review | Baseline |
| Completeness | 25% | All topics covered | Checklist | Baseline |
| Readability | 25% | Flesch ≥65 | textstat | Baseline |
| Usability | 20% | Task completion ≥80% | User test (n=5) | Baseline |

## Changes from Prior Cycle

| Criterion | Old Weight | New Weight | Rationale |
|-----------|------------|------------|-----------|
| [Example] | 30% | 20% | Target achieved in Cycle N-1 |

## Success Threshold

This cycle is successful if: [e.g., "Overall improvement ≥15% OR two criteria meet targets"]
```

---

## Next Steps

After completing Analyze:

1. **If document has claims, processes, or instructional content** → Consider [02-are-analyze-audits.md](./02-are-analyze-audits.md)
2. **Otherwise** → Proceed to [03-are-refine.md](./03-are-refine.md)

---

*This prompt covers the Analyze phase for individual documents. For multi-document analysis, see [are-document-sets.md](./are-document-sets.md).*
