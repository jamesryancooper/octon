---
title: Spec — Shared shadcn/ui Kit (Tailwind v4)
---

## Problem & Goal

- **Problem.** Each app hand-rolls UI primitives leading to drift across Next.js and Astro surfaces; we lack a cohesive design system with test coverage and governance aligned to Harmony guardrails.
- **Goal.** In two weeks, ship a shared React component library (`@harmony/ui`) based on shadcn/ui + Tailwind v4 that can be consumed by Next.js 16 (React 19) and Astro v5 (via React islands) with Storybook, tests, and feature-flagged rollout.

## Scope & Cuts

- **In-scope.**
  - Introduce Tailwind v4 tokens + preset in `packages/config`.
  - Bootstrap shadcn/ui components (Button, Input, Alert) in `packages/ui` with CSS build (`dist/ui.css`).
  - Wire Tailwind v4 (or fallback prebuilt CSS) into `apps/ai-console`, `apps/web`, `apps/docs`.
  - Add Storybook + Vitest + Playwright component tests for `ui`.
  - Document contributor workflow, flags, rollout.
- **Out-of-scope.**
  - Migrating legacy styling in Astro layout chrome (remains Astro-native).
  - Non-React consumers (e.g., Fastify templates) — future evaluation.
  - Theme editor UI; only CSS-variable-driven theme tokens for now.

## Contracts (APIs/UI)

- **UI contracts/states.**
  - `Button`: variants (`default|outline|ghost`), sizes (`sm|md|lg`), disabled states, loading icon slot.
  - `Input`: states (default/error/disabled), icon slot.
  - `Alert`: semantic variants (`info|success|warning|destructive`), dismissible action.
- **Exports.** All components re-exported from `@harmony/ui` root; CSS bundle available at `@harmony/ui/dist/ui.css`.
- **Data model changes.** None.

## Non-Functionals

- **Perf budgets.**
  - CSS bundle ≤ 55 kB gzip for base (`dist/ui.css`), validated via `pnpm --filter @harmony/ui run build:css` + size check.
  - Next.js hydration time for `<Button/>` ≤ 50 ms (local smoke via Lighthouse CI optional).
- **Reliability.**
  - Turborepo pipelines: lint/type/test/build ≤ 5 min; Storybook build produced per PR.
- **Privacy & data retention.** No user data collected; ensure components do not log PII; telemetry limited to existing OTel boundaries.

## Security (OWASP ASVS / STRIDE)

- **ASVS sections.** v5: V1 (Architecture), V4 (Access Control) not impacted; V12 (File & Resources) for third-party packages; V14 (Config) for Tailwind presets.
- **STRIDE table.**

| Threat | Risk | Mitigation | Test |
| --- | --- | --- | --- |
| Spoofing | React islands reusing shared context across Astro boundaries leading to privilege confusion | Enforce per-island render; document “one island, one context” guidance | Playwright island isolation test |
| Tampering | CSS token override in apps causing inconsistent theming | Token preset exported via TS module; lint ensure tokens imported read-only | Vitest snapshot of token map |
| Repudiation | Shared components emit console logs without attribution | Standardize `data-component` attributes; rely on existing logging policy | Vitest ensures no stray console usage |
| Information Disclosure | Dependency update introduces telemetry | SBOM + license gate; manual review of new deps | CI SBOM diff + license scan |
| Denial of Service | Tailwind config mis-scan purges required classes, breaking UI | Content globs include `packages/ui/**/*`; automated smoke in each app | Playwright smoke in Next + Astro |
| Elevation of Privilege | Feature flag disabled but CSS/JS shipped globally | Feature flag guards usage in apps; optional CSS import for Astro minimal surfaces | Feature flag unit tests |

## NIST SSDF Activities (SP 800-218)

- **Plan.** Spec + ADR filed; supply-chain assessment for shadcn, Radix, Tailwind v4. SBOM delta evaluated per PR.
- **Protect.** Branch protection remains; Tailwind preset stored in git; secrets unaffected. License gate ensures permissive deps.
- **Produce.** CodeQL/Semgrep already in pipeline; add Vitest + Playwright tests; Storybook for visual review.
- **Respond.** Rollback by disabling feature flags or reverting `@harmony/ui` version; incidents logged in postmortem template.

## Flags & Rollout

- **Flag keys.** `flag.ui_kit_v1` (per surface). Default OFF.
- **Rollout guardrails.**
  - Stage 0: Internal toggle (dev org only).
  - Stage 1: 10% traffic (Next.js) + selected docs pages (Astro) after 48 h stable.
  - Stage 2: Full enablement once SLOs unaffected for 5 business days.
  - Rollback: disable flag or promote prior Vercel preview (per promote SOP).

## Observability

- Emit browser console warnings only via existing logging util; add optional boundary component to capture React errors and forward to existing OTel endpoint (future work).
- Track Storybook accessibility audit results as part of CI summary.

## Acceptance Criteria

- `@harmony/ui` publishes JS + CSS bundle, passes lint/type/test, and exposes Tokens README.
- Next.js and Astro apps render `<Button/>` inside flags without hydration errors; Playwright and Vitest suites green.
- Storybook preview demonstrates light/dark themes; a11y addon reports no critical violations on baseline components.
- SBOM + license scan show only MIT/BSD/Apache dependencies.

## ADR link

- ADR-008 — Shared shadcn/ui kit adoption (Tailwind v4).

## Compatibility appendix

- React 19 peer support confirmed for `@radix-ui/react-slot` (`pnpm view @radix-ui/react-slot peerDependencies` → `^16.8 || ... || ^19.0`).
- Tailwind CSS v4 available as `tailwindcss@next` (version 4.0.0).
- Next.js 16 already in repo; HMR/SSR smoke test to be added during PR3.

