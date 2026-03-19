# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repo-side locality binding into the instance layer | `.octon/instance/manifest.yml` | `locality.registry_path` and `locality.manifest_path` bind repo instance control metadata to the canonical locality surfaces |
| Locality schema version, registry binding, and resolution mode | `.octon/instance/locality/manifest.yml` | `resolution_mode` is ratified as `single-active-scope` in v1 |
| Declared scope inventory and repo-level locality metadata | `.octon/instance/locality/registry.yml` | Authoritative inventory root for declared scopes; every declared scope must resolve to a canonical per-scope manifest |
| Canonical scope identity, rooted path binding, ownership, tags, and optional routing or mission defaults | `.octon/instance/locality/scopes/<scope-id>/scope.yml` | Each scope is authored once here and may declare exactly one `root_path` in v1 |
| Scope-specific durable authored context | `.octon/instance/cognition/context/scopes/<scope-id>/**` | Durable scope-local context belongs in `instance/**`, not in mutable continuity or generated summaries |
| Shared durable context versus scope-local context boundary | `.octon/framework/cognition/governance/principles/locality.md` and `.octon/instance/cognition/context/shared/**` | Shared repo context remains under `shared/**`; scope-specific durable context moves under `scopes/**` |
| Mission-to-scope references | `.octon/instance/orchestration/missions/**` | Missions may reference scopes, but scope identity and precedence remain under `instance/locality/**` |
| Single-root harness boundary for locality | `.octon/framework/cognition/governance/principles/locality.md` and `.octon/framework/capabilities/_meta/architecture/architecture.md` | Live framework docs already reject descendant `.octon/` roots and ancestor-chain ambiguity |
| Cross-subsystem locality placement, precedence, and portability semantics after promotion | `.octon/framework/cognition/_meta/architecture/specification.md` and `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Durable architecture references that must converge on the same scope registry contract |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Runtime-facing effective scope map | `.octon/generated/effective/locality/scopes.effective.yml` | Compiled non-authoritative scope view used by runtime-facing consumers |
| Effective locality provenance mapping | `.octon/generated/effective/locality/artifact-map.yml` | Maps compiled scope entries back to authoritative manifest and registry sources |
| Effective locality freshness receipt | `.octon/generated/effective/locality/generation.lock.yml` | Carries freshness and source-digest metadata for fail-closed runtime consumption |
| Invalid scope quarantine state | `.octon/state/control/locality/quarantine.yml` | Mutable control truth for locally quarantined scopes; not authored authority |
| Future scope continuity placement | `.octon/state/continuity/scopes/<scope-id>/**` | Downstream operational truth that remains blocked until locality registry and validation are live |
| Locality validation and fail-closed enforcement | `.octon/framework/assurance/runtime/**` | Validators must reject malformed manifests, overlapping scopes, stale effective outputs, and raw-path ambiguity |
| Scope-aware routing consumption | `.octon/generated/effective/capabilities/**` | Downstream routing may consume scope metadata from authoritative locality manifests and compiled locality outputs, not ad hoc path conventions |
| Proposal discovery for this temporary package | `.octon/generated/proposals/registry.yml` | Derived non-authoritative registry that should list this proposal package while active |

## Boundary Rules

- `instance/locality/**` is the only authored source of truth for scope
  identity and rooted path binding.
- In v1, each `scope_id` declares exactly one `root_path`, and each target
  path resolves to zero or one active scope.
- `generated/effective/locality/**` is non-authoritative, rebuildable,
  freshness-protected, and committed by default under the ratified generated
  output policy.
- `state/control/locality/quarantine.yml` is mutable operational control
  truth, not authored locality authority.
- Scope-local durable context belongs under `instance/cognition/context/scopes/**`;
  scope-local continuity belongs under `state/continuity/scopes/**` only after
  locality registry and validation are live.
- Missions may reference scopes but may not define scope identity, ownership,
  or precedence.
- Descendant-local `.octon/` roots, local sidecar locality systems,
  hierarchical scope inheritance, ancestor-chain composition, and disjoint
  multi-root scopes are invalid in v1.
