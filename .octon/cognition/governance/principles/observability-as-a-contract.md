---
title: Observability as a Contract
description: Require telemetry outputs as part of feature completeness so behavior is diagnosable and auditable in production.
pillar: Continuity, Trust, Insight
status: Active
---

# Observability as a Contract

> If behavior changes, telemetry changes with it.

## What This Means

Observability is not optional instrumentation added later. Every
`material_side_effect` must include telemetry that is traceable and sufficient
for diagnosis, receipts, and rollback decisions.

Octon uses risk-tiered telemetry profiles (`minimal`, `sampled`, `full`)
mapped to ACP level, side-effect profile, and run budgets.

Receipt evidence must include at least one representative `trace_id` for changed flows.
If a PR exists, PR evidence is an optional projection that links back to receipt artifacts.

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

Default risk tier to ACP mapping is policy-canonical (`acp.risk_tier_mapping`).
Minimum telemetry requirements by ACP level are canonical in
[RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md#telemetry-profile-gate-canonical)
and enforced in policy at `acp.telemetry_gate`.
This document requires telemetry to remain traceable and receipt-linked; profile-level minima, reason codes, and fail-closed outcomes are matrix/policy SSOT behavior.

If a non-default profile is used, the change receipt must include:
- selected profile
- reason code (for example budget or circuit-breaker constraint)
- policy/receipt reference

This is a policy record, not a standing manual approval gate.
For authority boundaries, see [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT): ACP governs promote/finalize authority and Deny by Default governs capability-attempt authority.
Profile downgrades must be policy-bound and receipted; ad-hoc approval is not sufficient.

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

## Canonical References

- Promotion/contraction and budget envelopes: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)
- Risk tier mapping and promotion evidence minimums: RA/ACP Promotion Inputs Matrix (canonical)
- Shared terminology: [RA/ACP Glossary](../controls/ra-acp-glossary.md)
- Waiver/exception taxonomy: [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md)

## Anti-Pattern: Blind Shipping

Shipping changed behavior without telemetry leaves teams unable to prove correctness or diagnose regressions.

## Exceptions

Low-risk internal scripts may use reduced telemetry, but production paths and shared services may not. Any non-default telemetry profile must be recorded in receipts with a policy reason.

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/_meta/architecture/observability-requirements.md`
- `.octon/cognition/governance/principles/autonomous-control-points.md`
- `.octon/cognition/governance/principles/deny-by-default.md`
- `.octon/cognition/governance/pillars/continuity.md`
- `.octon/cognition/governance/pillars/trust.md`
- `.octon/cognition/governance/pillars/insight.md`
