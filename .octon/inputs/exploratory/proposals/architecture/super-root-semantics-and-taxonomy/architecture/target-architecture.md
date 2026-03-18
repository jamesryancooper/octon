# Target Architecture

## Decision

Adopt `/.octon/` as one authoritative super-root with one manifest-defined
resolution pipeline and a class-first top-level taxonomy.

The ratified top-level class roots are:

- `framework/`
- `instance/`
- `inputs/`
- `state/`
- `generated/`

This replaces the current mixed-tree, domain-first root contract in which
portable framework assets, repo-specific authoritative artifacts, mutable
continuity and evidence, and rebuildable generated outputs coexist in one
surface without explicit class boundaries.

## Status

- status: ratified design packet drafted into manifest-governed proposal form
- proposal area: super-root semantics, source taxonomy, and class-root
  migration
- implementation order: 1 of 15 in the ratified proposal sequence
- dependencies: none
- migration role: defines the topological, authority, and portability taxonomy
  that all later cutovers must obey

## Why This Proposal Exists

The pre-cutover repository reflected the older mixed-tree baseline:

- `.octon/README.md` describes `.octon/` as a copyable repo-root harness.
- `.octon/octon.yml` expressed portability as a `portable:` allowlist.
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md` still prefers
  capability-category top-level organization over class separation.
- `.octon/framework/cognition/_meta/architecture/specification.md` still requires a
  class-root super-root.
- repo-root `.proposals/` remained an external exploratory workspace rather
  than an integrated raw-input class.

Those signals encode contradictory rules about what is portable, what is
authoritative, what is mutable truth, what may be reset safely, and what may
be regenerated. This proposal resolves that contradiction by making artifact
class explicit at the top level.

## Problem Statement

The pre-cutover repo baseline documented `.octon/` as a single copyable
harness, used a `portable:` allowlist in `octon.yml`, and retained a
domain-first top-level structure. At the same time, the current system already
relies on repo-specific bootstrap artifacts, continuity, decisions, and
operational state inside the same tree. This proposal resolves that
contradiction by moving Octon from a mixed-tree model to a class-root
super-root model.

### Current Baseline Signals

| Current baseline signal | Observed current-state source | Migration implication |
| --- | --- | --- |
| `.octon/` is still described as a copyable repo-root harness | `.octon/README.md` | Replace raw whole-tree copy with profile-driven install and export semantics |
| Portability is still expressed as a path allowlist in `octon.yml` | `.octon/octon.yml` | Replace path allowlists with class roots and profile-based portability |
| Shared-foundation guidance still prefers capability-category organization over class separation | `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Ratify class-first top-level organization while preserving domain organization inside the framework class |
| Umbrella specification still requires a class-root super-root | `.octon/framework/cognition/_meta/architecture/specification.md` | Amend the canonical root contract so class roots become the top-level invariant |

## Scope

- define the authoritative meaning of the Octon super-root
- define the five class roots and their roles
- define dependency-direction rules and source-of-truth boundaries
- define the new portability, install, and export mental model at a high level
- authorize migration away from the current domain-first mixed-tree topology
- provide the canonical framing for later proposals on overlays, locality,
  extensions, proposals, state, generated outputs, validation, and migration

## Non-Goals

- detailed schema for locality, extension packs, proposal manifests, or
  generated catalogs
- detailed overlay merge semantics for specific framework domains
- detailed runtime behavior for routing, graph generation, or proposal
  registry generation
- implementation of migration tools, shims, or cutover scripts
- re-litigating descendant-local harnesses, external sidecar target states,
  `.octon.global/`, `.octon.graphs/`, or a generic `memory/` directory

## Super-Root Invariants

The promoted architecture must preserve these invariants:

1. `/.octon/` remains the single authoritative super-root.
2. The super-root is class-first at the top level and domain-organized only
   within the authored class roots.
3. Only `framework/**` and `instance/**` are authoritative authored surfaces.
4. `state/**` is authoritative only as mutable operational truth and retained
   evidence.
