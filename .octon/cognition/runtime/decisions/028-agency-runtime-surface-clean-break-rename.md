# ADR 028: Agency Runtime Surface Clean-Break Rename

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: agency runtime surface naming `actors/` in active docs/contracts/validators

## Context

Agency already applies bounded surfaces, but its runtime surface was still named
`actors/` while other bounded-surface domains use `runtime/`.

This naming mismatch increased cognitive load for discovery and contract
enforcement, and it created validator/documentation drift where both `actors/`
and `runtime/` appeared in active artifacts.

## Decision

Adopt `/.octon/agency/runtime/` as the sole canonical runtime surface and
remove `/.octon/agency/actors/` in a clean-break migration.

All active agency references, templates, architecture contracts, and validators
must resolve runtime artifacts exclusively through `agency/runtime/*`.

CI and local guardrails must fail if deprecated `agency/actors` paths
reappear.

## Consequences

### Benefits

- Architectural clarity: agency now uses the same runtime surface name as other
  bounded domains.
- Correctness: one canonical runtime path removes split authority and reference
  ambiguity.
- Better agent discovery: path semantics are uniform across domains.
- Stronger prevention: validators now enforce `agency/actors` deprecation.

### Risks

- Broad reference changes may miss active call-sites.
- Historical migration records still contain old path references.
- Validation gaps could allow regressions if not updated with the rename.

### Mitigations

- One-shot clean-break updates for docs, templates, and validators in the same
  change set.
- Explicit banlist entries for `agency/actors` identifiers and paths.
- Preserve historical append-only records and scope active enforcement to
  non-historical surfaces.
- Record migration plan plus execution evidence alongside the ADR.
