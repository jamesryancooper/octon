# Target Architecture

## Decision

Adopt a repo-root `/.extensions/` sidecar for optional specialization packs, but
keep all Harmony authority surfaces in `/.harmony/`.

`/.extensions/` is `pack-centric`, not `domain-centric`.

## Scope Binding

- `/.extensions/` binds to the repo-root harness only.
- Descendant harness support is removed and out of scope for this design.
- Every extension resolution, effective-index compile, and host integration
  operation runs against the root harness at repo root.

## V1 Layout

```text
.extensions/
  README.md
  catalog.yml
  <pack-id>/
    pack.yml
    README.md
    skills/
      manifest.fragment.yml
      registry.fragment.yml
      <pack-id>--<skill-id>/
        SKILL.md
        references/
    commands/
      manifest.fragment.yml
      <pack-id>--<command-id>.md
    templates/
      catalog.fragment.yml
      <pack-id>--<template-id>/
        manifest.json
        MANIFEST.md
        ...
    prompts/
      catalog.fragment.yml
      <pack-id>--<prompt-id>.md
    context/
      catalog.fragment.yml
      <pack-id>--<doc-id>.md
    validation/
      catalog.fragment.yml
      schemas/
      fixtures/
      checks/
  .archive/
```

## V1 Storage Model

- Each pack lives directly at `.extensions/<pack-id>/`.
- `pack.yml` carries the semantic version, compatibility contract, versioned
  dependency edges, trust metadata, and content entrypoints.
- V1 supports one installed version per pack id.
- Content buckets live directly under the pack root.
- Archival is handled through `.archive/` or external history.

## What `.extensions/` Contains

Allowed v1 contents:

- `catalog.yml` for installed/enabled pack selection
- `pack.yml` for per-pack identity and compatibility
- `skills/` for additive specialized skills
- `commands/` for additive command wrappers
- `templates/` for pack-local scaffolding assets
- `prompts/` for pack-local prompt assets
- `context/` for pack-local reference and guidance docs
- `validation/` for pack-local schemas, fixtures, and checks
- `README.md` and pack documentation
- optional `.archive/` for removed or historical pack snapshots

## What `.extensions/` Does Not Contain

Disallowed in v1:

- governance contracts
- practices guidance
- methodology surfaces
- `agency/` content
- `orchestration/` content
- `engine/` content
- `assurance/` authority
- services and other executable runtime service contracts
- mutable operational state (`_ops/state`, logs, runs, caches)
- compiled effective manifests or registries
- any direct replacement for `.harmony` authority files

## Runtime And Authority Model

- `/.extensions/` is a source surface only.
- `/.harmony/harmony.yml` defines the root-harness binding and the machine-
  readable compatibility values consumed by pack compatibility checks:
  - `versioning.harness.release_version`
  - `extensions.api_version`
- `/.harmony/engine/governance/**` remains authoritative for precedence,
  fail-closed behavior, and trust boundaries.
- `/.harmony/engine/_ops/state/extensions/effective/**` holds derived effective
  catalogs, artifact maps, and lock metadata after validation.
- Core Harmony manifests remain authoritative for native content.
- Pack fragments are additive only and must not redefine surface-global
  settings such as defaults or routing policy.

## End-To-End Integration Mechanics

### Effective Catalog Coverage

Harmony must compile effective catalogs for every supported extension bucket:

- skills manifest
- skills registry
- commands manifest
- templates catalog
- prompts catalog
- context catalog
- validation catalog

The effective layer is not limited to discovery-only metadata for skills and
commands.

### Rebased Artifact Resolution Boundary

The effective layer is the only runtime-facing resolution surface.

That means Harmony must compile:

- rebased repo-relative artifact paths
- source digests for every referenced extension artifact
- a canonical artifact map that resolves effective ids to concrete source files
- rebased runtime metadata for any allowed write scopes or durable output paths

Runtime and host tooling must never reconstruct pack-relative paths by
interpreting raw extension layout directly.

### Operational Permission And Output Rebase

Extension artifacts must never write durable runtime state back into
`/.extensions/`.

If an extension artifact declares write scopes or durable output paths, Harmony
must compile those declarations into Harmony-owned destinations under approved
roots such as:

- `/.harmony/capabilities/runtime/skills/_ops/state/logs/**`
- `/.harmony/engine/_ops/state/extensions/**`
- `/.harmony/output/reports/**`

If a declared write scope or output path cannot be deterministically rebased
into an approved Harmony-owned destination, compilation fails closed.

### Compatibility Contract

Compatibility must be checked against two machine-readable root-harness values:

- `harmony.yml.versioning.harness.release_version`
- `harmony.yml.extensions.api_version`

Pack-to-pack dependency edges must also be versioned. Id-only dependency edges
are insufficient for safe evolution.

### Freshness, Invalidation, And Publish Safety

The extension compiler must produce:

- an input digest set
- an active generation id
- a lock / resolution receipt
- atomically published effective catalogs and artifact maps

