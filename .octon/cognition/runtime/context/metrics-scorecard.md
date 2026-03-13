---
title: Octon Scorecard and Metrics
description: Operational scorecard contract for flow, reliability, quality, observability, security, and documentation hygiene.
---

# Octon Scorecard and Metrics

Status: Active contract

## Purpose

Define the minimum operational scorecard that keeps Octon delivery fast,
safe, and continuously improvable without introducing dashboard sprawl.

## Operating Contract

- Cadence: weekly digest generated every Monday.
- Digest location: `/.octon/cognition/runtime/evaluations/digests/` and registered in `/.octon/cognition/runtime/evaluations/digests/index.yml`.
- Action ledger location: `/.octon/cognition/runtime/evaluations/actions/open-actions.yml`.
- Review: weekly 15-minute review; select 1-2 actions with explicit owners.
- Sources: CI artifacts, ObservaKit telemetry, and Knowledge Plane traces.
- Data handling: deterministic aggregation only; no manual edits in score data.

## Ownership

| Metric Area | Owner | Backup | Review Cadence |
|---|---|---|---|
| Flow (DORA) | `architect` | `implementer` | Weekly |
| Reliability (SLO burn) | `verifier` | `architect` | Weekly |
| Quality (tests/contracts) | `implementer` | `verifier` | Weekly |
| Observability (trace coverage) | `verifier` | `architect` | Weekly |
| Security (critical exposure) | `architect` | `verifier` | Weekly |
| Hygiene (docs/waivers) | `architect` | `implementer` | Weekly |

## Scorecard Thresholds

| Category | Metric | Target (Green) | Warning (Yellow) | Breach (Red) |
|---|---|---|---|---|
| Flow | Lead time (p75) | <= 3 days | > 3 and <= 7 days | > 7 days |
| Flow | Deploy frequency | >= 3/week | 1-2/week | < 1/week |
| Flow | Change failure rate | <= 15% | > 15% and <= 25% | > 25% |
| Flow | MTTR | <= 4 hours | > 4 and <= 24 hours | > 24 hours |
| Reliability | Error budget burn (7d) | <= 50% | > 50% and <= 100% | > 100% |
| Reliability | p95 latency SLO miss | <= 1% requests | > 1% and <= 3% | > 3% |
| Quality | Contract drift findings | 0 | 1 | >= 2 |
| Quality | Test flake rate | <= 2% | > 2% and <= 5% | > 5% |
| Observability | Requests with trace_id | >= 98% | >= 95% and < 98% | < 95% |
| Observability | KP correlation coverage | >= 95% | >= 90% and < 95% | < 90% |
| Security | Open critical vulns > 7d | 0 | 1 | >= 2 |
| Hygiene | Expired waivers | 0 | 1 | >= 2 |

## Required Actions by Severity

- Green: keep current trajectory; no forced remediation.
- Yellow: create an action item with owner and target date in the same week.
- Red: freeze non-critical changes in affected area until mitigation plan exists.

## Evidence and Traceability

Weekly digest MUST include:

- metric snapshots and status color per category,
- trend deltas vs previous week,
- selected remediation actions with owners and due dates,
- links to source evidence artifacts and trace IDs.

## Related Contracts

- Methodology overview: `.octon/cognition/practices/methodology/README.md`
- Operations runbooks: `.octon/cognition/practices/operations/index.yml`
- Tooling and metrics: `.octon/cognition/practices/methodology/tooling-and-metrics.md`
- Reliability and ops: `.octon/cognition/practices/methodology/reliability-and-ops.md`
- Risk tiers: `.octon/cognition/practices/methodology/risk-tiers.md`
- Knowledge Plane: `.octon/cognition/runtime/knowledge/knowledge.md`
- Runtime evaluations surface: `.octon/cognition/runtime/evaluations/README.md`
- Runtime digest surface: `.octon/cognition/runtime/evaluations/digests/README.md`
- Runtime action surface: `.octon/cognition/runtime/evaluations/actions/README.md`
- Observability requirements: `.octon/cognition/_meta/architecture/observability-requirements.md`
- Governance model: `.octon/cognition/_meta/architecture/governance-model.md`
