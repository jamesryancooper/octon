---
title: The Six Pillars
description: Harmony's six pillars organize the complete development lifecycle into three phases — PLAN, SHIP, LEARN — forming a closed feedback loop that serves the Convivial Purpose.
---

# The Six Pillars

Harmony's six pillars organize the complete development lifecycle into three phases, forming a closed feedback loop that serves our [Convivial Purpose](../purpose/convivial-purpose.md).

> **The software we ship should expand human capability, respect attention, and foster connection—not extract, manipulate, or diminish.**

The pillars are the *what*. The [Convivial Purpose](../purpose/convivial-purpose.md) is the *why*. The [Methodology](../methodology/README.md) is the *how*.

Harmony is written **solo-first**: one developer working with AI (agents + automation), following a pillar-guided lifecycle. If/when you have collaborators, the same pillars still apply.

---

## Visual Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                      CONVIVIAL PURPOSE                          │
│    Technology that expands capability, respects attention,      │
│    fosters connection, and resists extraction                   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       THE SIX PILLARS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PLAN      ┌─────────────────┬─────────────────┐               │
│             │    DIRECTION    │     FOCUS       │               │
│             │    Validated    │    Absorbed     │               │
│             │    Discovery    │   Complexity    │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      ▼                 ▼                        │
│   SHIP      ┌─────────────────┬─────────────────┐               │
│             │    VELOCITY     │     TRUST       │               │
│             │    Agentic      │    Governed     │               │
│             │   Automation    │   Determinism   │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      ▼                 ▼                        │
│   LEARN     ┌─────────────────┬─────────────────┐               │
│             │   CONTINUITY    │    INSIGHT      │               │
│             │  Institutional  │   Structured    │               │
│             │     Memory      │    Learning     │               │
│             └────────┬────────┴────────┬────────┘               │
│                      │                 │                        │
│                      └────────┬────────┘                        │
│                               │                                 │
│                               ▼                                 │
│                    (feeds back to DIRECTION)                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 30-Second Summary

> "Harmony has six pillars in three phases:
>
> **PLAN:** Direction (know what to build) and Focus (build without distraction).
>
> **SHIP:** Velocity (ship fast) and Trust (ship safely).
>
> **LEARN:** Continuity (remember) and Insight (improve).
>
> Together they form a complete loop from discovery through delivery to learning."

---

## The Three Phases

| Phase | Pillars | Developer Question |
|-------|---------|-------------------|
| **PLAN** | [Direction](./direction.md), [Focus](./focus.md) | "What are we building, and how do we think about it?" |
| **SHIP** | [Velocity](./velocity.md), [Trust](./trust.md) | "How do we deliver fast and safely?" |
| **LEARN** | [Continuity](./continuity.md), [Insight](./insight.md) | "How do we remember and improve?" |

---

## The Six Pillars

| # | Pillar | Phase | Developer Receives | Harmony Provides |
|---|--------|-------|-------------------|------------------|
| 1 | [Direction through Validated Discovery](./direction.md) | PLAN | Confidence that effort is well-spent | Spec-first validation, user signals, scoped appetites |
| 2 | [Focus through Absorbed Complexity](./focus.md) | PLAN | Cognitive bandwidth freed for what matters | Kits, schemas, modular boundaries |
| 3 | [Velocity through Agentic Automation](./velocity.md) | SHIP | Sustained, high-frequency delivery | AI agents, automated gates, trunk-based flow |
| 4 | [Trust through Governed Determinism](./trust.md) | SHIP | Confidence in correctness, security, recoverability | Typed contracts, bounded agents, reversibility |
| 5 | [Continuity through Institutional Memory](./continuity.md) | LEARN | Context survives time and handoffs | ADRs, traces, decision logs, audit trails |
| 6 | [Insight through Structured Learning](./insight.md) | LEARN | Understanding that makes tomorrow better | Postmortems, EvalKit feedback, retro-driven updates |

---

## Lifecycle Flow

The six pillars map naturally to a complete development lifecycle:

```text
DISCOVER ──→ BUILD ──→ SHIP ──→ PERSIST ──→ LEARN ──→ (loop)
    │          │        │          │          │
    ▼          ▼        ▼          ▼          ▼
Direction   Focus   Velocity   Continuity  Insight
                    + Trust
```

**The loop closes:** Insight feeds back into Direction—what we learn informs what we build next.

---

## Narrative Flow

> **Harmony gives developers:**
>
> **Direction through Validated Discovery** — Know what to build because every feature is validated before investment.
>
> **Focus through Absorbed Complexity** — Build calmly because Harmony handles infrastructure, process, and boundaries.
>
> **Velocity through Agentic Automation** — Ship fast because AI removes bottlenecks and multiplies output.
>
> **Trust through Governed Determinism** — Ship safely because behavior is predictable, agents are bounded, security is enforced, and mistakes are reversible.
>
> **Continuity through Institutional Memory** — Remember everything because decisions, traces, and context are captured durably.
>
> **Insight through Structured Learning** — Improve always because every outcome teaches us something.

---

## Pillar Relationships

### Key Tensions (Productive)

| Tension | Resolution |
|---------|------------|
| **Direction ↔ Velocity** | Direction constrains Velocity. Don't ship fast on the wrong thing. |
| **Velocity ↔ Trust** | Trust enables sustainable Velocity. Speed without safety creates fear. |

### Key Enablements

