# Canonicalization Target Map

## Purpose

List the durable runtime, documentation, governance, and validation surfaces
that should receive the long-lived outputs of this temporary design package.

## Promoted Targets

- `/.harmony/cognition/practices/methodology/architecture-readiness/`
  - durable methodology docs for target classification, scoring dimensions,
    failure-mode analysis, and applicability boundaries
- `/.harmony/capabilities/runtime/skills/audit/audit-architecture-readiness/`
  - primary read-only audit skill for whole-harness and bounded-surface domain
    architecture-readiness evaluations
- `/.harmony/orchestration/runtime/workflows/audit/audit-architecture-readiness/`
  - orchestration workflow for larger-scope runs, optional supplemental audits,
    and consolidated reporting
- `/.harmony/scaffolding/governance/patterns/adr-architecture-readiness-matrix.md`
  - reusable ADR review pattern derived from the package ADR matrix

## Source Material Promotion Map

- `architectural-evaluation-framework.md`
  - promote core invariant and failure-mode methodology into
    `/.harmony/cognition/practices/methodology/architecture-readiness/`
- `architecture-readiness-scorecard.md`
  - promote scoring model into the new audit skill references and methodology
    docs
- `architectural-design-checklist.md`
  - promote quick-check guidance into methodology docs and skill references
- `adr-acceptance-matrix.md`
  - promote into the scaffolding governance pattern target
- `governed-autonomous-engineering-architecture-audit-prompt.md`
  - promote into the new audit skill and orchestration workflow stage assets as
    internal execution guidance

## Independence Rule

Promoted targets must not retain references back to this package. Any contract,
schema, fixture, or operator guidance that a durable target needs must be
materialized inside the live target surface before this package exits.

## Exit Rule

This package is archived in place now that its durable implementation targets
have been established and promoted.
