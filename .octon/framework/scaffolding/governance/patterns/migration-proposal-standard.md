---
title: Migration Proposal Standard
description: Required files and migration-specific constraints for v1 migration proposals.
---

# Migration Proposal Standard

Migration proposals extend `proposal-standard.md`.

Canonical path:

- `/.octon/inputs/exploratory/proposals/migration/<proposal_id>/`
- the final directory name must equal `proposal_id` with no numeric prefix

Required files:

- `migration-proposal.yml`
- `migration/plan.md`
- `migration/release-notes.md`
- `migration/rollback.md`

## Subtype Manifest Contract

`migration-proposal.yml` must define:

- `schema_version`
- `change_profile`
- `release_state`

Allowed values:

- `schema_version`: `migration-proposal-v1`
- `change_profile`: `atomic` | `transitional`
- `release_state`: `pre-1.0` | `stable`

Rules:

- `migration/plan.md` must follow the clean-break migration plan template
  sections exactly.
- `migration/release-notes.md` must describe the final-state cutover only.
- `migration/rollback.md` must name rollback trigger conditions and evidence
  references.
