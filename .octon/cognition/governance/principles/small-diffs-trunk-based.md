---
title: Small Diffs, Trunk-based
description: Keep changes tiny, focused, and short-lived to maximize flow, review quality, and rollback safety.
pillar: Velocity, Trust
status: Active
---

# Small Diffs, Trunk-based

> Integrate often with small, single-purpose diffs and short-lived branches.

## What This Means

Octon treats small-batch delivery as default guidance for flow and review quality. Changes should be narrowly scoped and merged quickly into trunk.

For material side-effects, fast merges are encouraged only after ACP promote requirements (evidence + receipts) are satisfied. "Merge quickly" never bypasses ACP stage/promote sequencing.

Default thresholds (review-quality guidance, not ACP hard gates):

- Branch lifetime `<= 1 working day`
- PR size `<= 400 changed lines` (excluding generated/lock files)
- One concern per PR

Thresholds apply per promotable slice (receipt-linked unit), not mission wall-clock duration. Long autonomous runs may contain multiple staged slices; each promoted slice should remain small and single-purpose.
Promotable-slice semantics are defined in [Documentation is Code](./documentation-is-code.md#promotable-slice-definition).
For non-PR promote paths, the same small-slice guidance applies to receipt-linked
promotions and decomposition planning.
Canonical decomposition workflow is defined in
[Promotable Slice Decomposition](../controls/promotable-slice-decomposition.md).

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
- `Documentation is Code` defines promotable-slice artifact completeness at promotion time.

## Canonical References

- For authority boundaries, see [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT): ACP governs promote/finalize authority and Deny by Default governs capability-attempt authority.
- Promotion/contraction mechanics: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)

## Anti-Pattern: Big-bang PR

Large, mixed-concern PRs stall reviews, hide risk, and create painful rollback choices.

## Exceptions

Allow larger diffs only for mechanical codemods or generated-file updates, and isolate them from behavioral changes.

Even for small diffs, material side-effects must follow stage -> ACP gate -> promote with receipt emission.

Stage-only flows may exceed these advisory thresholds when decomposition and risk
rationale are documented and promoted slices remain small.
Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/practices/methodology/flow-and-wip-policy.md`
- `.octon/cognition/governance/principles/autonomous-control-points.md`
- `.octon/cognition/governance/principles/no-silent-apply.md`
- `.octon/cognition/governance/pillars/velocity.md`
- `.octon/cognition/governance/pillars/trust.md`
