---
title: React Rules - Monitoring
description: Observability guidance for validating performance rules in production.
version: "1.0.1"
---

# Monitoring Rules

## Runtime Signals

- Track route-level `p50/p95/p99` latency after rendering or data-loading changes
- Track hydration warnings and mismatch rates
- Track client bundle size and route chunk drift over time
- Track cache hit/miss behavior for server-rendered data paths
