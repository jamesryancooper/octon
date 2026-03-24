---
title: Scaffold Migration Proposal
description: Materialize the package from canonical templates and render package-specific placeholders.
---

# Step 3: Scaffold Migration Proposal

## Purpose

Create a standard-governed migration proposal that is immediately valid against
the fail-closed proposal validator stack.

## Actions

1. Create `.octon/inputs/exploratory/proposals/migration/<proposal_id>/`.
2. Materialize `proposal-core/` and `proposal-migration-core/`.
3. Render:
   - `proposal.yml`
   - `migration-proposal.yml`
   - migration working docs
   - generated navigation files
4. Regenerate `navigation/artifact-catalog.md` from the on-disk package shape.
5. Render `navigation/source-of-truth-map.md` from the migration subtype
   contract.
6. Regenerate `.octon/generated/proposals/registry.yml` from manifests by
   invoking the canonical projection generator.
7. Record the scaffolded package inventory so later stages can prove the exact
   on-disk shape that passed validation.

## Proceed When

- [ ] Package directory exists
- [ ] `migration-proposal.yml` exists
- [ ] `.octon/generated/proposals/registry.yml` includes the scaffolded package
- [ ] Core artifacts exist
- [ ] Migration required docs exist
- [ ] Scaffold inventory can be captured without guesswork
