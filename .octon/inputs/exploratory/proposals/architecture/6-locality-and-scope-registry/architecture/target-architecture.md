# Target Architecture

## Decision

Ratify `/.octon/instance/locality/**` as the authoritative repo-owned scope
registry and locality validation boundary inside the class-first super-root.

The promoted locality and scope contract requires:

- `instance/manifest.yml` to bind the locality manifest and registry into the
  repo-instance layer
- `instance/locality/manifest.yml` and `instance/locality/registry.yml` to be
  the authoritative locality control surfaces
- each scope to be declared at
  `instance/locality/scopes/<scope-id>/scope.yml`
- v1 scope identity to allow exactly one `root_path` per `scope_id`
- v1 path resolution to yield zero or one active scope for any target path
- overlapping or otherwise ambiguous active scopes to fail closed and
  quarantine locally
- scope-local durable context to live under
  `instance/cognition/context/scopes/<scope-id>/**`
- scope-local active continuity to live under
  `state/continuity/scopes/<scope-id>/**` only after the locality registry and
  validation pipeline are live
- missions to reference one or more `scope_id` values without becoming a
  second locality system
- runtime-facing locality consumers to use compiled
  `generated/effective/locality/**` views that remain non-authoritative and
  freshness-protected
- descendant-local `.octon/` roots, local sidecars, hierarchical inheritance,
  ancestor-chain composition, and disjoint multi-root scopes to remain invalid
  in v1

This proposal turns the live locality scaffolding already present in the
repository into one deterministic, machine-enforceable contract that later
state, routing, validation, and migration work can depend on.

## Status

- status: accepted proposal drafted from ratified Packet 6 inputs
- proposal area: root-owned locality model, scope identity, scope registry
  placement, scope manifest schema, generated locality outputs, quarantine
  semantics, and scope-aware migration sequencing
- implementation order: 6 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
  - `root-manifest-profiles-and-export-semantics`
  - `repo-instance-architecture`
  - `overlay-and-ingress-model`
- migration role: establishes the canonical scope registry and locality
  validation boundary before scope continuity, scope-aware capability routing,
  locality quarantine finalization, and legacy mixed-path cleanup land

## Why This Proposal Exists

Packet 4 ratified `instance/**` as the repo-owned durable authority layer.
Packet 5 ratified overlay and ingress boundaries so repo-local authority no
longer depends on ad hoc placement. Locality is the next boundary that needs
to become explicit. The live repository already points toward a scope-registry
model, but later packets cannot safely build on it until scope identity,
placement, resolution, generated outputs, and quarantine behavior are locked.

The live repository has already moved materially toward this target:

- `.octon/instance/manifest.yml` already binds locality through
  `locality.registry_path` and `locality.manifest_path`.
- `.octon/instance/locality/manifest.yml` already exists and declares
  `resolution_mode: single-active-scope`.
- `.octon/instance/locality/registry.yml` already exists as the authoritative
  registry scaffold, though it currently declares an empty `scopes` list.
- `.octon/framework/cognition/governance/principles/locality.md` already
  enforces the single-root harness rule and rejects descendant `.octon/`
  roots.
- `.octon/framework/capabilities/_meta/architecture/architecture.md` already
  states that exactly one `.octon/` may exist on a repository ancestor chain.
- `.octon/framework/cognition/_meta/architecture/specification.md` and
  `.octon/framework/cognition/_meta/architecture/shared-foundation.md` already
  list `instance/locality/**` among the canonical instance-native surfaces.

What remains is not to invent locality from scratch. The remaining work is to
ratify and normalize the model so validators, workflows, and downstream
packets stop answering these questions informally:

- where locality authority lives under the super-root
- how a `scope_id` is declared and validated
- what makes a target path inside or outside a scope
- whether one scope may bind multiple unrelated roots
- how compiled effective locality views relate to authoritative manifests
- where scope-local durable context and scope-local continuity belong
- how missions may reference scopes without defining locality themselves

### Current Live Signals This Proposal Must Normalize

| Current live signal | Current live source | Ratified implication |
| --- | --- | --- |
| Repo-instance locality binding already exists | `.octon/instance/manifest.yml` | Packet 6 must ratify the live binding rather than invent a competing locality control surface |
| Locality control metadata already exists with `single-active-scope` direction | `.octon/instance/locality/manifest.yml` | Packet 6 must define the final schema and v1 resolution semantics for that manifest |
| The authoritative registry scaffold exists but is empty | `.octon/instance/locality/registry.yml` | Packet 6 must define the final registry and per-scope manifest contract plus the path from scaffold to populated scope inventory |
| The live locality principle already rejects descendant harness roots | `.octon/framework/cognition/governance/principles/locality.md` | Packet 6 must keep locality root-owned and must not reopen local harness or sidecar topology |
| The live skills architecture already enforces one `.octon/` per ancestor chain | `.octon/framework/capabilities/_meta/architecture/architecture.md` | Packet 6 must preserve deterministic single-root scope resolution instead of introducing ancestor-chain composition |
| The umbrella architecture already lists locality as instance-native | `.octon/framework/cognition/_meta/architecture/specification.md` | Packet 6 must finish the scope contract without moving locality into framework, state, generated, or raw inputs |

