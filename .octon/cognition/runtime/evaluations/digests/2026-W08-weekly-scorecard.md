---
title: Weekly Scorecard Digest 2026-W08
description: Baseline weekly runtime evaluation digest to activate evaluations surface.
week: 2026-W08
digest_date: 2026-02-22
status: yellow
actions:
  - id: ACTION-2026-W08-01
    owner: cognition-ops
    due_date: 2026-02-27
    status: open
    summary: Establish recurring weekly digest production cadence.
    evidence: /.octon/cognition/practices/operations/weekly-evaluations.md
---

# Weekly Scorecard Digest: 2026-W08

## Metadata

- Digest date: 2026-02-22
- Covered window: 2026-02-16 to 2026-02-22
- Compiler/source run IDs: n/a (initial baseline)
- Reviewer: cognition-ops

## Category Status

| Category | Status (green/yellow/red) | Notes |
|---|---|---|
| Flow | yellow | Cadence is newly initialized; trendline not established yet. |
| Reliability | green | Runtime validation scripts pass in baseline run. |
| Quality | yellow | Fixture tests added this cycle; longitudinal coverage pending. |
| Observability | yellow | Digest series and action ledger activated this week. |
| Security | green | No new policy or guardrail regressions observed in baseline checks. |
| Hygiene | yellow | Initial action opened to institutionalize weekly rhythm. |

## Metric Snapshots and Deltas

| Metric | Current | Previous | Delta | Status |
|---|---|---|---|---|
| Lead time (p75) | n/a | n/a | n/a | yellow |
| Deploy frequency | n/a | n/a | n/a | yellow |
| Change failure rate | n/a | n/a | n/a | yellow |
| MTTR | n/a | n/a | n/a | yellow |
| Error budget burn (7d) | n/a | n/a | n/a | yellow |
| p95 latency SLO miss | n/a | n/a | n/a | yellow |
| Contract drift findings | 0 | n/a | n/a | green |
| Test flake rate | n/a | n/a | n/a | yellow |
| Requests with trace_id | n/a | n/a | n/a | yellow |
| KP correlation coverage | n/a | n/a | n/a | yellow |
| Open critical vulns > 7d | 0 | n/a | n/a | green |
| Expired waivers | 0 | n/a | n/a | green |

## Remediation Actions

- Action ID: ACTION-2026-W08-01
  - owner: cognition-ops
  - due_date: 2026-02-27
  - status: open
  - linked evidence: `/.octon/cognition/practices/operations/weekly-evaluations.md`

## Evidence Links

- CI artifacts: `/.github/workflows/harness-self-containment.yml`
- Observability traces: n/a for baseline digest
- Knowledge references: `/.octon/cognition/runtime/evaluations/index.yml`

