---
title: Reliability and Operations
description: Provider-agnostic reliability and operations policy for SLIs/SLOs, incidents, rollbacks, and postmortems.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
---

# Reliability and Ops

Use this policy for reliability governance independent of deployment provider.

## SLIs, SLOs, and Error Budgets

- SLIs: availability, p95 latency, 5xx error rate, saturation.
- Starter SLOs:
  - API availability >= 99.9% monthly
  - p95 API latency <= 300ms warm and <= 600ms including cold starts
  - p95 top-route TTFB <= 400ms
  - 5xx error rate <= 0.5%
- Canonical ownership: these starter SLO defaults are the methodology-wide baseline. Other methodology docs should reference this section instead of repeating numeric thresholds.
- Error budget burn triggers a freeze on risky merges/promotions until recovery.

## Release Hygiene Defaults

- Release behind default-off flags for risky or user-visible behavior.
- Rollback-first policy for SLO threats.
- Canonical rollback path: promote the previous known-good deployment using your deployment platform's promote/rollback primitive.

## On-call and Incident Handling

- Page only for SLO threats and material user impact.
- Incident sequence: stabilize, rollback if needed, then fix-forward.
- Postmortems are blameless and required for Sev-1 and material Sev-2 incidents.
- Observability contract:
  - required trace/log coverage for changed critical flows
  - `trace_id`/`span_id` in operational logs
  - redaction of sensitive fields at log boundaries

## Incident Severity (Summary)

| Severity | Impact | Action |
|---|---|---|
| Sev-1 | Broad customer impact or active SLO breach | Page immediately, rollback-first, 30-min watch window, postmortem within 48h |
| Sev-2 | Partial degradation or material budget risk | Mitigate quickly, prioritize fix in current cycle, postmortem when budget materially affected |
| Sev-3 | Minor issue with workaround | Triage in normal flow and capture in retro |

## Postmortem Minimum Sections

- Title and metadata (time window, severity, owner)
- Impact summary
- Timeline
- Detection and response evaluation
- Root cause and contributing factors
- Follow-up actions with owners and due dates
- Links to traces, dashboards, PRs, and ADR updates
