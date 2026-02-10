---
title: Examples
description: Worked examples for the audit-ui skill.
---

# Examples

## Example: Component Library Audit

### Invocation

```
/audit-ui target="src/components/" file_types="tsx,css"
```

### Execution Trace

1. **Fetch Ruleset** — WebFetch default URL, parsed 112 rules across 8 categories (accessibility: 28, performance: 15, forms: 14, focus-states: 12, animations: 10, typography: 11, images: 10, dark-mode: 12)

2. **Discover Files** — Glob for `*.tsx` and `*.css` in `src/components/`, found 23 files

3. **Scan & Classify** — Read each file, checked against applicable rules:
   - `Button.tsx:42` — Missing `focus-visible` outline (HIGH)
   - `Modal.tsx:15` — No `aria-label` on close button (CRITICAL)
   - `Modal.tsx:67` — Focus not trapped inside modal (CRITICAL)
   - `Card.css:23` — No dark mode variant for background color (MEDIUM)
   - `Input.tsx:31` — Missing `aria-describedby` for error message (HIGH)
   - `Input.tsx:55` — No `aria-invalid` state on validation error (HIGH)
   - `Tooltip.css:8` — Animation uses `left` instead of `transform` (LOW)

4. **Report** — Generated findings report with 7 violations (2 CRITICAL, 3 HIGH, 1 MEDIUM, 1 LOW) and 16 clean files

### Output Report (Abbreviated)

```markdown
# UI Audit Report — 2026-02-09

## Executive Summary
- Files scanned: 23
- Violations found: 7 (CRITICAL: 2, HIGH: 3, MEDIUM: 1, LOW: 1)
- Rules applied: 112 from 8 categories
- Ruleset source: https://raw.githubusercontent.com/.../web_interface_guidelines.md

## Findings

### CRITICAL
- `src/components/Modal.tsx:15` — **[a11y-aria-label]** Close button missing aria-label. Add `aria-label="Close"` to the button element.
- `src/components/Modal.tsx:67` — **[a11y-focus-trap]** Modal does not trap focus. Implement focus trapping to prevent tabbing outside the modal.

### HIGH
- `src/components/Button.tsx:42` — **[focus-visible]** Interactive element missing visible focus indicator. Add `outline` or `ring` on `:focus-visible`.
- `src/components/Input.tsx:31` — **[forms-describedby]** Error message not linked to input. Add `aria-describedby` pointing to the error element ID.
- `src/components/Input.tsx:55` — **[forms-invalid]** Input does not indicate invalid state to assistive technology. Add `aria-invalid={true}` when validation fails.

### MEDIUM
- `src/components/Card.css:23` — **[dark-mode-bg]** Background color has no dark mode variant. Add `@media (prefers-color-scheme: dark)` or dark class variant.

### LOW
- `src/components/Tooltip.css:8` — **[animation-transform]** Animation uses `left` property instead of `transform`. Use `transform: translateX()` for GPU-accelerated animation.

## Clean Files
Files scanned with no violations:
- src/components/Header.tsx
- src/components/Footer.tsx
- src/components/Nav.tsx
- ... (13 more)
```