5. `generated/**` is rebuildable and never authoritative.
6. Raw extensions live only under `inputs/additive/extensions/**`.
7. Raw proposals live only under `inputs/exploratory/proposals/**`.
8. Raw `inputs/**` paths must never become direct runtime or policy
   dependencies.
9. Repo-root ingress adapters are projections only; canonical internal ingress
   lives under `instance/ingress/**`.
10. Instance overlays are legal only at framework-declared overlay points.
11. Locality remains root-owned and does not reintroduce descendant-local
   `.octon/` roots.
12. No `.octon.global/`, `.octon.graphs/`, or generic `memory/` surface is
   introduced.

## Class Model

| Root | Authority status | Purpose | Notes |
| --- | --- | --- | --- |
| `framework/**` | Authoritative authored | Portable Octon framework/core artifacts | Remains internally domain-organized |
| `instance/**` | Authoritative authored | Repo-specific durable authoritative artifacts | Repo-owned bindings, ingress, locality, decisions, missions, desired extension config |
| `inputs/additive/extensions/**` | Non-authoritative | Raw reusable extension-pack payloads | Additive only; never direct runtime or policy authority |
| `inputs/exploratory/proposals/**` | Non-authoritative | Raw exploratory proposal material | Temporary by default; promotable only into durable targets |
| `state/**` | Operational truth | Mutable continuity, evidence, and control state | Never used as authored policy/design authority |
| `generated/**` | Non-authoritative | Rebuildable effective views, graphs, projections, summaries, and registries | May be committed per policy but never authoritative |
| `octon.yml` plus companion manifests | Authoritative control metadata | Class bindings, versioning, profiles, and control policies | Defines the only resolution pipeline for the super-root |

### Placement Rules

- Nothing except root ingress files and `octon.yml` sits directly under
  `/.octon/`.
- `framework/` and `instance/` stay internally domain-organized.
- `inputs/` is lifecycle-organized (`additive/` and `exploratory/`).
- `state/` is operational-kind organized (`continuity/`, `evidence/`,
  `control/`).
- `generated/` is output-kind organized (`effective/`, `cognition/`,
  `proposals/`).

## Ratified Target-State Topology

```text
.octon/
  README.md
  octon.yml

  framework/
    manifest.yml
    overlay-points/
      registry.yml
    agency/
      governance/
      runtime/
    capabilities/
      governance/
      runtime/
      _ops/
    cognition/
      governance/
      practices/
      runtime/
        context/
          reference/
    orchestration/
      governance/
      runtime/
    scaffolding/
      governance/
      runtime/
    assurance/
      governance/
      runtime/
    engine/
      governance/
      runtime/

  instance/
    manifest.yml
    ingress/
      AGENTS.md
    bootstrap/
      START.md
      OBJECTIVE.md
      scope.md
      conventions.md
      catalog.md
    governance/
      policies/
      contracts/
    agency/
      governance/
      runtime/
    assurance/
      governance/
      runtime/
    locality/
      manifest.yml
      registry.yml
      scopes/
        <scope-id>/
          scope.yml
    cognition/
      context/
        shared/
        scopes/
          <scope-id>/
      decisions/
    capabilities/
      runtime/
        skills/
        commands/
    orchestration/
      missions/
    extensions.yml

  inputs/
    additive/
      extensions/
        <pack-id>/
          pack.yml
          README.md
          skills/
          commands/
          templates/
          prompts/
          context/
          validation/
        .archive/
    exploratory/
      proposals/
        <kind>/
          <proposal-id>/
            proposal.yml
            <subtype-manifest>.yml
            README.md
            support/
        .archive/

  state/
    continuity/
      repo/
        log.md
        tasks.json
        entities.json
        next.md
      scopes/
        <scope-id>/
          log.md
          tasks.json
          entities.json
          next.md
    evidence/
      runs/
      decisions/
        repo/
        scopes/
          <scope-id>/
      validation/
      migration/
    control/
      extensions/
        active.yml
        quarantine.yml
      locality/
        quarantine.yml

  generated/
    effective/
      locality/
        scopes.effective.yml
        artifact-map.yml
        generation.lock.yml
      capabilities/
        routing.effective.yml
        artifact-map.yml
        generation.lock.yml
      extensions/
        catalog.effective.yml
        artifact-map.yml
        generation.lock.yml
    cognition/
      graph/
        index.yml
        nodes.yml
        edges.yml
      projections/
        definitions/
        materialized/
      summaries/
        decisions.md
    proposals/
      registry.yml
```

