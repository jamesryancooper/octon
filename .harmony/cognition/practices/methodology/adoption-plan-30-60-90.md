---
title: 30/60/90 Adoption Plan
description: A staged 30/60/90 day adoption plan for Harmony, including quick-start guidance, daily cadence, and suggested sequence of guardrail adoption.
---

# 30/60/90 Adoption Plan

This document is a focused onboarding and adoption guide for Harmony. Use it when rolling Harmony out over the first 90 days, and for quick reminders of the day-to-day cadence and guardrails.

## 30/60/90 Adoption Plan (high-level)

- **Day 1–30 (Foundations)**: set up **board, Spec/ADR, CODEOWNERS, branch protection**, Turbo pipelines, minimal CI (lint, unit, typecheck, preview). Enable **Vercel previews/envs**, **secret scanning**, **Dependabot**.
- **Day 31–60 (Security/Reliability)**: add **CodeQL, Semgrep, SBOM**, Pact/Schemathesis, Playwright smoke; define **SLOs**, alerts on burn rate; OTel + pino; require **Observability** for changed flows.
- **Day 61–90 (Perf & Flags)**: set **perf/bundle budgets**, feature flag process, load tests on preview, postmortems template, error‑budget policy in README.
  - Automate **flags hygiene** with `scripts/flags-stale-report.js`; adopt `scripts/smoke-check.sh` for fast preview validation.

## Quick-Start Cadence (Tomorrow Morning)

- **Cadence & roles**: 1‑week cycle; switch hats between **Driver (build)** and **Navigator (review)**; async daily check‑ins.
- **Simplicity‑first**: Ship the smallest viable change that meets the requirement; avoid new dependencies unless they clearly reduce complexity or meet a non‑functional requirement.
- **Board & WIP**: Backlog → Ready (3) → In‑Dev (1) → In‑Review (1) → Preview (1) → Release → Done → Blocked.

### Spec → Plan → PR Flow

1. Write **spec one-pager** + **ADR**.
2. Convert to **feature story** (context + plan + AC).
3. Use **AI IDE** to propose plan/diffs/tests with checkpoints.
4. Open tiny PR → **preview deploy** → run e2e smoke → merge if gates pass.

### Required CI Checks (Summary)

- Lint/format; TS `--strict`; unit; typecheck.
- **OpenAPI diff (oasdiff)**; **CodeQL + Semgrep**.
- **Dependabot/SCA + Dependency Review (license)**.
- **Secret scanning + TruffleHog**; **SBOM**.
- Preview URL comment; **Observability for changed flows** (trace/logs + trace_id in PR).
- Recommended: Pact/Schemathesis and **e2e smoke (Playwright or `scripts/smoke-check.sh`)**; publish **bundle/perf budgets** (CI enforcement optional).

### Starter SLOs and Release Hygiene

- **SLOs (starter)**: Availability 99.9%; p95 API ≤300 ms warm (≤600 ms incl. cold); p95 TTFB ≤400 ms; 5xx ≤0.5%. **Error budget** gates releases.
- **Release behind a flag**: ship with `flag.<feature>=off` → enable for internal → ramp; **rollback** = *promote prior preview to production*.
- **How to rollback**: Vercel dashboard/CLI: `vercel promote <deployment-url>`.

### Top 10 Security/Perf Checks

1. STRIDE threats covered.
2. CSRF tokens on mutations.
3. CSP set.
4. SSRF outbound allow‑list.
5. Secrets in env only.
6. CodeQL/Semgrep clean.
7. SBOM present.
8. License policy OK.
9. p95 latency within budget.
10. Bundle under budget.

### Day-in-the-Life (Solo)

- **Mon**: Spec/Plan → small PR #1.
- **Tue**: Tests/contracts; PR #2.
- **Wed**: Feature + flags; preview smoke.
- **Thu**: Security scans & perf budgets; PR #3.
- **Fri**: Enable flag for internal; retro (15m); plan next cycle.
