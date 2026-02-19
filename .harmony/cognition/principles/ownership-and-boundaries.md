---
title: Ownership and Boundaries
description: Make ownership explicit and enforce architectural boundaries to keep change safe, local, and evolvable.
pillar: Focus, Continuity, Trust
status: Active
---

# Ownership and Boundaries

> Every slice has an owner, and every boundary is enforceable in tooling.

## What This Means

Harmony requires explicit ownership for code surfaces and enforceable module boundaries. Ownership clarifies who attests, who decides, and who reviews. Boundaries prevent accidental coupling and reduce regression spread.

Owner identity should be explicit in repository governance metadata (for example `CODEOWNERS`, service owner records, or designated owning teams).

## Owner Attestation

For boundary exceptions, "owner" means the accountable owner of the impacted
boundary surface (for example a codeowner, service owner, or designated owning
team).

Owner attestation asserts:

- boundary exception reason and requested scope
- exception TTL (time-bound validity)
- rollback plan reference for the affected boundary

Attestation is recorded as a typed evidence item in receipts and must be
hash-bound to the staged artifacts so policy can verify integrity.

Owner attestation is input to ACP quorum when policy requires it; it is not a
separate gating mechanism.

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
Owner attestation is a quorum input and never a standalone promotion gate.

## Why It Matters

### Pillar Alignment: Focus through Absorbed Complexity

Clear boundaries limit cognitive load and localize change reasoning.

### Pillar Alignment: Continuity through Institutional Memory

Ownership metadata keeps operational accountability stable over time.

### Pillar Alignment: Trust through Governed Determinism

Boundaries enforced in CI prevent hidden architecture drift.

### Quality Attributes Promoted

- **Maintainability**: clear review and change responsibility.
- **Scalability**: slices can evolve independently.
- **Reliability**: fewer hidden transitive dependencies.
- **Security**: restricted cross-surface access reduces risk.

## In Practice

### ✅ Do

```typescript
// Good: enforce import boundaries
// eslint rule concept: billing slice cannot import checkout internals
import { CheckoutFacade } from '@slices/checkout/public-api';
```

```python
# Good: explicit package boundary use
from inventory.api import reserve_stock  # public boundary import
# not from inventory.internal.db import reserve
```

### ❌ Don't

```typescript
// Bad: reach-in import bypasses contract boundary
import { mutableState } from '../../checkout/internal/state';
```

```python
# Bad: cross-slice internals import
from billing._private.retries import force_retry_all
```

## Relationship to Other Principles

- `Monolith-first ModuLith` depends on strong internal boundaries.
- `Contract-first` defines stable interfaces across slices.
- `Small Diffs, Trunk-based` works better with local ownership.
- `Autonomous Control Points` governs promotion authority; ownership contributes required attestations when policy demands it.

## Anti-Pattern: Boundary Erosion

Repeated reach-in imports and unclear ownership create fragile coupling that blocks safe iteration.

## Exceptions

Boundary exceptions may require owner attestation and a follow-up task to
restore the boundary.

Promotion authority remains ACP policy gate + required quorum.

## Related Documentation

- `.harmony/cognition/_meta/architecture/repository-blueprint.md`
- `.harmony/cognition/_meta/architecture/governance-model.md`
- `.harmony/cognition/principles/autonomous-control-points.md`
- `.harmony/cognition/principles/deny-by-default.md`
- `.harmony/cognition/principles/pillars/focus.md`
- `.harmony/cognition/principles/pillars/continuity.md`
- `.harmony/cognition/principles/pillars/trust.md`
