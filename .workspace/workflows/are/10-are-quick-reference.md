---
title: ARE Loop - Quick Reference Card
description: Condensed reference for the ARE Loop methodology
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
  - reference
---

# ARE Loop - Quick Reference Card

```text
┌──────────────────────────────────────────────────────────────────────────┐
│  ARE LOOP QUICK REFERENCE                                                │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  TIERS:                                                                  │
│  • ARE-Lite (15-30 min / 1-2 days): Minor updates, low-risk docs         │
│  • ARE-Standard (1-2 hr / 3-5 days): New docs, significant changes       │
│  • ARE-Full (2-4 hr / 5-7 days): Critical docs, major refactors          │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  SUGGESTED ORDER (ARE-Standard): ~2.5-3.5 hrs total                      │
│  0. Skim doc (15-30m) → 1-5. Analyze (60-90m) → 6-8. Refine (50-70m)     │
│  → 9-11. Evaluate + Decide (45-65m)                                      │
│                                                                          │
│  TIME ALLOCATION (per cycle): 25% Analyze / 45% Refine / 30% Evaluate    │
│  WIP LIMIT: 1-2 concurrent cycles per contributor                        │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  PHASES:                                                                 │
│                                                                          │
│  1. ANALYZE (PLAN)                                                       │
│     Read → Identify gaps → Classify (Category + Dimension) → Score       │
│     Tags: [GAP] [EXPAND] [SIMPLIFY]                                      │
│                                                                          │
│  2. REFINE (SHIP)                                                        │
│     Prioritize → Ideate (15%) → Implement (25%) → Validate (5%)          │
│     Types: Add | Update | Remove | Restructure | Consolidate             │
│                                                                          │
│  3. EVALUATE (LEARN)                                                     │
│     Re-read → Score dimensions → Collect feedback → Self-check → Decide  │
│     Decisions: Standardize | Continue | Pivot | Archive                  │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  SCORING RUBRIC:                                                         │
│  5 = Excellent    4 = Good    3 = Adequate    2 = Weak    1 = Poor       │
│                                                                          │
│  DIMENSIONS (target ≥4 for most):                                        │
│  Clarity | Alignment | Leanness | Implementability | Coherence           │
│                                                                          │
│  CATEGORIES: Content | Structure | Style | Technical                     │
│  EXPLORATION: Gap | Expansion | Simplification                           │
│                                                                          │
│  OPTIONAL CHECKS (ARE-Standard+ or claim-heavy docs):                    │
│  • Guarantee/Promise Audit: Claims defined? Evidence? Achievable?        │
│  • Differentiation Check: Positioning clear? Trade-offs documented?      │
│  • Process Overhead Audit: Steps, time burden, justification (process docs)│
│  • Anti-Pattern Audit: What NOT to do documented? Linked to best practices?│
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  BASELINE CRITERIA (Cycle Zero):                                         │
│  Accuracy 30% | Completeness 25% | Readability 25% | Usability 20%       │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  STRESS TESTS:                                                           │
│  All: 30-Second Pitch                                                    │
│  Standard+: 30-Min Comprehension | Day 1 | Team Change | Solo User       │
│             | Emergency/Hotfix                                           │
│  Full: + Conflict Resolution | Remote/Async | Budget/Constraint          │
│         | Legacy/Brownfield | Vendor Dependency | Audit/Compliance       │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  STOP-THE-LINE TRIGGERS (must resolve before Standardize):               │
│  • Broken critical path      • Security/safety risk                      │
│  • Factual inaccuracy        • Missing required content                  │
│  • Broken critical links     • Legal/compliance exposure                 │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  FINAL VERDICT:                                                          │
│  Ready = All dimensions ≥4, no stop-the-line, tests pass → Standardize   │
│  Needs Work = Fixable issues → Continue                                  │
│  Blocked = Major issues → Escalate or Pivot                              │
│  Not Viable = 3+ cycles no progress → Archive                            │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  DECISION MATRIX:                                                        │
│  Cycles 1-2, <10% improvement → Continue                                 │
│  Cycles 3, <10% improvement → Pivot or Archive                           │
│  Cycles 3, 10-20% improvement → Continue 1-2 more                        │
│  Cycles 3+, ≥20% improvement → Standardize                               │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  RE-EVALUATION TRIGGERS:                                                 │
│  Time-based | Major update | Feedback spike | Context change             │
│  Metric regression | Dependency update                                   │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  DELIVERABLES CHECKLIST (per cycle):                                     │
│  ☐ Evaluation Context documented                                         │
│  ☐ Gap Analysis Summary completed                                        │
│  ☐ Criteria Document (weights + targets)                                 │
│  ☐ Change Log (what changed, why)                                        │
│  ☐ Evaluation Report (metrics, decision, next steps)                     │
│  ☐ Criteria Evolution Log updated                                        │
│  ☐ Implementation Roadmap (if 5+ gaps identified)                        │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  IMPLEMENTATION ROADMAP (for multi-gap cycles):                          │
│  Quick Wins (this/next cycle) → Medium-Term (2-3 cycles) → Strategic     │
│                                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  FOR DOC SETS (ARE-Standard+):                                           │
│  • Define Minimum Viable Documentation (Day 1 essential, ≤1 hr read)     │
│  • Check Visual Artifacts (diagrams, decision trees, reference cards)    │
│  • Verify Concern Distribution (one authoritative owner per topic)       │
│  • Confirm Entry Points (clear "start here", reading order, prereqs)     │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Prompt File Quick Links

| Phase | Prompt |
|-------|--------|
| Start here | [00-are-overview.md](./00-are-overview.md) |
| Analyze | [01-are-analyze-single-doc.md](./01-are-analyze-single-doc.md) |
| Audits | [02-are-analyze-audits.md](./02-are-analyze-audits.md) |
| Refine | [03-are-refine.md](./03-are-refine.md) |
| Evaluate | [04-are-evaluate.md](./04-are-evaluate.md) |
| Stress Tests | [05-are-stress-tests.md](./05-are-stress-tests.md) |
| Quality Gates | [06-are-quality-gates.md](./06-are-quality-gates.md) |
| Doc Sets | [are-document-sets.md](./are-document-sets.md) |
| Templates | [07-are-templates.md](./07-are-templates.md) |
| Tooling | [08-are-tooling.md](./08-are-tooling.md) |
| Best Practices | [09-are-best-practices.md](./09-are-best-practices.md) |
| Example | [11-are-worked-example.md](./11-are-worked-example.md) |

---

*Print this card or keep it visible during ARE cycles for quick reference.*
