# @harmony/ui

Shared React component library built on **shadcn/ui**, **Radix UI**, and **Tailwind CSS v4**. The
package is consumed by multiple Harmony apps:

- `apps/ai-console` (Next.js 16 / React 19) – direct component imports
- `apps/web` (Astro 5) – React islands only
- `apps/docs` (Astro 5 + Starlight) – React islands only

> The `ui` package must stay framework-agnostic beyond React/Radix. Do **not** import domain or
> adapter packages from here.

## Installation & build

```bash
pnpm install
pnpm --filter @harmony/ui build          # emits dist/index.js + dist/ui.css
pnpm --filter @harmony/ui storybook      # optional local playground
pnpm --filter @harmony/ui test           # Vitest + RTL
```

## Tailwind v4 preset & CSS

- Consumers that run Tailwind (e.g., Astro apps) should reuse the shared preset exported from
  `@harmony/config/tailwind-preset` plus the PostCSS preset from `@harmony/config/postcss-preset.mjs`.
- Tailwind content globs **must** include this package so classes are not purged.
- The Next.js app currently imports the **prebuilt CSS bundle** (`@harmony/ui/dist/ui.css`) instead
  of running Tailwind, due to a known Turbopack ↔ Tailwind v4 / lightningcss issue. See "Tailwind in
  consumers" below for options and guidance.

## Usage in Next.js (apps/ai-console)

The Next app keeps Turbopack enabled and **does not** run Tailwind v4 locally right now. Instead it
imports the compiled design-system CSS:

```tsx
// app/layout.tsx
import '@harmony/ui/dist/ui.css';
import { Button } from '@harmony/ui';

export default function Page() {
  return (
    <main className="p-6">
      <Button variant="default">Primary action</Button>
    </main>
  );
}
```

If/when Turbopack gains first-class Tailwind v4 support, restore the shared PostCSS/Tailwind preset
and switch the import back to a Tailwind entrypoint.

## Usage in Astro (apps/web, apps/docs)

1. Install the React integration (`@astrojs/react`) and enable it in `astro.config.ts`.
2. Import Tailwind (or the prebuilt CSS) inside Astro layouts.
3. Wrap ui components inside **a single island per interactive region** to avoid cross-island
   context issues:

```tsx
// src/components/islands/cta-button.tsx
'use client';
import { Button } from '@harmony/ui';

export default function CtaButton({ href }: { href: string }) {
  return (
    <Button asChild variant="outline">
      <a href={href}>Get started</a>
    </Button>
  );
}
```

```astro
---
import '../styles/tailwind.css';
import CtaButton from '../components/islands/cta-button.tsx';
---

<CtaButton client:idle href="/docs" />
```

## Theming

- Theme tokens (colors, radii) are defined in `src/styles/tailwind.css` using Tailwind v4 `@theme`.
- Dark mode follows the `class` strategy (`.dark`). Consumers should toggle the class on `<html>` or
  `<body>` to align with their framework.

## Tailwind in consumers (Next mitigation & options)

- **Current mitigation (Next.js)**: Tailwind is compiled during the UI kit build, and the app imports
  `@harmony/ui/dist/ui.css`. This sidesteps the lightningcss native module issue in Turbopack and
  keeps SSR/HMR happy.

- **Option A – Tailwind inside the UI kit (default)**
  - Author component styles with Tailwind utilities, compile them during the UI kit build, and ship
    the resulting CSS. Example:

    ```css
    /* src/styles/components/button.css */
    .btn { @apply inline-flex items-center justify-center font-semibold rounded-xl px-4 py-2; }
    .btn--primary { @apply bg-[var(--harmony-brand)] text-white hover:opacity-90; }
    .btn--ghost { @apply bg-transparent text-[var(--harmony-brand)] ring-1 ring-[color-mix(in srgb,var(--harmony-brand) 50%,transparent)]; }
    ```

    ```tsx
    import clsx from 'clsx';

    export function Button({ variant = 'primary', className, ...props }) {
      return <button className={clsx('btn', `btn--${variant}`, className)} {...props} />;
    }
    ```

    Consumers just import `@harmony/ui/dist/ui.css`.

- **Option B – Theme via CSS variables**
  - Expose tokens from the kit and let apps override them without Tailwind:

    ```css
    :root { --harmony-brand: #3b82f6; }
    .button--primary { background: var(--harmony-brand); }
    ```

    ```css
    /* app/styles/app.css */
    :root { --harmony-brand: #8b5cf6; }
    ```

- **Need Tailwind utilities in the app?** Keeping Turbopack and Tailwind together today is unstable.
  Prefer CSS Modules or plain CSS for local tweaks:

  ```css
  /* components/CardShell.module.css */
  .root { padding: 1.25rem; border-radius: 1rem; }
  .title { font-weight: 700; }
  ```

  ```tsx
  import s from './CardShell.module.css';
  import { Card } from '@harmony/ui';
  ```

Recommended path: keep Tailwind authoring inside the UI kit build (Option A), expose CSS variables
(Option B), and use CSS Modules for app-specific layout tweaks until the Turbopack/Tailwind runtime
story stabilizes.

## Scripts summary

| Script              | Description                                              |
| ------------------- | -------------------------------------------------------- |
| `pnpm build`        | TypeScript + Tailwind build (`dist/index.*`, `dist/ui.css`) |
| `pnpm typecheck`    | `tsc --noEmit`                                           |
| `pnpm lint`         | ESLint with Harmony settings                             |
| `pnpm test`         | Vitest + React Testing Library using `jsdom`             |
| `pnpm storybook`    | Storybook dev server (React + Vite)                      |
| `pnpm storybook:build` | Static Storybook build for design reviews            |

## Contribution workflow

1. Add or update components via the shadcn CLI (`pnpm dlx shadcn@latest add <component>`).
2. Ensure components export from `src/index.ts`, ship MDX docs + Storybook stories, and include unit
   tests for critical behavior.
3. Keep PRs small: update tokens/configs separately from component changes. Run `pnpm test`,
   `pnpm lint`, and `pnpm build` before pushing.
4. Document new patterns in `docs/specs/adr-ui-shadcn.md` and update the contributor guide when
   deviating from the defaults.

Questions? Reach out in the Harmony #ui channel and link your Spec + ADR before shipping changes.
