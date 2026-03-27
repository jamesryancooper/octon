---
title: Octon Harness Umbrella Specification
description: Canonical cross-subsystem contract for the Octon super-root.
status: Active
---

# Octon Harness Umbrella Specification

## Purpose

Define the authoritative cross-subsystem contract for `/.octon/` after the
super-root cutover.

## Constitutional Authority

The repo-local supreme control regime for `/.octon/` lives under
`framework/constitution/**`:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/constitution/precedence/{normative.yml,epistemic.yml}`
- `/.octon/framework/constitution/obligations/{fail-closed.yml,evidence.yml}`
- `/.octon/framework/constitution/ownership/roles.yml`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/support-targets.schema.json`

This umbrella specification remains the canonical cross-subsystem topology,
placement, and structural SSOT surface. It is subordinate to the
constitutional kernel and must not restate competing repo-local constitutional
authority.

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
6. `state/**` is class-organized into `state/continuity/**`,
   `state/evidence/**`, and `state/control/**`.
7. `generated/**` is never source of truth.
8. Raw `inputs/**` paths must never become direct runtime or policy
   dependencies.
9. Human-led ideation lives under `inputs/exploratory/ideation/**`.
10. Retired legacy roots from the mixed-tree topology must not be
   reintroduced.
11. `/.octon/octon.yml` is the authoritative root manifest for topology,
    versioning, profiles, and fail-closed policy hooks.
12. `repo_snapshot` is behaviorally complete and includes enabled-pack
    dependency closure.
13. `full_fidelity` is advisory only and is not a synthetic export payload.
14. `framework/overlay-points/registry.yml` is the canonical framework-authored
    overlay declaration surface.
15. `instance/manifest.yml#enabled_overlay_points` is the canonical repo-side
    overlay enablement surface.
16. Canonical internal ingress lives under `instance/ingress/**`;
    `/.octon/AGENTS.md` is the projected ingress surface; repo-root ingress
    files are thin adapters only.
17. Repo-root ingress files are valid only as a symlink to `/.octon/AGENTS.md`
    or a byte-for-byte parity copy.
18. Overlay-capable instance surfaces are legal only at framework-declared
    overlay points enabled by `instance/manifest.yml`.
19. Allowed v1 overlay merge modes are `replace_by_path`, `merge_by_id`, and
    `append_only`.
20. Overlay-capable artifacts may not target closed framework domains such as
    `framework/engine/runtime/**`.
21. Undeclared or disabled overlay artifacts fail closed.
22. Repo-owned bootstrap, locality, context, ADRs, repo-native capabilities,
    missions, and desired extension configuration belong in `instance/**`.
23. `instance/locality/manifest.yml`, `instance/locality/registry.yml`, and
    `instance/locality/scopes/<scope-id>/scope.yml` are the only authored
    locality authority surfaces.
24. In v1, each `scope_id` declares exactly one `root_path`.
25. In v1, locality resolution yields zero or one active scope per target
    path.
26. Descendant `.octon/` roots, hierarchical scope inheritance, and
    ancestor-chain scope composition are invalid locality models.
27. `state/continuity/repo/**` is the canonical repo-wide and cross-scope
    continuity surface.
28. `state/continuity/scopes/<scope-id>/**` is legal only for declared,
    non-quarantined scopes.
29. `state/evidence/**` is retained evidence and must not be treated as
    rebuildable generated output.
30. `instance/extensions.yml`, `state/control/extensions/active.yml`,
    `state/control/extensions/quarantine.yml`, and
    `generated/effective/extensions/**` form the canonical desired/actual/
    quarantine/compiled extension publication model.
31. `state/control/locality/quarantine.yml` is mutable operational control
    truth; `generated/effective/locality/**` is non-authoritative compiled
    locality state.
32. `generated/effective/capabilities/**` is the only runtime-facing
    capability-routing surface and must publish
    `routing.effective.yml`, `artifact-map.yml`, and `generation.lock.yml`.
33. `generated/cognition/**` contains derived cognition summaries, graph
    datasets, and projections only; it never becomes memory or ADR authority.
34. Retained assurance and validation receipts belong under
    `state/evidence/validation/**`, not under `generated/**`.
35. Runtime-facing publication receipts live under
    `state/evidence/validation/publication/**` and remain retained
    operational evidence rather than generated outputs.
36. Raw exploratory proposals live only under
    `inputs/exploratory/proposals/<kind>/<proposal_id>/**`; archived proposal
    packages live only under
    `inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/**`.
37. `generated/proposals/registry.yml` is the only generated proposal
    discovery surface, is rebuilt deterministically from proposal manifests,
    and remains non-authoritative.
38. `octon.yml#policies.generated_commit_defaults` is the binding default
    commit-versus-rebuild policy for generated outputs.
