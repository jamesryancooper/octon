---
title: Ownership and Boundaries
description: Make ownership explicit and enforce architectural boundaries to keep change safe, local, and evolvable.
pillar: Focus, Continuity, Trust
status: Active
---

# Ownership and Boundaries

> Every slice has an owner, and every boundary is enforceable in tooling.

## What This Means

Harmony requires explicit ownership for code surfaces and enforceable module boundaries. Ownership clarifies who decides and who reviews. Boundaries prevent accidental coupling and reduce regression spread.

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

## Anti-Pattern: Boundary Erosion

Repeated reach-in imports and unclear ownership create fragile coupling that blocks safe iteration.

## Exceptions

Boundary exceptions require explicit owner approval and a follow-up task to restore the boundary.

## Related Documentation

- `docs/architecture/repository-blueprint.md`
- `docs/architecture/governance-model.md`
- `docs/pillars/focus.md`
- `docs/pillars/continuity.md`
- `docs/pillars/trust.md`
