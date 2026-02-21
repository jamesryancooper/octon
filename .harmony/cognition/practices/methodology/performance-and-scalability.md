---
title: Performance and Scalability
description: Performance and scalability guidance for Harmony, including perf budgets, caching, queues, load testing, and Partial Prerendering/streaming.
---

# Performance and Scalability

This document collects Harmony’s performance and scalability guidance in one place. Use it when setting perf budgets, designing caching and queueing, and planning load tests for critical flows.

## Performance and Scalability (high-level)

- **Perf budgets & SLIs**: TTFB, p95 route/API latencies, error rate, bundle size, **cold start** limits (see Vercel guidance). Use **Edge** for ultra‑low‑latency reads; use **Serverless** for short, bursty compute. Move sustained/heavy or long‑running work to background queues/workers; minimize cold starts.
- **Caching**: at app (**React cache for Next.js surfaces**; for **Astro**, rely on SSG + CDN or adapter SSR caching), CDN (Vercel), and data (Upstash Redis) with **cache‑key discipline**.
- **Queues/backpressure**: Default: **QStash** for serverless simplicity; alternative: **BullMQ + Upstash (Redis)** for heavier workloads or long‑running tasks; **Vercel Cron** for scheduled jobs.
- **DB basics**: indexes on read paths, batched writes, pagination, idempotency keys, soft limits and rate limiting.
- **Load test plan**: quick repeatables (k6/Artillery/autocannon) on Preview. Run against **PR Preview** for risky changes or **Trunk Preview** for broader regressions; minimum 2 minutes or ≥1,000 requests. Recommended policy: consider gating merges if p95 exceeds budget by >10%.
- **Partial Prerendering & Streaming**: adopt PPR for mixed static/dynamic pages; keep dynamic islands behind `Suspense` with clear span boundaries; measure TTFB/TTI before/after adoption.
- **Cost/perf correlation**: track token usage and infra cost alongside latency/error SLIs (ObservaKit + CostKit). Prefer changes that improve or maintain both; flag regressions in PRs with a short note.
