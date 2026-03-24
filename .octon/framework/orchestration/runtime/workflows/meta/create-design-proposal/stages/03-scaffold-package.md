---
title: Scaffold Design Package
description: Materialize the package from canonical templates and render package-specific placeholders.
---

# Step 3: Scaffold Design Package

## Purpose

Create a standard-governed design proposal that is immediately valid against the
baseline standard validator.

## Actions

1. Create `.octon/inputs/exploratory/proposals/design/<proposal_id>/`.
2. Compose:
   - `design-proposal-core/`
   - one class overlay
   - selected optional overlays
3. Materialize:
   - `design-proposal.yml`
   - core navigation and implementation docs
   - class-specific `normative/` docs
   - selected optional-module docs and directories
4. Regenerate `navigation/artifact-catalog.md` from the on-disk package shape.
5. Render `navigation/source-of-truth-map.md` from the selected class and
   modules.
6. Regenerate `.octon/generated/proposals/registry.yml` from manifests by
   invoking the canonical projection generator.
7. Record the scaffolded package inventory so later stages can prove the exact
   on-disk shape that passed validation.

## Proceed When

- [ ] Package directory exists
- [ ] `design-proposal.yml` exists
- [ ] `.octon/generated/proposals/registry.yml` includes the scaffolded proposal
- [ ] Core artifacts exist
- [ ] Class-specific required docs exist
- [ ] Selected optional modules exist
- [ ] Scaffold inventory can be captured without guesswork
