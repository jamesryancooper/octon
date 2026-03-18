---
title: Continuity through Institutional Memory
description: Knowledge persists because decisions, traces, and context are captured durably.
phase: LEARN
---

# Continuity through Institutional Memory

> Knowledge persists because decisions, traces, and context are captured durably.

---

## Overview

| Element | Content |
|---------|---------|
| **Developer Receives** | Continuity — context survives time and handoffs |
| **Octon Provides** | Institutional Memory — ADRs, traces, decision logs, audit trails |
| **Phase** | LEARN |
| **Partner Pillar** | [Insight](./insight.md) |

---

## Key Kits

| Kit | Maturity | Purpose |
|-----|----------|---------|
| Dockit | `[Production]` | Documentation generation and management |
| ObservaKit | `[Production]` | Traces and observability |
| ADR templates | `[Production]` | Architectural decision records |
| RunbookKit | `[Production]` | Operational procedure documentation |
| OnboardKit | `[Beta]` | Structured onboarding documentation |

---

## Failure Mode

**Knowledge loss: slow onboarding, repeated decisions, tribal knowledge**

When this pillar fails, knowledge exists only in your head. Weeks later (or after a context switch), answers to "why did we do this?" require rediscovering the reasoning, rereading code, and re-litigating decisions.

### Anti-Patterns

- **Undocumented decisions** — No ADR for significant architectural choices
- **Orphaned code** — Code without context explaining why it exists
- **"Ask Past You" answers** — Knowledge concentrated in memory instead of artifacts
- **Repeated decisions** — Revisiting the same architectural debates
- **Stale documentation** — Docs that don't reflect current reality

---

## RCDS Alignment

| RCDS Layer | Connection | Strength |
|------------|------------|----------|
| **Flourishing & Care** | Memory preserves human context and relationships | ◐ Secondary |
| **Structures & Scale** | Memory supports small, plural systems (local knowledge) | ◐ Secondary |
| **Attention & Interaction** | Memory reduces cognitive reconstruction effort | ◉ Strong |
| **Practice & Governance** | Memory supports ongoing evaluation and governance | ◉ Strong |

---

## Pillar Relationships

### Phase Partner: Insight (LEARN Phase)

Continuity and Insight are partners in the LEARN phase. Continuity captures *what happened*; Insight extracts *what we learned*. You need memory before you can learn—traces, ADRs, and decision logs provide the raw material for postmortems, evals, and retros. Without Continuity, Insight has nothing to analyze.

### Enabler: Continuity → Trust

Continuity enables Trust by providing audit trails that make governance possible. Decision logs explain *why* the system behaves as it does; traces prove *what* happened. Bounded agents in Trust are only trustworthy if their actions are recorded in Continuity.

### Receiver: Direction → Continuity

Validated specs from Direction become institutional memory in Continuity. ADRs reference the specs that motivated decisions; specs explain the "why we built this" that survives time and handoffs. Direction creates context; Continuity preserves it.

### Mutual Support: Focus ↔ Continuity

Focus absorbs complexity into kits and boundaries; Continuity documents *which* complexity was absorbed and *why*. When a developer asks "why does this kit work this way?", Continuity provides the answer. Without documentation, absorbed complexity becomes mysterious complexity.

### Accelerator: Continuity → Velocity

Continuity enables Velocity by reducing re-entry time. You ship faster when decisions are documented, not trapped in memory. Knowledge that persists means less time asking "why is X like this?" and more time building. Continuity's failure mode (slow re-entry) directly undermines Velocity.

---

## Actionability

### Developer Action

1. Write ADRs for significant architectural decisions
2. Document decisions with context, rationale, and alternatives considered
3. Tag traces with decision context for significant operations
4. Keep runbooks updated when procedures change

### Octon Enforcement

| Mechanism | Description | Priority |
|-----------|-------------|----------|
| **ADR templates** | Structured templates for decision records | Active |
| **"No merge without ADR" gate** | CI blocks PRs touching significant paths without ADR link | P0 |
| **ADR status validation** | ADRs must be in `accepted` status before work merges | P1 |
| **Trace context requirements** | Significant operations must include decision context | P2 |
| **Runbook freshness check** | CI warns when runbooks are >90 days stale | P2 |

### Violation Signals

- Undocumented decisions in significant PRs
- Orphaned code without explanatory ADRs
- Recurring "why is this like this?" questions with no linked ADR/spec
- Repeated decisions on already-decided topics
- Re-entry taking >2 days after time away to make a safe change

---

## Metrics

| Metric | What It Measures | Target | Collection Method |
|--------|------------------|--------|-------------------|
| **ADR coverage ratio** | % of significant PRs with linked ADRs | ≥90% | CI: ADR-linked PRs / total significant PRs |
| **ADR recency** | Average age of ADRs for active systems | <180 days | Parse ADR dates |
| **Re-entry time-to-productivity** | Days from "back after time away" to first safe merged PR | ≤2 days | Track return date → first PR |
| **Knowledge freshness index** | % of docs updated in last 90 days | ≥70% | Parse last_modified dates |
| **Tribal knowledge index** | % of "ask Bob" answers in support channels | ≤10% | Slack/Discord monitoring |
| **Decision discoverability score** | % of "why" questions answered by docs | ≥80% | Quarterly survey |
| **Runbook accuracy rate** | % of runbook executions without deviation | ≥95% | Track runbook executions |
| **Repeat decision rate** | % of decisions revisiting decided topics | ≤5% | ADR analysis |

---

## Convivial Alignment

| Dimension | How Continuity Serves It |
|-----------|--------------------------|
| **Expands Capability** | ✅ Preserved context helps users understand systems |
| **Respects Attention** | ✅ Memory reduces cognitive reconstruction effort |
| **Fosters Connection** | ✅ Shared memory supports collaboration (with future you and others) |
| **Resists Extraction** | ✅ Data minimalism through focused capture |

---

## Knowledge Types Captured

| Knowledge Type | Kit | Artifacts |
|----------------|-----|-----------|
| **Architectural decisions** | ADR templates | `docs/adr/*.md` |
| **System behavior** | ObservaKit | Traces, spans, logs |
| **Documentation** | Dockit | Generated docs, READMEs |
| **Operational procedures** | RunbookKit | Runbooks, playbooks |
| **Onboarding knowledge** | OnboardKit | Guides, checklists |
| **API contracts** | Trust pillar | OpenAPI specs, schemas |

---

## ADR Structure

Every ADR should include:

```yaml
title: "ADR-NNNN: Decision Title"
status: proposed | accepted | deprecated | superseded
date: YYYY-MM-DD
deciders: [list of people]
context: Why this decision was needed
decision: What we decided
consequences:
  positive: [benefits]
  negative: [tradeoffs]
  neutral: [observations]
alternatives_considered:
  - option: Alternative approach
    pros: [advantages]
    cons: [disadvantages]
    rejected_reason: Why not chosen
related_adrs: [ADR-NNNN, ...]
related_specs: [spec references]
```

---

## Related Documentation

- [Insight through Structured Learning](./insight.md) — Phase partner
- [Trust through Governed Determinism](./trust.md) — Enabled by Continuity
- [Pillars Overview](./README.md) — All six pillars
- [ADR Policy](../../runtime/decisions/README.md) — ADR storage and discovery contract
- [Architecture: Observability Requirements](../../_meta/architecture/observability-requirements.md) — Trace requirements
- [Convivial Purpose](../purpose/convivial-purpose.md) — The "why" this pillar serves