## Problem Statement

Octon needs a final locality model that is:

- single-root compatible
- machine-enforceable
- deterministic at path-resolution time
- compatible with the five-class super-root
- explicit about authored authority versus generated outputs
- safe under migration and fail-closed behavior
- simple enough for operators to reason about without consulting multiple
  architecture documents at once

The architecture must hold an important tension. Locality matters because
context should stay close to the work, but the ratified super-root rejects
descendant harnesses, local sidecars, and ancestor-chain scope composition.
The scope registry resolves that tension by giving Octon one repo-owned
locality model under `instance/locality/**` and one manifest-defined pipeline
for turning scope declarations into effective views.

## Scope

- define the authoritative meaning of locality under the super-root
- define the canonical locality control surfaces and per-scope manifest path
- define the v1 scope-manifest contract
- define v1 cardinality and path-resolution rules
- define scope-local durable context and scope-local continuity placement
- define the relationship between missions and scopes
- define generated effective locality outputs and freshness expectations
- define validator and quarantine expectations for invalid scope state
- define portability and migration sequencing constraints that locality imposes
  on downstream state and routing work

## Non-Goals

- re-litigating the five-class super-root
- re-litigating whether locality is repo-owned
- introducing descendant `.octon/` roots or local sidecar locality systems
- introducing hierarchical scope inheritance or ancestor-chain composition in
  v1
- permitting multi-root `scope_id` definitions in v1
- defining detailed capability-routing ranking or weighting logic
- defining general memory-routing policy beyond the locality-specific
  placements constrained here
- redefining the global generated-output commit policy beyond the already
  ratified effective-output defaults

## Locality And Scope Contract

### Canonical Control Surfaces

| Path | Role | Authority status |
| --- | --- | --- |
| `instance/manifest.yml` | Repo-instance binding to locality control metadata | Authoritative control metadata |
| `instance/locality/manifest.yml` | Locality schema version, registry binding, and resolution mode | Authoritative control metadata |
| `instance/locality/registry.yml` | Inventory of declared scopes and repo-level locality metadata | Authoritative control metadata |
| `instance/locality/scopes/<scope-id>/scope.yml` | Canonical definition of a single scope | Authoritative authored |
| `instance/cognition/context/scopes/<scope-id>/**` | Durable scope-local context | Authoritative authored |
| `state/continuity/scopes/<scope-id>/**` | Active scope-local continuity | Operational truth |
| `generated/effective/locality/scopes.effective.yml` | Runtime-facing effective scope view | Non-authoritative generated |
| `generated/effective/locality/artifact-map.yml` | Provenance map from effective entries to authoritative sources | Non-authoritative generated |
| `generated/effective/locality/generation.lock.yml` | Freshness receipt for locality compilation | Non-authoritative generated |
| `state/control/locality/quarantine.yml` | Mutable quarantine record for invalid scopes | Operational control truth |

### Illustrative Target-State Locality Topology

```text
.octon/
  instance/
    manifest.yml
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
  state/
    continuity/
      repo/
      scopes/
        <scope-id>/
    control/
      locality/
        quarantine.yml
  generated/
    effective/
      locality/
        scopes.effective.yml
        artifact-map.yml
        generation.lock.yml
```

Locality authority is authored under `instance/**`, scope-local operational
truth is authored nowhere and lives only under `state/**`, and runtime-facing
effective locality views are rebuilt under `generated/**`.

### Scope Manifest Contract

Each `instance/locality/scopes/<scope-id>/scope.yml` must declare at least the
following fields:

| Field | Meaning | v1 constraint |
| --- | --- | --- |
| `scope_id` | Stable unique scope identifier | Required and unique across the repo |
| `display_name` | Human-readable scope label | Required |
| `root_path` | Repo-relative rooted subtree owned by the scope | Required and singular in v1 |
| `include_globs` | Optional inclusion refinements inside the rooted subtree | Optional and subordinate to `root_path` |
| `exclude_globs` | Optional exclusion refinements inside the rooted subtree | Optional and subordinate to `root_path` |
| `owner` | Accountable owning team or actor | Required |
| `status` | Scope activation or lifecycle status | Required |
| `tech_tags` | Technology classification hints | Required |
| `language_tags` | Language classification hints | Required |
| `routing_hints` | Optional routing metadata for downstream consumers | Optional |
| `mission_defaults` | Optional mission-scoping defaults | Optional |

No additional field may authorize extra roots, hierarchical inheritance, or
ancestor-composed scope behavior in v1.

