---
title: Ownership and Boundaries
description: Make ownership explicit and enforce architectural boundaries to keep change safe, local, and evolvable.
pillar: Focus, Continuity, Trust
status: Active
---

# Ownership and Boundaries

> Every slice has an owner, and every boundary is enforceable in tooling.

## What This Means

Octon requires explicit ownership for code surfaces and enforceable module boundaries. Ownership clarifies who attests, who decides, and who reviews. Boundaries prevent accidental coupling and reduce regression spread.

Owner identity should be explicit in repository governance metadata (for example `CODEOWNERS`, service owner records, or designated owning teams).

## Owner Attestation

For boundary exceptions, "owner" means the accountable owner of the impacted
boundary surface (for example a codeowner, service owner, or designated owning
team).

Owner attestation asserts:

- boundary exception reason and requested scope
- exception TTL (time-bound validity)
- rollback plan reference for the affected boundary

Deterministic owner-signal precedence (canonical):
1. ownership registry declarations under `.octon/` (authoritative, portable)
2. repository-native metadata (for example `CODEOWNERS`) as optional projection
3. external systems as non-authoritative hints

Owner attestation is policy-scoped:

- required only for boundary exceptions and ACP-2/ACP-3 categories when policy says so
- not required for routine ACP-1 promotions

Attestation is recorded as a typed evidence item in receipts and must be
hash-bound to the staged artifacts so policy can verify integrity.

Owner attestation is input to ACP quorum when policy requires it; it is not a
separate gating mechanism.
If required attestation is missing, runtime behavior is deterministic and bounded:

- immediate decision: `STAGE_ONLY` with `ACP_OWNER_ATTESTATION_MISSING`
- bounded retry policy: policy-defined attempts/backoff and timeout window
- exhausted window: policy may return `ESCALATE` with
  `ACP_OWNER_ATTESTATION_TIMEOUT`
- no indefinite waiting and no standalone human gate

This precedence ensures deterministic behavior even when optional metadata
sources are unavailable.

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

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

## Canonical References

- Promotion/contraction and quorum mechanics: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)
- Promotion evidence/receipt minimums: [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md)
- Shared terminology: [RA/ACP Glossary](../controls/ra-acp-glossary.md)

## Anti-Pattern: Boundary Erosion

Repeated reach-in imports and unclear ownership create fragile coupling that blocks safe iteration.

## Exceptions

Boundary exceptions may require owner attestation and a follow-up task to
restore the boundary.

Promotion authority remains ACP policy gate + required quorum.

## Related Documentation

- `.octon/cognition/_meta/architecture/repository-blueprint.md`
- `.octon/cognition/_meta/architecture/governance-model.md`
- `.octon/cognition/governance/principles/autonomous-control-points.md`
- `.octon/cognition/governance/principles/deny-by-default.md`
- `.octon/cognition/governance/pillars/focus.md`
- `.octon/cognition/governance/pillars/continuity.md`
- `.octon/cognition/governance/pillars/trust.md`
