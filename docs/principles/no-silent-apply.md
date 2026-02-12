---
title: No Silent Apply
description: Agents propose plans, diffs, and tests, while humans approve material side-effects.
pillar: Trust, Direction
status: Active
---

# No Silent Apply

> Agent autonomy ends where material side-effects begin.

## What This Means

Harmony agent loops default to Plan -> Diff -> Explain -> Test. Applying material side-effects (writes, merges, deploys, production mutations) requires human approval at defined checkpoints.

Local runs should default to `--dry-run` unless explicitly approved.

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

No-silent-apply prevents invisible side-effects and keeps control boundaries explicit.

### Pillar Alignment: Direction through Validated Discovery

Human gating ensures proposed execution still aligns with user intent and risk posture.

### Quality Attributes Promoted

- **Security**: blocks unauthorized changes and privilege misuse.
- **Reliability**: reduces accidental production mutations.
- **Maintainability**: keeps review artifacts explicit and auditable.

## In Practice

### ✅ Do

```typescript
// Good: dry-run by default
await runner.execute({ plan, dryRun: true });
await approvals.require('apply_changes', { risk: 'medium', diffSummary });
await runner.apply(plan);
```

```python
# Good: explicit approval gate before side-effect
result = agent.run(plan=plan, dry_run=True)
if approval_service.granted("apply_changes", payload={"risk": "high"}):
    agent.run(plan=plan, dry_run=False)
```

### ❌ Don't

```typescript
// Bad: direct mutation without checkpoint
await agent.editFiles(changes);
await git.push('origin', 'main');
```

```python
# Bad: auto-merge bot bypasses review
if tests_green:
    github.merge(pr_number)
```

## Relationship to Other Principles

- `HITL Checkpoints` defines where approvals are required.
- `Guardrails` enforces fail-closed execution policy.
- `Determinism and Provenance` records approval context and run lineage.

## Anti-Pattern: Invisible Autonomy

When agents can apply changes silently, teams lose accountability and incident diagnosis becomes difficult.

## Exceptions

Low-risk read-only automation (analysis, reporting, lint suggestions) can run without approval if no side-effects occur.

## Related Documentation

- `docs/methodology/README.md`
- `docs/architecture/governance-model.md`
- `docs/pillars/trust.md`
- `docs/pillars/direction.md`
