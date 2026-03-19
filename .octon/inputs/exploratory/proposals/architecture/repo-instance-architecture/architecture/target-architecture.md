# Target Architecture

## Decision

Ratify `/.octon/instance/**` as the repo-specific durable authoritative layer
inside the class-first super-root.

The promoted repo-instance contract requires:

- `instance/**` to hold repo-owned durable authority and control metadata
- `instance/manifest.yml` to be the required instance companion manifest
- canonical internal ingress to live at `instance/ingress/AGENTS.md`
- `instance/extensions.yml` to remain the one-file desired extension
  configuration surface in v1
- `instance/**` to contain repo-owned bootstrap, locality, durable context,
  ADRs, repo-native capabilities, and missions
- overlay-capable instance content to be legal only at framework-declared
  overlay points enabled by `instance/manifest.yml`
- `instance/**` to exclude mutable state, retained evidence, generated
  outputs, raw packs, and raw proposals
- `instance/**` to be excluded from `bootstrap_core`, included in
  `repo_snapshot`, and preserved across normal framework updates unless an
  explicit migration contract says otherwise

This proposal removes ambiguity about what belongs in the durable repo-owned
layer versus the portable framework bundle, non-authoritative raw inputs,
mutable operational state, and rebuildable generated outputs.

## Status

- status: accepted proposal drafted from ratified Packet 4 inputs
- proposal area: repo-instance durable authority, canonical ingress,
  repo-native capability placement, desired extension configuration, and
  instance-side control metadata
- implementation order: 4 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
  - `root-manifest-profiles-and-export-semantics`
- migration role: completes the repo-instance side of the super-root cutover
  so later overlay, locality, state, extension, memory, generated-output, and
  migration work can rely on a stable repo-owned authority boundary

## Why This Proposal Exists

Packet 1 ratified the five-class super-root and Packet 2 ratified the root
manifest and profile model. Those decisions only become operational once Octon
defines the repo-owned durable authority layer precisely enough that
placement, portability, ingress, and validation are machine-enforceable.

The live repository has already moved materially toward this target:

- `.octon/README.md` already describes `.octon/` as a class-first super-root.
- `.octon/octon.yml` already declares class roots, profile semantics, and
  fail-closed control-plane policies.
- `.octon/instance/manifest.yml` already exists and declares instance
  identity, enabled overlay points, locality bindings, and feature toggles.
- `.octon/instance/ingress/AGENTS.md` already exists as canonical internal
  ingress.
- `.octon/instance/extensions.yml` already exists with the ratified one-file
  desired configuration split.
- `.octon/instance/locality/registry.yml` already exists as the locality
  registry scaffold.
- `.octon/framework/overlay-points/registry.yml` already points at
  repo-instance overlay-capable paths.

What remains is not to invent `instance/**` from scratch. The remaining work
is to ratify and normalize the layer so validators, workflows, and later
proposals stop relying on inference when answering questions such as:

- what belongs in `instance/**` versus `framework/**`
- which repo-owned artifacts are durable authority versus mutable state
- which repo-specific surfaces are instance-native versus overlay-capable
- where canonical ingress and bootstrap artifacts live
- how repo-native capabilities differ from reusable additive packs
- how framework updates preserve repo-local context, decisions, and control
  metadata

### Current Live Signals This Proposal Must Normalize

| Current live signal | Current live source | Ratified implication |
| --- | --- | --- |
| Root docs already present `.octon/` as a class-first super-root | `.octon/README.md` | Packet 4 must build on the class-root contract instead of re-litigating top-level topology |
| The root manifest already includes class roots, profiles, and fail-closed policies | `.octon/octon.yml` | Repo-instance durability and portability must align to the root manifest contract |
| An instance companion manifest already exists with identity, overlay, locality, and feature metadata | `.octon/instance/manifest.yml` | Packet 4 must ratify this file as the authoritative instance control surface rather than inventing a competing manifest |
| Canonical internal ingress already lives under instance | `.octon/instance/ingress/AGENTS.md` | Packet 4 must lock internal ingress placement and keep repo-root adapters thin only |
| Desired extension configuration already uses the ratified one-file split | `.octon/instance/extensions.yml` | Packet 4 must treat desired extension configuration as repo-owned authority rather than operational state |
| The locality registry scaffold already exists inside instance | `.octon/instance/locality/registry.yml` | Packet 4 must place locality under durable repo authority rather than framework or state |
| Framework already declares overlay-capable instance paths | `.octon/framework/overlay-points/registry.yml` | Packet 4 must distinguish instance-native surfaces from overlay-capable surfaces and defer detailed merge mechanics to Packet 5 |

