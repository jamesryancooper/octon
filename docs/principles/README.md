---
title: Harmony Principles
description: Core principles that guide decision-making in the Harmony framework, translating the Six Pillars into day-to-day engineering choices.
---

# Harmony Principles

Principles are the operational translation layer between philosophy and practice. They answer the question: *"Given our pillars and purpose, how should I make this specific decision?"*

```
Convivial Purpose (WHY)
        ↓
   Six Pillars (WHAT)
        ↓
   Principles (HOW) ← You are here
        ↓
   Methodology (WHEN)
        ↓
      Kits (WITH)
```

## Core Principles Index

| Principle | Summary | Primary Pillar |
|-----------|---------|----------------|
| [Progressive Disclosure](./progressive-disclosure.md) | Load information in layers, from summary to detail | Focus |
| [Simplicity Over Complexity](./simplicity-over-complexity.md) | Default to the smallest viable solution | Focus, Velocity |
| [Single Source of Truth](./single-source-of-truth.md) | One authoritative location for each type of knowledge | Continuity, Trust |
| [Locality](./locality.md) | Context lives close to where it's needed | Focus, Continuity |
| [Reversibility](./reversibility.md) | Every change should be undoable | Trust, Velocity |
| [Deny by Default](./deny-by-default.md) | No permissions until explicitly granted | Trust |
| [Determinism](./determinism.md) | Same inputs produce same outputs | Trust, Insight |
| [HITL Checkpoints](./hitl-checkpoints.md) | Agents propose, humans approve | Trust, Direction |

## Relationship to Pillars

Each principle implements one or more of the [Six Pillars](../pillars/README.md):

### PLAN Phase Principles
- **Progressive Disclosure** → Focus (absorbed complexity)
- **Simplicity Over Complexity** → Focus (cognitive bandwidth)
- **Locality** → Focus (scoped context reduces noise)
- **HITL Checkpoints** → Direction (validated decisions)

### SHIP Phase Principles
- **Single Source of Truth** → Trust (predictable behavior)
- **Simplicity Over Complexity** → Velocity (fewer moving parts)
- **Reversibility** → Trust (recoverable mistakes) + Velocity (ship fast, roll back safely)
- **Deny by Default** → Trust (bounded agents, enforced security)
- **Determinism** → Trust (predictable, reproducible behavior)
- **HITL Checkpoints** → Trust (human oversight on material changes)

### LEARN Phase Principles
- **Single Source of Truth** → Continuity (durable knowledge)
- **Progressive Disclosure** → Insight (efficient learning)
- **Locality** → Continuity (discoverable, domain-specific knowledge)
- **Determinism** → Insight (reproducible conditions enable learning)

## How to Use Principles

### In Design Documents
Reference principles when justifying decisions:

> *"We chose a monolith over microservices per [Simplicity Over Complexity](./simplicity-over-complexity.md) — we don't yet have evidence that we need distributed coordination."*

### In Code Reviews
Cite principles when requesting changes:

> *"This duplicates the schema definition. Per [Single Source of Truth](./single-source-of-truth.md), we should generate types from the OpenAPI spec."*

### In Architecture Decisions
Use principles as evaluation criteria:

| Option | Progressive Disclosure | Simplicity | Single Source |
|--------|----------------------|------------|---------------|
| A | ✓ | ✓ | ✗ |
| B | ✓ | ✗ | ✓ |

## Principle Categories

### Core Principles
Foundational principles that apply to all engineering decisions. See [`principles.md`](../principles.md) for the complete list including:
- Monolith-first modulith
- Contract-first
- Small diffs, trunk-based
- Determinism
- Reversibility

### Agentic Principles
Principles specific to AI-assisted development:
- No silent apply
- Determinism & provenance
- HITL checkpoints

### Anti-Principles
Patterns we explicitly avoid:
- Early microservices
- Long-lived branches
- Flaky tests

## Related Documentation

- [Six Pillars](../pillars/README.md) — The structural framework principles implement
- [Principles (full list)](../principles.md) — Complete principles reference
- [Methodology](../methodology/README.md) — Operational procedures
- [Workspace Architecture](../architecture/workspaces/README.md) — How principles manifest in workspace design
