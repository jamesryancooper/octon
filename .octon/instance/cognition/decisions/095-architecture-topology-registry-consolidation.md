# ADR 095: Architecture Topology Registry Consolidation

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`
  - `/.octon/README.md`
  - `/.octon/instance/bootstrap/START.md`
  - `/.octon/instance/ingress/AGENTS.md`

## Context

The live repo carried repeated topology truth across the umbrella
specification, the super-root README, bootstrap orientation, and ingress.
Those docs had started to drift in overlay-point, ingress, and historical
cutover details.

The remediation packet required a single machine-readable topology and
authority registry, with human-readable docs demoted to generated or
registry-checked projections.

## Decision

Make `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
the canonical machine-readable topology and authority registry.

Rules:

1. The registry owns `class_roots`, `delegated_registries`, `path_families`,
   `publication_metadata`, and `doc_targets`.
2. Active topology docs are registry-backed summaries, not competing path
   encyclopedias.
3. Delegated machine-readable subregistries remain authoritative for overlay
   points, ingress read order, and ADR discovery.
4. Historical wave, cutover, and proposal-lineage narrative moves to ADRs or
   retained migration evidence instead of remaining in active docs.
5. The active doc roles are narrowed as follows:
   - `/.octon/README.md` is the concise super-root overview.
   - `specification.md` is the steady-state structural contract narrative.
   - `START.md` is the boot-sequence orientation surface.
   - `instance/ingress/AGENTS.md` is the ingress and execution-posture surface.

## Consequences

- Topology truth becomes easier to validate and less drift-prone.
- Active docs become smaller, more role-specific, and more operator-legible.
- Validators can check doc scope against explicit registry metadata.
