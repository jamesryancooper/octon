---
name: react-best-practices
description: >
  Reference knowledge skill for React and Next.js performance optimization.
  Provides 57 rules across 8 categories, prioritized by impact from critical
  (eliminating waterfalls, reducing bundle size) to incremental (advanced
  patterns). Apply when writing, reviewing, or refactoring React/Next.js code.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Vercel Engineering (adapted for Harmony Framework)
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(_ops/state/logs/*)
---

# React Best Practices

Comprehensive performance optimization guide for React and Next.js applications.

## When to Use

Use this skill when:

- Writing new React or Next.js components and wanting to follow best practices
- Reviewing existing code for performance issues
- Refactoring React/Next.js applications for better performance
- Diagnosing slow rendering, large bundle sizes, or waterfall requests
- Building with Server Components, Server Actions, or App Router

## Quick Start

```
/react-best-practices target="src/"
```

## How to Apply

When this skill is activated:

1. Read the target code to understand the current implementation
2. Load `references/rules.md` for the full rule set
3. Check against applicable rules, prioritizing CRITICAL and HIGH impact first
4. Report violations with rule references, impact level, and corrected examples
5. For new code, apply the patterns proactively during generation

## Rule Categories

| # | Category | Impact | Rules | Key Focus |
|---|----------|--------|-------|-----------|
| 1 | Eliminating Waterfalls | CRITICAL | 5 | Defer await, parallelize, strategic Suspense |
| 2 | Bundle Size Optimization | CRITICAL | 5 | Avoid barrel files, dynamic imports, preload on intent |
| 3 | Server-Side Performance | HIGH | 5 | Auth in Server Actions, colocated data, streaming |
| 4 | Client-Side Data Fetching | MEDIUM | 5 | Deduplication, optimistic updates, prefetching |
| 5 | Re-render Optimization | MEDIUM | 5 | State colocation, stable references, memo |
| 6 | Rendering Performance | MEDIUM | 5 | Layout thrashing, CSS containment, virtualization |
| 7 | JavaScript Performance | LOW | 5 | Web Workers, Maps, RegExp caching |
| 8 | Advanced Patterns | LOW | 5+ | Streaming SSR, progressive enhancement |

## Boundaries

- Reference knowledge only — apply rules to code, do not rewrite the rules
- Cite rules by section and number when reporting violations (e.g., "Rule 2.1: Avoid Barrel File Imports")
- Do not modify source files unless explicitly asked to refactor
- Server Component rules (section 3) only apply to Next.js App Router projects
- Prioritize CRITICAL and HIGH rules over MEDIUM and LOW

## When to Escalate

- Rules conflict with project-specific architecture decisions
- Project uses Pages Router instead of App Router (some rules differ)
- Performance issue isn't covered by existing rules

## References

- [Rules](references/rules.md) — Full rule set with code examples (57 rules across 8 categories)
