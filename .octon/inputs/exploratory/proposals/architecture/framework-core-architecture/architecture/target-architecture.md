# Target Architecture

## Decision

Ratify `/.octon/framework/**` as the portable authored Octon core bundle
inside the class-first super-root.

The promoted framework/core contract requires:

- `framework/**` to be the base authored authority surface of the super-root
- `framework/**` to remain domain-organized internally
- `framework/**` to contain only portable authored core assets and portable
  helper assets needed to validate, package, migrate, generate, or update that
  core bundle
- `framework/manifest.yml` to be the required framework companion manifest
- `framework/overlay-points/registry.yml` to be the framework-owned registry of
  declared overlay points
- framework updates to preserve repo-owned `instance/**`, `state/**`, and
  `inputs/**` content unless an explicit migration contract says otherwise

This proposal removes ambiguity about what belongs in the framework class and
what must remain in instance, inputs, state, or generated surfaces.

## Status

- status: accepted proposal drafted from ratified Packet 3 inputs
- proposal area: portable framework/core bundle, framework boundaries,
  companion manifest, and framework-side overlay registry binding
- implementation order: 3 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
  - `root-manifest-profiles-and-export-semantics`
- migration role: completes the framework side of the super-root cutover so
  later overlay, locality, state, extension, proposal, generated-output, and
  migration work can rely on a stable portable core boundary

## Why This Proposal Exists

Packet 1 ratified the five-class super-root and Packet 2 ratified the root
manifest and profile model. Those decisions only become operational once Octon
defines the portable framework/core layer precisely enough that placement,
updates, and overlays are machine-enforceable.

The live repository has already moved materially toward this target:

- `.octon/README.md` already names `framework/` as portable authored Octon
  core.
- `.octon/octon.yml` already declares class roots, profile semantics, and
  fail-closed control-plane policies.
- `.octon/framework/manifest.yml` already exists and carries framework
  identity, version, supported instance schema versions, overlay registry
  binding, subsystems, generators, and bundled policy sets.
- `.octon/framework/overlay-points/registry.yml` already exists and declares
  overlay points plus merge metadata.
