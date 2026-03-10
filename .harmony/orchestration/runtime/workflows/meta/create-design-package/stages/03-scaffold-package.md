---
title: Scaffold Design Package
description: Materialize the package from canonical templates and render package-specific placeholders.
---

# Step 3: Scaffold Design Package

## Purpose

Create a standard-governed design package that is immediately valid against the
baseline standard validator.

## Actions

1. Create `.design-packages/<package_id>/`.
2. Compose:
   - `design-package-core/`
   - one class overlay
   - selected optional overlays
3. Materialize:
   - `design-package.yml`
   - core navigation and implementation docs
   - class-specific `normative/` docs
   - selected optional-module docs and directories
4. Regenerate `navigation/artifact-catalog.md` from the on-disk package shape.
5. Render `navigation/source-of-truth-map.md` from the selected class and
   modules.

## Proceed When

- [ ] Package directory exists
- [ ] `design-package.yml` exists
- [ ] Core artifacts exist
- [ ] Class-specific required docs exist
- [ ] Selected optional modules exist
