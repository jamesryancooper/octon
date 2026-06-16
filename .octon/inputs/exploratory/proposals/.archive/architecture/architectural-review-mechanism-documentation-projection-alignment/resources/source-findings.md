# Source Findings

## Executive Finding

The native Architectural Review Mechanism is substantially present, but
incomplete and partially stale across documentation, invocation, generated
projection, and navigation surfaces.

## Findings To Address

1. Product feature omission is currently intentional, but likely creates
   navigation debt for an operator-visible, lifecycle-gated mechanism.
2. `architecture-readiness-audit` is canonical and should remain so.
3. The retired `audit-architecture-readiness` name should remain absent from
   live authored runtime, skill, command, and generated invocation surfaces.
4. `domain-architecture-audit` and `surface-architecture-audit` are canonical
   in methodology and report schema surfaces, but existing invocation surfaces
   use `audit-domain-architecture` and `audit-surface-architecture`.
5. The governed mechanism index lists the main architectural-review workflow
   and skill surfaces but omits explicit coverage for domain and surface audit
   modes.
6. Command facade coverage is ambiguous for `architecture-readiness-audit`,
   domain architecture audit, and surface architecture audit.
7. Existing architectural-review validators pass for the covered modes but do
   not fully enforce domain/surface canonical mapping or documented omission
   rationales.
8. Capability publication validation reported stale shared projection state
   because unrelated closeout skill digests were stale, even though
   architectural-review entries themselves were current.
9. Generated proposal projections became stale relative to the current
   worktree after an additional active proposal packet appeared.
10. Archived architectural-review proposal packets validate but some artifact
    catalogs omit visible files, which is retained-evidence hygiene rather
    than native authority failure.

## Non-Negotiable Boundaries

- Do not hand-edit generated projections.
- Do not treat generated files as authority.
- Do not promote extension-owned packetization into native Octon.
- Do not collapse distinct review modes.
- Do not claim a lifecycle gate exists unless a validator or workflow contract
  enforces it.
- Preserve post-integration and current-state mechanism reviews as
  evidence-only unless an explicit lifecycle policy changes them.
