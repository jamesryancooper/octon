---
title: Tooling and Metrics
description: Harmony’s tooling map (GitHub, Vercel, Turborepo) and metrics strategy, including DORA metrics, Kaizen log, WIP/cycle analytics, and cost dashboards.
---

# Tooling and Metrics

This document centralizes Harmony’s tooling and metrics guidance. Use it alongside the methodology overview when wiring up GitHub/Vercel/Turborepo workflows and defining the metrics you will track over time.

## Tooling Map (GitHub/Vercel/Turborepo)

- **GitHub Projects**: board columns above; templates for Spec/Story/bug; Insights for cycle time. Protect `main` with **required checks**.
- **Actions matrix per package**: `turbo run lint test build --filter=...` using remote cache.
- **Required checks**: the gates configured in `infra/ci/pr.yml` (subset of CI/CD Quality Gates); adopt additional gates incrementally.
- **Vercel**: previews on every PR; **promote** for instant rollback; env & secret management; **feature flags** via Vercel Flags/Toolbar; **cron** for schedules.
- **Scripts**: `scripts/smoke-check.sh` for quick PR preview smoke checks; `scripts/flags-stale-report.js` for weekly flag hygiene reports.

## Metrics and Improvement

- **Minimal DORA**: lead time (PR open→merge), deployment frequency, change‑fail %, MTTR. Track automatically via PR & Actions timestamps; correlate with SLO burn.
- **SRE targets**: publish current SLOs, weekly error‑budget report; adjust gates when burn is high (e.g., freeze features, raise test thresholds).
- **Kaizen log**: surface daily `kaizen` PRs in the weekly retro; aim for ≥5 small improvements/week. Celebrate and keep the habit compounding.
- **WIP/cycle analytics**: monitor WIP aging, 50th/90th percentile cycle time, and blocked WIP. Tighten WIP or cut scope if trends degrade for 2 consecutive weeks.
- **Cost dashboard**: review monthly AI token and infra cost trends; investigate anomalies; record decisions in the weekly retro and PR notes.
- **Weekly retro prompts**:
  - *What blocked flow?*
  - *What broke gates?*
  - *Which SLI/SLO regressed?*
  - *What 1 guardrail to tighten/loosen?*

---

## Metrics-to-Pillar Mapping

Every metric category in Harmony traces back to one or more of the [Six Pillars](../pillars/README.md). This mapping ensures we measure what matters for the outcomes we care about.

| Metric Category | Primary Pillar | Connection |
|-----------------|----------------|------------|
| **DORA metrics** | [Velocity](../pillars/velocity.md) | Lead time and deploy frequency measure delivery speed; change-fail rate and MTTR measure sustainable velocity. |
| **SRE targets** | [Trust](../pillars/trust.md) | SLOs and error budgets enforce governed determinism; they're the quantitative expression of trustworthy systems. |
| **WIP/cycle analytics** | [Focus](../pillars/focus.md) | WIP aging and cycle time reveal cognitive load and flow health. High WIP signals lost focus. |
| **Kaizen log** | [Insight](../pillars/insight.md) | Daily improvements and retro-driven changes embody structured learning. Each kaizen PR is learning made concrete. |
| **Cost dashboard** | [Trust](../pillars/trust.md) | Cost governance is a trust guardrail—predictable costs mean predictable operations. |

### Secondary Pillar Connections

| Metric Category | Secondary Pillars | Why |
|-----------------|-------------------|-----|
| DORA metrics | Direction | High velocity without direction is wasted motion; track spec coverage alongside deploy frequency. |
| SRE targets | Continuity | SLO burn analysis requires traces and logs preserved by Continuity. |
| Kaizen log | Velocity | Friction removal accelerates flow; each improvement compounds. |
| Weekly retro | Insight → Direction | Retro learnings feed the next cycle's specs, closing the feedback loop. |

### The Insight → Direction Loop in Metrics

The weekly retro prompts explicitly connect Insight back to Direction:
- "What blocked flow?" → informs next cycle's scope cuts
- "What broke gates?" → informs spec validation criteria
- "Which SLI/SLO regressed?" → informs future perf/reliability requirements
- "What guardrail to tighten/loosen?" → informs methodology refinement

This is the [Insight → Direction feedback loop](../pillars/insight.md) made operational.
