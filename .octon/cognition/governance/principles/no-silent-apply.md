---
title: No Silent Apply
description: No durable side-effects without evidence and receipts; ACPs are the canonical enforcement mechanism.
pillar: Trust, Direction
status: Active
---

# No Silent Apply

> No durable side-effects without explicit evidence and append-only receipts.

## What This Means

This principle defines an outcome: canonical trigger `material_side_effect`
must never be silent. Durable changes require evidence and receipts that make
the decision auditable and reversible.

## Mechanism

Enforcement lives in [Autonomous Control Points](./autonomous-control-points.md). This document intentionally stays narrow to avoid duplicating ACP gate semantics.
ACP is the single normative source for promotion/finalize mechanics (including `contraction` alias), quorum behavior, and receipt schema rules.
No-silent-apply adds an outcome contract only; it does not define separate gate outcomes or approval workflows.
Operational mechanism is ACP gate evaluation plus receipt emission.
Receipt minimum fields and completeness levels are defined in the RA/ACP promotion inputs matrix (SSOT).

Capability attempts still follow [Deny by Default](./deny-by-default.md).

## Canonical References

- Promotion/contraction mechanics: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)
- Promotion evidence and receipt minimums: [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md)
- Shared terminology: [RA/ACP Glossary](../controls/ra-acp-glossary.md)

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

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
- Don’t treat human authorization as the default runtime gate.
- Don’t ship side-effects without evidence and receipts.

## Relationship to Other Principles

- `Autonomous Control Points` is the canonical policy for stage/promote/receipt behavior.
- `Guardrails` enforces fail-closed execution policy.
- `Deny by Default` governs capability attempts before ACP promotion evaluation.
- `Determinism and Provenance` records gate decisions, evidence, and run lineage.

## Anti-Pattern: Invisible Autonomy

When agents can apply changes silently, teams lose accountability and incident diagnosis becomes difficult.

## Exceptions

Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).

Read-only automation (analysis, reporting, lint suggestions) can run without promotion gates if no durable side-effects occur.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/_meta/architecture/governance-model.md`
- `.octon/cognition/governance/principles/autonomous-control-points.md`
- `.octon/cognition/governance/principles/deny-by-default.md`
- `.octon/cognition/governance/pillars/trust.md`
- `.octon/cognition/governance/pillars/direction.md`
