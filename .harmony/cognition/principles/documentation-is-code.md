---
title: Documentation is Code
description: Keep specs, ADRs, and runbooks versioned with implementation so decisions remain explicit and auditable.
pillar: Direction, Continuity
status: Active
---

# Documentation is Code

> If code changes intent, behavior, or operations, the docs change in the same diff.

## What This Means

Specs, ADRs, and operational procedures are first-class engineering artifacts. They are versioned, reviewed, and traceable like code.

Harmony requires spec-first planning and decision capture for material changes.

## Why It Matters

### Pillar Alignment: Direction through Validated Discovery

Direction is preserved when intent, assumptions, and acceptance criteria are explicit before implementation.

### Pillar Alignment: Continuity through Institutional Memory

Continuity fails when rationale and runbooks are left in chat logs or memory.

### Quality Attributes Promoted

- **Maintainability**: future contributors can understand intent quickly.
- **Reliability**: runbooks and ADRs reduce incident response ambiguity.
- **Velocity**: less rediscovery work during changes and reviews.

## In Practice

### ✅ Do

```typescript
// Good: change references design and ADR IDs
/**
 * ADR-0042: switch to token bucket limiter.
 * Spec: docs/specs/2026-02-11-rate-limit.md
 */
export function allowRequest() { /* ... */ }
```

```python
# Good: behavior linked to operational procedure
"""
Runbook: docs/runbooks/rate-limit-rollback.md
Spec: docs/specs/2026-02-11-rate-limit.md
"""
def evaluate_rate_limit(ctx):
    ...
```

### ❌ Don't

```typescript
// Bad: undocumented breaking behavior change
export const DEFAULT_TIMEOUT_MS = 500; // changed from 3000, no ADR/spec update
```

```python
# Bad: incident fix shipped with no rollback notes or rationale
apply_hotfix_without_runbook = True
```

## Relationship to Other Principles

- `Contract-first` ties docs to machine-verifiable interfaces.
- `Single Source of Truth` ensures one canonical location per decision.
- `Learn Continuously` uses postmortem artifacts as input.

## Anti-Pattern: Tribal Knowledge

When critical context stays in chat or memory, teams repeat mistakes and slow down as complexity grows.

## Exceptions

Very small typo/formatting fixes may skip ADR updates, but not behavioral, schema, or risk changes.

## Related Documentation

- `.harmony/cognition/methodology/spec-first-planning.md`
- `.harmony/scaffolding/patterns/adr-policy.md`
- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/principles/pillars/direction.md`
- `.harmony/cognition/principles/pillars/continuity.md`
