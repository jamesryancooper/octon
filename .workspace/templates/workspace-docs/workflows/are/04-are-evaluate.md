---
title: ARE Loop - Evaluate Phase
description: Measure impact, make decisions, and plan next steps
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./03-are-refine.md
  - ./05-are-stress-tests.md
  - ./06-are-quality-gates.md
  - ./00-are-overview.md
tags:
  - documentation
  - methodology
  - evaluation
---

# ARE Loop - Evaluate Phase

**Purpose**: Measure the refined document against criteria to validate impact and inform future cycles. This phase is *summative*—focus on evidence-based judgments.

**Time Allocation**: 30% of cycle budget

| Tier | Time Budget |
|------|-------------|
| ARE-Lite | 5-10 min |
| ARE-Standard | 45-65 min |
| ARE-Full | 60-90 min |

---

## Step 1: Re-read

Read the entire document fresh, as if encountering it for the first time.

---

## Step 2: Check Against Criteria

Score each dimension using the Scoring Rubric:

| Dimension | Before | After | Target | Met? |
|-----------|--------|-------|--------|------|
| Clarity | | | ≥4 | |
| Alignment | | | ≥4 | |
| Leanness | | | ≥3 | |
| Implementability | | | ≥4 | |
| Coherence | | | ≥4 | |

---

## Step 3: Measure Impact

### Run Quantitative Tests

- Readability scores
- Analytics deltas
- Automated checks

### Conduct Qualitative Tests

- User trials
- Task completion
- Feedback surveys

### Compare Pre/Post Metrics

- Calculate improvement percentages per criterion
- Compare against criteria targets

---

## Success Criteria Checklist

For each change made, verify success beyond "we did it":

| Gap ID | Change Made | Intended Outcome | Evidence of Success | Verdict |
|--------|-------------|------------------|---------------------|---------|
| | | | | ✅ Achieved / ⚠️ Partial / ❌ Failed |

### Success Evidence Types

- **Quantitative**: Metric improved (readability score, task completion rate)
- **Qualitative**: User feedback positive, fewer questions about this topic
- **Negative evidence**: Support tickets decreased, error reports dropped
- **Proxy evidence**: Similar docs saw improvement with same pattern

> **Note**: "We made the change" is not success. "Users can now complete the task" is success.

---

## Step 4: Collect Feedback (if applicable)

For ARE-Standard and ARE-Full tiers:

| Feedback Source | Method | Key Findings |
|-----------------|--------|--------------|
| Peer review | | |
| Target user test | | |
| Automated checks | | |

---

## Step 5: Analyze Results

- Identify successes, partial wins, and failures
- Document unexpected findings

---

## Step 6: Adjust Criteria for Next Cycle

