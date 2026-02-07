---
title: ARE Loop - Templates Reference
description: All blank templates for ARE Loop artifacts
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./01-are-analyze-single-doc.md
  - ./03-are-refine.md
  - ./04-are-evaluate.md
tags:
  - documentation
  - methodology
  - templates
---

# ARE Loop - Templates Reference

This file consolidates all ARE Loop templates for easy reference. Templates are also included in their respective phase prompts.

---

## Template A: Gap Analysis Summary

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

## Template B: Criteria Document

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

## Template C: Change Log

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

## Template D: Ideation Record

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

## Template E: Evaluation Report

```markdown
# Evaluation Report: [Document Name]

**Cycle**: N  
**Date**: YYYY-MM-DD  
**Evaluator**: [Name]
**Tier**: ARE-Lite / ARE-Standard / ARE-Full

## Summary

Brief summary of evaluation findings and decision.

## Health Indicators

| Indicator | Status | Notes |
|-----------|--------|-------|
| Accuracy target met | ✅ / ⚠️ / ❌ | |
| Completeness target met | ✅ / ⚠️ / ❌ | |
| Readability target met | ✅ / ⚠️ / ❌ | |
| Usability target met | ✅ / ⚠️ / ❌ | |
| User feedback positive | ✅ / ⚠️ / ❌ | |
| Cross-references accurate | ✅ / ⚠️ / ❌ | |
| Stress tests passed | ✅ / ⚠️ / ❌ | |

## Metrics Summary

| Criterion | Baseline | This Cycle | Change | Target | Met? |
|-----------|----------|------------|--------|--------|------|
| Accuracy | | | | | ✅/❌ |
| Completeness | | | | | |
| Readability | | | | | |
| Usability | | | | | |
| **Overall** | | | **+__%** | | |

## Measurement Details

- **Quantitative**: [Methods used, sample sizes, tools]
- **Qualitative**: [Feedback sources, themes]

## Successes

- [Bullet list of what worked]

## Partial Wins

- [Things that improved but didn't meet target]

## Lessons Learned

- [What to do differently next cycle]

## Gaps Addressed

[Summary of gaps fixed this cycle]

## Remaining Gaps

[Gaps deferred to future cycles]

## Criteria Adjustments

See Criteria Evolution Log

## Cycle Decision

**Decision**: ☐ Standardize | ☐ Continue | ☐ Pivot | ☐ Archive

**Rationale**: [Why this decision?]

**If Continuing**:

- Next cycle scope: [Brief description]
- Priority gaps: [List]
- Timeline: [Start date]

**If Standardizing**:

- [ ] Canonical version updated
- [ ] Stakeholders notified
- [ ] Follow-up items logged (if any)

## Re-Evaluation Triggers

[Conditions that should trigger the next cycle]

## Artifacts

- Gap Analysis: [link]
- Change Log: [link]
- User Feedback: [link]

## Follow-Up Items

| Item | Owner | Due |
|------|-------|-----|
| | | |
```

---

## Template F: Criteria Evolution Log

```markdown
# Criteria Evolution Log: [Document Name]

**Document**: [Name/Path]  
**Started**: YYYY-MM-DD  
**Last Updated**: YYYY-MM-DD

## Evolution History

| Cycle | Date | Criterion | Old Weight | New Weight | Rationale |
|-------|------|-----------|------------|------------|-----------|
| 0 | YYYY-MM-DD | Accuracy | - | 30% | Baseline |
| 0 | YYYY-MM-DD | Completeness | - | 25% | Baseline |
| 0 | YYYY-MM-DD | Readability | - | 25% | Baseline |
| 0 | YYYY-MM-DD | Usability | - | 20% | Baseline |
| 1 | YYYY-MM-DD | Completeness | 25% | 20% | Target achieved; shift focus |
| 1 | YYYY-MM-DD | Usability | 20% | 25% | User testing showed gaps |
| 2 | YYYY-MM-DD | [New: Structure] | - | 10% | Header issues emerged |
| ... | | | | | |

## Current Active Criteria

| Criterion | Weight | Target | Last Achieved |
|-----------|--------|--------|---------------|
| | | | |

## Retired Criteria

| Criterion | Retired Cycle | Reason |
|-----------|---------------|--------|
| | | |

## Notes

[Any context about criteria philosophy, organizational standards, etc.]
```

---

## Template G: Stress Test Report

```markdown
# Stress Test Report: [Document Name]

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Tier**: ARE-Standard / ARE-Full

## Summary

- Tests Required: ___
- Tests Passed: ___
- Pass Rate: ___%

## Results

| Test | Result | Time | Notes |
|------|--------|------|-------|
| 30-Second Pitch | Pass/Fail | | |
| 30-Minute Comprehension | Pass/Fail | | |
| Day 1 Test | Pass/Fail | | |
| Team Change Test | Pass/Fail | | |
| Solo User Test | Pass/Fail | | |
| Emergency/Hotfix Test | Pass/Fail | | |
| Conflict Resolution Test | Pass/Fail/N/A | | |
| Remote/Async Test | Pass/Fail/N/A | | |
| Budget/Constraint Test | Pass/Fail/N/A | | |
| Legacy/Brownfield Test | Pass/Fail/N/A | | |
| Vendor Dependency Test | Pass/Fail/N/A | | |
| Audit/Compliance Test | Pass/Fail/N/A | | |

## Key Findings

### Strengths
- [What worked well]

### Gaps Identified
- [Test]: [Issue found]

## Recommendations

1. [Highest priority fix]
2. [Second priority fix]

## Verdict

☐ Ready for Standardize
☐ Should iterate before Standardize
☐ Major issues; must iterate
```

---

## Template H: Document Set Analysis

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

*All templates are available in their respective phase prompts. This file provides a consolidated reference.*