| Enablement | How It Works |
|------------|--------------|
| **Focus → Velocity** | Absorbed complexity removes infrastructure bottlenecks. Teams ship fast because they're not rebuilding plumbing. |
| **Focus → Trust** | When complexity is absorbed into well-tested kits, the building blocks themselves are trustworthy. |
| **Trust → Insight** | Safe experimentation (feature flags, rollback) enables learning from real-world outcomes. |
| **Continuity → Insight** | Memory enables learning. Postmortems analyze traces and ADRs that Continuity preserved. |
| **Direction → Continuity** | Validated specs become institutional memory—the "why we built this" that survives time and handoffs. |

---

## RCDS Layer Mapping

The pillars map to the [Resonant Computing Design Stack (RCDS)](../purpose/resonant-computing-design-stack.md) layers:

| Pillar | Flourishing & Care | Structures & Scale | Attention & Interaction | Practice & Governance |
|--------|-------------------|-------------------|------------------------|----------------------|
| Direction | ◉ Strong | ◐ Secondary | ○ Minimal | ◉ Strong |
| Focus | ◐ Secondary | ◉ Strong | ◉ Strong | ◐ Secondary |
| Velocity | ◐ Secondary | ◐ Secondary | ◉ Strong | ◉ Strong |
| Trust | ◉ Strong | ◐ Secondary | ◉ Strong | ◉ Strong |
| Continuity | ◐ Secondary | ◐ Secondary | ◉ Strong | ◉ Strong |
| Insight | ◉ Strong | ◐ Secondary | ◐ Secondary | ◉ Strong |

**Legend:** ◉ = Primary | ◐ = Secondary | ○ = Minimal

### Coverage Analysis

| RCDS Layer | Pillars Serving This Layer | Coverage |
|------------|---------------------------|----------|
| Flourishing & Care | Direction, Trust, Insight | ✅ Strong |
| Structures & Scale | Focus | ◐ Adequate |
| Attention & Interaction | Focus, Velocity, Trust, Continuity | ✅ Strong |
| Practice & Governance | All six pillars | ✅ Excellent |

---

## Convivial Alignment

The pillars serve Harmony's Convivial Purpose: *Technology that expands capability, respects attention, fosters connection, and resists extraction.*

| Pillar | Expands Capability | Respects Attention | Fosters Connection | Resists Extraction |
|--------|-------------------|-------------------|-------------------|-------------------|
| Direction | ✅ Builds genuinely useful features | ◐ Spec template can include attention-class | ○ Indirect | ✅ Validated specs resist feature bloat |
| Focus | ✅ Cognitive freedom enables better building | ✅ Absorbed complexity reduces cognitive load | ○ Indirect | ✅ Modularity resists complexity extraction |
| Velocity | ◐ Humane tools reach people quickly | ○ Speed alone doesn't respect attention | ○ Indirect | ⚠️ Risk: can ship extractive features fast |
| Trust | ✅ Predictable systems expand autonomy | ✅ Predictability reduces cognitive load | ✅ Transparent systems build trust | ✅ Bounded agents resist manipulation |
| Continuity | ✅ Preserved context helps understanding | ✅ Memory reduces reconstruction effort | ✅ Shared memory fosters collaboration over time | ✅ Data minimalism through focused capture |
| Insight | ✅ Learning makes tools genuinely better | ✅ Eval can include attention metrics | ✅ Reflection creates shared understanding | ✅ Learning optimizes for flourishing |

### Convivial Risk: Velocity

Velocity scored lowest on convivial alignment because speed alone can enable shipping dark patterns quickly. This is mitigated by:

1. **Direction constraint** — Velocity is maximized *within* validated specs
2. **Trust guardrails** — Bounded agents cannot propose manipulative features
3. **Velocity-specific guardrails** — Dark pattern scanning, attention gates, extraction gates

> **The Convivial Constraint:** We ship fast because humane tools deserve fast delivery—not because deploy frequency is intrinsically good.

---

## Kit Maturity Reference

| Kit | Pillar | Maturity | Notes |
|-----|--------|----------|-------|
| SpecKit | Direction | `[Production]` | Spec-first validation |
| PlanKit (planning kernel) | Direction | `[Production]` | Shaping and appetite management |
| kit-base | Focus | `[Production]` | Foundation for all kits |
| PromptKit | Focus | `[Production]` | AI prompt orchestration |
| AgentKit | Velocity | `[Production]` | AI agents for autonomous tasks |
| FlowKit | Velocity | `[Production]` | Workflow orchestration |
| CIKit | Velocity | `[Production]` | CI/CD automation templates |
| PatchKit | Velocity | `[Aspirational]` | Automated code patching (roadmap: Q2 2026) |
| PolicyKit | Trust | `[Production]` | Policy enforcement |
| GuardKit | Trust | `[Production]` | Security guardrails |
| EvalKit | Trust, Insight | `[Production]` | AI evaluation framework |
| FlagKit | Trust | `[Production]` | Feature flags |
| Dockit | Continuity | `[Production]` | Documentation generation |
| ObservaKit | Continuity | `[Production]` | Traces and observability |
| RunbookKit | Continuity | `[Production]` | Operational procedures |
| OnboardKit | Continuity | `[Beta]` | Structured onboarding |
| DatasetKit | Insight | `[Production]` | Dataset management for evals |

---

## Related Documentation

- [Convivial Purpose](../purpose/convivial-purpose.md) — The *why* beneath the pillars
- [Resonant Computing Design Stack](../purpose/resonant-computing-design-stack.md) — The four-layer framework
- [Methodology Overview](../methodology/README.md) — Operational implementation of the pillars
- [Kit Documentation](../kits/README.md) — Tools that implement the pillars
