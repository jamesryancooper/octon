---
title: Small Diffs, Trunk-based
description: Keep changes tiny, focused, and short-lived to maximize flow, review quality, and rollback safety.
pillar: Velocity, Trust
status: Active
---

# Small Diffs, Trunk-based

> Integrate often with small, single-purpose diffs and short-lived branches.

## What This Means

Harmony treats small-batch delivery as policy, not preference. Changes should be narrowly scoped and merged quickly into trunk.

For material side-effects, "merge quickly" never means bypassing ACP stage/promote sequencing. Fast integration is valid only when required ACP evidence and receipts are present.

Default thresholds:

- Branch lifetime `<= 1 working day`
- PR size `<= 400 changed lines` (excluding generated/lock files)
- One concern per PR

## Why It Matters

### Pillar Alignment: Velocity through Agentic Automation

Small diffs keep CI fast, reviews quick, and automation loops unblocked.

### Pillar Alignment: Trust through Governed Determinism

Smaller change sets reduce blast radius and make regressions easier to isolate and reverse.

### Quality Attributes Promoted

- **Velocity**: faster review/merge cadence.
- **Reliability**: lower defect density per change set.
- **Maintainability**: clearer history and easier blame/debug.
- **Simplicity**: smaller mental model per review.

## In Practice

### ✅ Do

```typescript
// Good: isolated behavioral change
export function normalizePhone(value: string): string {
  return value.replace(/[^\d+]/g, '');
}
```

```python
# Good: single concern PR-level change

def normalize_phone(value: str) -> str:
    return "".join(ch for ch in value if ch.isdigit() or ch == "+")
```

### ❌ Don't

```typescript
// Bad: mixed refactor + feature + migration in one PR
// - renames 30 files
// - adds billing workflow
// - changes auth middleware
// - rewrites tests
```

```python
# Bad: long-lived feature branch habit
if branch_age_days > 1:
    raise RuntimeError("Split work and merge smaller increments")
```

## Relationship to Other Principles

- `Reversibility` depends on small rollback units.
- `Flags by Default` enables shipping incomplete work safely.
- `Autonomous Control Points` stay lightweight when diffs are small and reversible.
- `No Silent Apply` requires evidence/receipt visibility for durable side-effects.

## Anti-Pattern: Big-bang PR

Large, mixed-concern PRs stall reviews, hide risk, and create painful rollback choices.

## Exceptions

Allow larger diffs only for mechanical codemods or generated-file updates, and isolate them from behavioral changes.

Even for small diffs, material side-effects must follow stage -> ACP gate -> promote with receipt emission.

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
Fast trunk flow cannot bypass stage/promote for material side effects.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/methodology/flow-and-wip-policy.md`
- `.harmony/cognition/principles/autonomous-control-points.md`
- `.harmony/cognition/principles/no-silent-apply.md`
- `.harmony/cognition/principles/pillars/velocity.md`
- `.harmony/cognition/principles/pillars/trust.md`
