---
title: ARE Loop - Best Practices & Anti-Patterns
description: Operational guidance, common mistakes, and failure recovery
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./00-are-overview.md
tags:
  - documentation
  - methodology
  - best-practices
---

# ARE Loop - Best Practices & Anti-Patterns

This prompt covers operational guidance for running ARE cycles effectively, common anti-patterns to avoid, and how to recover from failure modes.

---

## Flow Optimization

### Core Principles

- **One cycle at a time**: Complete or explicitly pause a cycle before starting another
- **Timebox ruthlessly**: If a phase exceeds allocation, cut scope rather than extend time
- **Ship incrementally**: Standardize partial improvements rather than waiting for perfection
- **Celebrate wins**: Document and share improvements to maintain momentum

### Time Management

| If You're... | Do This |
|--------------|---------|
| Running over time in Analyze | Cut scope, not depth |
| Running over time in Refine | Ship what's done, defer rest |
| Running over time in Evaluate | Make the decision with available data |
| Stuck on a gap | Defer to next cycle, note why |

### Maintaining Flow

- Start each day with a clear goal for the current phase
- End each session by documenting where you stopped
- Don't context-switch between documents mid-cycle
- If interrupted, document your state before switching

---

## Scaling for Teams

| Team Size | Approach |
|-----------|----------|
| **Solo** | Full ownership of all phases; seek external feedback in Evaluate |
| **2 people** | Rotate: one owns Analyze/Evaluate, other owns Refine; swap each cycle |
| **3+ people** | Assign phase owners; use async handoffs with clear artifacts |

### Handoff Best Practices

When handing off between phases:

1. **Artifact completeness**: Ensure all required outputs exist
2. **Context transfer**: Brief summary of decisions and rationale
3. **Open questions**: Document uncertainties for the next person
4. **Timeline clarity**: When do they need to complete by?

### Team Coordination

| Phase | Owner Responsibilities |
|-------|----------------------|
| Analyze | Gap Analysis Summary, Criteria Document |
| Refine | Change Log, Revised Document |
| Evaluate | Evaluation Report, Criteria Evolution Log |

---

## Measurement Discipline

### Minimum Viable Measurement

- Flesch score (automated)
- 3 user data points (feedback, testing, or interview)

### Recommended Measurement

- Flesch score
- Analytics (page views, time on page)
- 5-user task completion test
- Feedback survey

### Full Measurement (ARE-Full)

- All above
- Expert review
- Stakeholder interviews
- A/B testing (if applicable)

### Measurement Pitfalls

| Pitfall | Why It's Harmful | Better Approach |
|---------|------------------|-----------------|
| No measurement | Can't prove improvement | At minimum: Flesch + 3 users |
| Only automated metrics | Misses user experience | Combine automated + qualitative |
| Too many metrics | Analysis paralysis | Focus on 3-5 key metrics |
| Measuring activity | "Words written" ≠ quality | Measure user outcomes |

---

## Common Anti-Patterns

### Analyze Phase Anti-Patterns

| Anti-Pattern | Why It's Harmful | Better Approach |
|--------------|------------------|-----------------|
| **Skipping Analyze** | Random improvements without direction | Always baseline, even if quick |
| **Opinion-based gaps** | "I think it's unclear" isn't evidence | Require validation method for each gap |
| **Boiling the ocean** | Trying to fix everything at once | Scope to top 3-5 gaps per cycle |
| **Static criteria** | Using same criteria for 3+ cycles | Evolve criteria based on findings |

### Refine Phase Anti-Patterns

| Anti-Pattern | Why It's Harmful | Better Approach |
|--------------|------------------|-----------------|
| **Endless Refine cycles** | Perfectionism kills momentum | Timebox; ship "good enough" |
| **Scope creep** | "While I'm here..." derails focus | Defer new discoveries to next cycle |
| **Style drift** | Inconsistent with rest of doc | Match existing style unless style IS the problem |
| **No ideation** | First idea isn't always best | Generate 3+ options before choosing |

### Evaluate Phase Anti-Patterns

