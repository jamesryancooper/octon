---
title: React Best Practices Rules Index
description: Summary index for React/Next.js rules with category-specific detail files.
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
license: MIT
version: "1.0.1"
---

# React Best Practices Rules

Activation-safe summary. Load only the category file relevant to the active task.

| Category | Priority | Detail File |
|---|---|---|
| Eliminating waterfalls | Critical | `rules-waterfalls.md` |
| Bundle size optimization | Critical | `rules-bundle.md` |
| Server-side performance | High | `rules-server.md` |
| Async and throughput | High | `rules-async.md` |
| Rendering and re-render optimization | High | `rules-rendering.md` |
| React 19 patterns | Medium | `rules-react19.md` |
| Testing guidance | Medium | `rules-testing.md` |
| Monitoring guidance | Medium | `rules-monitoring.md` |

## Category Selection Heuristic

- Use `rules-waterfalls.md` for latency from serial awaits
- Use `rules-bundle.md` for payload and code-splitting issues
- Use `rules-server.md` for RSC, server actions, and caching paths
- Use `rules-async.md` for client fetch and JS throughput bottlenecks
- Use `rules-rendering.md` for unnecessary renders, hydration, and paint issues
