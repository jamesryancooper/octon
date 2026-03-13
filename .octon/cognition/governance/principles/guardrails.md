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
This is an umbrella principle: enforcement mechanics are delegated to canonical SSOTs so policy behavior cannot fork across documents.

## Where Enforcement Lives

- Guardrails integrate capability-attempt and promote/finalize controls from SSOT governance documents across design, CI, and runtime.
- For authority boundaries, see [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT): ACP governs promote/finalize authority and Deny by Default governs capability-attempt authority.
- Guardrails block on missing evidence only when that evidence is required by configured policy/validator checks.
- Guardrails do not define independent gate levels, quorum rules, or receipt schemas.

## Mechanism

Operational mechanism is ACP policy gates for durable-state promotion and
deny-by-default policy for capability attempts.

## Canonical References

- Promotion/contraction mechanics: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)
- Waiver/exception taxonomy: [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md)

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

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
- `Arbitration and Precedence` defines tie-break precedence: [Arbitration and Precedence](./arbitration-and-precedence.md).

## Anti-Pattern: Governance Theater

Policies that only warn but never block create a false sense of safety and erode trust.

## Exceptions

Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).
Non-waivable controls remain blocked.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/_meta/architecture/governance-model.md`
- `.octon/cognition/governance/pillars/trust.md`