- Update Criteria Evolution Log with rationale
- Shift weights based on findings (e.g., if readability improved but usability didn't, increase usability weight)
- Add new criteria if gaps emerged

---

## Evaluation Quality Self-Check

Before finalizing, verify evaluation thoroughness:

| Check | Passed? |
|-------|---------|
| All phases completed (Analyze/Refine/Evaluate) | ☐ |
| Gap Analysis has evidence for each gap | ☐ |
| User feedback collected (minimum 3 data points) | ☐ |
| Metrics measured against baseline | ☐ |
| Criteria Evolution Log updated | ☐ |
| Decision is specific and actionable | ☐ |
| Next steps documented (if continuing) | ☐ |

---

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
| No stop-the-line triggers active | ✅ / ⚠️ / ❌ | |

---

## Step 7: Decide

Based on evaluation results, determine the **Final Verdict** and **Next Action**:

### Final Verdict

| Verdict | Criteria | Meaning |
|---------|----------|---------|
| **Ready** | All dimensions ≥4, no stop-the-line triggers, stress tests pass | Safe to publish/standardize |
| **Needs Work** | Some dimensions <4 but fixable, or minor stop-the-line issues | Iterate to resolve; don't publish yet |
| **Blocked** | Major stop-the-line issues or fundamental problems | Cannot proceed without significant intervention |
| **Not Viable** | Diminishing returns after 3+ cycles, or fundamental audience mismatch | Archive or major pivot |

**Final Verdict**: ☐ Ready | ☐ Needs Work | ☐ Blocked | ☐ Not Viable

**Rationale**: _[1-2 sentences explaining verdict]_

### Decision Action

| Decision | Criteria | Next Action |
|----------|----------|-------------|
| **Accept/Standardize** | Verdict is "Ready" | Publish/merge changes, update canonical version |
| **Iterate/Continue** | Verdict is "Needs Work" | Return to Analyze with narrow scope |
| **Stop/Pivot** | Verdict is "Blocked" | Document blockers, escalate, or major approach change |
| **Archive** | Verdict is "Not Viable" | Document decision and rationale; stop investment |

**Key Strengths** (even if not Ready):
1. _[What's working well]_
2. _[What's working well]_

**Key Gaps** (if any):
1. _[Primary issue]_
2. _[Secondary issue]_

**Priority Actions for Next Cycle** (if continuing):
1. _[Highest priority fix]_
2. _[Second priority fix]_

---

## Decision Criteria Matrix

| Cycles Completed | Improvement vs. Baseline | Decision |
|------------------|--------------------------|----------|
| 1-2 | <10% | Continue with adjusted criteria |
| 1-2 | ≥10% | Continue or Standardize if goals met |
| 3 | <10% | Pivot (major approach change) or Archive |
| 3 | 10-20% | Continue 1-2 more cycles |
| 3 | ≥20% | Standardize or continue for polish |
| 4-6 | <20% cumulative | Pivot or Archive |
| 4-6 | ≥20% cumulative | Standardize |

---

## Risk Assessment for Deferred Gaps

For gaps not addressed in this cycle, document the risk of deferral:

| Gap ID | Description | Likelihood of Impact (H/M/L) | Severity if Hit (H/M/L) | Risk Level | Decision |
|--------|-------------|------------------------------|-------------------------|------------|----------|
| | | | | H×H=Critical, else High/Med/Low | Accept / Must-fix next cycle |

### Risk Level Guide

- **Critical** (H×H): Must address in next cycle or accept documented risk
- **High** (H×M or M×H): Should address in next 1-2 cycles
- **Medium** (M×M, H×L, L×H): Address when convenient
- **Low** (anything with L): Acceptable to defer indefinitely

> **Rule**: Any Critical risk deferred for 2+ cycles requires explicit stakeholder sign-off.

---

## Implementation Roadmap (for multi-gap refinements)

When a cycle identifies many gaps, organize refinements into a phased roadmap:

### Quick Wins (This Cycle or Next)

| Gap ID | Refinement | Effort | Dependencies | Owner |
|--------|-----------|--------|--------------|-------|
| | | Low | None | |

### Medium-Term (2-3 Cycles)

| Gap ID | Refinement | Effort | Dependencies | Owner |
|--------|-----------|--------|--------------|-------|
| | | Medium | | |

### Strategic (Future Cycles)

| Gap ID | Refinement | Effort | Dependencies | Owner |
|--------|-----------|--------|--------------|-------|
| | | High | | |

### Roadmap Guidelines

- **Quick Wins**: Low effort, high impact, no blockers—do these first
- **Medium-Term**: Require some setup or research; schedule for upcoming cycles
- **Strategic**: Large effort or external dependencies; plan but don't rush
- Update roadmap each cycle as items complete or priorities shift

> **Tip**: For ARE-Lite, skip the roadmap—just fix what you can. For ARE-Standard with 5+ gaps, a simple roadmap prevents overwhelm.

---

## Stakeholder Communication (ARE-Standard+)

After completing evaluation, communicate findings appropriately:

| Stakeholder | What to Share | Format | When |
|-------------|---------------|--------|------|
| Doc owner/author | Full findings, next steps | Evaluation Report | Immediately |
| Affected teams | Summary of changes | Slack/email announcement | Within 1 week |
| Future maintainers | Lessons learned, deferred items | Archived with doc | With publication |

### Communication Template (for announcements)

> **[Doc Name] updated** (Cycle N complete)
> - **What changed**: [1-2 sentence summary]
> - **Why**: [Key gaps addressed]
> - **Impact**: [Who should re-read; what's different]
> - **Feedback**: [How to provide input]

> **Tip**: Skip formal communication for ARE-Lite; use for ARE-Standard and ARE-Full.

---

## Evaluate Inputs

| Input | Source | Required |
|-------|--------|----------|
| Refined document | Refine phase | Yes |
| Baseline data | Analyze phase | Yes |
| Criteria Document | Analyze phase | Yes |
| User test results | Testing | Recommended |

---

## Evaluate Outputs

| Output | Description | Template |
|--------|-------------|----------|
| Evaluation Report | Metrics, successes, lessons | See below |
| Criteria Evolution Log | Updated criteria + rationale | See below |
| Cycle Decision | Standardize/Continue/Pivot/Archive | In Evaluation Report |
| Next Cycle Scope | If continuing | In Evaluation Report |

---

## Evaluate Pitfalls

| Pitfall | Mitigation |
|---------|------------|
| **Confirmation bias** | Use blind testing where possible; have non-authors review |
| **Vanity metrics** | Tie metrics to user outcomes, not activity |
| **Skipping criteria adjustment** | Always update Criteria Evolution Log, even if no changes |
| **No decision made** | Force a decision; "Continue" is valid but must have next scope |
| **Premature acceptance** | Don't skip evaluation to ship faster |
| **Endless iteration** | Set a maximum cycle count (typically 2-3) |
| **Ignoring feedback** | User feedback trumps evaluator opinion |

---

## Template: Evaluation Report

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

See Criteria Evolution Log (Appendix F)

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

## Template: Criteria Evolution Log

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

## Next Steps

After completing Evaluate:

1. **For ARE-Standard+** → Run [05-are-stress-tests.md](./05-are-stress-tests.md) for validation scenarios
2. **Before Standardize decision** → Check [06-are-quality-gates.md](./06-are-quality-gates.md) for stop-the-line triggers
3. **If continuing** → Return to [01-are-analyze-single-doc.md](./01-are-analyze-single-doc.md) with narrowed scope

---

*This prompt covers the Evaluate phase. Ensure Refine outputs are complete before starting evaluation.*