- `.octon/framework/cognition/_meta/architecture/specification.md` already
  treats `framework/**` as the first authored authority surface.
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md` already
  adopts class-first super-root language and profile-driven portability.

What remains is not a top-level taxonomy rewrite. The remaining work is to
make the framework boundary explicit enough that later proposals and validators
stop relying on inference when answering questions such as:

- what belongs in `framework/**` versus `instance/**`
- which framework artifacts are part of the portable bundle
- which framework helper assets under `_ops/**` are portable helpers versus
  repo-state leakage
- which framework subtrees may be overlaid by instance and which are closed
- how framework updates behave in already adopted repositories

### Current Live Signals This Proposal Must Normalize

| Current live signal | Current live source | Ratified implication |
| --- | --- | --- |
| Root docs already present `.octon/` as a class-first super-root | `.octon/README.md` | Packet 3 must build on the class-root contract instead of re-litigating top-level topology |
| The root manifest already includes class roots, profiles, and fail-closed policies | `.octon/octon.yml` | Framework bundle semantics must align to the root manifest and profile contract |
| A framework companion manifest already exists with release and compatibility metadata | `.octon/framework/manifest.yml` | Packet 3 must ratify this file as authoritative rather than inventing a competing control surface |
| A framework-owned overlay registry already exists and declares merge metadata | `.octon/framework/overlay-points/registry.yml` | Packet 3 must treat overlay declaration as a framework concern and leave full merge behavior to Packet 5 |
| The umbrella specification already places framework first in authority order | `.octon/framework/cognition/_meta/architecture/specification.md` | Packet 3 must make framework placement and bundle boundaries precise enough for validation |
| Shared-foundation guidance already retires whole-tree copy guidance | `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Packet 3 must finish the framework-specific boundary definition rather than relying on broad class-first summaries alone |

## Problem Statement

Octon needs a portable authored core that is:

- architecturally explicit
- reviewable in Git
- safe to install and update
- separate from repo-owned durable authority
- separate from mutable operational truth and retained evidence
- separate from generated outputs
- separate from raw additive and exploratory inputs

The current repo has enough of the target state in place that quiet drift is
the main risk. Without a ratified framework/core proposal, repo-local content
can still slip into `framework/**`, or portable framework authority can remain
scattered across instance or legacy mixed-path surfaces. That drift would make
updates unsafe and would weaken the portability guarantees that Packets 1 and 2
already established.

## Scope

- define the authoritative meaning of the framework class
- define what belongs in `framework/**`
- define what does not belong in `framework/**`
- ratify `framework/manifest.yml` as the framework companion manifest
- ratify `framework/overlay-points/registry.yml` as the framework-owned overlay
  registry
- define framework-side portability, compatibility, and update semantics
- define framework-side validation and wrong-class placement expectations
- provide the canonical framework boundary that later overlay, routing,
  portability, validation, and migration proposals must inherit

## Non-Goals

- full overlay merge semantics for each overlay point
- detailed extension-pack schema
- detailed proposal schema
- detailed state and evidence retention rules
- detailed generated-output schemas
- re-litigating the five-class super-root
- re-litigating integrated `inputs/**` placement

## Framework Class Contract

### Canonical Framework Control Surfaces

| Path | Role | Authority status |
| --- | --- | --- |
| `framework/manifest.yml` | Framework identity, release version, supported instance schema range, overlay registry binding, subsystem set, generator set, and bundled policy-set references | Authoritative control metadata |
| `framework/overlay-points/registry.yml` | Declared framework-owned overlay points and allowed overlay metadata | Authoritative control metadata |
| `framework/agency/**` | Portable agency governance and runtime foundations | Authoritative authored |
| `framework/assurance/**` | Portable assurance contracts, validators, and validation helpers | Authoritative authored |
| `framework/capabilities/**` | Portable base capabilities, routing inputs, and capability governance | Authoritative authored |
| `framework/cognition/**` | Portable cognition governance, practices, and reference context | Authoritative authored |
| `framework/engine/**` | Portable engine/runtime authority and engine governance | Authoritative authored |
| `framework/orchestration/**` | Portable orchestration governance, workflows, and update/export mechanics | Authoritative authored |
| `framework/scaffolding/**` | Portable templates, patterns, and reusable framework bundles | Authoritative authored |
| `framework/**/_ops/**` | Portable helper scripts and operational support assets | Portable helper only |

### Illustrative Target-State Framework Topology

```text
.octon/
  framework/
    manifest.yml
    overlay-points/
      registry.yml
    agency/
      governance/
      runtime/
    assurance/
      governance/
      runtime/
      _ops/
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
    engine/
      governance/
      runtime/
    orchestration/
      governance/
      runtime/
      _ops/
    scaffolding/
      governance/
      runtime/
```

The top-level super-root remains class-first, but the framework class remains
domain-organized internally. That is a deliberate readability and cohesion
choice, not a contradiction.

## Framework Content Rules

### What Belongs In `framework/**`

The framework class may contain:

- base governance contracts that apply across adopted repositories
- engine/runtime authority and governance owned by Octon itself
- base or native capability definitions that are portable across repositories
- portable cognition governance, practices, and reference context
- portable scaffolding templates and reusable framework bundles
- portable orchestration workflows for bootstrap, export, migration, and
  update work
- portable assurance contracts, validator foundations, and framework-side
  validation helpers
- portable helper assets under `_ops/**` only when they support framework
  validation, packaging, migration, generation, or update mechanics and do not
  become repo-owned state sinks

### What Must Not Live In `framework/**`

The framework class must exclude:

- repo-specific ingress or bootstrap artifacts
- repo-local context, decisions, locality, and continuity
- repo-owned governance overlays and repo-native capabilities
- mutable operational truth and retained evidence
- raw extension packs
- raw proposals
- generated effective views, registries, summaries, graphs, and projections
- any other artifact whose authority belongs to `instance/**`, `state/**`,
  `inputs/**`, or `generated/**`

### Portable Helper Rule For `_ops/**`

Framework `_ops/**` paths are allowed only as portable helper surfaces.
They may contain scripts, validators, packaging helpers, migration helpers, or
generation helpers that travel with the framework bundle.
They must not store repo-specific operational truth, retained evidence,
workspace-local caches that affect authority, or any mutable sink that should
instead live under `state/**` or `generated/**`.

## Overlay Boundary And Companion Contracts

Packet 3 does not define all overlay merge behavior. That work belongs to the
dedicated overlay proposal. Packet 3 does, however, ratify these framework-side
facts:

- overlay points are declared by the framework, not inferred by the instance
  layer
- the canonical registry lives at `framework/overlay-points/registry.yml`
- `framework/manifest.yml` binds to that registry
- no framework artifact is implicitly overlayable
- overlay-capable instance artifacts must target declared overlay points rather
  than shadow arbitrary framework files

To stay aligned to the ratified blueprint, each overlay-point entry must remain
compatible with the machine-declared contract that includes:

- `overlay_point_id`
- `owning_domain`
- `instance_glob`
- `merge_mode`
- `validator`
- `precedence`
- optional `artifact_kinds`

Allowed v1 merge modes remain:

- `replace_by_path`
- `merge_by_id`
- `append_only`

Packet 5 will define the detailed operational overlay semantics. Packet 3
defines ownership, binding, and the fail-closed baseline.

## Validation, Assurance, And Fail-Closed Expectations

Validation for the framework class must reject:

- repo-specific durable authority placed under `framework/**`
- mutable repo state or retained evidence placed under `framework/**`
- raw `inputs/**` dependencies in framework runtime or policy paths
- generated outputs treated as framework source of truth
- missing or schema-invalid `framework/manifest.yml`
- missing or schema-invalid `framework/overlay-points/registry.yml`
- framework helper assets under `_ops/**` that behave like repo-owned state
  sinks
- undeclared instance shadowing of framework artifacts
- attempts to overlay non-overlayable framework surfaces, especially engine
  runtime authority
- framework updates that violate the supported instance schema range declared by
  `framework/manifest.yml`

## Portability, Compatibility, And Update Semantics

- `framework/**` is the default portable authored core bundle used by
  `bootstrap_core`.
- `bootstrap_core` must always include the full framework bundle plus minimal
  root and instance seed metadata only.
- `repo_snapshot` must include the full framework bundle alongside
  repo-authoritative instance content and enabled-pack dependency closure.
- framework release and compatibility semantics are rooted in `octon.yml` and
  `framework/manifest.yml`, not inferred from path allowlists.
- framework compatibility with adopted repositories is declared by the
  supported instance schema range in `framework/manifest.yml`.
- normal framework updates may touch `framework/**`, root version bindings, and
  explicit migration contracts only.
- normal framework updates must not rewrite repo-owned context, ADRs,
  continuity, proposals, or other repo-specific authority as a default path.
- first-party bundled packs remain packs under
  `inputs/additive/extensions/**`; they do not become part of the framework
  bundle just because they are first-party.

## Migration And Rollout Implications

Packet 3 lands after the top-level taxonomy and root-manifest model because the
framework bundle depends on both.

### Migration Work Authorized By This Proposal

- inventory all portable authored assets that belong in `framework/**`
- move or alias framework-worthy assets out of legacy mixed paths into
  `framework/**`
- normalize `framework/manifest.yml` and
  `framework/overlay-points/registry.yml` as canonical framework control
  surfaces
- update operator guidance so framework is treated as the portable authored
  core bundle rather than as a generic shared tree
- add validation for wrong-class placement, undeclared shadowing, and portable
  helper semantics
- ensure later proposals treat `framework/**` as base authored authority rather
  than as just one domain subtree among many

### Non-Negotiable Sequencing Constraints

- do not wait for full overlay implementation before defining the framework
  boundary
- do not internalize extension-pack or proposal mechanics in ways that
  implicitly expand `framework/**`
- do not let generated outputs or mutable state become framework authority by
  convenience
- do not weaken the root-manifest profile contract when describing framework
  install or update behavior

## Downstream Dependency Impact

This proposal blocks or constrains downstream work in:

- repo-instance architecture
- overlay and ingress model
- locality and scope registry
- state, evidence, and continuity architecture
- inputs/additive/extensions
- inputs/exploratory/proposals
- generated/effective/cognition/registry
- portability, compatibility, trust, and provenance
- validation, fail-closed, quarantine, and staleness
- migration and rollout

## Exit Condition

This proposal is complete only when the durable `.octon/` architecture treats
`framework/**` as the canonical portable authored core bundle, and no
canonical runtime, documentation, validation, or update surface relies on
transitional ambiguity about whether framework content is repo-owned,
generated, stateful, or raw input.