## Authority, Ownership, And Precedence

### Authored Authority

- `framework/**`
- `instance/**`

### Operational Truth

- `state/**`

### Non-Authoritative Surfaces

- `inputs/**`
- `generated/**`

### Ownership

- framework maintainers own `framework/**`
- repo maintainers own `instance/**`
- runtime/operators own governed writes to `state/**`
- pack authors own raw pack payloads in `inputs/additive/**`
- proposal authors own raw proposal material in `inputs/exploratory/**`
- generators and validators own `generated/**`

### Precedence

1. framework base contracts and runtime authority
2. instance overlays and repo bindings, only at declared overlay points
3. enabled extension contributions, but only through compiled validated
   effective views
4. state as operational truth for continuity, evidence, and control classes
5. generated outputs as derived inspection and runtime-support artifacts
6. proposals never participate in runtime or policy precedence

Outside declared overlay points, framework wins and instance content is
invalid.

## Dependency-Direction Rules

- Runtime and policy consumers may depend on authored authority, operational
  truth, and validated effective outputs.
- Runtime and policy consumers must not depend directly on raw
  `inputs/additive/**` or `inputs/exploratory/**` paths.
- `generated/**` may depend on `framework/**`, `instance/**`, `state/**`, and
  validated raw inputs; authored authority must not depend on `generated/**`
  as source of truth.
- Instance-native surfaces remain repo-authoritative without overlaying
  framework paths.
- Overlay-capable instance surfaces may exist only where the framework
  declares explicit overlay points.
- Proposals may promote into `framework/**`, `instance/**`,
  `inputs/additive/extensions/**`, or repo-native durable targets, but never
  into `state/**`, `generated/**`, or back into `inputs/exploratory/**`.

## Overlay And Ingress Implications

This proposal fixes the boundary that later overlay work must obey:

- `instance/**` splits into instance-native surfaces and overlay-capable
  surfaces.
- Canonical internal ingress lives under `instance/ingress/AGENTS.md`.
- Repo-root `AGENTS.md`, `CLAUDE.md`, and similar files remain thin ingress
  adapters only.
- Overlay points must be machine-declared by the framework and enabled by the
  repo instance.
- Blanket instance shadow trees and arbitrary path-shadowing remain rejected.

Detailed merge modes, overlay registry schema, and enablement validation are
handled by the downstream overlay proposal, but they must remain subordinate to
the class-root taxonomy defined here.

## Root Manifest And Profile Implications

`octon.yml` becomes the authoritative super-root manifest and must define:

- `schema_version`
- class-root bindings
- `versioning.harness.release_version`
- `versioning.harness.supported_schema_versions`
- `extensions.api_version`
- install, export, and update profiles
- raw-input dependency policy
- generated-staleness policy
- migration workflow references
- excluded and human-led zones

Companion manifests become required:

- `framework/manifest.yml`
- `instance/manifest.yml`

The v1 profile model is:

- `bootstrap_core`: `octon.yml`, `framework/**`, and `instance/manifest.yml`
- `repo_snapshot`: `octon.yml`, `framework/**`, `instance/**`, and enabled
  extension-pack dependency closure
- `pack_bundle`: selected extension packs plus dependency closure
- `full_fidelity`: exact repository reproduction by normal clone

There is no v1 `repo_snapshot_minimal` profile.

