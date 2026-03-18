---
title: Complexity Calibration
description: Favor minimal sufficient complexity. Complexity is accepted only when justified by risk, scale, safety, performance, or compliance.
pillar: Focus, Velocity, Trust
status: Active
---

# Complexity Calibration

> Favor minimal sufficient complexity: as simple as possible, as complex as necessary.

## What This Means

Complexity Calibration is Octon's governing rule for design and delivery complexity. The target is not minimum novelty or minimum code volume. The target is the smallest robust solution that meets constraints.

Complexity is valid only when it is justified by one or more of:

- Risk containment
- Scale requirements
- Safety requirements
- Performance requirements
- Compliance requirements

Complexity is invalid when it is speculative, ornamental, or unbounded.

## Complexity Calibration Test

Before introducing non-trivial complexity, answer:

1. What concrete constraint requires this complexity?
2. What simpler option was considered and why is it insufficient?
3. What measurable signal would allow simplification later?
4. What maintenance cost is introduced and who owns it?

If these are not explicit, do not add complexity.

## Complexity Fitness

Approved complexity must be:

- **Proportional**: aligned to actual risk/scale/safety/performance/compliance pressure
- **Intentional**: introduced for a declared reason, not by drift
- **Maintainable**: operable, testable, observable, and supportable over time

Reject both:

- **Under-engineering**: too little control for required reliability and safety
- **Over-engineering**: too much architecture for actual constraints

## In Practice

### ✅ Do

- Start with the smallest robust solution that satisfies current constraints.
- Add seams where one-way-door changes are expensive to reverse.
- Increase complexity only after evidence (incidents, saturation, policy requirements, measured bottlenecks).
- Keep rollback and observability aligned with complexity level.

### ❌ Don't

- Add frameworks, services, or abstraction layers only for future possibilities.
- Use "simplicity" as a reason to skip required safety or compliance controls.
- Accept complexity without explicit ownership and operational evidence.

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Monolith-first Modulith | Default topology is minimal sufficient complexity; distribution requires evidence |
| Reversibility | Higher complexity requires stronger rollback and recovery guarantees |
| Observability as a Contract | Added complexity requires corresponding diagnostic evidence |
| Arbitration and Precedence | Tradeoffs resolve through deterministic governance hierarchy |

## Related Documentation

- [Engineering Principles & Standards (Authoritative)](./principles.md)
- [Monolith-first Modulith](./monolith-first-modulith.md)
- [Reversibility](./reversibility.md)
- [Arbitration and Precedence](./arbitration-and-precedence.md)