39. Proposals are excluded from runtime resolution, policy resolution,
    `bootstrap_core`, and `repo_snapshot`.
40. No descendant-local or scope-local proposal workspace exists in v1.
41. Raw extension packs use `octon-extension-pack-v3` and must carry
    `compatibility.required_contracts` plus pack-authored provenance fields.
42. Repo trust decisions remain in `instance/extensions.yml`; pack provenance
    remains in `pack.yml`.
43. `pack_bundle` is a trust-agnostic raw additive transfer profile and does
    not imply pack activation or publication.
44. Material execution must resolve through the engine-owned
    `authorize_execution(...)` boundary before side effects occur.
45. Protected execution is legal only under `hard-enforce`.
46. Workflow contracts use `workflow-contract-v2` and declare stage-level
    authorization metadata.
47. Runtime execution evidence belongs under `state/evidence/runs/**`.
48. Canonical mutable execution control truth belongs under
    `state/control/execution/**`; per-run objective binding control roots live
    under `state/control/execution/runs/<run-id>/**`.
49. Canonical ephemeral execution scratch belongs under
    `generated/.tmp/execution/**`.
50. Repo-owned network egress policy lives at
    `instance/governance/policies/network-egress.yml`.
51. Repo-owned execution budget policy lives at
    `instance/governance/policies/execution-budgets.yml`.
52. The machine-readable execution path and policy invariant registry lives at
    `framework/cognition/_meta/architecture/contract-registry.yml`.
53. Mission authority discovery lives only under
    `instance/orchestration/missions/**`; active mission charters use
    `octon-mission-v2` and remain continuity containers rather than the
    atomic execution unit.
54. Mission-scoped mutable execution control truth lives only under
    `state/control/execution/missions/<mission-id>/**`.
55. Consequential run contracts live only under
    `state/control/execution/runs/<run-id>/run-contract.yml`.
56. Retained control-plane mutation evidence lives only under
    `state/evidence/control/execution/**`.
57. Mission continuity and handoff state lives only under
    `state/continuity/repo/missions/<mission-id>/**`.
58. Mission/operator read models under
    `generated/cognition/summaries/{missions,operators}/**` are derived only
    from canonical authority, control, evidence, and continuity surfaces.
59. Mission effective scenario resolution lives only under
    `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`
    and remains derived-only, freshness-bounded runtime input.
60. No autonomous runtime path may silently fall back to mission-less
    execution after the mission-scoped reversible autonomy cutover.
61. External UI, chat, or in-memory session state may not become a second
    authoritative mission control plane.
62. For Mission-Scoped Reversible Autonomy, runtime closeout records under
    `instance/cognition/decisions/067-*.md`; proposal-lineage closeout records
    under `instance/cognition/decisions/068-*.md` plus the matching migration
    plan under `instance/cognition/context/shared/migrations/**`; proposal
    packets remain historical lineage only.

## Class-Root Authority Order

The order below is the structural class-root resolution order for placement and
source-of-truth family conflicts. Normative and epistemic precedence live under
`framework/constitution/precedence/**`.

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

The umbrella specification is the canonical cross-subsystem topology and
placement registry surface for the super-root. It must align with, and never
outrank, the constitutional kernel.

### OCTON-SPEC-016

The umbrella specification owns the structural SSOT matrix for runtime,
governance, and practices. Normative and epistemic precedence belong to the
constitutional kernel.

## Structural SSOT Matrix (Runtime, Governance, Practices)

| Authority slice | Canonical surface | Rule |
| --- | --- | --- |
| runtime-execution | `/.octon/framework/engine/runtime/**` | Engine execution authority MUST NOT override engine enforcement. |
| governance-policy | `/.octon/*/governance/**` | Governance policy MUST NOT be superseded by practices guidance. |
| operating-practices | `/.octon/*/practices/**` | Practices guidance MUST NOT override runtime or governance contracts. |

## Canonical References

- constitutional charter: `/.octon/framework/constitution/CHARTER.md`
- constitutional manifest: `/.octon/framework/constitution/charter.yml`
- normative precedence:
  `/.octon/framework/constitution/precedence/normative.yml`
- epistemic precedence:
  `/.octon/framework/constitution/precedence/epistemic.yml`
- fail-closed obligations:
  `/.octon/framework/constitution/obligations/fail-closed.yml`
- evidence obligations:
  `/.octon/framework/constitution/obligations/evidence.yml`
- ownership roles: `/.octon/framework/constitution/ownership/roles.yml`
- constitutional objective contracts:
  `/.octon/framework/constitution/contracts/objective/**`
- constitutional contract registry:
  `/.octon/framework/constitution/contracts/registry.yml`
- support-target schema:
  `/.octon/framework/constitution/support-targets.schema.json`
