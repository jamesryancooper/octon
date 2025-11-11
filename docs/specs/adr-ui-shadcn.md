---
title: ADR-008 — Shared shadcn/ui Kit Adoption (Tailwind v4)
---

- **Status.** Proposed (target acceptance after PR2 smoke tests).
- **Context.**
  - Harmony apps span Next.js 16 (React 19) and Astro v5; UI primitives diverged, hurting velocity and a11y consistency.
  - shadcn/ui offers copy-first Radix-based components aligning with React 19; Tailwind v4 delivers tokenized theming via `@theme` and smaller runtime.
  - Verified compatibility: `@radix-ui/react-slot` peers include React `^19.0`; `tailwindcss@next` resolves to `4.0.0`.
- **Decision.**
  - Create `@harmony/ui` package leveraging shadcn/ui with Tailwind v4 tokens defined in `packages/config` preset.
  - Consume via direct imports in Next.js and via React islands in Astro; provide optional prebuilt CSS for low-JS pages.
  - Govern changes through Storybook, Vitest/Playwright tests, SBOM/license gates, and Changesets releases.
- **Consequences.**
  - Pros: unified design system, faster feature delivery, consistent a11y/theming, reuse across apps, alignment with Harmony methodology (tiny PRs + flags).
  - Cons: Tailwind v4 adoption requires coordination; Astro React islands add complexity; ongoing upkeep for templates and Radix updates.
  - Follow-ups: implement plan PR1–PR9; monitor CSS bundle size; evaluate Chromatic for visual regression; revisit Edge-rendered flags once Next/Edge surfaces exist.
- **Links.**
  - Spec: `docs/specs/shadcn-ui-spec.md`.
  - Future PRs: PR1 (presets), PR2 (ui bootstrap), PR3–PR9 (rollout per plan).

