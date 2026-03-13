---
title: Select Template Bundles
description: Resolve the template composition and selected module set.
---

# Step 2: Select Template Bundles

## Purpose

Choose the exact template bundle composition before any files are written.

## Actions

1. Always include the core template:
   `.octon/scaffolding/runtime/templates/design-package-core/`
2. Include exactly one class overlay:
   - `design-package-domain-runtime/`, or
   - `design-package-experience-product/`
3. Apply class defaults:
   - `domain-runtime` -> `reference`, `history`, `contracts`, `conformance`,
     `canonicalization`
   - `experience-product` -> `reference`, `history`
4. Apply boolean overrides for:
   - `include_contracts`
   - `include_conformance`
   - `include_canonicalization`
5. Resolve the final `selected_modules` list recorded in `design-package.yml`.

## Proceed When

- [ ] Core template is selected
- [ ] Class overlay is selected
- [ ] Final selected_modules list is explicit
- [ ] Validation paths implied by the module set are known
