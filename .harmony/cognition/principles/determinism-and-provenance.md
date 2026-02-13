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
- `No Silent Apply` pairs provenance with approval decisions.
- `Observability as a Contract` links run metadata to traces.

## Anti-Pattern: Opaque AI Execution

Without provenance, failures are non-reproducible and compliance review becomes guesswork.

## Exceptions

Exploratory local prompts may skip full records, but production-impacting outputs may not.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `docs/services/README.md`
- `.harmony/cognition/principles/pillars/trust.md`
- `.harmony/cognition/principles/pillars/insight.md`
- `.harmony/cognition/principles/pillars/continuity.md`
