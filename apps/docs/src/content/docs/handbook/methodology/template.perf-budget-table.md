---
title: Perf Budget Table
---

| Surface | Metric | Budget | Method |
|---|---|---|---|
| API /foo | p95 latency | ≤300ms warm / ≤600ms cold | OTel + SLO panel |
| Homepage | TTFB p95 | ≤400ms | Vercel Analytics |
| Bundle | JS (app) | ≤250kB gz | size-limit CI |
