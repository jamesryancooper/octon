---
title: Velocity through Agentic Automation
description: Ship fast because AI automation removes bottlenecks and multiplies output.
phase: SHIP
---

# Velocity through Agentic Automation

> Ship fast because AI automation removes bottlenecks and multiplies output.

*Documentation gloss: AI agents that autonomously handle tasks like PR reviews, test generation, and deployment gates—not just scripted automation.*

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Velocity — sustained, high-frequency delivery |
| **Harmony Provides** | Agentic Automation — AI agents, automated gates, trunk-based flow |
| **Phase** | SHIP |
| **Partner Pillar** | [Trust](./trust.md) |

---

## The Convivial Constraint

Velocity is powerful—and therefore dangerous without guardrails.

**Speed serves purpose, not metrics.** Velocity is maximized *within* Direction's validated scope and *subject to* Trust's convivial guardrails. We ship fast because:

1. **Humane tools deserve fast delivery.** Users waiting for accessibility fixes, security patches, or genuinely helpful features shouldn't wait because of process drag.

2. **Fast feedback enables fast learning.** Shipping quickly lets us learn quickly, feeding the Insight → Direction loop.

3. **Speed is not the goal; flourishing is.** Velocity is a *means*, not an *end*. If shipping fast means shipping harm, the answer is not to ship.

**What Velocity Does NOT Mean:**
- ❌ Ship anything fast
- ❌ Bypass convivial review for speed
- ❌ Optimize deploy frequency regardless of outcomes
- ❌ Fast-track features that manipulate or extract

**What Velocity DOES Mean:**
- ✅ Ship *validated, humane* features fast
- ✅ Remove *non-convivial* bottlenecks (unnecessary approvals, slow CI, manual gates)
- ✅ Keep *convivial* gates (spec validation, dark pattern scanning, privacy review)
- ✅ Optimize for *flourishing outcomes per unit time*

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| AgentKit | `[Production]` | AI agents for PR review, code generation, task automation |
| FlowKit | `[Production]` | Workflow orchestration and state management |
| CIKit | `[Production]` | CI/CD pipeline templates and automation recipes |
| PatchKit | `[Aspirational]` | Automated code patching and refactoring (roadmap: Q2 2026) |

---

## Failure Mode

**Bottleneck-driven slowdowns: waiting for reviews, large batches**

When this pillar fails, delivery stalls. PRs sit in review queues, deployments batch up into risky big-bang releases, and manual gates create delays that compound into frustration and missed deadlines.

### Anti-Patterns

- **Long PR queue times** — PRs waiting days for review
- **Large batch deploys** — Accumulating changes instead of shipping continuously
- **Manual gates everywhere** — Requiring ACP gate for routine operations
- **Waiting for review** — Processes that block on approvals and async feedback loops

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Velocity ensures humane tools reach people quickly; speed serves flourishing, constrained by Direction's validated specs | ◐ Secondary |
| **Structures & Scale** | Agentic automation enables scale-in: solo developers deliver high frequency without headcount bloat | ◐ Secondary |
| **Attention & Interaction** | Automation removes attention-draining toil (reviews, tests, deploys), freeing developer focus | ◉ Strong |
| **Practice & Governance** | Fast cycles enable fast learning; automated gates ensure speed doesn't bypass safety | ◉ Strong |

---

## Pillar Relationships

### Phase Partner: Trust (Productive Tension)

Velocity and Trust are phase partners in SHIP: Velocity pushes *fast*, Trust ensures *safe*. The tension is productive—Trust's guardrails (contracts, bounded agents, rollback) are what make high Velocity sustainable. Without Trust, Velocity creates fear; without Velocity, Trust becomes paralysis.

### Constraint: Direction → Velocity

Direction constrains Velocity: we ship fast *within* validated direction. Velocity maximizes speed toward a *known good destination*, not speed for its own sake. A PR without a linked validated spec is velocity toward nowhere.

### Enabler: Focus → Velocity

Focus enables Velocity: absorbed complexity removes infrastructure bottlenecks. You can ship fast because you're not rebuilding plumbing every sprint. Velocity is Focus paying dividends.

### Input: Velocity → Continuity

Velocity feeds Continuity: fast shipping generates traces, logs, and deployment records that become institutional memory. High-frequency deploys create richer observability data.

### Enabler: Velocity → Insight

Velocity enables Insight: fast cycles mean fast feedback. The more frequently we ship, the more data points for learning. Velocity accelerates the Insight → Direction feedback loop.

---

## Actionability

### Developer Action

1. Use AI-assisted PRs via AgentKit
2. Deploy from trunk using trunk-based development
3. Automate tests with CIKit patterns
4. Ship behind feature flags for safe progressive rollout

### Harmony Enforcement

| Mechanism | Description | Status |
|-----------|-------------|--------|
| **CI gates** | Automated quality, security, and performance checks | Active |
| **Automated testing** | Tests run automatically on every PR | Active |
| **Trunk-based merge rules** | Branch protection with required checks | Active |
| **Agent-assisted review** | AgentKit provides initial PR review | Active |
| **Velocity convivial guardrails** | Dark pattern scanning, attention gates | Active |

### Violation Signals

- Long PR idle times (>4 working hours without a completed review pass)
- Large batch deploys (>5 PRs accumulated)
- Manual gates blocking routine operations
- DORA metrics degrading (lead time, deploy frequency)

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **Deploy frequency** | How often we deploy to production | Daily+ | Count deploys per day/week |
| **Lead time** | Time from commit to production | <1 day | Timestamp diff: commit → deploy |
| **PR cycle time** | Time from PR open to merge | <4 hours | PR timestamps |
| **Change fail rate** | % of deploys causing incidents | <5% | Incident count / deploy count |
| **MTTR** | Mean time to recovery from failures | <1 hour | Incident timestamps |
| **Agent review coverage** | % of PRs with AgentKit review | >90% | AgentKit logs |

These align with **DORA metrics** for measuring software delivery performance.

---

## Convivial Alignment

| Dimension | How Velocity Serves It |
|-----------|------------------------|
| **Expands Capability** | ◐ Humane tools reach people quickly |
| **Respects Attention** | ○ Speed alone doesn't respect attention—requires guardrails |
| **Fosters Connection** | ○ Indirect |
| **Resists Extraction** | ⚠️ Risk: can ship extractive features fast without guardrails |

### Convivial Risk Mitigation

Velocity scored lowest on convivial alignment because speed alone can enable shipping dark patterns quickly. This is mitigated by:

1. **Direction constraint** — Velocity is maximized *within* validated specs
2. **Trust guardrails** — Bounded agents cannot propose manipulative features
3. **Velocity-specific guardrails** — Dark pattern scanning, attention gates, extraction gates

---

## Related Documentation

- [Trust through Governed Determinism](./trust.md) — Phase partner
- [Direction through Validated Discovery](./direction.md) — Constraint source
- [Pillars Overview](./README.md) — All six pillars
- [Methodology: CI/CD Quality Gates](../methodology/ci-cd-quality-gates.md) — Implementation details
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
