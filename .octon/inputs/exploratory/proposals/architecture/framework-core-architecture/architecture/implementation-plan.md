# Implementation Plan

This proposal does not create a new top-level model. It finishes the
framework-side normalization of the ratified super-root so later proposals can
depend on a stable portable core bundle.

## Workstream 1: Finalize The Framework Boundary Contract

- Rewrite the durable framework boundary framing in `.octon/README.md`,
  `.octon/instance/bootstrap/START.md`,
  `.octon/framework/cognition/_meta/architecture/specification.md`, and
  `.octon/framework/cognition/_meta/architecture/shared-foundation.md` so
  they all describe `framework/**` as the portable authored core bundle.
- Explicitly document what belongs in `framework/**` versus `instance/**`,
  `inputs/**`, `state/**`, and `generated/**`.
- Remove residual language that treats framework as a generic shared tree
  rather than as a portable authored class root with strict boundaries.

## Workstream 2: Lock The Framework Control Surfaces

- Normalize `framework/manifest.yml` as the required framework companion
  manifest with the ratified field set and compatibility semantics.
- Normalize `framework/overlay-points/registry.yml` as the framework-owned
  overlay registry and keep its machine-declared shape aligned to the ratified
  blueprint.
- Keep these files subordinate to the root manifest while making them the only
  valid framework-scoped control surfaces for framework identity and overlay
  declaration.

## Workstream 3: Inventory And Normalize Portable Framework Content

- Inventory the current framework tree and confirm which authored assets belong
  in `framework/**`.
- Move or alias any remaining framework-worthy material from legacy mixed paths
  into the canonical framework domains.
- Ensure repo-specific ingress, bootstrap, locality, context, decisions,
  continuity, proposals, state, and generated outputs are not treated as
  framework content.
- Preserve internal domain organization within framework during the cleanup.

## Workstream 4: Enforce Placement, Overlay, And Helper Rules

- Add validators that reject wrong-class placement of repo-specific authority
  into `framework/**`.
- Add validators that reject mutable state, retained evidence, raw inputs, and
  generated outputs when they appear under `framework/**`.
- Add validators that reject undeclared instance shadowing of framework
  artifacts and attempts to overlay closed framework surfaces.
- Add helper-surface checks so framework `_ops/**` paths remain portable
  helpers rather than repo-state sinks.

## Workstream 5: Align Profile, Update, And Migration Semantics

- Ensure `bootstrap_core` and `repo_snapshot` treat the full framework tree as
  the portable authored bundle.
- Ensure framework update and migration workflows operate on `framework/**`,
  root version bindings, and explicit migration contracts only.
- Prevent normal update paths from rewriting repo-owned instance, state, or
  proposal content.
- Keep compatibility checks tied to `framework/manifest.yml` and the root
  manifest rather than to ad hoc path assumptions.

## Workstream 6: Update Operator Guidance And Scaffolding

- Update bootstrap and export guidance so operators understand framework as the
  portable authored core bundle.
- Update scaffolding and proposal templates so new framework-facing artifacts
  land under the correct class root by default.
- Update workflow and runbook guidance so later packet work inherits the
  framework boundary instead of reinterpreting it.

## Workstream 7: Add Cutover Gates And Remove Residual Ambiguity

- Add cutover validation that blocks partial framework migration states where
  repo-specific or generated material still masquerades as framework content.
- Remove or clearly mark transitional assumptions once framework placement and
  validation rules are live.
- Preserve one authoritative framework bundle throughout the migration; do not
  create a parallel "shared" or "portable" surface outside `framework/**`.

## Downstream Dependency Impact

This proposal is a prerequisite for:

- repo-instance architecture
- overlay and ingress model
- locality and scope registry
- portability, compatibility, trust, and provenance
- unified validation, fail-closed, quarantine, and staleness semantics
- the final migration and rollout plan

## Exit Condition

This proposal is complete only when the durable `.octon/` control plane,
architecture docs, validators, and workflows all agree that `framework/**` is
the portable authored core bundle and that framework updates do not rely on
mixed-tree assumptions about repo authority, state, generated outputs, or raw
inputs.