## Problem Statement

Octon needs a repo-owned durable authority layer that is:

- architecturally explicit
- reviewable in Git
- preserved across framework updates
- separate from portable framework/core
- separate from mutable operational truth and retained evidence
- separate from rebuildable generated outputs
- separate from raw additive and exploratory inputs

Without a ratified repo-instance proposal, durable repo-owned authority will
continue to drift between mixed paths, state-like control files, and informal
placement habits. That drift creates ambiguity about bootstrap authority,
locality ownership, repo context, decisions, missions, and desired extension
selection.

## Scope

- define the authoritative meaning of the instance class
- define what belongs in `instance/**`
- define what does not belong in `instance/**`
- ratify `instance/manifest.yml` as the instance companion manifest
- ratify canonical internal ingress placement under `instance/ingress/**`
- distinguish instance-native surfaces from overlay-capable surfaces
- define instance-side portability, compatibility, and update semantics at a
  high level
- define validation expectations and wrong-class placement rules for
  repo-instance content
- provide the canonical repo-instance boundary that later overlay, locality,
  state, extension, memory, and migration proposals must inherit

## Non-Goals

- detailed overlay merge semantics for each overlay point
- detailed locality registry schema beyond repo-instance placement and
  responsibility split
- detailed extension desired/actual/quarantine/compiled mechanics
- detailed proposal schema
- detailed state and evidence retention rules
- detailed generated-output schemas or commit-policy mechanics
- re-litigating the five-class super-root
- re-litigating integrated `inputs/**` placement

## Repo-Instance Contract

### Canonical Instance Control Surfaces

| Path | Role | Authority status |
| --- | --- | --- |
| `instance/manifest.yml` | Repo-instance identity, framework binding, enabled overlay points, locality binding, and feature toggles | Authoritative control metadata |
| `instance/ingress/AGENTS.md` | Canonical internal ingress for this repository's harness | Authoritative authored |
| `instance/bootstrap/**` | Repo bootstrap docs, objective, scope, conventions, and catalog guidance | Authoritative authored |
| `instance/locality/**` | Repo-local locality manifest, registry, and scope definitions | Authoritative authored |
| `instance/cognition/context/**` | Repo-shared and scope-specific durable context | Authoritative authored |
| `instance/cognition/decisions/**` | Durable architecture decision records and authored decision authority | Authoritative authored |
| `instance/capabilities/runtime/**` | Repo-native capabilities that are not reusable additive packs | Authoritative authored |
| `instance/orchestration/missions/**` | Repo-owned mission definitions and orchestration artifacts | Authoritative authored |
| `instance/extensions.yml` | Desired extension configuration, sources, trust, and acknowledgements | Authoritative control metadata |
| `instance/governance/policies/**` | Repo-specific governance overlays | Authoritative only when overlay-bound |
| `instance/governance/contracts/**` | Repo-specific governance contract overlays | Authoritative only when overlay-bound |
| `instance/agency/runtime/**` | Repo-specific agency runtime overlays | Authoritative only when overlay-bound |
| `instance/assurance/runtime/**` | Repo-specific assurance runtime overlays | Authoritative only when overlay-bound |

### Illustrative Target-State Instance Topology

```text
.octon/
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
```

The super-root remains class-first at the top level, but the instance class is
allowed to remain repo-domain-organized internally for readability and durable
ownership.

## Instance Content Rules

### What Belongs In `instance/**`

The repo-instance class may contain:

- canonical internal ingress
- repo bootstrap docs and objective, scope, conventions, and catalog artifacts
- locality manifest, registry, and scope definitions
- repo-shared and scope-specific durable context
- ADRs and other durable authored decisions
- repo-native capabilities that are not reusable additive packs
- repo-owned missions and orchestration artifacts
- desired extension configuration plus trust and acknowledgement metadata
- overlay-capable repo-owned surfaces only where the framework overlay
  registry declares them and the instance manifest enables them

### What Must Not Live In `instance/**`

The repo-instance class must exclude:

- repo continuity and scope continuity
- run evidence and operational decision evidence
- validation or migration receipts
- quarantine and withdrawal control state
- generated effective catalogs, graphs, projections, summaries, and registries
- raw extension pack payloads
- raw proposals or proposal archives
- any other artifact whose authority belongs to `framework/**`, `inputs/**`,
  `state/**`, or `generated/**`

