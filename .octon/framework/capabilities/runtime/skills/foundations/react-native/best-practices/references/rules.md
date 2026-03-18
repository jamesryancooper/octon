---
title: React Native Rules Index
description: Summary index for React Native rules by impact tier.
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-native-skills
license: MIT
version: "1.0.1"
---

# React Native Rules

Activation-safe summary. Load the tier file that matches the issue impact.

| Impact Tier | Typical Use | Detail File |
|---|---|---|
| Critical | Rendering correctness, list virtualization, major jank risks | `rules-critical.md` |
| High | Animation, scroll handling, navigation, state correctness | `rules-high.md` |
| Medium | Architecture, compiler patterns, UI composition | `rules-medium.md` |
| Low | Monorepo/dependency hygiene, JS utilities, fonts | `rules-low.md` |

## Selection Heuristic

- Start with `rules-critical.md` for correctness/perf regressions visible to users
- Use `rules-high.md` when interaction smoothness or nav behavior degrades
- Use `rules-medium.md` for maintainability/perf tradeoff cleanup
- Use `rules-low.md` for polish and consistency pass
