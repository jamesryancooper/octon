# Subsystem Targeted Integration: Verify Subsystem Fit

Verify the subsystem-scoped extraction output against the live repository.

## Shared Contracts

- apply `../../shared/repository-grounding.md`
- apply `../../shared/architecture-review-method.md` when recommendations
  would produce, revise, harden, or approve architecture inside the subsystem

## Output

Emit a corrected recommendation set that:

- confirms the subsystem fit,
- identifies already-covered subsystem surfaces,
- checks current-system steelmanning, constraints, complexity, bottlenecks,
  failure modes, quality attributes, hardening, rollback, and Octon-fit gates
  for architecture recommendations,
- and records cross-subsystem dependencies that must be explicit in the final
  packet.
