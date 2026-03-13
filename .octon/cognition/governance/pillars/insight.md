---
title: Insight through Structured Learning
description: Improve continuously because every outcome teaches us something.
phase: LEARN
---

# Insight through Structured Learning

> Improve continuously because every outcome teaches us something.

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Insight — understanding that makes tomorrow better than today |
| **Octon Provides** | Structured Learning — postmortems, EvalKit feedback, retro-driven updates |
| **Phase** | LEARN |
| **Partner Pillar** | [Continuity](./continuity.md) |

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| EvalKit | `[Production]` | AI evaluation framework |
| DatasetKit | `[Production]` | Dataset management for evals |
| Postmortem templates | `[Production]` | Structured incident analysis |
| Retro practices | `[Production]` | Reflection and improvement |

---

## Failure Mode

**Stagnation: repeating mistakes, AI that doesn't improve, ossified methodology**

When this pillar fails, you make the same mistakes repeatedly, AI systems don't get better, and processes become rigid and outdated. The system doesn't learn from experience—it just accumulates scars.

### Anti-Patterns

- **Repeated incidents** — Same root cause triggers multiple incidents
- **Flat eval scores** — AI performance doesn't improve over time
- **Skipped retros** — Reflection sacrificed under pressure
- **Learning debt** — Open postmortems, stale action items
- **Ossified methodology** — "We've always done it this way"

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Learning improves human flourishing over time; eval criteria include attention respect and capability expansion | ◉ Strong |
| **Structures & Scale** | Learning supports adaptive, convivial tools | ◐ Secondary |
| **Attention & Interaction** | Learning improves attention respect over time | ◐ Secondary |
| **Practice & Governance** | Learning embodies iterative, reflective practice | ◉ Strong |

---

## Pillar Relationships

### Feedback Loop: Insight → Direction (Loop Closure)

Insight closes the loop to Direction: what we learn from postmortems, evals, and retros informs what we should build next. Learning without application is academic; Insight feeds Direction to make future specs better.

**What we shipped teaches us what to shape.**

### Phase Partner: Insight ↔ Continuity

Continuity captures *what happened*; Insight extracts *what we learned*. Postmortems analyze the traces and ADRs that Continuity preserved. Memory enables learning; learning creates new memory worth preserving.

### Input: Trust → Insight (Safe Experimentation)

Trust enables Insight: feature flags, rollback capability, and bounded agents let us ship experiments safely. We can learn from real-world outcomes because Trust makes failure recoverable. Insight feeds back to Trust by identifying where guardrails should be strengthened.

### Output: Insight → Focus (Methodology Improvement)

Insight improves Focus: retros reveal which complexity isn't yet absorbed ("we had to build custom X"), informing kit roadmaps. Postmortems identify infrastructure gaps that Focus should address. EvalKit feedback on AI orchestration improves PromptKit.

### Accelerator: Insight → Velocity

Yesterday's learning is tomorrow's velocity. Learning from postmortems removes the root causes of slowdowns. Eval-driven prompt refinement improves AI agent effectiveness. Retro action items address process friction.

### Convivial Grounding

Insight serves Convivial Purpose by ensuring we optimize for human flourishing, not just engagement metrics. Eval criteria should include attention respect, capability expansion, and connection fostering. Postmortems should assess whether incidents violated user dignity.

---

## Actionability

### Developer Action

1. Run evals regularly (EvalKit in CI)
2. Conduct blameless postmortems for significant incidents
3. Update prompts based on eval feedback
4. Run a weekly retro (even solo)
5. Complete action items from postmortems and retros

### Octon Enforcement

| Mechanism | Description | Priority |
|-----------|-------------|----------|
| **Eval runs in CI** | EvalKit executes on every PR touching AI behavior | Active |
| **Eval score threshold gates** | Block merges when eval scores drop >5% | P0 |
| **Automatic postmortem triggers** | P1/P2 incidents auto-create postmortem tickets | P1 |
| **Retro cadence enforcement** | Block new sprint start if retro not logged | P2 |
| **Learning artifact requirements** | AI behavior changes require learning-impact.md | P3 |

### Violation Signals

- Repeated incidents with same root cause
- Flat or declining eval scores
- Skipped retros (>2 consecutive)
- Learning debt accumulation (open postmortems >7 days)
- Stale action items (>14 days without progress)

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **Eval score trends** | AI performance over time | Improving | EvalKit score history |
| **Postmortem completion rate** | % of qualifying incidents with completed postmortems | 100% | Track postmortem tickets |
| **Postmortem time-to-completion** | Days from incident to postmortem completion | <7 days | Timestamp diff |
| **Retro frequency** | Retros conducted per sprint/cycle | 100% | Retro artifact count |
| **Action item completion rate** | % of postmortem/retro actions completed | ≥80% | Track action items |
| **Repeat incident rate** | % of incidents with same root cause as previous | ≤5% | Root cause analysis |
| **Prompt refinement velocity** | Time from eval regression to prompt improvement | <7 days | Track refinement cycle |
| **Learning debt** | Count of open postmortems + stale actions | Decreasing | Dashboard tracking |

---

## Convivial Alignment

| Dimension | How Insight Serves It |
|-----------|------------------------|
| **Expands Capability** | ✅ Learning makes tools genuinely better over time |
| **Respects Attention** | ✅ Eval criteria can include attention metrics |
| **Fosters Connection** | ✅ Reflection creates shared understanding (with future you and others) |
| **Resists Extraction** | ✅ Learning optimizes for flourishing, not engagement |

---

## Learning Artifacts

### Postmortem Structure

Every postmortem should include:

```yaml
incident_id: INC-NNNN
severity: P1 | P2 | P3
date: YYYY-MM-DD
timeline:
  - timestamp: "YYYY-MM-DDTHH:MM:SSZ"
    event: "Description of what happened"
root_cause: "The underlying reason this incident occurred"
contributing_factors:
  - "Factor 1"
  - "Factor 2"
action_items:
  - description: "What needs to be done"
    owner: "@person"
    due_date: YYYY-MM-DD
    type: process | technical | training | tooling
learning_summary: "What we learned from this incident"
convivial_impact_review:
  user_harm_occurred: boolean
  attention_respect_violated: boolean
  trust_eroded: boolean
```

### Retro Summary Structure

```yaml
sprint_id: "Sprint-NN"
date: YYYY-MM-DD
participants: ["@you"]
wins:
  - "What went well"
challenges:
  - "What was difficult"
action_items:
  - description: "Improvement to make"
    owner: "@person"
    pillar_alignment: Direction | Focus | Velocity | Trust | Continuity | Insight
methodology_updates:
  - type: kit_enhancement | process_change | guardrail_addition | documentation
    description: "What to update"
    rationale: "Why this change"
```

---

## The Eval-to-Prompt Feedback Loop

When eval scores regress:

1. **Detect**: EvalKit identifies regression in CI
2. **Alert**: Automatic ticket created with failing examples
3. **Analyze**: Review eval results, identify pattern
4. **Refine**: Update prompts to address failure mode
5. **Verify**: Re-run evals to confirm improvement
6. **Document**: Log prompt version → eval score correlation

This loop is Insight in action: systematic learning from AI behavior.

---

## Related Documentation

- [Continuity through Institutional Memory](./continuity.md) — Phase partner
- [Direction through Validated Discovery](./direction.md) — Feedback loop destination
- [Pillars Overview](./README.md) — All six pillars
- [EvalKit Documentation](/.octon/capabilities/runtime/services/_meta/docs/kits-reference.md) — AI evaluation
- [Postmortem Policy](../../practices/methodology/reliability-and-ops.md) — Incident learning
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
