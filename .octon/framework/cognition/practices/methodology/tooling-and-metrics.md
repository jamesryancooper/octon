---
title: Tooling and Metrics
description: Provider-agnostic tooling policy and metrics strategy for CI quality, flow health, reliability, and cost governance.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# Tooling and Metrics

This document defines provider-agnostic tooling and measurement defaults for Octon.

## Tooling Policy

- Use repository-hosted CI workflows as the enforcement surface for required checks.
- Keep required checks mapped to `ci-cd-quality-gates.md` and branch protections on `main`.
- Use preview or staging environments for risky changes before production promotion.
- Keep feature-flag hygiene automated through a scheduled workflow or equivalent policy job.
- Do not require vendor-specific commands as normative policy.

## Recommended Workflow Surfaces in This Repository

- `.github/workflows/pr-quality.yml` for required PR gates.
- `.github/workflows/smoke.yml` for smoke validation.
- `.github/workflows/flags-stale-report.yml` for stale-flag hygiene.

Equivalent workflow surfaces are acceptable if they preserve the same governance contract.

## Metrics and Improvement

- Minimal DORA: lead time, deployment frequency, change-fail rate, MTTR.
- Reliability: SLO attainment, error-budget burn, incident recovery time.
- Flow: WIP aging, p50/p90 cycle time, blocked-item rate.
- Cost: AI token usage and infrastructure cost trend with anomaly review.

## CI Health Targets

- Numeric CI health targets are canonical in [ci-cd-quality-gates.md#ci-health-objectives](./ci-cd-quality-gates.md#ci-health-objectives).
- Tracking remains owned here: monitor median and 90th percentile durations and prioritize cache/job/scope corrections when targets miss for two consecutive weeks.

## Metrics-to-Pillar Mapping

| Metric Category | Primary Pillar | Connection |
|-----------------|----------------|------------|
| DORA | [Velocity](../../governance/pillars/velocity.md) | Measures delivery throughput and recovery speed. |
| Reliability | [Trust](../../governance/pillars/trust.md) | Quantifies governed determinism and resilience. |
| Flow health | [Focus](../../governance/pillars/focus.md) | Reveals cognitive load and execution friction. |
| Kaizen outcomes | [Insight](../../governance/pillars/insight.md) | Converts learning loops into measurable change. |
| Cost governance | [Trust](../../governance/pillars/trust.md) | Keeps operations predictable and auditable. |
