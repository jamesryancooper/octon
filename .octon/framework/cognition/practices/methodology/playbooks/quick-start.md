---
title: Quick-Start Playbook
description: Day-one operational checklist for running Octon with small, safe, reversible delivery.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/README.md"
---

# Quick-Start Playbook

## Cadence and Roles

- 1-week cycle; switch hats between **Driver** and **Navigator**.
- Async daily check-ins.

## Complexity Calibration

Ship the smallest robust solution that meets constraints. Avoid new
dependencies unless they clearly reduce complexity or satisfy non-functional
requirements.

## Board and WIP

Backlog -> Ready (3) -> In-Dev (1) -> In-Review (1) -> Preview (1) -> Release
-> Done -> Blocked.

## Spec -> Plan -> PR Flow

1. Write spec one-pager + ADR.
2. Convert to feature story (context + plan + acceptance criteria).
3. Use AI IDE to propose plan/diffs/tests with risk-tiered ACP gates.
4. Open tiny PR -> preview deploy -> run e2e smoke -> merge when gates pass.

## Required CI Checks

- lint/format
- strict typing
- unit tests
- API/contract diff checks
- static/security analysis
- dependency/license policy checks
- secret scanning
- SBOM
- preview URL evidence
- observability evidence for changed flows (`trace_id` linked in PR)

Recommended: contract fuzzing and e2e smoke; publish bundle/perf budgets with
risk-tiered enforcement.

## Starter SLOs

- availability: 99.9%
- p95 API latency: <= 300ms warm (<= 600ms including cold paths)
- p95 TTFB: <= 400ms
- 5xx error rate: <= 0.5%

Error budget posture gates release decisions.

## Flagged Release and Rollback

- Ship with `flag.<feature>=off` -> enable for internal cohorts -> ramp.
- Rollback via your deployment platform's deterministic restore/promotion
  command.
- Capture rollback command/evidence in the PR receipt.

## Top 10 Security and Perf Checks

1. STRIDE threats covered.
2. CSRF tokens on mutations.
3. CSP set.
4. SSRF outbound allow-list.
5. Secrets in env only.
6. CodeQL/Semgrep clean.
7. SBOM present.
8. License policy OK.
9. p95 latency within budget.
10. bundle within budget.

## Incident Hotline

Page only for SLO burn or customer impact. Rollback first, then fix. Publish a
blameless postmortem within 48h.
