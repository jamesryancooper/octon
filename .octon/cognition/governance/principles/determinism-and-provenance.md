---
title: Determinism and Provenance
description: Record enough model and execution context to reproduce AI-assisted outputs and explain how they were produced.
pillar: Trust, Insight, Continuity
status: Active
---

# Determinism and Provenance

> If an AI-assisted output matters, its inputs, model settings, and evidence trail must be reproducible.

## What This Means

For ACP promotion-relevant outputs and any `material_side_effect` runs, artifacts MUST carry run metadata: provider, model/version, prompt hash, key parameters, and trace/eval IDs. Exploratory local drafts MAY use reduced records. Deterministic defaults reduce variance; provenance makes remaining variance auditable.

This document is Octon's single normative source for replay and reproducibility semantics across deterministic execution, idempotent retries, and ACP receipts.

Canonical provenance schema pointer:
`.octon/capabilities/governance/policy/acp-provenance-fields.schema.json`.

## SSOT: Replay and Reproducibility Contract

For any materially relevant run, record:

- input identity (prompt/version hash, context hash, plan or diff hash)
- execution identity (run ID, operation ID, step ID, actor/profile, deterministic or bounded variance mode)
- decision identity (ACP decision outcome: `ALLOW`, `STAGE_ONLY`, `DENY`, `ESCALATE`)
- evidence identity (trace/eval IDs, evidence bundle refs, receipt ID, rollback handle ref where applicable)

For `material_side_effect` runs and ACP promotion decisions, these fields are required.

Governance-trigger semantics for evidence/receipt enforcement are keyed on
canonical predicate `material_side_effect` (see
[RA/ACP Glossary](../controls/ra-acp-glossary.md)).

Bounded variance is valid only when policy-approved and receipted. Deterministic mode remains the default.

## Normative Boundary

This document is normative for required provenance and replay fields only.
Runtime posture is defined in [Governed Determinism](./determinism.md), gate outcomes in [Autonomous Control Points](./autonomous-control-points.md), and capability authority in [Deny by Default](./deny-by-default.md).
Terminology for apply/promote/finalize (including `contraction` alias) and approval/attestation/quorum is defined in [RA/ACP Glossary](../controls/ra-acp-glossary.md).

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

Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).

Exploratory local prompts may skip full records, but production-impacting outputs may not.

## Related Documentation

- `.octon/cognition/governance/principles/autonomous-control-points.md`
- `.octon/cognition/governance/principles/idempotency.md`
- `.octon/cognition/governance/principles/determinism.md`
- `.octon/cognition/practices/methodology/README.md`
- `.octon/capabilities/runtime/services/_meta/docs/platform-overview.md`
- `.octon/cognition/governance/pillars/trust.md`
- `.octon/cognition/governance/pillars/insight.md`
- `.octon/cognition/governance/pillars/continuity.md`
