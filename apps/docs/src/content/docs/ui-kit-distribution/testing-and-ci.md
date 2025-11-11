---
title: Testing and CI
description: Verify the UI Kit with Storybook and visual testing; enforce style rules with linting.
---

## Storybook at the UI Kit level

- Build component stories in the UI Kit repository.
- Run visual regression via Chromatic or Playwright screenshot tests.
- Capture a11y checks (axe) and interaction tests (Testing Library) per component.

## Visual regression

Chromatic (hosted) or Playwright (self-hosted) both work:

- Baseline diffs on PRs; block merges on unacceptable visual drift.
- Tag stories for smoke vs full regressions to optimize CI runtime.

## Unit and interaction tests

- Use Vitest/Jest + Testing Library for DOM-level assertions.
- Prefer testing public component API and accessible states.

## Linting: CSS & Tailwind inside the kit

Keep Tailwind rules scoped to the UI Kit. In the kit, enforce:

```json
// packages/ui/.stylelintrc.json (example)
{
  "extends": [
    "stylelint-config-standard",
    "stylelint-config-recommended",
    "stylelint-config-css-modules"
  ],
  "rules": {
    "no-descending-specificity": null,
    "selector-max-specificity": "0,3,1"
  }
}
```

## CI guardrails

- Run `typecheck`, `lint`, `test`, `build` on PRs.
- Generate a SBOM and run dependency scans.
- Upload Storybook static and visual results as artifacts for review.


