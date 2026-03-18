---
name: react-composition-patterns
description: >
  Reference knowledge skill for React composition patterns. Provides 8
  prioritized rules covering compound components, state lifting, explicit
  variants, and React 19 APIs. Apply when writing or reviewing React
  component architecture.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Vercel Engineering (adapted for Octon Framework)
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(_ops/state/logs/*)
---

# React Composition Patterns

Reference knowledge for building flexible, maintainable React components through composition.

## When to Use

Use this skill when:

- Designing or refactoring React component architecture
- A component has accumulated multiple boolean props for customization
- You need to share state across sibling components without prop drilling
- Building a component library or design system
- Reviewing components for composition patterns compliance

## Quick Start

```
/react-composition-patterns target="src/components/"
```

## How to Apply

When this skill is activated:

1. Read the target code to understand current component architecture
2. Load `references/rules.md` for the full rule set
3. Check each component against applicable rules, prioritized by impact
4. Report violations inline with rule references and suggested fixes
5. For new code, apply the patterns proactively during generation

## Rule Categories

| # | Category | Impact | Key Focus |
|---|----------|--------|-----------|
| 1 | Component Architecture | HIGH | Avoid boolean prop proliferation, use compound components |
| 2 | State Management | MEDIUM | Decouple state from UI, generic context interfaces, lift state to providers |
| 3 | Implementation Patterns | MEDIUM | Explicit component variants, prefer children over render props |
| 4 | React 19 APIs | MEDIUM | `ref` as prop (no `forwardRef`), `use()` instead of `useContext()` |

## Boundaries

- Reference knowledge only — apply rules to code, do not rewrite the rules
- Cite rules by section number when reporting violations (e.g., "Rule 1.1: Avoid Boolean Prop Proliferation")
- Do not modify source files unless explicitly asked to refactor
- React 19 API rules (section 4) only apply to React 19+ projects

## When to Escalate

- Rules conflict with project-specific component conventions
- Project uses a fundamentally different composition approach (e.g., render props by design)
- React version is unclear — ask before applying React 19 rules

## References

- [Rules](references/rules.md) — Full rule set with code examples (8 rules across 4 categories)
