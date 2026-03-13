---
title: Security and Privacy Baseline
description: Apply least privilege, fail-closed controls, and data minimization as default behavior across all environments.
pillar: Trust
status: Active
---

# Security and Privacy Baseline

> Secure and privacy-preserving behavior is the default path, not an opt-in enhancement.

## What This Means

Every change must preserve least-privilege access, secret hygiene, explicit input validation, and data minimization. PII/PHI is redacted at log/write boundaries and secrets never leave trusted secret stores.

Security and privacy requirements are mandatory release criteria.
Least privilege and fail-closed behavior are non-waivable controls.

Non-waivable control classes:
1. fail-closed authorization checks for privileged actions
2. least-privilege default capability posture
3. receipt emission and auditability for durable `material_side_effect` decisions
4. explicit break-glass controls for irreversible ACP-4 operations

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

Trust depends on safety boundaries that hold under stress, retries, and agent automation.

### Quality Attributes Promoted

- **Security**: fewer exploitable paths and stronger containment.
- **Reliability**: controlled failures instead of undefined behavior.
- **Maintainability**: standardized controls reduce ad-hoc security patches.

## In Practice

### ✅ Do

```typescript
// Good: explicit authorization + redaction
if (!authz.can(user, 'orders:read')) {
  throw new ForbiddenError();
}
logger.info('order_fetched', {
  orderId,
  customerEmail: '[REDACTED]'
});
```

```python
# Good: fail-closed validation and secret handling
api_key = os.environ["PAYMENT_API_KEY"]  # from secret store injection

if not has_scope(actor, "payments:charge"):
    raise PermissionError("forbidden")

safe_payload = {"amount": payload["amount"], "email": "[REDACTED]"}
logger.info("charge_attempt", extra=safe_payload)
```

### ❌ Don't

```typescript
// Bad: implicit allow with fallback
if (user.role !== 'admin') {
  // allow for now, tighten later
}
```

```python
# Bad: sensitive data in logs
logger.info("charge_attempt", extra={"card": card_number, "ssn": ssn})
```

## Relationship to Other Principles

- `Deny by Default` enforces permission baseline.
- `Guardrails` operationalize policy gates.
- `Observability as a Contract` adds auditable security evidence.

## Anti-Pattern: Security-by-Waiver

Treating security controls as optional for speed creates hidden risk that later blocks delivery and trust.

## Exceptions

No exceptions for secret exposure or unredacted PII/PHI.
Temporary exceptions for low-risk controls must exclude the non-waivable classes above.
Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).
Waivers must be policy-bound, receipted, and never used to bypass non-waivable controls.

## Related Documentation

- `.octon/cognition/practices/methodology/security-baseline.md`
- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/_meta/architecture/governance-model.md`
- `.octon/cognition/governance/pillars/trust.md`