Before runtime consumption, Harmony must verify that the active generation still
matches current extension source digests.

If source digests no longer match:

- Harmony must recompile before consuming extension content
- Harmony must not consume stale effective catalogs
- if recompilation fails, Harmony falls back to core-only behavior and records
  the extension layer as unavailable

### Projection Withdrawal And Cleanup

When a pack is disabled, rejected during recompile, or excluded because the
active generation is stale, Harmony must rebuild all host-visible and policy
projections from the surviving generation.

That includes:

- host-visible skill and command projections
- policy catalogs and extension-aware permission views
- generation pointers and active lock state

No stale extension-derived projection may remain visible after fallback to
core-only behavior.

### Host And Policy Integration

Harmony-side projections that currently depend on native manifests must consume
the effective extension view when extensions are enabled. This includes:

- host-visible skill and command discovery surfaces
- skill-link materialization or equivalent host adapter setup
- deny-by-default policy compilation for extension-provided skills
- extension-aware validation and audit entrypoints

## Harmony Implementation Required

The v1 design is not complete until `/.harmony/` can effectively consume and
handle `/.extensions/` whenever the sidecar is present.

### Engine Governance

`/.harmony/engine/governance/` must define:

- the extension boundary contract
- the root-harness-only binding rule
- trust tiers and provenance requirements
- compatibility rules between Harmony and pack versions
- the machine-readable root-harness compatibility contract at:
  - `harmony.yml.versioning.harness.release_version`
  - `harmony.yml.extensions.api_version`
- duplicate-id and collision policy
- fail-closed handling for invalid or partially valid packs
- the v1 allowed and forbidden content classes

### Engine Runtime

`/.harmony/engine/runtime/` must implement:

- repo-root discovery of `/.extensions/`
- parsing of `catalog.yml` and `pack.yml`
- dependency and conflict resolution for enabled packs
- generation of a lock / resolution receipt
- compilation of effective catalogs and artifact maps under
  `/.harmony/engine/_ops/state/extensions/effective/`
- runtime consumption of those effective indexes whenever extensions are
  available
- deterministic fallback to core-only behavior when no extensions are present
- staleness detection, invalidation, and atomic publish behavior for compiled
  generations
- projection withdrawal and cleanup behavior when packs are disabled or a
  generation is rejected as stale

### Capabilities Integration

`/.harmony/capabilities/runtime/` must support pack fragments for:

- `skills/manifest.fragment.yml`
- `skills/registry.fragment.yml`
- `commands/manifest.fragment.yml`
- `templates/catalog.fragment.yml`
- `prompts/catalog.fragment.yml`
- `context/catalog.fragment.yml`
- `validation/catalog.fragment.yml`

It must also support host-visible consumption of enabled extension skills and
commands through the same effective routing model used for native content, and
must expose effective catalogs for the non-routable supported buckets.

### Validation And Assurance

`/.harmony/assurance/runtime/` must provide:

- schema and structure validation for `catalog.yml` and `pack.yml`
- validation for allowed content buckets
- validation that forbidden content classes do not appear under `.extensions/`
- validation that effective indexes compile cleanly
- validation that every effective catalog entry has a rebased path and source
  digest
- validation that every extension-declared write scope or durable output path
  has a valid Harmony-owned rebase target
- validation that the active generation lock matches current source digests
- validation that canonical `.harmony/` surfaces do not retain disallowed raw
  `.extensions/` dependencies
- alignment-check integration so extension support remains part of normal
  assurance

### Documentation And Portability

`/.harmony/harmony.yml` plus architecture docs must define:

- how Harmony recognizes `/.extensions/`
- that `/.extensions/` binds only to the root harness
- the machine-readable root-harness compatibility keys:
  - `versioning.harness.release_version`
  - `extensions.api_version`
- whether bootstrap/update flows preserve or scaffold the sidecar
- the source-of-truth split between raw extension content and derived effective
  projections
- authoring rules for extension packs

### Recommended Supporting Surfaces Included In V1

The full implementation also includes:

- scaffolding support under `/.harmony/scaffolding/` for creating new extension
  packs with the approved directory shape
- Harmony-managed commands or workflows under
  `/.harmony/orchestration/runtime/workflows/` and
  `/.harmony/capabilities/runtime/commands/` for validating, enabling, and
  auditing extension packs, compiling effective catalogs, and surfacing
  extension-unavailable states, including stale-generation cleanup

These are included because they materially reduce drift and make the extension
model operable, not merely documented.

## Naming And Safety Rules

- Every pack id is globally unique.
- Every pack-contributed artifact id must start with `<pack-id>--`.
- Raw `.extensions/` paths must not become direct live dependencies of
  canonical `.harmony/` surfaces.
- Pack-local validation assets may validate pack content only; they do not
  become global governance policy.

## Deferred From V1

These are explicit non-goals for the first cut:

- pack-provided workflows
- pack-provided services
- pack-provided automations, watchers, or missions
- multi-version side-by-side pack installs
- pack-owned governance or methodology
