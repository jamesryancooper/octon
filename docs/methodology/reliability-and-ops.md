---
title: Reliability and Operations
description: SRE-aligned reliability and operations guide for Harmony, covering SLIs/SLOs, error budgets, on-call, incidents, and the blameless postmortem template.
---

# Reliability and Ops

This document is the detailed SRE and operations companion to the Harmony Methodology. Use it to define SLIs/SLOs, manage error budgets, and run incidents and postmortems in a way that aligns with Harmony’s guardrails.

## SLIs, SLOs, and Error Budgets

- **SLIs**: availability, p95 latency, error rate, saturation (CPU/DB connections/queue depth).
- **SLOs (starter)**:
  - API availability ≥ **99.9%** (monthly).
  - p95 API latency ≤ **300 ms** (warm), ≤ **600 ms** (includes cold starts).
  - p95 page **TTFB ≤ 400 ms** for top route.
  - 5xx error rate ≤ **0.5%**.
- **Error budgets**: 43m/month at 99.9%; if burned, freeze feature flags and focus on reliability until recovered. Alert on **burn‑rate** (multi‑window).
- **Cost guardrails**: publish monthly AI token and infra cost budgets; alert on anomalies (spend or unit‑cost spikes). Treat sustained anomalies like error‑budget burns: freeze risky merges/promotions and resolve before widening rollout.

## On-call and Incidents

- **On‑call (solo)**: define your paging window; no 24/7 pages for low‑impact; page only for SLO threats.
- **Incidents**: severities, **rollback first** (Vercel promote), then fix‑forward; blameless **postmortem** template below.
- **Observability**: **OpenTelemetry** for traces/metrics + structured logs (**pino**) wired to your vendor. Next.js supports OTel and `@vercel/otel`; Astro can emit server traces when using SSR adapters. Bootstrap OTel early from `infra/otel/instrumentation.ts` (default OTLP endpoint `http://localhost:4318`, override with `OTEL_EXPORTER_OTLP_ENDPOINT`).
  - Coverage: target trace/span coverage for the top 5 user flows; add spans around new/changed paths.
  - Safety: use GuardKit to redact PII in logs by default; only log IDs and non‑sensitive metadata.
  - Hygiene: include `trace_id`/`span_id` in all logs; set retention appropriate to data policies; link a representative trace in the PR comment for High‑risk changes.
  - Local‑first telemetry: when offline or in `--dry-run`, buffer spans/logs locally and flush later (per ObservaKit’s offline mode) to preserve provenance without leaking secrets.

## Blameless Postmortem Template (Outline)

- Title & metadata
  - Short, descriptive title; incident ID; date/time window.
  - Severity level (Sev‑1/Sev‑2/Sev‑3), owners, and reviewers.
- Summary and impact
  - One‑paragraph summary of what happened.
  - User/customer impact, duration, and SLO/SLA effects.
- Timeline
  - Ordered list of key events from first symptom to full recovery.
  - Include detection, paging, mitigation, and verification steps.
- Detection and response
  - How the incident was detected (alert, support ticket, manual).
  - What worked well and what was slow or missing in the response.
- Root cause and contributing factors
  - Technical root cause (including flags, configs, and deployments).
  - Contributing factors (gaps in tests, observability, process, or documentation).
- What went well / what was painful
  - Practices that helped (for example, clear runbooks, fast rollback).
  - Pain points (for example, flaky alerts, missing dashboards, unclear ownership).
- Follow‑ups and owners
  - Concrete actions with owners and due dates (tests, docs, tooling, process).
  - How success will be measured (for example, new SLOs, alert quality, reduced MTTR).
- Learning and knowledge capture
  - Links to traces, dashboards, PRs, and ADRs updated or created.
  - Notes for Kaizen/autopilot candidates (for example, automation or guardrail improvements).

## Incident Severity Levels (Summary)

| Severity | Impact & Examples | Action |
| --- | --- | --- |
| Sev‑1 | Broad customer impact or SLO breach in production; revenue/security risk | Page on‑call; rollback first (promote prior preview); freeze risky merges; 30‑min watch window; postmortem within 48h |
| Sev‑2 | Limited cohort impact or partial degradation; error budget at risk | Page on‑call; mitigate (flag, rollback subset); prioritize fix in current cycle; postmortem if SLO budget materially affected |
| Sev‑3 | Minor issue with workaround; no SLO risk | Triage during focus hours; fix‑forward via small PR behind a flag; include note in weekly retro |
