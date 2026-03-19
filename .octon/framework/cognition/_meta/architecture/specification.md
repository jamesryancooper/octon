---
title: Octon Harness Umbrella Specification
description: Canonical cross-subsystem contract for the Octon super-root.
status: Active
---

# Octon Harness Umbrella Specification

## Purpose

Define the authoritative cross-subsystem contract for `/.octon/` after the
super-root cutover.

## Root Invariants

1. `/.octon/` is the single authoritative super-root.
2. The only canonical class roots are `framework/`, `instance/`, `inputs/`,
   `state/`, and `generated/`.
3. Only `framework/**` and `instance/**` are authored authority.
4. `framework/**` is limited to portable authored core and portable helper
   assets only; repo-local mutable state, retained evidence, and generated
   outputs are forbidden there.
5. `state/**` is authoritative only as operational truth and retained
   evidence.
6. `generated/**` is never source of truth.
7. Raw `inputs/**` paths must never become direct runtime or policy
   dependencies.
8. Human-led ideation lives under `inputs/exploratory/ideation/**`.
9. Retired legacy roots from the mixed-tree topology must not be
   reintroduced.
10. `/.octon/octon.yml` is the authoritative root manifest for topology,
   versioning, profiles, and fail-closed policy hooks.
11. `repo_snapshot` is behaviorally complete and includes enabled-pack
    dependency closure.
12. `full_fidelity` is advisory only and is not a synthetic export payload.
13. `framework/overlay-points/registry.yml` is the canonical framework-authored
    overlay declaration surface.
14. `instance/manifest.yml#enabled_overlay_points` is the canonical repo-side
    overlay enablement surface.
15. Canonical internal ingress lives under `instance/ingress/**`;
    `/.octon/AGENTS.md` is the projected ingress surface; repo-root ingress
    files are thin adapters only.
16. Repo-root ingress files are valid only as a symlink to `/.octon/AGENTS.md`
    or a byte-for-byte parity copy.
17. Overlay-capable instance surfaces are legal only at framework-declared
    overlay points enabled by `instance/manifest.yml`.
18. Allowed v1 overlay merge modes are `replace_by_path`, `merge_by_id`, and
    `append_only`.
19. Overlay-capable artifacts may not target closed framework domains such as
    `framework/engine/runtime/**`.
20. Undeclared or disabled overlay artifacts fail closed.
21. Repo-owned bootstrap, locality, context, ADRs, repo-native capabilities,
    missions, and desired extension configuration belong in `instance/**`.
22. `instance/locality/manifest.yml`, `instance/locality/registry.yml`, and
    `instance/locality/scopes/<scope-id>/scope.yml` are the only authored
    locality authority surfaces.
23. In v1, each `scope_id` declares exactly one `root_path`.
24. In v1, locality resolution yields zero or one active scope per target
    path.
25. Descendant `.octon/` roots, hierarchical scope inheritance, and
    ancestor-chain scope composition are invalid locality models.
26. `state/control/locality/quarantine.yml` is mutable operational control
    truth; `generated/effective/locality/**` is non-authoritative compiled
    locality state.

## Precedence

1. `framework/**` base contracts and runtime authority
2. `instance/**` repo-specific authored authority
3. `state/**` operational truth
4. `generated/**` derived support artifacts
5. `inputs/**` non-authoritative raw input

Within a declared overlay point:

- `replace_by_path`: instance content replaces the framework artifact at the
  overlay point
- `merge_by_id`: instance content merges into keyed framework sets
- `append_only`: instance content appends to the framework register

Outside declared overlay points, framework wins and instance overlay content is
invalid.

## Contract Markers

### OCTON-SPEC-015

The umbrella specification is the canonical cross-subsystem contract registry
surface for super-root authority, placement, and fail-closed behavior.

### OCTON-SPEC-016

The umbrella specification owns the cross-subsystem SSOT precedence contract
for runtime, governance, and practices.

## SSOT Precedence Matrix (Runtime, Governance, Practices)

