---
title: Migration Proposal Standard
description: Required files and migration-specific constraints for v1 migration proposals.
---

# Migration Proposal Standard

Migration proposals extend `proposal-standard.md`.

Required files:

- `migration-proposal.yml`
- `migration/plan.md`
- `migration/release-notes.md`
- `migration/rollback.md`

Rules:

- `migration/plan.md` must follow the clean-break migration plan template
  sections exactly.
- `migration/release-notes.md` must describe the final-state cutover only.
- `migration/rollback.md` must name rollback trigger conditions and evidence
  references.
