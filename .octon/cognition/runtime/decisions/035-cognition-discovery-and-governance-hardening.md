---
id: 035
title: "ADR-035: Cognition Discovery and Governance Hardening"
status: accepted
date: 2026-02-21
---

# ADR-035: Cognition Discovery and Governance Hardening

## Context

The cognition domain has strong bounded surfaces but still carries scale risks:

- duplicate numeric ADR identity in the decisions record set,
- uneven machine-discoverability outside runtime indexes,
- limited semantic guardrails for some drift-sensitive cognition surfaces,
- heavyweight docs that increase agent traversal cost.

## Decision

Adopt a clean-break hardening migration that:

1. Enforces unique numeric ADR identity and filename/index consistency.
2. Adds machine-readable discovery indexes for governance and practices surfaces.
3. Adds section-level indexes for heavyweight cognition docs to improve targeted loading.
4. Expands cognition drift guardrails and alignment checks.
5. Promotes metrics scorecard from draft to operational contract.

## Consequences

### Positive

- Reduced ambiguity in decision discovery and traceability.
- Better agent performance and discoverability for cognition governance/practices docs.
- Stronger fail-closed checks against structural and semantic drift.
- Clearer long-term maintainability posture for cognition evolution.

### Tradeoffs

- Additional index files and validation checks increase maintenance overhead.
- Existing docs now have explicit index contracts that must be kept in sync.

## Evidence

- Migration plan: `/.octon/cognition/runtime/migrations/2026-02-21-cognition-discovery-and-governance-hardening/plan.md`
- Migration bundle: `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/`
