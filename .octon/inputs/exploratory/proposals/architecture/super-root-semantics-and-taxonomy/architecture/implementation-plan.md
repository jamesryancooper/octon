# Implementation Plan

This proposal is the architectural anchor for the full super-root migration.
Its implementation work is partly immediate contract rewriting and partly the
sequencing rule that all later packets must obey.

## Workstream 1: Replace The Root Contract

- Rewrite the durable root framing in `.octon/README.md`, `.octon/instance/bootstrap/START.md`,
  `.octon/framework/cognition/_meta/architecture/shared-foundation.md`, and
  `.octon/framework/cognition/_meta/architecture/specification.md`.
- Remove the old mixed-tree language that treats `.octon/` as a copyable
  domain-first harness with one catch-all state remainder.
- Make the five-class taxonomy the canonical mental model for portability,
  authority, state, and rebuildability.

## Workstream 2: Establish The Super-Root Control Plane

- Extend `.octon/octon.yml` into the authoritative super-root manifest with:
  - class-root bindings
  - harness release version and supported schema versions
  - extension API version
  - install, export, and update profiles
  - raw-input dependency policy
  - generated-output freshness policy
  - migration workflow references
- Introduce `framework/manifest.yml` and `instance/manifest.yml` as required
  companion manifests.
- Replace the old `profiles:` allowlist model with profile-driven portability.

## Workstream 3: Introduce Class Roots And Placement Rules

- Create `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`
  under `/.octon/`.
- Keep internal domain organization within `framework/` and `instance/`.
- Keep lifecycle organization within `inputs/`.
- Keep operational-kind organization within `state/`.
- Keep output-kind organization within `generated/`.
- Add scaffolding and documentation so new artifacts land under the correct
  class root from first write.

## Workstream 4: Enforce Authority And Dependency Boundaries

- Add validators that reject direct runtime or policy dependence on raw
  `inputs/**`.
- Add validators that reject artifacts placed under the wrong class root when
  the class contract declares the allowed home.
- Add validators that reject missing, incompatible, or unresolved required
  manifests.
- Add freshness and provenance requirements for required runtime-facing
  effective outputs.
- Fail closed on native or extension collisions in active compiled views.

## Workstream 5: Rehome Generated Outputs First

- Move generated and effective outputs into `generated/**` early because they
  are easiest to regenerate and least authoritative.
- Publish artifact maps and generation locks with required effective outputs.
- Update runtime and inspection consumers to read generated effective views
  from the new class root rather than legacy mixed paths.

## Workstream 6: Rehome Operational Truth Before Scope Expansion

- Move repo continuity and retained evidence into `state/**`.
- Move control-plane operational truth into `state/control/**`.
- Land locality registry and validation before any scope continuity is added.
- Introduce scope continuity only after locality resolution is canonical and
  validated.

## Workstream 7: Rehome Durable Repo Authority

- Move repo-owned ingress, bootstrap, locality, shared context, ADRs,
  repo-native capabilities, missions, and desired extension configuration into
  `instance/**`.
- Split `instance/**` into instance-native and overlay-capable surfaces.
- Keep ingress adapters at repo root thin and refreshable.

## Workstream 8: Internalize Raw Inputs After Boundary Enforcement

- Internalize extension packs into `inputs/additive/extensions/**`.
- Internalize raw proposals into `inputs/exploratory/proposals/**`.
- Do not allow runtime or policy consumers to read those raw inputs directly.
- Introduce the desired, actual, quarantine, and compiled extension pipeline
  only after raw-input dependency enforcement is live.

## Workstream 9: Complete Validation, Cutover, And Cleanup

- Add cutover workflows and validators that block partial mixed-path
  migrations.
- Add compatibility adapters only where necessary and only with explicit
  expiration.
- Remove legacy mixed-path and external-workspace support after the class-root
  model, profiles, and validators are all live.
- Preserve one authoritative super-root throughout the migration; do not
  create parallel authority surfaces.

## Ratified Downstream Packet Order

The downstream execution order remains:

1. root manifest, profiles, and export semantics
2. framework/core architecture
3. repo-instance architecture
4. overlay and ingress model
5. locality and scope registry
6. state, evidence, and continuity
7. inputs/additive/extensions
8. inputs/exploratory/proposals
9. generated/effective/cognition/registry
10. memory, context, ADRs, and operational decision evidence
11. capability routing and host integration
12. portability, compatibility, trust, and provenance
13. validation, fail-closed, quarantine, and staleness
14. migration and rollout

## Non-Negotiable Sequencing Constraints

- Do not land internalized raw inputs before the raw-input dependency ban is
  validator-enforced.
- Do not land scope continuity before locality registry and validation are in
  place.
- Do not ship `repo_snapshot` without enabled-pack dependency closure.
- Do not remove legacy paths before the profile model and cutover workflows
  are live.
- Do not let generated outputs or raw inputs become substitute authority
  surfaces.

## Impact Map

- docs and contracts:
  - root README and orientation
  - umbrella and shared-foundation architecture contracts
  - root and companion manifests
- validation and assurance:
  - class-placement validators
  - raw-input dependency checks
  - generated-output freshness checks
  - migration cutover gates
- migration workflows:
  - staged rehome workflows
  - compatibility shims with explicit removal conditions

## Exit Condition

This proposal is complete only when the durable `.octon/` architecture uses the
five-class super-root as its sole top-level taxonomy and no canonical runtime,
policy, or documentation surface depends on the legacy mixed-tree contract.