- root manifest: `/.octon/octon.yml`
- overlay registry: `/.octon/framework/overlay-points/registry.yml`
- overlay enablement: `/.octon/instance/manifest.yml#enabled_overlay_points`
- projected ingress: `/.octon/AGENTS.md`
- desired extension config: `/.octon/instance/extensions.yml`
- raw additive extension packs: `/.octon/inputs/additive/extensions/`
- raw exploratory proposals: `/.octon/inputs/exploratory/proposals/`
- archived exploratory proposals:
  `/.octon/inputs/exploratory/proposals/.archive/`
- ingress: `/.octon/instance/ingress/AGENTS.md`
- bootstrap docs: `/.octon/instance/bootstrap/`
- locality: `/.octon/instance/locality/`
- scope schema contract:
  `/.octon/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json`
- scope-local durable context: `/.octon/instance/cognition/context/scopes/`
- repo continuity: `/.octon/state/continuity/repo/`
- scope continuity: `/.octon/state/continuity/scopes/`
- retained evidence: `/.octon/state/evidence/`
- publication validation receipts:
  `/.octon/state/evidence/validation/publication/`
- extension actual state: `/.octon/state/control/extensions/active.yml`
- extension quarantine state: `/.octon/state/control/extensions/quarantine.yml`
- locality quarantine: `/.octon/state/control/locality/quarantine.yml`
- execution budget state: `/.octon/state/control/execution/budget-state.yml`
- execution exception leases:
  `/.octon/state/control/execution/exception-leases.yml`
- mission control root:
  `/.octon/state/control/execution/missions/`
- retained control evidence:
  `/.octon/state/evidence/control/execution/`
- effective mission scenario routes:
  `/.octon/generated/effective/orchestration/missions/`
- effective locality outputs: `/.octon/generated/effective/locality/`
- effective capability-routing outputs:
  `/.octon/generated/effective/capabilities/`
- effective extension outputs: `/.octon/generated/effective/extensions/`
- execution scratch root: `/.octon/generated/.tmp/execution/`
- derived cognition outputs: `/.octon/generated/cognition/`
- mission summaries:
  `/.octon/generated/cognition/summaries/missions/`
- operator digests:
  `/.octon/generated/cognition/summaries/operators/`
- machine mission views:
  `/.octon/generated/cognition/projections/materialized/missions/`
- readable decision summary:
  `/.octon/generated/cognition/summaries/decisions.md`
- repo context and ADRs: `/.octon/instance/cognition/`
- repo missions: `/.octon/instance/orchestration/missions/`
- mission autonomy policy:
  `/.octon/instance/governance/policies/mission-autonomy.yml`
- ownership registry:
  `/.octon/instance/governance/ownership/registry.yml`
- export runner: `/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
- framework architecture: `/.octon/framework/cognition/_meta/architecture/`
- execution contract registry:
  `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- repo-owned network egress policy:
  `/.octon/instance/governance/policies/network-egress.yml`
- repo-owned execution budget policy:
  `/.octon/instance/governance/policies/execution-budgets.yml`
- generated proposal registry: `/.octon/generated/proposals/registry.yml`

Mission-scoped autonomy uses one authority/control/evidence/read-model split:
authored mission scaffolds stay under `instance/orchestration/missions/**`,
mutable control truth stays under `state/control/execution/missions/**`,
retained control evidence stays under `state/evidence/control/execution/**`,
and generated route/view surfaces stay under `generated/**`.
No autonomous active or paused mission is valid until the seed-before-active
path materializes that full family.

Proposal lifecycle authority stays in `proposal.yml` and the subtype manifest.
`navigation/source-of-truth-map.md` is the manual proposal-local precedence
map, `navigation/artifact-catalog.md` is generated inventory, and the proposal
registry is discovery-only. Archived design imports with
`archive.archived_from_status=legacy-unknown` stay off the main registry
projection until normalized into the standard packet contract.

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
- mutable scope continuity belongs under `state/continuity/scopes/<scope-id>/**`
  and must not exist for undeclared or quarantined scopes
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
- Missing execution grants or execution receipts for material runtime paths
  block runtime.
- Invalid overlay registries, undeclared enablement, unsupported merge modes,
  or overlay artifacts outside enabled declared roots block runtime.
- Repo-root ingress files that diverge from the projected ingress surface block
  runtime.
- Framework-local `_ops/state/**` paths block runtime.
- Stale required generated outputs block runtime.
- Stale required effective publication families block runtime and policy use.
- Runtime-effective publication validators must require coherent publication
  receipts under `state/evidence/validation/publication/**`.
- Direct reads from raw `inputs/**` by runtime or policy code block runtime.
- Direct reads from raw exploratory proposal paths by runtime or policy code
  are always invalid raw-input dependencies.
- Incomplete enabled-pack closure blocks `repo_snapshot` export.
- Missing required pack provenance or unsupported `required_contracts` blocks
  pack publication and any `repo_snapshot` that depends on the pack.
