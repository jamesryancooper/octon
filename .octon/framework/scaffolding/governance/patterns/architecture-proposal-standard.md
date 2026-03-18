---
title: Architecture Proposal Standard
description: Required files and architecture-specific constraints for v1 architecture proposals.
---

# Architecture Proposal Standard

Architecture proposals extend `proposal-standard.md`.

Required files:

- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/acceptance-criteria.md`
- `architecture/implementation-plan.md`

Rules:

- `architecture/target-architecture.md` must describe the intended end state.
- `architecture/acceptance-criteria.md` must define conditions that prove the
  target architecture has landed.
- `architecture/implementation-plan.md` must translate the target architecture
  into implementable workstreams.
