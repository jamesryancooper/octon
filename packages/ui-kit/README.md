# @harmony/ui-kit

Shared React component library built on **shadcn/ui**, **Radix UI**, and **Tailwind CSS v4**. The
package is consumed by multiple Harmony apps:

- `apps/ai-console` (Next.js 16 / React 19) – direct component imports
- `apps/web` (Astro 5) – React islands only
- `apps/docs` (Astro 5 + Starlight) – React islands only

> The `ui-kit` package must stay framework-agnostic beyond React/Radix. Do **not** import domain or
> adapter packages from here.

## Installation & build

```bash
pnpm install
pnpm --filter @harmony/ui-kit build          # emits dist/index.js + dist/ui.css
pnpm --filter @harmony/ui-kit storybook      # optional local playground
pnpm --filter @harmony/ui-kit test           # Vitest + RTL
```

## Tailwind v4 preset & CSS

- Consumers should reuse the shared preset exported from `@harmony/config/tailwind-preset` and the
  PostCSS preset from `@harmony/config/postcss-preset.mjs`.
- Tailwind content globs **must** include this package so classes are not purged:

```ts
// Example: apps/ai-console/tailwind.config.ts
import preset from '@harmony/config/tailwind-preset';

const config = {
  presets: [preset],
  content: [
    './app/**/*.{ts,tsx}',
    '../../packages/ui-kit/src/**/*.{ts,tsx}'
  ],
  darkMode: ['class']
};
export default config;
```

- For surfaces that do **not** want Tailwind tooling (e.g., Astro pages with limited React islands),
  import the prebuilt stylesheet instead:

```ts
// Astro component
import '@harmony/ui-kit/dist/ui.css';
```

## Usage in Next.js (apps/ai-console)

1. Ensure Tailwind and PostCSS configs mirror the example above.
2. Import the global Tailwind entry in `app/layout.tsx`:

```tsx
import './globals.css';
import { Button } from '@harmony/ui-kit';

export default function Page() {
  return (
    <main className="p-6">
      <Button variant="default">Primary action</Button>
    </main>
  );
}
```

## Usage in Astro (apps/web, apps/docs)

1. Install the React integration (`@astrojs/react`) and enable it in `astro.config.ts`.
2. Import Tailwind (or the prebuilt CSS) inside Astro layouts.
3. Wrap ui-kit components inside **a single island per interactive region** to avoid cross-island
   context issues:

```tsx
// src/components/islands/cta-button.tsx
'use client';
import { Button } from '@harmony/ui-kit';

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
4. Document new patterns in `docs/specs/adr-ui-kit-shadcn.md` and update the contributor guide when
   deviating from the defaults.

Questions? Reach out in the Harmony #ui channel and link your Spec + ADR before shipping changes.
