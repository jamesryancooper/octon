---
name: react-native-best-practices
description: >
  Reference knowledge skill for React Native and Expo performance optimization.
  Provides 35+ rules across 14 categories, prioritized by impact from critical
  (core rendering, list performance) to incremental (fonts, imports). Apply when
  writing, reviewing, or refactoring React Native/Expo code.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Vercel Engineering (adapted for Octon Framework)
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/*)
---

# React Native Best Practices

Comprehensive performance optimization guide for React Native and Expo applications.

## When to Use

Use this skill when:

- Writing new React Native or Expo components and wanting to follow best practices
- Reviewing existing mobile code for performance issues
- Refactoring React Native applications for better performance
- Diagnosing slow list rendering, janky animations, or navigation lag
- Building with React Native Reanimated, Gesture Handler, or FlashList

## Quick Start

```
/react-native-best-practices target="src/"
```

## How to Apply

When this skill is activated:

1. Read the target code to understand the current implementation
2. Load `references/rules.md` for the full rule set
3. Check against applicable rules, prioritizing CRITICAL and HIGH impact first
4. Report violations with rule references, impact level, and corrected examples
5. For new code, apply the patterns proactively during generation

## Rule Categories

| # | Category | Impact | Key Focus |
|---|----------|--------|-----------|
| 1 | Core Rendering | CRITICAL | Never use `&&` with falsy values, wrap strings in `<Text>` |
| 2 | List Performance | HIGH | FlashList, stable refs, memoization, compressed images |
| 3 | Animation | HIGH | GPU properties, Reanimated worklets, gesture detection |
| 4 | Scroll Performance | HIGH | Scroll event throttling, header collapsing |
| 5 | Navigation | HIGH | Native stack, tab preloading |
| 6 | React State | MEDIUM | Minimize subscriptions, external store selectors |
| 7 | State Architecture | MEDIUM | Zustand patterns, optimistic updates |
| 8 | React Compiler | MEDIUM | Compiler compatibility, stable references |
| 9 | User Interface | MEDIUM | expo-image, Pressable, bottom sheets |
| 10 | Design System | MEDIUM | Constrained style props, platform variants |
| 11 | Monorepo | LOW | Native dependency isolation |
| 12 | Dependencies | LOW | Minimal native modules |
| 13 | JavaScript | LOW | Avoid heavy computation on JS thread |
| 14 | Fonts | LOW | Proper font loading with expo-font |

## Boundaries

- Reference knowledge only — apply rules to code, do not rewrite the rules
- Cite rules by section and number when reporting violations (e.g., "Rule 2.6: Use a List Virtualizer")
- Do not modify source files unless explicitly asked to refactor
- Prioritize CRITICAL and HIGH rules over MEDIUM and LOW

## When to Escalate

- Rules conflict with project-specific architecture decisions
- Project uses a non-standard navigation library
- Performance issue isn't covered by existing rules

## References

- [Rules](references/rules.md) — Full rule set with code examples (35+ rules across 14 categories)
