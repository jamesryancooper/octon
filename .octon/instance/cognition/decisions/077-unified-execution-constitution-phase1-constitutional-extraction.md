# ADR 077: Unified Execution Constitution Phase 1 Constitutional Extraction

- Date: 2026-03-28
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase1-constitutional-extraction/plan.md`
  - `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase1-constitutional-extraction/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

The governing packet's Phase 1 exit criteria require:

- one constitutional kernel exists
- old constitutional surfaces are shims, not conflicting authorities
- ingress reads the constitutional kernel first

The live repository already contains `framework/constitution/**`, but Phase 0
confirmed that:

- ingress still carried cognition architecture and principles in the critical
  read path
- projected ingress adapters widened the read path beyond the canonical
  internal ingress source
- old constitutional prose still existed outside the kernel, most visibly under
  agency, cognition, and assurance governance surfaces

Without an explicit Phase 1 cutover, Octon would keep a real kernel while still
advertising competing constitutional or quasi-constitutional surfaces beside it.

## Decision

Complete Phase 1 as an atomic singular-kernel cutover.

Rules:

1. `framework/constitution/**` remains the only repo-local constitutional
   kernel.
2. `instance/ingress/AGENTS.md` becomes the constitution-first minimal read
   set; projected ingress adapters stop widening that read path.
3. Old constitutional surfaces stay at their current paths only as explicit
   non-conflicting shims or subordinate overlays.
4. Validators and scaffolding must enforce the new ingress and shim contract so
   `/init` and local validation cannot reintroduce the pre-Phase-1 model.

## Consequences

### Benefits

- Repo-local constitutional authority becomes singular in both file placement
  and operator guidance.
- Old governance surfaces remain discoverable for compatibility, but they stop
  acting like peer constitutions.
- Bootstrap templates and validators preserve the same Phase 1 model as the
  live repo.

### Costs

- Several long-lived governance files become explicit shims, which may require
  downstream docs to update their framing over time.
- Historical references into legacy charter prose remain as lineage only, not
  live authority.

## Completion

This decision is complete once:

- live ingress and projected ingress adapters reflect the constitution-first
  minimal read set
- old constitutional surfaces are explicitly marked as shims or subordinate
  overlays
- validators and scaffolding align with the same Phase 1 model
