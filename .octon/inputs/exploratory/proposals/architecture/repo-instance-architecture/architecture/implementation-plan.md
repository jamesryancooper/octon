# Implementation Plan

This proposal does not introduce a new top-level topology. It finishes the
repo-instance side of the ratified super-root so later proposals can depend on
one stable repo-owned authority layer.

## Workstream 1: Finalize The Repo-Instance Boundary Contract

- Rewrite the durable repo-instance framing in `.octon/README.md`,
  `.octon/instance/bootstrap/START.md`,
  `.octon/framework/cognition/_meta/architecture/specification.md`, and
  `.octon/framework/cognition/_meta/architecture/shared-foundation.md` so
  they all describe `instance/**` as the canonical repo-owned durable layer.
- Explicitly document what belongs in `instance/**` versus `framework/**`,
  `inputs/**`, `state/**`, and `generated/**`.
- Remove residual language that treats instance as an informal catch-all or as
  a mutable workspace.

## Workstream 2: Lock The Instance Control Surfaces

- Normalize `instance/manifest.yml` as the required instance companion
  manifest with the ratified field set and enablement semantics.
- Normalize `instance/ingress/AGENTS.md` as the canonical internal ingress
  surface and keep repo-root adapters thin only.
- Normalize `instance/extensions.yml` as desired extension configuration and
  keep it separate from actual active state and compiled outputs.

## Workstream 3: Inventory And Normalize Durable Repo Authority

- Inventory the current instance tree and confirm which authored assets belong
  in `instance/**`.
- Move or alias remaining repo-owned bootstrap, locality, context, decision,
  mission, and repo-native capability artifacts into their canonical instance
  paths.
- Ensure mutable continuity, retained evidence, generated outputs, raw packs,
  and raw proposals are not treated as instance content.
- Preserve internal domain organization within instance during cleanup.

## Workstream 4: Separate Instance-Native From Overlay-Capable Content

- Keep canonical instance-native surfaces under `instance/manifest.yml`,
  `instance/ingress/**`, `instance/bootstrap/**`, `instance/locality/**`,
  `instance/cognition/**`, `instance/capabilities/runtime/**`,
  `instance/orchestration/missions/**`, and `instance/extensions.yml`.
- Prepare overlay-capable paths under `instance/governance/**`,
  `instance/agency/runtime/**`, and `instance/assurance/runtime/**` so Packet
  5 can land machine-enforced overlay rules without further path churn.
- Do not allow blanket instance shadowing of framework paths while this work
  lands.

## Workstream 5: Enforce Placement, Ingress, Extension, And Collision Rules

- Add validators that reject wrong-class placement of mutable state, retained
  evidence, raw inputs, or generated outputs into `instance/**`.
- Add validators that reject ingress drift away from
  `instance/ingress/AGENTS.md`.
- Add validators that reject invalid overlay-capable artifacts when no
  declared enabled overlay point covers them.
- Add validators that reject repo-native capability collisions with additive
  packs or published extension contributions unless a declared collision
  policy exists.

## Workstream 6: Align Portability, Update, And Migration Semantics

- Ensure `bootstrap_core` retains only the minimal `instance/manifest.yml`
  seed rather than shipping repo authority by default.
- Ensure `repo_snapshot` treats `instance/**` as required repo-owned durable
  authority.
- Ensure framework update and migration workflows preserve repo-owned ingress,
  bootstrap, locality, context, decisions, and missions unless an explicit
  migration contract says otherwise.
- Keep desired extension configuration repo-owned even when enabled-pack
  payloads travel in `repo_snapshot`.

## Workstream 7: Prepare Downstream Packet Work

- Give Packet 5 a stable set of overlay-capable paths and a canonical ingress
  home.
- Give Packet 6 a stable locality authority home under `instance/locality/**`.
- Give Packet 7 a clear separation between durable authority in `instance/**`
  and mutable operational truth in `state/**`.
- Give Packet 8 a clear separation between desired extension configuration in
  `instance/**`, actual state in `state/**`, and compiled outputs in
  `generated/**`.
- Give Packet 11 stable routing targets for durable context and ADRs under
  `instance/cognition/**`.

## Downstream Dependency Impact

This proposal is a prerequisite for:

- overlay and ingress model
- locality and scope registry
- state, evidence, and continuity architecture
- inputs/additive/extensions architecture
- memory, context, ADRs, and operational decision evidence
- unified validation, fail-closed, quarantine, and staleness semantics
- the final migration and rollout plan

## Exit Condition

This proposal is complete only when the durable `.octon/` control plane,
architecture docs, validators, and workflows all agree that `instance/**` is
the canonical home for repo-specific durable authority and that no mutable
state, generated outputs, or raw inputs masquerade as repo-instance source of
truth.
