---
title: Guardrails
description: Enforce policy, safety, and evidence gates fail-closed across human and agent workflows.
pillar: Trust
status: Active
---

# Guardrails

> Guardrails are executable constraints that prevent unsafe changes by default.

## What This Means

Guardrails combine policy checks, evaluation thresholds, and security controls at design, CI, and runtime boundaries. They enforce shared policy engines fail-closed; they do not define a separate promotion gate model.

## Where Enforcement Lives

- Capability attempts are enforced by [Deny by Default](./deny-by-default.md).
- Promotion/contraction to durable state is enforced by [Autonomous Control Points](./autonomous-control-points.md).
- Guardrails integrate these controls across design, CI, and runtime and block on missing required evidence.

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
Guardrails enforce fail-closed behavior through ACP and deny-by-default policies.

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

Trust is sustained when safety rules are consistently enforced and cannot be bypassed silently.

### Quality Attributes Promoted

- **Security**: unsafe behavior is blocked before release.
- **Reliability**: known risk patterns are intercepted early.
- **Maintainability**: policy logic is centralized and explicit.
- **Simplicity**: deterministic pass/fail outcomes reduce ambiguity.

## In Practice

### ✅ Do

```typescript
// Good: fail-closed policy gate
const policyResult = await policyEngine.evaluate(changeSet);
if (!policyResult.passed) {
  throw new Error(`Policy gate failed: ${policyResult.reason}`);
}
```

```python
# Good: required evidence gate
required = ["trace_id", "risk_rubric", "rollback_plan"]
missing = [k for k in required if k not in pr_metadata]
if missing:
    raise RuntimeError(f"Block merge: missing evidence {missing}")
```

### ❌ Don't

```typescript
// Bad: advisory-only policy with silent continue
if (!policyResult.passed) {
  console.warn('policy failed, proceeding anyway');
}
```

```python
# Bad: manual override with no scope/timebox
if engineer_says_ok:
    merge()
```

## Relationship to Other Principles

- `Deny by Default` is the permission model foundation.
- `Autonomous Control Points` governs stage/promote/finalize authorization through policy.
- `Security and Privacy Baseline` defines non-waivable controls.
- `Harmony Principles` defines tie-break precedence for conflicts: [Arbitration & Precedence](./README.md#arbitration--precedence).

## Anti-Pattern: Governance Theater

Policies that only warn but never block create a false sense of safety and erode trust.

## Exceptions

Temporary waivers require explicit owner, reason, scope, and expiry (`<= 7 days` or merge). Non-waivable controls remain blocked.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/_meta/architecture/governance-model.md`
- `.harmony/cognition/principles/pillars/trust.md`