## Validation And Fail-Closed Rules

Validators must fail closed when any of the following occur:

- direct runtime or policy dependence on raw `inputs/**`
- artifacts placed under the wrong class root
- missing, incompatible, or unresolved required manifests
- invalid or stale required effective outputs
- native and extension collisions in an active published generation
- partial cutovers that leave the repo depending on both legacy mixed paths
  and ratified class-root paths

Generated outputs must carry provenance and freshness metadata so runtime-facing
effective outputs can be rejected when stale.

## Portability, Compatibility, And Trust

The default portable unit is no longer the whole `.octon/` tree. Portability is
profile-driven:

- `framework/**` is the default portable authored core
- `instance/**` is repo-specific and exported intentionally, not by default
- `state/**` is never part of clean bootstrap
- `generated/**` is rebuildable and not the primary copy unit
- compatibility and versioning become explicit manifest concerns rather than
  incidental path assumptions
- trust and extension activation remain control-plane concerns, not raw pack
  placement side effects

## Migration Sequencing Constraints

This proposal is packet 1 of the ratified 15-packet sequence and originally
blocked downstream class-root work until accepted. The implemented cutover
collapsed the downstream packet work into the same clear-break release.

The ratified order is:

1. super-root semantics and taxonomy
2. root manifest, profiles, and export semantics
3. framework/core architecture
4. repo-instance architecture
5. overlay and ingress model
6. locality and scope registry
7. state, evidence, and continuity
8. inputs/additive/extensions
9. inputs/exploratory/proposals
10. generated/effective/cognition/registry
11. memory, context, ADRs, and operational decision evidence
12. capability routing and host integration
13. portability, compatibility, trust, and provenance
14. validation, fail-closed, quarantine, and staleness
15. migration and rollout

Key sequencing constraints:

- move generated and effective outputs before deeper class-root migrations
- move repo continuity and retained evidence into `state/**` before locality
  cutover
- land locality registry and validation before scope continuity
- move durable repo authority into `instance/**` before internalizing raw
  packs and proposals into `inputs/**`
- enforce the raw-input dependency ban before internalized inputs are allowed
- remove legacy mixed-path support only after profiles, validators, and cutover
  workflows are live

## Supporting Evidence

- current `.octon/README.md` still documents `.octon/` as a copyable repo-root
  harness
- current `.octon/octon.yml` still uses a `profiles:` allowlist model
- current shared-foundation architecture still prefers
  capability-category organization over class separation
- current umbrella specification still requires a domain-organized root
  harness
- `resources/octon_packet_1_super_root_semantics_and_taxonomy.md` is the
  ratified Packet 1 drafting source bundled with this proposal package

## Rejected Alternatives

The following are explicitly rejected and must not be re-litigated by
downstream work:

- the current mixed-tree, whole-root-copy portability model
- competing top-level topologies other than the five-class super-root
- descendant-local `.octon/` roots
- `.octon.global/`
- `.octon.graphs/`
- a generic `memory/` surface
- raw inputs as runtime or policy authority
- generated outputs as source of truth
- ad hoc overlay paths or blanket overlay rights across `instance/**`

## Settled Decisions That Must Not Be Re-Litigated

- `/.octon/` remains the single authoritative super-root
- the top-level target state is a five-class architecture, not a domain-first
  mixed tree
- integrated `inputs/**` is the only accepted target-state home for raw
  extensions and proposals
- `framework/` and `instance/` are the only authoritative authored class roots
- `state/` is mutable operational truth and retained evidence
- `generated/` is rebuildable and non-authoritative
- raw `inputs/**` paths must never become direct runtime or policy
  dependencies
- descendant-local `.octon/` roots, `.octon.global/`, `.octon.graphs/`, and a
  generic `memory/` directory remain rejected

## Remaining Narrow Open Questions

None. This proposal is drafted from a ratified packet and is intended to act
as the formal architectural anchor for the remaining migration sequence.
