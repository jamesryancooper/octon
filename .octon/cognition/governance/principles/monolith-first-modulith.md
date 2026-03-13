---
title: Monolith-first Modulith
description: Start with a modular monolith and split only when measured evidence requires distributed complexity.
pillar: Focus, Velocity
status: Active
---

# Monolith-first Modulith

> Start modular monolith-first; split only when SLOs, scale limits, or ownership constraints prove a real need.

## What This Means

Octon defaults to a modular monolith with clear slice boundaries, contracts, and ownership. The goal is to keep deployment and debugging simple while preserving seams for future extraction.

This is not anti-scale. It is evidence-first scale: design boundaries now, distribute later.

## Why It Matters

### Pillar Alignment: Focus through Absorbed Complexity

A monolith-first architecture absorbs infrastructure complexity early so developers can focus on product behavior.

### Pillar Alignment: Velocity through Agentic Automation

Small-batch automation works best when changes land in one deployable unit with predictable CI and rollback.

### Quality Attributes Promoted

- **Complexity Fitness**: one runtime/deploy surface by default unless constraints justify more.
- **Maintainability**: slice boundaries remain explicit inside one repo.
- **Scalability**: extraction paths are preserved through ports/adapters.
- **Reliability**: fewer network hops and partial-failure modes in early stages.

## In Practice

### ✅ Do

```typescript
// Good: vertical slice with explicit boundary
export interface BillingPort {
  charge(input: ChargeInput): Promise<ChargeResult>;
}

export class BillingService {
  constructor(private readonly gateway: BillingPort) {}
  async createInvoice(orderId: string) {
    return this.gateway.charge({ orderId });
  }
}
```

```python
# Good: slice-local module boundary
class InventoryService:
    def __init__(self, repo: "InventoryRepo"):
        self.repo = repo

    def reserve(self, sku: str, qty: int) -> None:
        self.repo.reserve_units(sku, qty)
```

### ❌ Don't

```typescript
// Bad: premature service split for tiny workload
await fetch('https://inventory.internal/reserve', { method: 'POST', body: payload });
await fetch('https://billing.internal/charge', { method: 'POST', body: payload });
// Adds network complexity without a measured need.
```

```python
# Bad: architecture chosen by trend, not constraints
if traffic < 1000 and team_size == 1:
    raise RuntimeError("Do not add orchestration + service mesh yet")
```

## Relationship to Other Principles

- `Complexity Calibration` keeps topology at minimal sufficient complexity.
- `Ownership and Boundaries` keeps slices clean while still in one deployable.
- `Contract-first` makes future extraction reversible.

## Anti-Pattern: Premature Distribution

Splitting into many services before clear latency, throughput, or ownership pressure creates operational drag, slower delivery, and harder debugging.

## Exceptions

Use multiple services earlier only when one of these is true:

- hard compliance/data residency boundary,
- independently scaling hotspot with measured saturation,
- independently owned domain with conflicting release cadence.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/_meta/architecture/runtime-architecture.md`
- `.octon/cognition/_meta/architecture/repository-blueprint.md`
- `.octon/cognition/governance/pillars/focus.md`
- `.octon/cognition/governance/pillars/velocity.md`
