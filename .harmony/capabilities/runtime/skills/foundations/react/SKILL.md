---
name: react
description: >
  Foundation skill set for React and Next.js applications. Provides context about
  the available skills, their purpose, and when to suggest them.
user-invocable: false
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Grep Glob
---

# React Foundation

Background context for Claude — not invoked directly. This skill set
targets **React and Next.js applications** with a focus on composition
patterns and performance optimization. Claude should use this to guide
skill suggestions and stack assumptions.

## Stack Assumptions

These skills encode patterns for a specific technology stack. They apply
when the project matches most of these choices:

| Layer           | Choice                                    |
|-----------------|-------------------------------------------|
| Language        | TypeScript                                |
| UI framework    | React 18+ / React 19                     |
| Meta-framework  | Next.js 13+ (App Router)                 |
| Rendering       | Server Components + Client Components    |
| Styling         | Tailwind CSS, CSS Modules, or CSS-in-JS  |
| State           | React Context, Zustand, or Jotai         |
| Data fetching   | Server Actions, SWR, or TanStack Query   |
| Build tool      | Next.js built-in (Turbopack/Webpack)     |

**When not to suggest these skills:** Vue, Angular, or Svelte projects.
Vanilla JavaScript without React. Server-side-only Node.js projects
without a UI layer. Projects using React but targeting a fundamentally
different paradigm (e.g., React Native — see `react-native-foundation`).
If the user's stack diverges on more than two rows, these skills will
produce friction rather than value.

## Child Skills

| Skill | Purpose |
|-------|---------|
| `/react-composition-patterns` | Composition patterns — compound components, state lifting, explicit variants |
| `/react-best-practices` | 57 performance rules across 8 categories (waterfalls, bundle size, SSR, re-renders, etc.) |

## Usage

Unlike scaffolding foundations (which run once in sequence), these children
are **reference knowledge skills** — they provide ongoing coding guidance
that the agent applies while writing or reviewing code. Each child is
independently usable with no dependency between them.

- For **component architecture** decisions, use `composition-patterns`
- For **performance optimization** and code review, use `best-practices`
- For **broad coverage** on a new project, start with `best-practices`
  (wider scope), then apply `composition-patterns` for component design
