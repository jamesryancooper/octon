---
title: ARE Loop - Stress Tests
description: Scenario-based validation for documentation quality
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./04-are-evaluate.md
  - ./06-are-quality-gates.md
tags:
  - documentation
  - methodology
  - testing
  - validation
---

# ARE Loop - Stress Tests

For ARE-Standard and ARE-Full tiers, validate documentation with scenario-based tests. These tests verify that documentation works in real-world conditions.

---

## Stress Test Menu

| Test | Question | Pass Criteria | Tier |
|------|----------|---------------|------|
| **30-Second Pitch** | Can you explain doc purpose in 30 seconds? | Core value is immediately clear | All |
| **30-Minute Comprehension** | Can a new reader understand core content in 30 min? | Reader can summarize key points | Standard+ |
| **Day 1 Test** | Can someone use this immediately? | Task completion without external help | Standard+ |
| **Team Change Test** | Can a new team member pick this up? | Context is self-contained | Standard+ |
| **Solo User Test** | Does this work for someone with no one to ask? | No steps require external help or approval | Standard+ |
| **Emergency/Hotfix Test** | Can someone follow this under time pressure? | Critical path is ≤5 min to find and execute | Standard+ |
| **Conflict Resolution Test** | If two sections seem to contradict, is resolution clear? | Explicit guidance or clear authority hierarchy | Full |
| **Remote/Async Test** | Does this work without synchronous explanation? | No "tribal knowledge" required | Full |
| **Budget/Constraint Test** | Can someone follow this with minimal budget/tools? | Core path doesn't require paid tools | Full |
| **Legacy/Brownfield Test** | Does this work for existing systems, not just greenfield? | Guidance acknowledges existing state | Full |
| **Vendor Dependency Test** | Are required vs. optional dependencies clear? | Lock-in risks stated; alternatives noted | Full |
| **Audit/Compliance Test** | Can external parties verify practices from this doc? | Evidence traceable, procedures documented | Full |

---

## Stress Test Execution Notes

| Test | How to Execute | Common Failure Modes |
|------|----------------|---------------------|
| **30-Second Pitch** | Time yourself explaining to a colleague | Rambling, no clear value statement |
| **30-Minute Comprehension** | Have someone unfamiliar read and summarize | Too much detail upfront, missing overview |
| **Day 1 Test** | New team member follows doc without help | Assumes context, missing prerequisites |
| **Team Change Test** | Imagine complete team turnover | Relies on undocumented knowledge |
| **Solo User Test** | Have someone follow docs without Slack/help access | "Ask your teammate" instructions |
| **Emergency/Hotfix Test** | Simulate urgency: find and execute critical steps | Buried critical info, too many prerequisites |
| **Conflict Resolution Test** | Search for contradictory guidance | No single source of truth, ambiguous authority |
| **Remote/Async Test** | Imagine following in different timezone, no chat | Assumes real-time availability |
| **Budget/Constraint Test** | Attempt to follow docs using only free tier tools | Assumes paid services without noting |
| **Legacy/Brownfield Test** | Imagine applying to existing messy codebase | "Start fresh" assumptions throughout |
| **Vendor Dependency Test** | List all tools mentioned; classify required vs optional | "Use X" without alternatives |
| **Audit/Compliance Test** | Imagine an auditor asks "show me your process for X" | Evidence scattered, procedures assumed, no audit trail |

---

## Test Selection by Tier

### ARE-Lite (1 test required)

- [ ] 30-Second Pitch

### ARE-Standard (6 tests required)

- [ ] 30-Second Pitch
- [ ] 30-Minute Comprehension
- [ ] Day 1 Test
- [ ] Team Change Test
- [ ] Solo User Test
- [ ] Emergency/Hotfix Test

### ARE-Full (All 12 tests)