### V1 Cardinality And Resolution Rules

The ratified v1 rules are:

- each `scope_id` has exactly one `root_path`
- each target path resolves to zero or one active scope
- multiple disjoint roots for one `scope_id` are invalid
- overlapping active scopes are invalid
- `include_globs` and `exclude_globs` may refine the rooted subtree but may
  not redefine the scope into multiple unrelated roots
- inactive or quarantined scopes do not participate in active resolution

### Locality Resolution Pipeline

For a target path, locality resolution is:

1. resolve the repo super-root
2. load `octon.yml`
3. load `instance/manifest.yml`
4. load `instance/locality/manifest.yml`
5. load `instance/locality/registry.yml`
6. resolve the applicable `scope_id`, if any
7. publish and consume `generated/effective/locality/**`

If more than one active scope matches a target path, resolution fails closed
and the affected scope state is quarantined until the locality problem is
fixed and a fresh effective generation is published.

### Scope-Local Durable Context And Scope Continuity

Durable scope-local context belongs at:

```text
instance/cognition/context/scopes/<scope-id>/**
```

Mutable scope-local continuity belongs at:

```text
state/continuity/scopes/<scope-id>/**
```

This proposal explicitly preserves the migration rule that repo continuity
moves into `state/continuity/repo/**` first, locality registry and validation
land second, and scope continuity appears only after locality identity is
canonical and validator-enforced.

### Missions And Scopes

Missions remain under:

```text
instance/orchestration/missions/**
```

Missions may reference one or more `scope_id` values, but they do not define
scope identity, scope ownership, scope precedence, or path binding. Missions
remain time-bounded orchestration containers; scopes remain stable locality
bindings.

### Generated Effective Locality Outputs

The runtime-facing locality output set is:

- `generated/effective/locality/scopes.effective.yml`
- `generated/effective/locality/artifact-map.yml`
- `generated/effective/locality/generation.lock.yml`

These outputs are:

- rebuildable and non-authoritative
- committed by default under the ratified generated-output policy matrix
- excluded from `bootstrap_core`
- excluded from `repo_snapshot` because `repo_snapshot` excludes all
  `generated/**`
- required to carry source digests, generator version, schema version, and
  generation timestamp so freshness and provenance remain explicit

### Validation, Quarantine, And Fail-Closed Rules

Validation must enforce all of the following:

- `instance/locality/manifest.yml` exists and is schema-valid
- `instance/locality/registry.yml` exists and is schema-valid
- every declared scope entry resolves to a valid `scope.yml`
- every `scope_id` is unique
- every `scope.yml` declares exactly one `root_path` in v1
- `include_globs` and `exclude_globs` stay subordinate to the declared
  `root_path`
- no two active scopes overlap for the same target path
- runtime-facing effective locality outputs carry freshness and provenance
  metadata
- runtime-facing consumers fail closed on stale or invalid effective locality
  outputs
- invalid scope state quarantines locally rather than silently degrading to
  ambiguous resolution

Quarantine records live at:

```text
state/control/locality/quarantine.yml
```

A quarantined scope is unavailable for active path resolution and unavailable
for downstream scope-bound state publication until the scope problem is fixed
and a fresh effective locality generation is published.

### Explicitly Rejected Locality Models

The following remain invalid in v1:

- descendant-local `.octon/` roots
- local capsule or sidecar locality systems
- hierarchical scope inheritance
- ancestor-chain scope composition
- disjoint multi-root scopes
- mission-defined locality as a substitute for the scope registry

## Portability And Migration Implications

- `instance/locality/**` is repo-specific durable authority and is excluded
  from `bootstrap_core`.
- `instance/locality/**` is included in `repo_snapshot` through `instance/**`
  because behaviorally complete repo reproduction requires authored locality
  state.
- scope definitions do not travel with the portable framework bundle.
- `generated/effective/locality/**` remains rebuildable and non-authoritative
  even when committed by default.
- locality compatibility is governed by the root and locality schema contracts,
  not by extension-pack compatibility logic.
- Packet 6 must land before scope continuity, scope-aware capability routing,
  locality quarantine finalization, and removal of legacy mixed-path locality
  assumptions.

## Downstream Dependency Impact

This proposal is a prerequisite for:

- state, evidence, and continuity cutover for scope continuity
- capability-routing and host-integration work that consumes scope metadata
- unified validation, fail-closed, quarantine, and staleness semantics for
  locality
- final migration and rollout cleanup of legacy mixed-path locality
  assumptions

## Exit Condition

This proposal is complete only when the durable `.octon/` control plane,
repo-instance locality manifests, effective locality outputs, validators,
missions, and architecture references all agree that locality is a root-owned
scope registry under `instance/locality/**` and that no descendant harnesses,
overlapping scopes, or ambiguous path-composition rules remain active.