| Authority slice | Canonical surface | Rule |
| --- | --- | --- |
| runtime-execution | `/.octon/framework/engine/runtime/**` | Engine execution authority MUST NOT override engine enforcement. |
| governance-policy | `/.octon/*/governance/**` | Governance policy MUST NOT be superseded by practices guidance. |
| operating-practices | `/.octon/*/practices/**` | Practices guidance MUST NOT override runtime or governance contracts. |

## Canonical References

- root manifest: `/.octon/octon.yml`
- overlay registry: `/.octon/framework/overlay-points/registry.yml`
- overlay enablement: `/.octon/instance/manifest.yml#enabled_overlay_points`
- projected ingress: `/.octon/AGENTS.md`
- desired extension config: `/.octon/instance/extensions.yml`
- ingress: `/.octon/instance/ingress/AGENTS.md`
- bootstrap docs: `/.octon/instance/bootstrap/`
- locality: `/.octon/instance/locality/`
- scope schema contract:
  `/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json`
- scope-local durable context: `/.octon/instance/cognition/context/scopes/`
- locality quarantine: `/.octon/state/control/locality/quarantine.yml`
- effective locality outputs: `/.octon/generated/effective/locality/`
- repo context and ADRs: `/.octon/instance/cognition/`
- repo missions: `/.octon/instance/orchestration/missions/`
- export runner: `/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
- framework architecture: `/.octon/framework/cognition/_meta/architecture/`
- generated proposal registry: `/.octon/generated/proposals/registry.yml`

## Overlay And Ingress Contract

### Instance-Native Surfaces

- `instance/manifest.yml`
- `instance/ingress/**`
- `instance/bootstrap/**`
- `instance/locality/**`
- `instance/cognition/context/**`
- `instance/cognition/decisions/**`
- `instance/capabilities/runtime/**`
- `instance/orchestration/missions/**`
- `instance/extensions.yml`

### Overlay-Capable Surfaces

| Overlay point | Instance path | Merge mode | Precedence |
| --- | --- | --- | ---: |
| `instance-governance-policies` | `.octon/instance/governance/policies/**` | `replace_by_path` | 10 |
| `instance-governance-contracts` | `.octon/instance/governance/contracts/**` | `replace_by_path` | 20 |
| `instance-agency-runtime` | `.octon/instance/agency/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `.octon/instance/assurance/runtime/**` | `append_only` | 40 |

No blanket shadow-tree model exists for `instance/**`. Any future
overlay-capable surface must be declared in the framework overlay registry
before it becomes legal.

## Locality And Scope Contract

- locality authority is rooted under `instance/locality/**`
- each scope is authored once at `instance/locality/scopes/<scope-id>/scope.yml`
- `include_globs` and `exclude_globs` refine a single rooted subtree and may
  not redefine scope authority into multiple roots
- missions may reference scopes, but they do not define locality
- runtime-facing locality consumers use compiled
  `generated/effective/locality/**`
- invalid scope state quarantines locally under
  `state/control/locality/quarantine.yml`

### Overlay Resolution Order

1. Load `framework/manifest.yml`.
2. Load `framework/overlay-points/registry.yml`.
3. Load `instance/manifest.yml`.
4. Verify `enabled_overlay_points` are a subset of declared overlay points.
5. Collect instance overlay artifacts only from the declared `instance_glob`
   paths.
6. Apply the validator and merge mode for each enabled overlay point.
7. Publish the resolved authoritative overlay result into the active runtime
   view.

## Fail-Closed Rules

- Missing required manifests block runtime.
- Wrong-class placement blocks runtime.
- Invalid overlay registries, undeclared enablement, unsupported merge modes,
  or overlay artifacts outside enabled declared roots block runtime.
- Repo-root ingress files that diverge from the projected ingress surface block
  runtime.
- Framework-local `_ops/state/**` paths block runtime.
- Stale required generated outputs block runtime.
- Direct reads from raw `inputs/**` by runtime or policy code block runtime.
- Incomplete enabled-pack closure blocks `repo_snapshot` export.
