---
title: Flags by Default
description: Separate deploy from release by gating risky behavior behind server-evaluated feature flags.
pillar: Velocity, Trust
status: Active
---

# Flags by Default

> Deploy safely anytime; release intentionally through flags.

## What This Means

Risky or user-visible behavior should be wrapped in server-evaluated flags so deploys remain reversible and progressive rollout is possible.

Flag hygiene is enforced by canonical contract and validator:
`flag_id`, `owner`, `created`, `expires`, `cleanup_by`, `default`, `description`,
`risk`, and `links` are required for each flag.

Canonical sources:
- [Flag Metadata Contract](../controls/flag-metadata-contract.md)
- `.octon/capabilities/governance/policy/flags.metadata.json`
- `.octon/capabilities/_ops/scripts/validate-flag-metadata.sh`

Validator execution is required in local and CI governance checks via
`.octon/capabilities/_ops/scripts/validate-deny-by-default.sh`.

ACP promotion for operations that modify flags must include `flags.metadata`
evidence and valid metadata checks, or fail closed per policy.

## Why It Matters

### Pillar Alignment: Velocity through Agentic Automation

Flags allow continuous deployment without waiting for full rollout confidence.

### Pillar Alignment: Trust through Governed Determinism

Flags provide controlled blast radius and immediate disable paths.

### Quality Attributes Promoted

- **Velocity**: release decoupled from deployment.
- **Reliability**: rollback via toggle, not emergency patch.
- **Security**: risky behavior can be disabled instantly.
- **Simplicity**: clear runtime gate instead of ad-hoc hotfixes.

## In Practice

### ✅ Do

```typescript
// Good: server-side flag guard
export async function getCheckoutFlow(userId: string) {
  const enabled = await flags.isEnabled('checkout_v2', { userId });
  return enabled ? checkoutV2() : checkoutV1();
}
```

```python
# Good: explicit default-off flag

def recommend_products(user_id: str) -> list[str]:
    if not flag_client.enabled("recommendation_v2", actor=user_id):
        return recommend_v1(user_id)
    return recommend_v2(user_id)
```

### ❌ Don't

```typescript
// Bad: client-only gate for security-sensitive behavior
if (window.localStorage.getItem('beta') === 'on') {
  enableNewPayments();
}
```

```python
# Bad: stale flag remains forever
if flags.enabled("legacy_cleanup_never"):
    run_old_path()  # No owner, no expiry, no removal plan
```

## Relationship to Other Principles

- `Reversibility` relies on fast disablement paths.
- `Small Diffs, Trunk-based` uses flags to keep changes mergeable.
- `Guardrails` enforce ownership and expiry policy for flags.

## Anti-Pattern: Permanent Flag Debt

Flags left in place after rollout create dead branches, confusion, and inconsistent runtime behavior.

## Exceptions

Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).

Skip flags for internal refactors with no behavior change and no user impact.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/practices/methodology/sandbox-flow.md`
- `.octon/cognition/governance/pillars/velocity.md`
- `.octon/cognition/governance/pillars/trust.md`
