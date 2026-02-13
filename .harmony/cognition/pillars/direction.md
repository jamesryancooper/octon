---
title: Direction through Validated Discovery
description: Build the right thing because every feature is validated before investment.
phase: PLAN
---

# Direction through Validated Discovery

> Build the right thing because every feature is validated before investment.

*Documentation gloss: specs, appetites, and user signals are verified before investment*

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Direction — confidence that effort is well-spent |
| **Harmony Provides** | Validated Discovery — spec-first validation, user signals, scoped appetites |
| **Phase** | PLAN |
| **Partner Pillar** | [Focus](./focus.md) |

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| SpecKit | `[Production]` | Spec-first validation and schema enforcement |
| PlanKit (planning kernel) | `[Production]` | Shaping and appetite management |
| Shape Up | `[Production]` | Appetite-driven scope control |
| Convivial Impact Assessment | `[Production]` | Ensures features serve genuine human needs |

---

## Failure Mode

**Wrong product: high velocity toward the wrong destination**

When this pillar fails, you ship features quickly and safely—but those features don't solve real problems. The result is wasted effort, user frustration, and technical debt from building the wrong thing.

### Anti-Patterns

- **Speculative PRs** — Code written before validating the problem exists
- **Scope creep beyond appetite** — Features that expand past their time-box
- **Skipping user signal collection** — Building based on assumptions, not evidence
- **No code without a validated spec** — The core rule this pillar enforces

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Validation ensures we build for genuine human need, not engagement metrics | ◉ Strong |
| **Structures & Scale** | Appetites enforce time-boxing, preventing feature bloat that creates scale problems | ◐ Secondary |
| **Attention & Interaction** | Convivial Impact Assessment in specs explicitly evaluates attention-class; validated specs prevent features that hijack user attention | ◐ Secondary |
| **Practice & Governance** | Validation is inherently an iterative, participatory practice; user signal collection is participatory feedback in action | ◉ Strong |

---

## Pillar Relationships

### Phase Partner: Focus

Direction defines *what* to build; Focus ensures you have the cognitive bandwidth *to* build it. A validated spec without absorbed complexity leads to overwhelmed developers.

### Feedback Loop: Insight → Direction

Insight feeds back to Direction: postmortems reveal what we should have validated but didn't; eval results inform future spec criteria. **What we shipped teaches us what to shape.**

### Enabler: Direction → Trust

Validated specs provide the certainty that makes Trust possible—you can ship confidently when you know you're building the right thing.

### Constraint: Direction → Velocity

Direction constrains Velocity: we ship fast *within* validated direction, not fast toward an unvalidated destination. A PR without a linked validated spec is velocity toward nowhere.

### Memory: Direction → Continuity

Validated specs become institutional memory—they're the "why we built this" that Continuity preserves.

---

## Actionability

### Developer Action

1. Write a spec using SpecKit templates
2. Get the spec validated (shaped → validated status)
3. Define appetite before coding begins
4. Link all PRs to their validated spec

### Harmony Enforcement

| Mechanism | Description | Priority |
|-----------|-------------|----------|
| **Schema validation on specs** | SpecKit validates spec structure and required fields | Active |
| **"No PR without linked spec" gate** | CI blocks PRs that lack a `spec:` reference | P0 |
| **Spec status check** | PRs can only merge if linked spec is in `validated` status | P1 |
| **Appetite exhaustion warning** | CI warns when estimated scope exceeds defined appetite | P2 |
| **Validation checklist gate** | Spec must have all validation checklist items checked | P3 |

### Violation Signals

- Code commits without associated validated spec
- Feature work outside defined appetite
- PRs merged without spec link
- Specs in `draft` status with active development

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **Spec coverage ratio** | % of shipped features with validated specs | ≥95% | CI: count PRs with spec links / total PRs |
| **Spec-to-ship time** | Time from spec validation to feature ship | Track trend | Timestamp diff: spec `validated_at` → PR `merged_at` |
| **Appetite adherence rate** | % of features shipped within appetite | ≥85% | Compare actual effort to spec `appetite` field |
| **Discovery validation rate** | % of discoveries that pass validation (vs. rejected) | 60-80% optimal | Count specs reaching `validated` vs. `rejected` |
| **Scope creep index** | Ratio of shipped scope to spec'd scope | ≤1.2 | Compare PR diff size to spec scope estimate |
| **User signal incorporation** | % of specs that include user research/signals | ≥80% | Schema field `user_signals: [...]` populated |

---

## Convivial Alignment

| Dimension | How Direction Serves It |
|-----------|------------------------|
| **Expands Capability** | ✅ Builds genuinely useful features that solve real problems |
| **Respects Attention** | ◐ Spec template can include attention-class requirements |
| **Fosters Connection** | ○ Indirect — validation may include user research |
| **Resists Extraction** | ✅ Validated specs resist feature bloat and scope creep |

---

## Related Documentation

- [Focus through Absorbed Complexity](./focus.md) — Phase partner
- [Insight through Structured Learning](./insight.md) — Feedback loop source
- [Pillars Overview](./README.md) — All six pillars
- [Methodology: Spec-First Planning](../methodology/spec-first-planning.md) — Implementation details
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
