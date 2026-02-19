---
title: No Silent Apply
description: No durable side-effects without evidence and receipts; ACPs are the canonical enforcement mechanism.
pillar: Trust, Direction
status: Active
---

# No Silent Apply

> No durable side-effects without explicit evidence and append-only receipts.

## What This Means

This principle defines an outcome: material side-effects must never be silent. Durable changes require evidence and receipts that make the decision auditable and reversible.

## Mechanism

Enforcement lives in [Autonomous Control Points](./autonomous-control-points.md). This document intentionally stays narrow to avoid duplicating ACP gate semantics.

Capability attempts still follow [Deny by Default](./deny-by-default.md).

## Minimum Always-Visible Fields

No-silent-apply requires that every promoted change exposes, at minimum:

- receipt identifier and ACP decision metadata
- evidence bundle references
- rollback handle reference
- intent/boundary summary for the promoted scope

Canonical receipt field definitions and completeness requirements live in `autonomous-control-points.md`.

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
No-silent-apply is fulfilled by receipts/evidence/rollback handles, not default human approval.

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

No-silent-apply prevents invisible side-effects and keeps control boundaries explicit.

### Pillar Alignment: Direction through Validated Discovery

ACP policy gating ensures proposed execution stays within intent and risk posture.

### Quality Attributes Promoted

- **Security**: blocks unauthorized changes and privilege misuse.
- **Reliability**: reduces accidental production mutations.
- **Maintainability**: keeps review artifacts explicit and auditable.

## In Practice

### ✅ Do

- Keep agent loops visible (`Plan -> Diff -> Explain -> Test`) before promote.
- Route all durable side-effects through ACP promotion.
- Keep receipt visibility sufficient for post-run audit and rollback.

### ❌ Don't

- Don’t mutate durable state without ACP policy evaluation.
- Don’t treat human approval as the default runtime gate.
- Don’t ship side-effects without evidence and receipts.

## Relationship to Other Principles

- `Autonomous Control Points` is the canonical policy for stage/promote/receipt behavior.
- `Guardrails` enforces fail-closed execution policy.
- `Deny by Default` governs capability attempts before ACP promotion evaluation.
- `Determinism and Provenance` records gate decisions, evidence, and run lineage.

## Anti-Pattern: Invisible Autonomy

When agents can apply changes silently, teams lose accountability and incident diagnosis becomes difficult.

## Exceptions

Read-only automation (analysis, reporting, lint suggestions) can run without promotion gates if no durable side-effects occur.

## Related Documentation

- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/_meta/architecture/governance-model.md`
- `.harmony/cognition/principles/autonomous-control-points.md`
- `.harmony/cognition/principles/deny-by-default.md`
- `.harmony/cognition/principles/pillars/trust.md`
- `.harmony/cognition/principles/pillars/direction.md`