| Anti-Pattern | Why It's Harmful | Better Approach |
|--------------|------------------|-----------------|
| **Skipping evaluation** | No feedback loop, no learning | Always measure, even if quick |
| **Vanity metrics** | "We wrote more words" isn't success | Tie metrics to user outcomes |
| **Ignoring user feedback** | Evaluator opinion ≠ user experience | User feedback trumps internal opinion |
| **No decision** | Cycles without closure pile up | Force Standardize/Continue/Pivot/Archive |

### Process Anti-Patterns

| Anti-Pattern | Why It's Harmful | Better Approach |
|--------------|------------------|-----------------|
| **No user feedback** | Improvements may not matter | Require minimum 3 user data points |
| **Multiple docs simultaneously** | Context-switching reduces quality | WIP limit of 1-2 concurrent cycles |
| **Ignoring Criteria Evolution** | Loop doesn't improve | Always update log, even with no changes |
| **Deferred gaps pile up** | Risk accumulates silently | Risk-assess deferred gaps each cycle |

---

## Failure Modes and Recovery

| Failure | Likely Cause | Recovery |
|---------|--------------|----------|
| **No gaps found in Analyze** | Over-mature doc, wrong criteria, or blind spots | Expand criteria scope; seek external/user feedback; benchmark against best-in-class |
| **No viable ideas in Refine** | Team fatigue, unclear gaps, or constrained thinking | Bring in fresh perspectives; do more benchmarking; reduce scope to one gap |
| **Refinement regresses quality** | Scope creep, unclear criteria, or poor implementation | Revert to prior version; tighten scope; pair with experienced reviewer |
| **No improvement after 3 cycles** | Fundamental doc/audience mismatch or wrong metrics | Pivot (new format, new audience focus) or Archive (doc may not be viable) |
| **Cycle exceeds time budget** | Scope too large or unclear criteria | Split into smaller scope; defer items to next cycle; timebox ruthlessly |
| **Stakeholder disagreement** | Unclear ownership or conflicting goals | Escalate to owner; document decision in ADR; align on success criteria before next cycle |

### Recovery Decision Tree

```
Problem identified
├── Is it recoverable this cycle?
│   ├── Yes → Fix and continue
│   └── No → Document and defer
│
├── Has this happened before?
│   ├── First time → Learn and adjust
│   └── Recurring → Root cause analysis needed
│
└── Is the document viable?
    ├── Yes → Adjust approach (Pivot)
    └── No → Stop investment (Archive)
```

---

## When to Escalate

| Situation | Escalate To | Expected Outcome |
|-----------|-------------|------------------|
| Blocked for >2 cycles | Team lead | Resource allocation or scope change |
| Stakeholder disagreement | Document owner | Decision authority |
| Technical accuracy dispute | Subject matter expert | Authoritative answer |
| Resource constraints | Manager | Prioritization decision |
| Fundamental viability question | Product/strategy owner | Continue/Archive decision |

---

## Quality Signals

### Healthy Cycle Signs

- Gaps decrease each cycle
- User feedback improves
- Metrics trend upward
- Criteria evolve appropriately
- Decisions are clear and actionable

### Unhealthy Cycle Signs

- Same gaps persist across cycles
- User feedback stagnates or declines
- Metrics flat or declining
- Criteria unchanged for 3+ cycles
- Decisions delayed or unclear

### Intervention Points

| Signal | Intervention |
|--------|--------------|
| 2 cycles with no improvement | Review criteria and approach |
| 3 cycles with same gaps | Consider architectural changes |
| User feedback consistently negative | User research needed |
| Team avoiding evaluation | Address psychological safety |

---

## Checklist: Before Starting a Cycle

- [ ] Prior cycle completed or explicitly paused
- [ ] WIP limit not exceeded (≤2 concurrent cycles)
- [ ] Tier selected (ARE-Lite/Standard/Full)
- [ ] Time budget allocated
- [ ] Criteria document available (or baseline for Cycle 0)
- [ ] User feedback mechanism in place

## Checklist: Cycle Health Check

Run this mid-cycle to catch problems early:

- [ ] On track for time budget
- [ ] Scope hasn't expanded
- [ ] Artifacts being created
- [ ] No blockers unaddressed
- [ ] User data collection happening

---

*Best practices help teams avoid common pitfalls. Review this prompt when cycles aren't producing expected results.*
