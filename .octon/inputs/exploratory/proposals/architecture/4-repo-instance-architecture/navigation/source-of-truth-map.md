# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-instance identity, framework binding, enabled overlay points, locality binding, and feature toggles | `.octon/instance/manifest.yml` | Required instance companion manifest after promotion |
| Canonical internal ingress | `.octon/instance/ingress/AGENTS.md` | Repo-root `AGENTS.md` and `/.octon/AGENTS.md` remain thin adapters only |
| Repo bootstrap and operator-facing onboarding guidance | `.octon/instance/bootstrap/**` | Repo-specific bootstrap content lives in instance, not framework |
| Repo-local locality manifest, registry, and scope definitions | `.octon/instance/locality/**` | Locality is root-owned durable repo authority, not state or framework content |
| Repo-shared and scope-specific durable context | `.octon/instance/cognition/context/**` | Durable authored context remains separate from mutable continuity and generated summaries |
| Durable architecture decisions and ADRs | `.octon/instance/cognition/decisions/**` | Authored decision authority belongs in instance rather than state evidence |
| Repo-native capabilities | `.octon/instance/capabilities/runtime/**` | Allowed only for truly repo-specific capabilities; reusable packs belong under `inputs/additive/extensions/**` |
| Repo-owned missions and orchestration artifacts | `.octon/instance/orchestration/missions/**` | Missions may reference scopes, but scope authority remains under `instance/locality/**` |
| Desired extension selection, sources, trust, and acknowledgements | `.octon/instance/extensions.yml` | Repo-controlled desired configuration, not actual active state |
| Overlay declaration and enablement constraints | `.octon/framework/overlay-points/registry.yml` and `.octon/instance/manifest.yml` | Instance overlay-capable content is valid only when framework declares the point and instance enables it |
| Super-root profile, update, and preservation semantics for instance content | `.octon/octon.yml` | `bootstrap_core` excludes instance except the minimal manifest seed; `repo_snapshot` includes the instance layer |
| Cross-subsystem instance boundary and authority precedence | `.octon/framework/cognition/_meta/architecture/specification.md` and `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Canonical architecture surfaces after promotion |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Actual active extension state | `.octon/state/control/extensions/active.yml` | Derived published operational truth must not be confused with desired config in `instance/extensions.yml` |
| Extension quarantine and withdrawal state | `.octon/state/control/extensions/quarantine.yml` | Mutable control state for blocked packs and dependents lives under `state/**`, not `instance/**` |
| Runtime-facing compiled extension outputs | `.octon/generated/effective/extensions/**` | Runtime consumes compiled validated outputs, never raw pack paths or desired config directly |
| Mutable continuity and retained evidence excluded from instance | `.octon/state/continuity/**` and `.octon/state/evidence/**` | Repo continuity, scope continuity, run evidence, and validation receipts are not repo-instance authority |
| Rebuildable effective and inspection outputs excluded from instance | `.octon/generated/**` | Effective views, graphs, summaries, projections, and registries remain derived outputs only |
| Proposal discovery for this temporary package | `.octon/generated/proposals/registry.yml` | Derived non-authoritative registry that must list this active proposal package |
| Wrong-class placement, ingress, overlay, and extension validation | `.octon/framework/assurance/runtime/**` | Validators reject wrong-class placement, undeclared overlays, invalid manifest control data, and extension/capability collisions |
| Migration and update orchestration for repo-instance surfaces | `.octon/framework/orchestration/runtime/workflows/**` | Update flows preserve repo-owned authority unless an explicit migration contract applies |

## Boundary Rules

- `instance/**` is the repo-specific durable authoritative layer.
- `instance/**` contains repo-owned authored authority and control metadata,
  not mutable operational truth.
- Mutable continuity, retained evidence, and quarantine state belong in
  `state/**`, not `instance/**`.
- Rebuildable effective views, summaries, graphs, projections, and registries
  belong in `generated/**`, not `instance/**`.
- Raw extension packs and raw proposals belong in `inputs/**`, not
  `instance/**`.
- Canonical ingress content lives under `instance/ingress/**`; root adapters
  are projections only.
- Overlay-capable instance content is legal only at framework-declared
  overlay points that the instance manifest enables.
- Repo-native capabilities under `instance/capabilities/runtime/**` must stay
  repo-specific and must not silently collide with enabled additive packs.
