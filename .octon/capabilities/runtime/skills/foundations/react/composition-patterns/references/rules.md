---
title: React Composition Patterns Rules Index
description: Summary index for composition-pattern rules with links to detailed guidance.
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns
license: MIT
version: "1.0.1"
---

# React Composition Patterns Rules

This file is the activation-safe summary. Load `rules-detail.md` for full examples.

| Area | Priority | Detail File |
|---|---|---|
| Component architecture (variants, compound components) | Critical | `rules-detail.md` |
| State composition and provider boundaries | High | `rules-detail.md` |
| Implementation patterns and API shape | High | `rules-detail.md` |
| React 19 API transitions | Medium | `rules-detail.md` |

## Quick Checklist

- Prefer compound components over boolean prop matrices
- Isolate stateful concerns into provider boundaries
- Keep public component APIs explicit and variant-driven
- Validate React 19 API updates before introducing custom wrappers
