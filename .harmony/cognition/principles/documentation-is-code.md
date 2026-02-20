---
title: Documentation is Code
description: Keep specs, ADRs, contracts, and runbooks versioned with implementation so decisions remain explicit and auditable.
pillar: Direction, Continuity
status: Active
---

# Documentation is Code

> If code changes intent, behavior, contracts, or operations, docs change in
> the same diff.

## What This Means

Specs, ADRs, contracts, and runbooks are first-class engineering artifacts.
They are versioned, reviewed, and traceable like source code.

Harmony requires spec-first planning and decision capture for material changes.
For material side-effects, required specs/ADRs/runbooks must exist in the same
changeset before ACP promotion to durable state. Docs may be authored during the
run, but cannot be missing at promote time.

## Why It Matters

### Pillar Alignment: Direction Through Validated Discovery

Direction remains stable when intent, assumptions, and acceptance criteria are
explicit before implementation.

### Pillar Alignment: Continuity Through Institutional Memory

Continuity breaks when rationale and runbooks live only in chats or memory.

### Quality Attributes Promoted

- **Maintainability**: Future contributors can understand intent quickly.
- **Reliability**: Runbooks and ADRs reduce incident response ambiguity.
- **Velocity**: Less rediscovery work during changes and reviews.

## In Practice

### Do

```typescript
/**
 * ADR-0042: Switch to token bucket limiter.
 * Spec: docs/specs/rate-limit/spec.md
 */
export function allowRequest() {
  // ...
}
```

```python
"""
Runbook: docs/runbooks/rate-limit.md
Spec: docs/specs/rate-limit/spec.md
"""

def evaluate_rate_limit(ctx):
    ...
```

### Do Not

```typescript
// Undocumented breaking behavior change
export const DEFAULT_TIMEOUT_MS = 500;
```

```python
# Incident fix shipped without rollback notes or rationale
apply_hotfix_without_runbook = True
```

## Canonical Guidance and Enforcement

- Template guidance:
  `.harmony/scaffolding/templates/documentation-standards.md`
- Template bundle:
  `.harmony/scaffolding/templates/docs/documentation-standards/`
- Operational service guide:
  `.harmony/capabilities/services/authoring/doc/guide.md`
- Enforcement:
  `/audit-documentation-standards` or `/documentation-quality-gate`

## Promotion-Time Artifact Completeness (SSOT)

This document is the canonical source for documentation artifact timing:
required governance artifacts must be complete before ACP promotion, not before
any staged work begins.

## Relationship to Other Principles

- `Contract-first` ties docs to machine-verifiable interfaces.
- `Single Source of Truth` keeps one canonical location per decision.
- `Learn Continuously` uses postmortem artifacts as input.

## Anti-Pattern: Tribal Knowledge

When critical context stays in chat or memory, teams repeat mistakes and slow
as complexity grows.

## Exceptions

Very small typo or formatting fixes may skip ADR updates, but not behavior,
contract, schema, or risk changes.

## Related Documentation

- `.harmony/cognition/methodology/spec-first-planning.md`
- `.harmony/scaffolding/patterns/adr-policy.md`
- `.harmony/scaffolding/templates/documentation-standards.md`
- `.harmony/cognition/principles/pillars/direction.md`
- `.harmony/cognition/principles/pillars/continuity.md`
