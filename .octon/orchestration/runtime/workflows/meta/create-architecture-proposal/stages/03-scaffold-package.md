---
title: Scaffold Architecture Proposal
description: Materialize the package from canonical templates and render package-specific placeholders.
---

# Step 3: Scaffold Architecture Proposal

## Purpose

Create a standard-governed architecture proposal that is immediately valid against the
baseline standard validator.

## Actions

1. Create `.proposals/architecture/<proposal_id>/`.
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
6. Add or update the matching active entry in `.proposals/registry.yml`.
7. Record the scaffolded package inventory so later stages can prove the exact
   on-disk shape that passed validation.

## Proceed When

- [ ] Package directory exists
- [ ] `design-package.yml` exists
- [ ] `.proposals/registry.yml` includes the scaffolded package
- [ ] Core artifacts exist
- [ ] Class-specific required docs exist
- [ ] Selected optional modules exist
- [ ] Scaffold inventory can be captured without guesswork
