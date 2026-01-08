---
title: ARE Loop - Worked Example
description: Complete example of ARE Loop applied to API Authentication Guide
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
  - example
---

# ARE Loop - Worked Example

This example demonstrates the ARE Loop applied to an API Authentication Guide over two cycles.

---

## Context

- **Document**: `docs/api/authentication.md`
- **Tier**: ARE-Standard
- **Known Issues**: Users report confusion, support tickets mention "can't find token refresh"
- **Baseline Metrics**: Flesch score 52, task completion 65%, 3 support tickets/week

---

## Cycle 1

### Cycle 1: Analyze (Day 1, ~2 hours)

#### Evaluation Context

| Field | Value |
|-------|-------|
| Document Being Evaluated | docs/api/authentication.md |
| Version | v1.0 |
| Evaluation Date | 2025-01-15 |
| Evaluator(s) | Jane Developer |
| Previous Cycle Date | N/A (Cycle 0) |
| Trigger for This Cycle | User feedback (support tickets) |

#### Gap Analysis

| ID | Category | Dimension | Description | Severity | Tag | Priority |
|----|----------|-----------|-------------|----------|-----|----------|
| G1 | Content | Completeness | Missing token refresh documentation | 5 | [GAP] | High |
| G2 | Style | Clarity | Jargon-heavy intro (Flesch 52) | 4 | [SIMPLIFY] | High |
| G3 | Technical | Implementability | No code examples for common languages | 3 | [GAP] | Medium |
| G4 | Structure | Coherence | Inconsistent header hierarchy | 2 | [SIMPLIFY] | Low |

#### Criteria Setting

| Criterion | Weight | Target | Measurement |
|-----------|--------|--------|-------------|
| Accuracy | 30% | 100% | Expert review |
| Completeness | 30% | All auth topics | Checklist |
| Readability | 25% | Flesch ≥65 | textstat |
| Usability | 15% | Task completion ≥80% | User test (n=5) |

#### Cycle Scope

- **In Scope**: G1 (token refresh), G2 (intro readability)
- **Deferred**: G3 (code examples), G4 (headers) - next cycle

---

### Cycle 1: Refine (Days 1-3, ~6 hours)

#### Ideation

| Gap | Ideas Generated | Selected |
|-----|-----------------|----------|
| G1 | 1. Add "Token Lifecycle" section with diagram<br>2. Inline refresh in existing auth flow<br>3. Separate "Token Management" page | #1 (best balance of depth and integration) |
| G2 | 1. Rewrite intro at 8th-grade level<br>2. Add TL;DR summary<br>3. Create glossary | #1 + #2 (complement each other) |

#### Implementation

**For G1 (Token Refresh)**:
- Added new "Token Lifecycle" section after "Getting Your First Token"
- Included sequence diagram showing token refresh flow
- Added troubleshooting for common refresh errors

**For G2 (Readability)**:
- Rewrote introduction: removed jargon, added context
- Added TL;DR box at top
- Defined technical terms on first use

#### Quick Validation

- Peer review caught missing error codes in token refresh section → Fixed
- Links validated ✓
- Readability check: Flesch improved from 52 to 68

---

### Cycle 1: Evaluate (Day 4, ~2 hours)

#### Metrics Summary

| Criterion | Baseline | This Cycle | Change | Target | Met? |
|-----------|----------|------------|--------|--------|------|
| Accuracy | 100% | 100% | - | 100% | ✅ |
| Completeness | 70% | 95% | +25% | 100% | ⚠️ |
| Readability | 52 | 68 | +31% | ≥65 | ✅ |
| Usability | 65% | 78% | +20% | ≥80% | ⚠️ |
| **Overall** | | | **+19%** | | |

#### User Testing Results (n=5)

- 4/5 users found token refresh section easily
- 3/5 completed full auth flow without help (was 2/5)
- Feedback: "Much clearer intro, but wish there were code examples"

#### Criteria Evolution

| Criterion | Old Weight | New Weight | Rationale |
|-----------|------------|------------|-----------|
| Completeness | 30% | 20% | Major gap addressed |
| Usability | 15% | 25% | Still lagging; code examples needed |

#### Health Indicators

| Indicator | Status |
|-----------|--------|
| Accuracy target met | ✅ |
| Completeness target met | ⚠️ (95%, target 100%) |
| Readability target met | ✅ |
| Usability target met | ⚠️ (78%, target 80%) |
| User feedback positive | ✅ |

#### Decision

**Verdict**: Needs Work  
**Decision**: Continue to Cycle 2

**Priority Actions for Next Cycle**:
1. Add code examples (addresses usability gap)
2. Clean up header hierarchy (deferred from Cycle 1)

---

## Cycle 2

