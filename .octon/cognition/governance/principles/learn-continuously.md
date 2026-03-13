---
title: Learn Continuously
description: Turn outcomes into small, evidence-backed improvements through postmortems, evals, and recurring refinement loops.
pillar: Insight, Continuity
status: Active
---

# Learn Continuously

> Every incident, release, and experiment should improve the next cycle.

## What This Means

Learning is operationalized as a routine loop: capture evidence, identify causes, define small follow-ups, and verify impact. Octon favors many small improvements over rare large process overhauls.

Guidance (non-normative): publish incident postmortems within 48 hours of
mitigation when practical. This timing target is not a fail-closed ACP gate.

## Why It Matters

### Pillar Alignment: Insight through Structured Learning

Insight requires a repeatable mechanism to convert outcomes into better defaults.

### Pillar Alignment: Continuity through Institutional Memory

Learning compounds only when findings are preserved and discoverable.

### Quality Attributes Promoted

- **Velocity**: recurring friction is removed systematically.
- **Maintainability**: repeated failure modes are designed out.
- **Reliability**: incident patterns are addressed at root cause.
- **Scalability**: stronger defaults support growth without chaos.

## In Practice

### ✅ Do

```typescript
// Good: make postmortem action items concrete and testable
const actionItem = {
  issue: 'retry storm on checkout',
  owner: 'platform',
  due: '2026-02-18',
  verification: 'load test shows <=1 retry/request'
};
```

```python
# Good: evidence-backed kaizen tracking
improvement = {
    "metric": "p95_checkout_latency_ms",
    "before": 820,
    "target": 500,
    "owner": "api",
}
```

### ❌ Don't

```typescript
// Bad: vague retro output with no verification
const action = 'be more careful next time';
```

```python
# Bad: incident closed without follow-up execution
postmortem = {"status": "done", "actions": []}
```

## Relationship to Other Principles

- `Observability as a Contract` provides the evidence to learn from.
- `Documentation is Code` preserves decision and incident memory.
- `Small Diffs, Trunk-based` enables fast follow-up improvements.

## Anti-Pattern: Ceremony-only Retrospectives

Running retros without measurable actions produces process theater and no system improvement.

## Exceptions

For trivial incidents with no user impact, use a lightweight note instead of a full postmortem.

## Related Documentation

- `.octon/cognition/practices/methodology/reliability-and-ops.md`
- `.octon/cognition/practices/methodology/tooling-and-metrics.md`
- `.octon/cognition/governance/pillars/insight.md`
- `.octon/cognition/governance/pillars/continuity.md`
