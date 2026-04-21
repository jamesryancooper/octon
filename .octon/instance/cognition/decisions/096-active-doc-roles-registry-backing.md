# ADR 096: Active Doc Roles And Registry Backing

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`
  - `/.octon/README.md`
  - `/.octon/instance/bootstrap/START.md`
  - `/.octon/instance/ingress/AGENTS.md`
  - `/.octon/instance/ingress/manifest.yml`

## Context

The active docs had accumulated mixed responsibilities: operator onboarding,
structural placement, full path matrices, and historical migration narrative
were all blended together. That increased drift risk and made the steady-state
operating model harder to read.

## Decision

Assign narrow steady-state roles to the active docs and back those roles with
machine-readable `doc_targets` metadata in the architecture registry.

Rules:

1. `/.octon/README.md` is the concise super-root overview.
2. `specification.md` is the human-readable steady-state structural contract
   narrative.
3. `START.md` is the boot sequence and first-run orientation surface.
4. `instance/ingress/AGENTS.md` is the canonical internal ingress surface for
   required reads and execution posture.
5. Canonical path matrices, publication metadata, and consumer rules resolve
   from the registry, while ingress read order still resolves from the ingress
   manifest.

## Consequences

- The active docs become easier to keep aligned.
- Structural edits now have an explicit machine-readable doc-role contract.
- Historical material can move out of the live operator path without being
  lost.