### Cycle 2: Analyze (Day 5, ~1.5 hours)

#### Updated Criteria

| Criterion | Weight | Target |
|-----------|--------|--------|
| Accuracy | 30% | 100% |
| Completeness | 20% | 100% |
| Readability | 25% | ≥65 (maintain) |
| Usability | 25% | ≥85% |

#### Remaining Gaps

| ID | Description | Severity | Priority |
|----|-------------|----------|----------|
| G3 | No code examples | 4 | High |
| G4 | Header hierarchy | 2 | Low |

#### Cycle Scope

- **In Scope**: G3 (code examples)
- **Deferred**: G4 (headers) - low priority, can live with it

---

### Cycle 2: Refine (Days 5-7, ~5 hours)

#### Ideation

| Gap | Ideas | Selected |
|-----|-------|----------|
| G3 | 1. Tabbed code blocks (Python, JS, cURL)<br>2. Separate pages per language<br>3. Link to external SDK docs | #1 (best UX, single page) |

#### Implementation

- Added tabbed code examples for all authentication steps
- Languages covered: Python, JavaScript, cURL
- Each example includes error handling
- Tested all examples locally → all work

#### Quick Validation

- All code examples run successfully ✓
- Links validated ✓
- Readability maintained at 66 ✓

---

### Cycle 2: Evaluate (Day 8, ~2 hours)

#### Metrics Summary

| Criterion | Cycle 1 | This Cycle | Change | Target | Met? |
|-----------|---------|------------|--------|--------|------|
| Accuracy | 100% | 100% | - | 100% | ✅ |
| Completeness | 95% | 100% | +5% | 100% | ✅ |
| Readability | 68 | 66 | -3% | ≥65 | ✅ |
| Usability | 78% | 91% | +17% | ≥85% | ✅ |
| **Overall** | | | **+5%** | | |

#### Support Ticket Comparison

| Period | Tickets/Week | Notes |
|--------|--------------|-------|
| Before Cycle 1 | 3 | Baseline |
| After Cycle 2 | 1 | -67% reduction |

*Measured over 2-week post-implementation window*

#### User Testing Results (n=5)

- 5/5 users completed auth flow without help
- Average time to first successful API call: 8 min (was 15 min)
- Feedback: "Code examples are exactly what I needed"

#### Stress Tests

| Test | Result |
|------|--------|
| 30-Second Pitch | Pass |
| 30-Minute Comprehension | Pass |
| Day 1 Test | Pass |
| Team Change Test | Pass |
| Solo User Test | Pass |
| Emergency/Hotfix Test | Pass |

**Verdict**: 6/6 required tests passed

#### Health Indicators

| Indicator | Status |
|-----------|--------|
| Accuracy target met | ✅ |
| Completeness target met | ✅ |
| Readability target met | ✅ |
| Usability target met | ✅ |
| User feedback positive | ✅ |
| Stress tests passed | ✅ |
| No stop-the-line triggers | ✅ |

#### Decision

**Final Verdict**: Ready  
**Decision**: Standardize

**Actions**:
- [x] Merged changes to main branch
- [x] Announced update in #dev-docs channel
- [ ] Create follow-up issue for header cleanup (low priority)

#### Re-Evaluation Triggers

| Trigger | Threshold |
|---------|-----------|
| Time-based | 6 months |
| User feedback | 3+ similar complaints |
| API changes | Any auth endpoint changes |

---

## Results Summary

| Metric | Baseline | After 2 Cycles | Improvement |
|--------|----------|----------------|-------------|
| Flesch Score | 52 | 66 | +27% |
| Task Completion | 65% | 91% | +40% |
| Support Tickets/Week | 3 | 1 | -67% |
| Total Investment | - | 8 days | - |

### Measurement Notes

- Task completion based on 5-user sample per cycle (informal testing with team members unfamiliar with the API)
- Support ticket reduction measured over 2-week post-implementation window
- Flesch score measured using textstat Python library

---

## Key Learnings

1. **Scope control matters**: Deferring code examples to Cycle 2 let us ship readability improvements faster
2. **User feedback is gold**: "Wish there were code examples" directly informed Cycle 2 priorities
3. **Criteria evolution works**: Shifting weight to usability after Cycle 1 focused effort correctly
4. **Measurement drives decisions**: Support ticket reduction provided concrete ROI evidence

---

## Artifacts Created

- Gap Analysis Summary (Cycle 1, Cycle 2)
- Criteria Document (evolved across cycles)
- Change Log (2 entries)
- Evaluation Reports (2)
- Criteria Evolution Log

---

*This example demonstrates a successful 2-cycle ARE-Standard application. Real-world cycles may require more iterations or pivot decisions.*