## Instance-Native Versus Overlay-Capable Surfaces

### Instance-Native Surfaces

These are canonical repo-owned authority and do not rely on framework overlay
points:

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

These are repo-owned surfaces that are legal only when a declared overlay
point exists and `instance/manifest.yml` enables it:

- `instance/governance/policies/**`
- `instance/governance/contracts/**`
- `instance/agency/runtime/**`
- `instance/assurance/runtime/**`
- any additional instance subtree only if explicitly declared in
  `framework/overlay-points/registry.yml`

Packet 4 ratifies the canonical homes and the enablement rule. Packet 5 owns
the detailed merge modes, precedence mechanics, and validator behavior. This
proposal does not allow blanket path shadow trees or arbitrary instance-side
framework replacement.

## Companion Manifest, Ingress, And Extension Config

### `instance/manifest.yml`

`instance/manifest.yml` is required and authoritative.
It must carry at least:

- `schema_version`
- `instance_id`
- `framework_id`
- `enabled_overlay_points`
- `locality` bindings
- `feature_toggles`

The live repository already contains this file. Packet 4 turns that existing
shape into a canonical contract surface.

### Canonical Ingress

Canonical internal ingress lives at:

```text
instance/ingress/AGENTS.md
```

Repo-root `AGENTS.md`, `CLAUDE.md`, or other host-facing ingress adapters may
exist, but they are projections only. Their canonical authored content lives
under `instance/ingress/**`.

### Desired Extension Configuration

`instance/extensions.yml` is the authoritative desired extension
configuration surface.

It remains a one-file v1 control surface with distinct top-level sections:

- `selection`
- `sources`
- `trust`
- `acknowledgements`

It is authored desired configuration, not actual active operational state and
not a runtime-facing compiled output.

## Validation, Assurance, And Fail-Closed Expectations

Validation for the repo-instance class must reject:

- wrong-class placement of mutable state or retained evidence into
  `instance/**`
- generated outputs treated as repo-instance source of truth
- raw `inputs/**` dependencies in repo-instance runtime or policy paths
- missing or schema-invalid `instance/manifest.yml`
- ingress that does not resolve to canonical internal content under
  `instance/ingress/**`
- schema-invalid `instance/extensions.yml` or any attempt to treat it as
  actual active state
- overlay-capable instance artifacts not covered by a declared enabled overlay
  point
- repo-native capabilities under `instance/capabilities/runtime/**` that
  silently duplicate pack ids or collide with enabled extension contributions
  without a declared collision policy

## Portability, Compatibility, And Update Semantics

- `instance/**` is repo-specific by default.
- `instance/**` is excluded from `bootstrap_core` except for the minimal
  `instance/manifest.yml` seed required to initialize a clean repo.
- `instance/**` is included in `repo_snapshot` because it is required for
  behaviorally complete repo reproduction.
- `instance/**` is preserved across normal framework updates unless an
  explicit migration contract applies.
- Framework updates must not directly rewrite repo context, repo ADRs, repo
  bootstrap artifacts, or repo ingress as a normal update path.
- Desired extension configuration travels with the repo snapshot, not the
  framework bundle.
- Repo-native capabilities under `instance/**` remain repo-owned and do not
  become portable framework assets by implication.

## Migration And Downstream Impact

This proposal authorizes the following migration work:

- inventory repo-owned durable authoritative artifacts that belong in
  `instance/**`
- move or alias canonical ingress into `instance/ingress/**`
- move or alias repo bootstrap files into `instance/bootstrap/**`
- bind `instance/manifest.yml` into the canonical architecture contract
- ratify `instance/extensions.yml` as desired extension configuration rather
  than derived state
- move repo-local durable context and ADRs into canonical
  `instance/cognition/**` locations
- prepare overlay-capable instance paths so Packet 5 can land machine-enforced
  overlay rules without path churn
- ensure later packets treat `instance/**` as the durable repo-owned layer
  rather than as an informal catch-all

### Downstream Sequencing Constraint

Packet 4 must land before:

- overlay and ingress model
- locality and scope registry
- state, evidence, and continuity cutover
- extension desired-state and compiled-state finalization
- memory, context, and decision routing finalization

## Exit Condition

This proposal is complete only when the durable `.octon/` architecture,
operator guidance, validators, and workflows all agree that `instance/**` is
the canonical home for repo-specific durable authority and that no mutable
state, generated outputs, or raw inputs masquerade as repo-instance source of
truth.
