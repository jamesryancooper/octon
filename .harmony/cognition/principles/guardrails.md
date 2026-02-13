---
title: Guardrails
description: Enforce policy, safety, and evidence gates fail-closed across human and agent workflows.
pillar: Trust
status: Active
---

# Guardrails

> Guardrails are executable constraints that prevent unsafe changes by default.

## What This Means

Guardrails combine policy checks, evaluation thresholds, and security controls at design, CI, and runtime boundaries. If required evidence is missing, the default outcome is block, not proceed.

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
- `HITL Checkpoints` governs where human authorization is required.
- `Security and Privacy Baseline` defines non-waivable controls.

## Anti-Pattern: Governance Theater

Policies that only warn but never block create a false sense of safety and erode trust.

## Exceptions

Temporary waivers require explicit owner, reason, scope, and expiry (`<= 7 days` or merge). Non-waivable controls remain blocked.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/architecture/governance-model.md`
- `.harmony/cognition/principles/pillars/trust.md`
