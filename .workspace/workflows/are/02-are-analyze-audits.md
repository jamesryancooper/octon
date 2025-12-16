---
title: ARE Loop - Optional Analyze Audits
description: Deep-dive audits for claims, processes, completeness, and anti-patterns
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./01-are-analyze-single-doc.md
  - ./03-are-refine.md
tags:
  - documentation
  - methodology
  - analysis
  - audits
---

# ARE Loop - Optional Analyze Audits

These audits extend the core Analyze phase for documents that require deeper scrutiny. Use them selectively based on document type and risk tier.

---

## When to Use These Audits

| Audit | Use When | Tier |
|-------|----------|------|
| **Completeness Check** | Any doc with cross-references or code | ARE-Standard+ |
| **Guarantee/Promise Audit** | Doc makes explicit claims or promises | ARE-Full or claim-heavy |
| **Differentiation Check** | Doc positions against alternatives | ARE-Full or positioning docs |
| **Process Overhead Audit** | Doc describes workflows or runbooks | ARE-Standard+ for process docs |
| **Anti-Pattern Audit** | Doc teaches how to do something | ARE-Standard+ for instructional docs |

---

## Completeness Check

Verify referential integrity before proceeding:

| Check | Status | Notes |
|-------|--------|-------|
| All internal cross-references resolve | ☐ | |
| All external links work (or marked intentionally broken) | ☐ | |
| No placeholder text (TODO, TBD, COMING SOON) | ☐ | |
| All code examples run/compile | ☐ | |
| All referenced files/templates exist | ☐ | |
| Version numbers and dates are current | ☐ | |
| Mentioned tools/dependencies are current (not deprecated/EOL) | ☐ | |

**Completeness Score**: ___/7 checks passing

> **Note**: Failing completeness checks are automatically High-severity gaps.

---

## Guarantee/Promise Audit

If the document makes explicit guarantees, promises, or claims, audit each:

| Guarantee/Claim | Clearly Defined? | Evidence Provided? | Achievable by Reader? | Action |
|-----------------|------------------|--------------------|-----------------------|--------|
| | Yes / Partial / No | Yes / No | Yes / Partial / No | |

### Example Claims to Audit

- "This guide will get you running in 15 minutes"
- "Following these steps ensures compliance with X"
- "This pattern prevents Y problems"

> **Rule**: Bold claims without substantiation become high-severity gaps.

---

## Differentiation Check

If the document claims to be different from or better than alternatives, verify:

| Alternative/Competitor | How This Doc Differs | Differentiation Clear? | Evidence Provided? |
|------------------------|---------------------|------------------------|-------------------|
| | | Yes / Partial / No | Yes / No |

### Differentiators to Verify (if claimed)

| Claimed Differentiator | Substantiated in Doc? | Evidence | Gap? |
|------------------------|----------------------|----------|------|
| | Yes / No | | |

### Questions to Ask

1. Can a reader clearly articulate "why this over alternatives"?
2. Are there scenarios where this approach is NOT the right choice? (Documented?)
3. Does the doc acknowledge trade-offs and boundaries?

> **When to use**: Only for documentation that explicitly positions itself against alternatives. Skip for routine docs.

---

## Process Overhead Audit

For documentation that describes workflows, runbooks, or multi-step processes, audit the overhead:

| Process/Workflow | Steps Required | Estimated Time | Automatable Steps | Justified? |
|------------------|----------------|----------------|-------------------|------------|
| | | min | /total | Yes / Partial / No |

### Questions to Ask

1. Is every step justified by clear value, or is there ceremony without purpose?
2. Could any manual steps be automated or eliminated?
3. Is the time burden proportionate to the outcome?
4. Would a reader following this process feel it's lean or heavy?

### Overhead Assessment

| Rating | Criteria |
|--------|----------|
| **Lean** | ≤5 steps for simple outcomes; all steps clearly justified |
| **Moderate** | 6-10 steps or some steps feel ceremonial |
| **Heavy** | >10 steps or significant unjustified overhead |

**Verdict**: ☐ Lean | ☐ Moderate | ☐ Heavy

> **When to use**: Only for documentation that prescribes processes (runbooks, workflows, onboarding guides). Skip for reference docs, API docs, or conceptual guides.

---

## Anti-Pattern Audit

Documentation that teaches practices should also document what NOT to do. Audit anti-pattern coverage:

| Category | Expected Anti-Pattern | Documented? | Linked to Best Practice? | Where? |
|----------|----------------------|-------------|-------------------------|--------|
| **Common mistakes** | Errors new readers frequently make | Yes / No | Yes / No | |
| **Misuse patterns** | Ways the guidance is commonly misapplied | Yes / No | Yes / No | |
| **Deprecated approaches** | Old practices that should no longer be used | Yes / No | Yes / No | |
| **Edge case traps** | Non-obvious situations where guidance fails | Yes / No | Yes / No | |

### Anti-Pattern Audit Questions

1. Does the doc explicitly call out common failure modes?
2. Are anti-patterns linked to their corresponding best practices?
3. Would a reader recognize when they're doing something wrong?
4. Are warnings/cautions clearly distinguished from regular guidance?

**Anti-Pattern Coverage**: ☐ Comprehensive | ☐ Partial | ☐ Missing

> **When to use**: For docs that teach how to do something (guides, tutorials, runbooks, policies). Skip for pure reference docs (API specs, changelogs). If the doc says "do X," consider whether it should also say "don't do Y."

> **Tip**: Missing anti-patterns are often discovered through support questions, incident postmortems, and user feedback. If you lack this data, mark as "Unknown" and note as a gap.

---

## Integrating Audit Findings

After completing relevant audits:

1. **Add findings to Gap Analysis** with appropriate severity
2. **Tag audit-sourced gaps** for traceability:
   - `[COMPLETENESS]` - From completeness check
   - `[CLAIM]` - From guarantee/promise audit
   - `[DIFFERENTIATION]` - From differentiation check
   - `[OVERHEAD]` - From process overhead audit
   - `[ANTI-PATTERN]` - From anti-pattern audit
3. **Proceed to Refine phase** → [03-are-refine.md](./03-are-refine.md)

---

*These audits are optional extensions to the core Analyze phase. Use them when document type warrants deeper scrutiny.*