- [ ] 30-Second Pitch
- [ ] 30-Minute Comprehension
- [ ] Day 1 Test
- [ ] Team Change Test
- [ ] Solo User Test
- [ ] Emergency/Hotfix Test
- [ ] Conflict Resolution Test
- [ ] Remote/Async Test
- [ ] Budget/Constraint Test
- [ ] Legacy/Brownfield Test
- [ ] Vendor Dependency Test
- [ ] Audit/Compliance Test

---

## Stress Test Template

| Test | Result | Notes |
|------|--------|-------|
| 30-Second Pitch | Pass / Fail | |
| 30-Minute Comprehension | Pass / Fail | |
| Day 1 Test | Pass / Fail | |
| Team Change Test | Pass / Fail | |
| Solo User Test | Pass / Fail | |
| Emergency/Hotfix Test | Pass / Fail | |
| Conflict Resolution Test | Pass / Fail / N/A | |
| Remote/Async Test | Pass / Fail / N/A | |
| Budget/Constraint Test | Pass / Fail / N/A | |
| Legacy/Brownfield Test | Pass / Fail / N/A | |
| Vendor Dependency Test | Pass / Fail / N/A | |
| Audit/Compliance Test | Pass / Fail / N/A | |

**Verdict**: ___ of ___ required tests passed

---

## Interpreting Results

| Pass Rate | Interpretation | Action |
|-----------|----------------|--------|
| 100% | Documentation is robust | Safe to Standardize |
| 80-99% | Minor gaps | Consider addressing before Standardize |
| 60-79% | Significant gaps | Should iterate; identify patterns |
| <60% | Major issues | Must iterate; review approach |

### Common Patterns

| If Failing... | Likely Root Cause | Focus Area |
|---------------|-------------------|------------|
| 30-Second Pitch | Unclear purpose | Rewrite introduction |
| Day 1 / Solo User | Missing prerequisites | Add getting-started section |
| Emergency/Hotfix | Poor information architecture | Improve navigation, add TL;DR |
| Legacy/Brownfield | Greenfield assumptions | Add migration/existing-system guidance |
| Audit/Compliance | Implicit procedures | Make processes explicit and traceable |

---

## Detailed Test Guides

### 30-Second Pitch

**Setup**: Find a colleague unfamiliar with the document.

**Execute**: 
1. Time yourself (30 seconds max)
2. Explain what the document is for and who should use it
3. Ask them to repeat back the core value

**Pass if**: They can articulate the document's purpose and audience.

**Fail if**: You exceeded time, rambled, or they couldn't summarize.

---

### Day 1 Test

**Setup**: Find someone who hasn't used this system/process before.

**Execute**:
1. Give them only the document (no verbal help)
2. Ask them to complete the primary task the doc describes
3. Observe silently; note where they struggle

**Pass if**: They complete the task without asking questions.

**Fail if**: They get stuck, ask for help, or complete incorrectly.

---

### Emergency/Hotfix Test

**Setup**: Simulate urgency (set a 10-minute timer).

**Execute**:
1. Define a critical scenario (e.g., "production is down")
2. Time how long to find relevant section
3. Time how long to execute the critical fix

**Pass if**: Find + execute ≤5 minutes total.

**Fail if**: Critical info buried, too many prerequisites, unclear steps.

---

### Audit/Compliance Test

**Setup**: Pretend you're an external auditor.

**Execute**:
1. Ask "Show me your process for [X]"
2. Can you trace from policy → procedure → evidence?
3. Are responsibilities clear?
4. Is there an audit trail?

**Pass if**: External party could verify compliance from documentation alone.

**Fail if**: Evidence scattered, procedures assumed, responsibilities unclear.

---

## Stress Test Report Template

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
| [Full tier tests...] | | | |

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

## Integration with Evaluate Phase

Run stress tests during Step 10 of the Suggested Evaluation Order:

1. Select tests based on tier
2. Execute tests and record results
3. Add failures to Gap Analysis for next cycle
4. Include pass rate in Health Indicators

→ Return to [04-are-evaluate.md](./04-are-evaluate.md) to complete evaluation

---

*Stress tests validate that documentation works in real-world conditions, not just on paper.*
