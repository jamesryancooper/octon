---
title: Idempotency
description: Ensure mutating operations can be retried safely without duplicating side effects.
pillar: Trust, Velocity
status: Active
---

# Idempotency

> A retry should produce the same final state as a single successful request.

## What This Means

Externally retriable mutating interfaces (APIs, jobs, webhooks, and kit calls) must accept an `idempotency_key` and return the same canonical result when replayed. This is required for reliable retries, agent restarts, and network-failure recovery.

## Equivalent Replay Keys

For internal mutation transitions, an equivalent stable replay identifier is allowed when `idempotency_key` is not the native interface field.
Accepted examples: `operation_id`, `receipt_id`, or `run_id + step_id`.
Replay-key semantics must remain reproducible and auditable per [Determinism and Provenance](./determinism-and-provenance.md).

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

Idempotency prevents duplicate mutations during partial failures and retries.

### Pillar Alignment: Velocity through Agentic Automation

Automation can retry aggressively only when retries are safe.

### Quality Attributes Promoted

- **Reliability**: duplicate side-effects are eliminated.
- **Scalability**: retry-heavy distributed workflows remain stable.
- **Security**: replay behavior is controlled and auditable.
- **Velocity**: fewer manual interventions during transient failures.

## In Practice

### ✅ Do

```typescript
// Good: dedupe on idempotency key
export async function createPayment(req: PaymentRequest, key: string) {
  const existing = await payments.byIdempotencyKey(key);
  if (existing) return existing.response;

  const response = await processor.charge(req);
  await payments.save({ key, response });
  return response;
}
```

```python
# Good: atomic idempotency record

def create_payment(req: dict, idem_key: str) -> dict:
    cached = repo.get_by_idempotency_key(idem_key)
    if cached:
        return cached
    result = charge(req)
    repo.store_idempotency_result(idem_key, result)
    return result
```

### ❌ Don't

```typescript
// Bad: same request can double-charge on retry
await processor.charge(req);
```

```python
# Bad: best-effort dedupe without durable storage
if idem_key in in_memory_cache:
    return in_memory_cache[idem_key]
# process restart loses cache and replays mutation
```

## Relationship to Other Principles

- `Determinism and Provenance` records replay context.
- `Reversibility` handles failures beyond retry safety.
- `Guardrails` enforces idempotency requirements in CI/policy.

## Anti-Pattern: Retry-unsafe Mutation

When retries trigger new side-effects, incidents compound under load and recovery automation becomes dangerous.

## Exceptions

Pure read operations do not require idempotency keys.

## Related Documentation

- `.harmony/scaffolding/patterns/api-design-guidelines.md`
- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/principles/pillars/trust.md`
- `.harmony/cognition/principles/pillars/velocity.md`
