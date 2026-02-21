---
title: Trust through Governed Determinism
description: Ship confidently because behavior is predictable, agents are bounded, security is enforced, and mistakes are reversible.
phase: SHIP
---

# Trust through Governed Determinism

> Ship confidently because behavior is predictable, agents are bounded, security is enforced, and mistakes are reversible.

*Documentation gloss: predictable behavior through typed contracts, bounded agents, security policies, and reversible operations*

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Trust — confidence in correctness, security, and recoverability |
| **Harmony Provides** | Governed Determinism — typed contracts, bounded agents, security policies, reversibility |
| **Phase** | SHIP |
| **Partner Pillar** | [Velocity](./velocity.md) |

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| PolicyKit | `[Production]` | Security policies and policy enforcement |
| GuardKit | `[Production]` | Security guardrails and agent boundaries |
| EvalKit | `[Production]` | AI evaluation framework for correctness |
| FlagKit | `[Production]` | Feature flags for progressive rollout and rollback |
| Pact | `[Production]` | Contract testing for typed boundaries |

---

## Failure Mode

**Fear-driven conservatism: hesitation to ship, over-engineering**

When this pillar fails, you become afraid to ship. The lack of safety nets leads to over-engineering, excessive review cycles, and paralysis. Ironically, this makes systems *less* safe because changes accumulate into risky big-bang releases.

**Secondary failure mode:** Security theater without real protection—processes that look safe but don't actually protect users or data.

### Anti-Patterns

- **Untyped interfaces** — Contracts without schema validation
- **Unbounded agent actions** — AI agents without capability limits
- **No rollback path** — Shipping without ability to revert
- **Security theater** — Processes that look secure but aren't

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Trust protects user dignity and rights through privacy and security | ◉ Strong |
| **Structures & Scale** | Determinism supports data minimalism and local-first patterns | ◐ Secondary |
| **Attention & Interaction** | Predictability reduces cognitive load; users can trust system behavior | ◉ Strong |
| **Practice & Governance** | Governance enables participatory oversight; bounded agents respect authority | ◉ Strong |

---

## Pillar Relationships

### Phase Partner: Velocity (Productive Tension)

Trust enables sustainable Velocity: speed without safety leads to fear, which slows everything down. Trust provides the guardrails that let you ship fast with confidence. **Go fast, stay safe.**

### Foundation: Focus → Trust

Focus absorbs the complexity of security and governance infrastructure so developers can trust the system without managing it manually. GuardKit and PolicyKit are absorbed complexity. Trust and Focus reinforce each other.

### Input: Direction → Trust

Direction feeds Trust: when you've validated *what* to build, you can trust that shipping it is worthwhile. Trust without Direction is confident delivery of the wrong thing.

### Output: Trust → Continuity

Trust generates memory: guardrail triggers, policy decisions, and rollback events become the audit trails that Continuity preserves. You can trust the system because you can see what it did.

### Enabler: Trust → Insight

Trust enables learning: feature flags and rollback capability let you ship experiments safely. Insight emerges from experiments that Trust makes low-risk.

### Convivial Grounding

Trust serves Convivial Purpose by ensuring systems are transparent, controllable, and protective of user rights. Bounded agents cannot propose dark patterns; security policies protect user data.

---

## Actionability

### Developer Action

1. Define typed contracts for all interfaces (OpenAPI, JSON Schema)
2. Use feature flags for new features (FlagKit)
3. Ensure rollback capability before shipping
4. Respect agent boundaries defined in PolicyKit/GuardKit

### Harmony Enforcement

| Mechanism | Description | Status |
|-----------|-------------|--------|
| **Schema validation** | Validates all data against typed contracts | Active |
| **Guardrail checks** | GuardKit enforces security boundaries | Active |
| **Bounded agent policies** | Agents operate within defined capability limits | Active |
| **Contract testing** | Pact validates interface contracts in CI | Active |
| **Rollback automation** | FlagKit enables instant feature rollback | Active |

### Violation Signals

- Untyped interfaces in production code
- Unbounded agent actions (no capability limits)
- Deployments without rollback path
- GuardKit violations in logs
- Missing contract tests for new interfaces

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **Contract coverage** | % of interfaces with typed contracts | ≥95% | Static analysis of API boundaries |
| **Rollback success rate** | % of rollbacks that complete successfully | 100% | Track rollback operations |
| **Guardrail trigger frequency** | How often guardrails block unsafe operations | Track trend | GuardKit logs |
| **Agent boundary violations** | Count of agent actions exceeding bounds | 0 | PolicyKit audit logs |
| **Feature flag coverage** | % of new features behind flags | ≥90% | FlagKit metadata |
| **Time to rollback** | Time from decision to rollback completion | <5 min | Deployment timestamps |

---

## Convivial Alignment

| Dimension | How Trust Serves It |
|-----------|---------------------|
| **Expands Capability** | ✅ Predictable, controllable systems expand user autonomy |
| **Respects Attention** | ✅ Predictability reduces cognitive load |
| **Fosters Connection** | ✅ Transparent systems build trust between users and builders |
| **Resists Extraction** | ✅ Bounded agents resist manipulation; security policies protect data |

Trust scored **highest** on convivial alignment (20/20) because it directly protects user dignity through predictability, security, and transparency.

---

## Agent Governance

Bounded agents in Harmony operate within explicit constraints:

| Bound Type | Description | Enforcement |
|------------|-------------|-------------|
| **Capability limits** | What actions agents can take | PolicyKit rules |
| **Domain restrictions** | What data agents can access | GuardKit boundaries |
| **Safety constraints** | What outputs agents can produce | EvalKit + GuardKit |
| **ACP promotion gates** | When ACP policy evaluation is required | FlowKit workflow |

**Non-negotiables for agents:**
- Cannot commit directly to protected branches
- Cannot approve their own PRs
- Cannot handle secrets or long-lived credentials
- Must produce artifacts (plans, diffs, tests) for human review
- Mutations require idempotency keys

---

## Related Documentation

- [Velocity through Agentic Automation](./velocity.md) — Phase partner
- [Focus through Absorbed Complexity](./focus.md) — Foundation
- [Pillars Overview](./README.md) — All six pillars
- [Methodology: Security Baseline](../methodology/security-baseline.md) — Security implementation
- [Architecture: Governance Model](../_meta/architecture/governance-model.md) — Agent governance details
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
