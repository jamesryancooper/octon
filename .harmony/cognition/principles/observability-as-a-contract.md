---
title: Observability as a Contract
description: Require telemetry outputs as part of feature completeness so behavior is diagnosable and auditable in production.
pillar: Continuity, Trust, Insight
status: Active
---

# Observability as a Contract

> If behavior changes, telemetry changes with it.

## What This Means

Observability is not optional instrumentation added later. Every meaningful behavior change must include telemetry that is traceable and sufficient for diagnosis, receipts, and rollback decisions.

Harmony uses risk-tiered telemetry profiles (`minimal`, `sampled`, `full`) mapped to ACP level, side-effect profile, and run budgets.

PR evidence must include at least one representative `trace_id` for changed flows.

## Why It Matters

### Pillar Alignment: Continuity through Institutional Memory

Telemetry is operational memory. Without it, incidents and decisions cannot be reconstructed.

### Pillar Alignment: Trust through Governed Determinism

Predictable systems require visibility into runtime behavior and failure modes.

### Pillar Alignment: Insight through Structured Learning

Learning loops depend on measurable outcomes, not anecdotes.

### Quality Attributes Promoted

- **Reliability**: faster detection and diagnosis.
- **Maintainability**: clearer operational behavior over time.
- **Scalability**: bottlenecks are observable before failures compound.
- **Security**: suspicious behavior becomes auditable.

## In Practice

### Telemetry Profiles (Risk + Budget Aware)

| Tier | Minimum Signals | Typical ACP Mapping |
|---|---|---|
| `minimal` | Structured event + core metric + representative `trace_id` | ACP-1 low-risk, reversible local loops |
| `sampled` | Tiered spans/logs/metrics with trace correlation and sampling policy | ACP-1/ACP-2 stage runs constrained by budgets or circuit-breakers |
| `full` | Complete spans, structured logs, key metrics, and rollback signals | ACP-2 promote by default; ACP-3 promote with additional safety signals |

Default mapping is policy-driven. ACP-2 promote defaults to `full`, and ACP-3 promote requires `full` plus additional recovery and breaker signals.

If a non-default profile is used, the change receipt must include:
- selected profile
- reason code (for example budget or circuit-breaker constraint)
- policy/receipt reference

This is a policy record, not a standing human approval checkpoint.

### ✅ Do

```typescript
// Good: span + structured event + correlation
const span = tracer.startSpan('checkout.submit', { attributes: { order_id: order.id } });
try {
  logger.info('checkout_submit_start', { orderId: order.id, trace_id: span.spanContext().traceId });
  const result = await checkoutService.submit(order);
  metrics.counter('checkout.submit.success').add(1);
  return result;
} finally {
  span.end();
}
```

```python
# Good: structured logs + trace correlation
with tracer.start_as_current_span("checkout.submit") as span:
    logger.info("checkout_submit_start", extra={"order_id": order_id, "trace_id": format(span.get_span_context().trace_id, '032x')})
    result = service.submit(order_id)
    metrics.counter("checkout.submit.success").add(1)
```

### ❌ Don't

```typescript
// Bad: unstructured, uncorrelated log only
console.log('checkout failed', err);
```

```python
# Bad: no telemetry around critical mutation
service.submit(order_id)  # No span, no metric, no trace linkage
```

## Relationship to Other Principles

- `Documentation is Code` links runbooks/ADRs to observed behavior.
- `Learn Continuously` uses telemetry for root-cause and trend analysis.
- `Guardrails` can fail closed on missing evidence.
- `Autonomous Control Points` defines risk tiers, budgets, and receipt requirements for promote decisions.

## Anti-Pattern: Blind Shipping

Shipping changed behavior without telemetry leaves teams unable to prove correctness or diagnose regressions.

## Exceptions

Low-risk internal scripts may use reduced telemetry, but production paths and shared services may not. Any non-default telemetry profile must be recorded in receipts with a policy reason.

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
Telemetry profile requirements must stay inside ACP budget/circuit envelopes.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/_meta/architecture/observability-requirements.md`
- `.harmony/cognition/principles/autonomous-control-points.md`
- `.harmony/cognition/principles/deny-by-default.md`
- `.harmony/cognition/principles/pillars/continuity.md`
- `.harmony/cognition/principles/pillars/trust.md`
- `.harmony/cognition/principles/pillars/insight.md`
