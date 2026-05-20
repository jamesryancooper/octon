---
title: Migration Proposal Standard
description: Required files and migration-specific constraints for v1 migration proposals.
---

# Migration Proposal Standard

Migration proposals extend `proposal-standard.md`.

Lifecycle gates, receipt requirements, and closeout/archive semantics are owned
by `proposal-standard.md`. This subtype standard only adds migration-specific
content requirements.

Canonical path:

- `/.octon/inputs/exploratory/proposals/migration/<proposal_id>/`
- the final directory name must equal `proposal_id` with no numeric prefix

Required files:

- `migration-proposal.yml`
- `migration/plan.md`
- `migration/release-notes.md`
- `migration/rollback.md`
- `support/implementation-grade-completeness-review.md` before `in-review`

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
- `navigation/source-of-truth-map.md` must identify the durable authorities,
  proposal-local lifecycle sources, derived projections, retained evidence
  surfaces, and boundary rules for the migration.
- `implemented` means the migration's final-state contract is live, required
  validation evidence exists, and no staged coexistence remains unless the
  selected profile explicitly permits it.

## Implementation-Grade Requirements

Migration proposals are implementation-grade complete only when they define:

- source-to-target artifact mapping;
- the atomic or transitional change profile and release state;
- rollback triggers and rollback mechanics;
- affected references, generated outputs, validators, and fixtures;
- evidence and closeout requirements;
- explicit blockers for any retained coexistence or staged behavior.
