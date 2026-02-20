---
title: Determinism and Provenance
description: Record enough model and execution context to reproduce AI-assisted outputs and explain how they were produced.
pillar: Trust, Insight, Continuity
status: Active
---

# Determinism and Provenance

> If an AI-assisted output matters, its inputs, model settings, and evidence trail must be reproducible.

## What This Means

Every AI-assisted artifact should carry run metadata: provider, model/version, prompt hash, key parameters, and trace/eval IDs. Deterministic defaults reduce variance; provenance makes remaining variance auditable.

This document is Harmony's single normative source for replay and reproducibility semantics across deterministic execution, idempotent retries, and ACP receipts.

Canonical provenance schema pointer:
`.harmony/capabilities/_ops/policy/acp-provenance-fields.schema.json`.

## SSOT: Replay and Reproducibility Contract

For any materially relevant run, record:

- input identity (prompt/version hash, context hash, plan or diff hash)
- execution identity (run ID, operation ID, step ID, actor/profile, deterministic or bounded variance mode)
- decision identity (ACP decision outcome: `ALLOW`, `STAGE_ONLY`, `DENY`, `ESCALATE`)
- evidence identity (trace/eval IDs, evidence bundle refs, receipt ID, rollback handle ref where applicable)

Governance-trigger semantics for evidence/receipt enforcement are keyed on
canonical predicate `material_side_effect` (see
[RA/ACP Glossary](./_meta/ra-acp-glossary.md)).

Bounded variance is valid only when policy-approved and receipted. Deterministic mode remains the default.

## Normative Boundary Matrix

| Requirement class | Normative owner |
|---|---|
| Required provenance and receipt replay fields | This document |
| Runtime variance posture (deterministic vs bounded variance) | [Governed Determinism](./determinism.md) |
| Promotion/contraction gate outcomes and ACP levels | [Autonomous Control Points](./autonomous-control-points.md) |
| Capability-attempt authorization | [Deny by Default](./deny-by-default.md) |

Terminology for apply/promote/finalize and approval/attestation/quorum is
defined in [RA/ACP Glossary](./_meta/ra-acp-glossary.md).

## Normative Boundary

This document is normative for required replay and provenance fields in
RA/ACP receipts. RA = Reversible Autonomy with Human-on-the-Loop Oversight,
governed via ACP gates.
It does not define promotion/contraction gate outcomes or quorum policy.

- Receipt/gate mechanics are defined in [Autonomous Control Points](./autonomous-control-points.md).
- Runtime variance posture is defined in [Governed Determinism](./determinism.md).

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

Reproducibility is required for confidence in AI-generated changes.

### Pillar Alignment: Insight through Structured Learning

Comparing runs over time requires stable metadata and traceable inputs.

### Pillar Alignment: Continuity through Institutional Memory

Provenance records preserve how decisions were generated and validated.

### Quality Attributes Promoted

- **Reliability**: reproducible behavior under repeated runs.
- **Security**: auditable lineage for compliance and incident review.
- **Maintainability**: easier debugging and model-change impact analysis.

## In Practice

### ✅ Do

```typescript
// Good: persist model and prompt provenance
await audit.write({
  trace_id,
  provider: 'anthropic',
  model: 'claude-sonnet-4-20250514',
  prompt_hash,
  temperature: 0.2,
  eval_run_id
});
```

```python
# Good: explicit run record
record = {
    "trace_id": trace_id,
    "provider": "openai",
    "model": "gpt-5.1",
    "prompt_hash": prompt_hash,
    "temperature": 0.2,
}
store_run_record(record)
```

### ❌ Don't

```typescript
// Bad: no model version, no prompt hash
await llm.complete(prompt);
```

```python
# Bad: mutable defaults and no audit trail
result = client.generate(prompt, model="latest")
```

## Relationship to Other Principles

- `Governed Determinism` controls runtime variance.
- `Autonomous Control Points` defines policy decisions; this principle defines the provenance fields required to reproduce those decisions.
- `Observability as a Contract` links run metadata to traces.

## Anti-Pattern: Opaque AI Execution

Without provenance, failures are non-reproducible and compliance review becomes guesswork.

## Exceptions

Waiver/exception semantics are canonical in [Waivers and Exceptions](./_meta/waivers-and-exceptions.md).

Exploratory local prompts may skip full records, but production-impacting outputs may not.

## Related Documentation

- `.harmony/cognition/principles/autonomous-control-points.md`
- `.harmony/cognition/principles/idempotency.md`
- `.harmony/cognition/principles/determinism.md`
- `.harmony/cognition/methodology/README.md`
- `.harmony/capabilities/services/_meta/docs/platform-overview.md`
- `.harmony/cognition/pillars/trust.md`
- `.harmony/cognition/pillars/insight.md`
- `.harmony/cognition/pillars/continuity.md`
