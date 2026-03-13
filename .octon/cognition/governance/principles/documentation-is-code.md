---
title: Documentation is Code
description: Keep specs, ADRs, contracts, and runbooks versioned with implementation so decisions remain explicit and auditable.
pillar: Direction, Continuity
status: Active
---

# Documentation is Code

> If code changes intent, behavior, contracts, or operations, docs change in
> the same promotable slice.

## What This Means

Specs, ADRs, contracts, and runbooks are first-class engineering artifacts.
They are versioned, reviewed, and traceable like source code.

Octon requires spec-first planning and decision capture for material changes.
For canonical trigger `material_side_effect`, required specs/ADRs/runbooks must exist in the same
promotable slice before ACP promotion to durable state. Docs may be authored
during the run, but cannot be missing at promote time for that promoted slice.

## Why It Matters

### Pillar Alignment: Direction Through Validated Discovery

Direction remains stable when intent, assumptions, and acceptance criteria are
explicit before implementation.

### Pillar Alignment: Continuity Through Institutional Memory

Continuity breaks when rationale and runbooks live only in chats or memory.

### Quality Attributes Promoted

- **Maintainability**: Future contributors can understand intent quickly.
- **Reliability**: Runbooks and ADRs reduce incident response ambiguity.
- **Velocity**: Less rediscovery work during changes and reviews.

## In Practice

### Do

```typescript
/**
 * ADR-0042: Switch to token bucket limiter.
 * Spec: docs/specs/rate-limit/spec.md
 */
export function allowRequest() {
  // ...
}
```

```python
"""
Runbook: docs/runbooks/rate-limit.md
Spec: docs/specs/rate-limit/spec.md
"""

def evaluate_rate_limit(ctx):
    ...
```

### Do Not

```typescript
// Undocumented breaking behavior change
export const DEFAULT_TIMEOUT_MS = 500;
```

```python
# Incident fix shipped without rollback notes or rationale
apply_hotfix_without_runbook = True
```

## Canonical Guidance and Enforcement

- Template guidance:
  `.octon/scaffolding/runtime/templates/documentation-standards.md`
- Template bundle:
  `.octon/scaffolding/runtime/templates/docs/documentation-standards/`
- Operational service guide:
  `.octon/capabilities/runtime/services/authoring/doc/guide.md`
- Enforcement:
  `/audit-documentation-standards` or `/audit-documentation`
- Promotion input minimums and receipt field requirements:
  [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md)
- Shared terminology:
  [RA/ACP Glossary](../controls/ra-acp-glossary.md)

## Promotion-Time Artifact Completeness (SSOT)

This document is the canonical source for documentation artifact timing:
required governance artifacts must be complete before ACP promotion, not before
any staged work begins.

## ACP Fail-Closed Enforcement (Required)

For ACP promotion, missing required governance artifacts MUST fail closed:

- ACP decision MUST be `STAGE_ONLY` or `DENY` (never silent allow)
- receipt MUST include `ACP_DOCS_EVIDENCE_MISSING` and any applicable generic evidence reason codes (for example `ACP_EVIDENCE_MISSING`)
- receipt MUST include missing artifact identifiers for remediation
- durable promotion MUST remain blocked until artifacts are complete

Current enforcement assets:

- workflow command: `/audit-documentation`
  (`.octon/orchestration/runtime/workflows/audit/audit-documentation/README.md`)
- audit command: `/audit-documentation-standards`
  (`.octon/capabilities/runtime/skills/audit/audit-documentation-standards/SKILL.md`)

Live enforcement binding:

- ACP promotion evaluation consumes docs-gate evidence from policy at
  `.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.docs_gate`.
- Missing docs-gate evidence produces reason-coded `STAGE_ONLY` or `DENY`
  outcomes (policy-mapped by ACP level) and emits receipts.
- CI must run governance lint and docs promotion fail-closed contract tests
  before merge:
  `.octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`
  and
  `.octon/cognition/_ops/principles/scripts/test-docs-promotion-fail-closed.sh`.

## Promotable Slice Definition

A promotable slice is the receipt-linked unit evaluated at an ACP promote gate.
For each promoted slice, required docs/spec/ADR/runbook artifacts must be
present and linked to the same promoted scope.

- Promotion authority and receipt semantics: [Autonomous Control Points](./autonomous-control-points.md)
- Contract completeness for promoted slices: [Contract-first](./contract-first.md)
- Slice-size thresholds and flow policy: [Small Diffs, Trunk-based](./small-diffs-trunk-based.md)
- Decomposition pattern for large governance work: [Promotable Slice Decomposition](../controls/promotable-slice-decomposition.md)

## Relationship to Other Principles

- `Contract-first` ties docs to machine-verifiable interfaces.
- `Single Source of Truth` keeps one canonical location per decision.
- `Learn Continuously` uses postmortem artifacts as input.
- `Small Diffs, Trunk-based` applies delivery thresholds per promotable slice.

## Anti-Pattern: Tribal Knowledge

When critical context stays in chat or memory, teams repeat mistakes and slow
as complexity grows.

## Exceptions

Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT).

Very small typo or formatting fixes may skip ADR updates, but not behavior,
contract, schema, or risk changes.

## Related Documentation

- `.octon/cognition/practices/methodology/spec-first-planning.md`
- `.octon/scaffolding/governance/patterns/adr-policy.md`
- `.octon/scaffolding/runtime/templates/documentation-standards.md`
- `.octon/orchestration/runtime/workflows/audit/audit-documentation/README.md`
- `.octon/capabilities/runtime/skills/audit/audit-documentation-standards/SKILL.md`
- `.octon/cognition/governance/pillars/direction.md`
- `.octon/cognition/governance/pillars/continuity.md`
