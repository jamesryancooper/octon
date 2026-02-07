---
title: ARE Loop - Quality Gates & Triggers
description: Stop-the-line triggers, trend comparison, and re-evaluation triggers
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./04-are-evaluate.md
  - ./05-are-stress-tests.md
tags:
  - documentation
  - methodology
  - quality-gates
---

# ARE Loop - Quality Gates & Triggers

This prompt covers hard blockers that must be resolved before publishing, trend tracking across cycles, and conditions that trigger new evaluation cycles.

---

## Stop-the-Line Triggers

These are hard blockers that **must** be addressed before accepting a document (Standardize decision). If any trigger is active, the decision must be "Continue" or "Pivot" until resolved.

| Trigger | Description | Resolution Required |
|---------|-------------|---------------------|
| **Broken critical path** | User cannot complete primary task following the doc | Fix blocking step(s) |
| **Factual inaccuracy** | Documented information is provably wrong | Correct or remove |
| **Security/safety risk** | Following the doc could cause harm | Remove or add clear warnings |
| **Missing required content** | Claimed feature/section doesn't exist | Add content or remove claim |
| **Broken links to critical resources** | Links to essential external resources 404 | Fix or provide alternatives |
| **Legal/compliance exposure** | Doc contains claims that create liability | Review with appropriate authority |

---

## Stop-the-Line Check

Complete this check before any "Standardize" decision:

| Trigger | Active? | Resolution Status |
|---------|---------|-------------------|
| Broken critical path | ☐ Yes / ☐ No | |
| Factual inaccuracy | ☐ Yes / ☐ No | |
| Security/safety risk | ☐ Yes / ☐ No | |
| Missing required content | ☐ Yes / ☐ No | |
| Broken links to critical resources | ☐ Yes / ☐ No | |
| Legal/compliance exposure | ☐ Yes / ☐ No | |

**Stop-the-Line Result**: ☐ Clear (no active triggers) | ☐ Blocked (triggers active)

### Usage

- Check all triggers before making a "Standardize" decision
- Any active trigger → document must iterate until resolved
- Stop-the-line triggers are non-negotiable; they cannot be deferred

> **Note**: Not all gaps are stop-the-line. Most gaps can be deferred with documented risk. Stop-the-line triggers represent *unacceptable* states.

---

## Trend Comparison (Cycle 2+)

Compare current cycle to previous to identify trends:

| Metric | Cycle N-1 | Cycle N | Trend | Notes |
|--------|-----------|---------|-------|-------|
| Overall improvement % | | | ↑ / → / ↓ | |
| Gaps identified | | | | |
| Gaps resolved | | | | |
| User feedback sentiment | | | | |
| Stress tests passing | /8 | /8 | | |

### Trend Interpretation

| Trend | Meaning | Action |
|-------|---------|--------|
| **↑ Improving** | Approach is working | Continue current approach |
| **→ Flat** | Stagnation; approach may need change | Consider pivoting approach or criteria |
| **↓ Regressing** | Getting worse | Investigate root cause; may need to revert |

### Warning Signs

- **Flat for 2+ cycles**: Criteria may be wrong or scope too large
- **Regressing**: Recent changes may have caused harm; review Change Log
- **Gaps increasing**: Scope creep or deeper issues emerging

---

## Re-Evaluation Triggers

After standardizing, define when to initiate a new cycle:

| Trigger | Threshold | Action |
|---------|-----------|--------|
| **Time-based** | Every ___ months | Full re-evaluation |
| **Major content update** | Significant changes to subject matter | Full re-evaluation |
| **User feedback spike** | 3+ similar complaints/questions | Targeted re-evaluation |
| **Context change** | Audience, tools, or scope change | Targeted re-evaluation |
| **Metric regression** | Metrics drop below targets | Targeted re-evaluation |
| **Dependency update** | Referenced tools/APIs change | Targeted re-evaluation |

### Re-Evaluation Trigger Template

Document triggers in the final Evaluation Report when standardizing:

```markdown
## Re-Evaluation Triggers for [Document Name]

**Standardized Date**: YYYY-MM-DD

| Trigger Type | Specific Threshold | Owner | Check Frequency |
|--------------|-------------------|-------|-----------------|
| Time-based | 6 months | [Name] | Calendar reminder |
| User feedback | 3+ similar issues | Support team | Ongoing monitoring |
| Dependency | [Tool X] major version | [Name] | Release notes |
| Context | Audience expansion | Product team | Quarterly review |
```

### Monitoring Recommendations

| Tier | Recommended Monitoring |
|------|------------------------|
| ARE-Lite | Time-based only (6-12 months) |
| ARE-Standard | Time-based + user feedback monitoring |
| ARE-Full | All triggers active; quarterly check-ins |

---

## Escalation Path

When quality gates are persistently blocked:

| Situation | Escalation |
|-----------|------------|
| Stop-the-line trigger unresolvable by author | Escalate to doc owner |
| Blocked for >2 cycles | Escalate to team lead |
| Fundamental architecture issue | Escalate to technical authority |
| Legal/compliance concern | Escalate to legal/compliance team |

### Escalation Template

```markdown
## Escalation: [Document Name]

**Date**: YYYY-MM-DD
**Escalated By**: [Name]
**Escalated To**: [Name/Role]

### Issue Summary

[1-2 sentences describing the blocker]

### Stop-the-Line Trigger(s) Active

- [ ] Broken critical path
- [ ] Factual inaccuracy  
- [ ] Security/safety risk
- [ ] Missing required content
- [ ] Broken critical links
- [ ] Legal/compliance exposure

### Cycles Attempted

- Cycle 1: [Date] - [Outcome]
- Cycle 2: [Date] - [Outcome]

### Why Escalation Needed

[Why this can't be resolved at current level]

### Requested Action

[What you need from the escalation target]
```

---

## Integration with Evaluate Phase

This prompt supplements the Evaluate phase:

1. **Run Stop-the-Line Check** before finalizing any "Standardize" decision
2. **Complete Trend Comparison** for Cycle 2+
3. **Document Re-Evaluation Triggers** when standardizing
4. **Escalate** if blocked and unable to resolve

→ Return to [04-are-evaluate.md](./04-are-evaluate.md) to complete the decision

---

*Quality gates ensure documentation meets minimum acceptable standards before publication.*
