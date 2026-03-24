---
title: Architecture Proposal Standard
description: Required files and architecture-specific constraints for v1 architecture proposals.
---

# Architecture Proposal Standard

Architecture proposals extend `proposal-standard.md`.

Canonical path:

- `/.octon/inputs/exploratory/proposals/architecture/<proposal_id>/`
- the final directory name must equal `proposal_id` with no numeric prefix

Required files:

- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/acceptance-criteria.md`
- `architecture/implementation-plan.md`

## Subtype Manifest Contract

`architecture-proposal.yml` must define:

- `schema_version`
- `architecture_scope`
- `decision_type`

Allowed values:

- `schema_version`: `architecture-proposal-v1`
- `architecture_scope`: `repo-architecture` | `domain-architecture` |
  `cross-domain-architecture`
- `decision_type`: `new-surface` | `surface-refactor` | `boundary-change`

Rules:

- `architecture/target-architecture.md` must describe the intended end state.
- `architecture/acceptance-criteria.md` must define conditions that prove the
  target architecture has landed.
- `architecture/implementation-plan.md` must translate the target architecture
  into implementable workstreams.
