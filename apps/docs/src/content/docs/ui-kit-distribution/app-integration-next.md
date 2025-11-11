---
title: Next.js App Integration (No Tailwind)
description: Import precompiled CSS from @harmony/ui, add app overrides and micro-utilities, and use CSS Modules for page specifics.
---

## Import UI Kit CSS and app overrides

```ts
// app/layout.tsx
import '@harmony/ui/dist/ui.css'
import './styles/app.css'
```

## Tokens + micro-utilities file

```css
/* app/styles/app.css */
:root {
  --brand: #3b82f6;
  --surface: #ffffff;
  --surface-2: #f7f7f8;
  --ink: #111827;
  --muted-ink: #6b7280;
  --space-1: .25rem; --space-2: .5rem; --space-3: .75rem; --space-4: 1rem;
  --space-5: 1.25rem; --space-6: 1.5rem; --space-8: 2rem; --space-10: 2.5rem;
  --fs-0: clamp(.875rem,.8rem+.2vw,1rem);
  --fs-1: clamp(1.125rem,1rem+.5vw,1.25rem);
  --fs-2: clamp(1.25rem,1.1rem+.8vw,1.5rem);
  --fs-3: clamp(1.5rem,1.2rem+1.2vw,2rem);
}
@layer base {}
@layer components {}
@layer utilities {
  .container { width: min(100% - 2rem, 72rem); margin-inline: auto; }
  .stack > * + * { margin-top: var(--space-4); }
  .stack--sm > * + * { margin-top: var(--space-2); }
  .stack--lg > * + * { margin-top: var(--space-6); }
  .cluster { display:flex; flex-wrap:wrap; align-items:center; gap:var(--space-3); }
  .cluster--lg { gap: var(--space-5); }
  .grid { display:grid; gap:var(--space-5); }
  @media (min-width:48rem){ .grid--2{grid-template-columns:repeat(2,1fr)} .grid--3{grid-template-columns:repeat(3,1fr)} }
}
```

## CSS Modules for page-specific styles

```css
/* components/Hero.module.css */
.root { padding-block: var(--space-10); }
.title { font-size: var(--fs-3); line-height: 1.1; }
.subtitle { color: var(--muted-ink); font-size: var(--fs-1); }
```

```tsx
// components/Hero.tsx
import s from './Hero.module.css'

export function Hero() {
  return (
    <section className={`${s.root} container stack`}>
      <h1 className={s.title}>Welcome</h1>
      <p className={s.subtitle}>Ship faster with our UI kit + Next.</p>
      <div className="cluster"><a className="button" href="#">Get started</a></div>
    </section>
  )
}
```

## Next.js configuration (if needed)

```js
// next.config.js
module.exports = {
  transpilePackages: ['@harmony/ui'],
}
```

## Turbopack notes

- Keep Tailwind disabled in the app. All styling arrives via precompiled CSS.
- Source maps: enable for the UI Kit build so class sources are traceable in dev.
- HMR/SSR: importing CSS from the kit works with Turbopack; ensure the kit build runs before `dev`.

## Common pitfalls

- Styles not applying: verify import order (`ui.css` first, then `app.css`), and check that the kit build ran.
- Overrides losing: use CSS Modules or `@layer` with the app CSS; avoid `!important`.
- Missing transpilation: if the kit ships untranspiled ESM/TS, add `transpilePackages` as shown above.


