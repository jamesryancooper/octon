---
title: Scaffold Architecture Proposal
description: Materialize the package from canonical templates and render package-specific placeholders.
---

# Step 3: Scaffold Architecture Proposal

## Purpose

Create a standard-governed architecture proposal that is immediately valid
against the fail-closed proposal validator stack.

## Actions

1. Create `.octon/inputs/exploratory/proposals/architecture/<proposal_id>/`.
2. Materialize `proposal-core/` and `proposal-architecture-core/`.
3. Render:
   - `proposal.yml`
   - `architecture-proposal.yml`
   - architecture working docs
   - generated navigation files
4. Regenerate `navigation/artifact-catalog.md` from the on-disk package shape.
5. Render `navigation/source-of-truth-map.md` from the architecture subtype
   contract.
6. Regenerate `.octon/generated/proposals/registry.yml` from manifests by
   invoking the canonical projection generator.
7. Record the scaffolded package inventory so later stages can prove the exact
   on-disk shape that passed validation.

## Proceed When

- [ ] Package directory exists
- [ ] `architecture-proposal.yml` exists
- [ ] `.octon/generated/proposals/registry.yml` includes the scaffolded package
- [ ] Core artifacts exist
- [ ] Architecture required docs exist
- [ ] Scaffold inventory can be captured without guesswork
