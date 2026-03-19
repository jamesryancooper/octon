# Implementation Plan

## Workstream 1: Core Contracts And Documentation

- Add durable architecture docs in `/.octon/` defining `/.octon.extensions/` as a
  repo-root source surface supported by Octon.
- Record that `/.octon.extensions/` binds to the root harness only.
- Add governance docs defining:
  - trust tiers
  - compatibility ranges
  - root-harness compatibility keys at
    `octon.yml.versioning.harness.release_version` and
    `octon.yml.versioning.extensions.api_version`
  - collision rules
  - allowed and forbidden content classes
  - fail-closed behavior
- Update `/.octon/octon.yml` and architecture references so bootstrap and
  update flows have an explicit stance on `/.octon.extensions/`.

## Workstream 2: Extension Catalog And Pack Schemas

- Define `catalog.yml` schema for installed/enabled pack selection.
- Keep `catalog.yml` limited to selection, pinning, and installation-state
  metadata.
- Define `pack.yml` schema for:
  - `id`
  - `version`
  - `display_name`
  - `compatibility`
  - `trust`
  - versioned dependency edges
  - declared content entrypoints
- Define fragment schemas for:
  - `skills/manifest.fragment.yml`
  - `skills/registry.fragment.yml`
  - `commands/manifest.fragment.yml`
  - `templates/catalog.fragment.yml`
  - `prompts/catalog.fragment.yml`
  - `context/catalog.fragment.yml`
  - `validation/catalog.fragment.yml`

## Workstream 3: Runtime Discovery And Resolution

- Add repo-root discovery of `/.octon.extensions/` in `/.octon/framework/engine/runtime/`.
- Implement loading for:
  - `catalog.yml`
  - enabled pack roots
  - `pack.yml`
  - declared fragment files
- Resolve enabled packs deterministically:
  - validate compatibility
  - topologically order dependencies
  - reject conflicts and cycles
  - reject catalog vs pack manifest mismatches
  - emit a resolution lock / receipt
- Preserve deterministic core-only behavior when no sidecar exists.

## Workstream 4: Effective Index Compiler

- Add compiler logic that reads validated extension content and emits effective
  indexes under `/.octon/generated/effective/extensions/`.
- Generate effective views for the v1 routable surfaces:
  - skills manifest
  - skills registry
  - commands manifest
- Generate effective catalogs for the non-routable supported surfaces:
  - templates catalog
  - prompts catalog
  - context catalog
  - validation catalog
- Generate a canonical artifact map with:
  - rebased repo-relative artifact paths
  - pack id
  - artifact id
  - source digest
- Generate rebased runtime metadata for:
  - allowed write scopes
  - durable output destinations
- Compile into a new generation directory, validate it, and publish it
  atomically.
- Keep runtime-facing discovery on effective indexes, not raw extension paths.
- Fail closed on:
  - unknown content classes
  - duplicate ids
  - forbidden bucket contents
  - invalid compatibility
  - incomplete pack declarations

## Workstream 5: Runtime Consumption

- Update Octon runtime and supporting tooling so enabled extension content is
  consumed through the effective indexes when available.
- Ensure native core content remains authoritative and extension content is
  additive only.
- Ensure host-facing integration for skills and commands reflects enabled
  extension entries through the same effective routing model.
- Ensure all consumers resolve extension artifacts through the effective
  artifact map rather than reconstructing pack-relative paths.
- When source digests do not match the active generation:
  - trigger recompilation
  - reject stale generations
  - fall back to core-only behavior if recompilation fails
- When packs are disabled or excluded from the surviving generation:
  - rebuild host-visible projections
  - rebuild extension-aware policy catalogs
  - withdraw stale extension entries from active projections

## Workstream 6: Host And Policy Integration

- Update host-visible skill and command setup so enabled extension entries are
  surfaced through effective catalogs.
- Update deny-by-default policy compilation to include extension-provided skills
  through the effective view.
- Ensure extension-aware host projections remain subordinate to Octon
  governance and runtime authority.
- Define teardown rules so stale or disabled extension projections are removed
  during fallback or regeneration.

## Workstream 7: Validation And Assurance

- Add validators for:
  - `catalog.yml`
  - `pack.yml`
  - allowed bucket structure
  - fragment schema correctness
  - effective-index compilation
- Add freshness and invalidation checks for:
  - source digests
  - generation locks
  - catalog vs pack manifest mismatch
- Add checks that every rebased write scope or durable output target resolves to
  an approved Octon-owned destination.
- Add guardrails that reject forbidden content under `/.octon.extensions/`.
- Add guardrails that block disallowed raw `.octon.extensions/` path dependencies from
  canonical `.octon/` surfaces outside approved derived projections.
- Integrate extension checks into `alignment-check` or equivalent assurance
  entrypoints.
- Add automated tests for:
  - valid pack load
  - duplicate id collision
  - dependency cycles
  - incompatible versions
  - disabled pack exclusion
  - effective-index generation
  - stale generation invalidation
  - root-harness-only binding
  - rebased write-scope validation
  - stale projection cleanup

## Workstream 8: Scaffolding Support

- Add scaffolding templates under `/.octon/framework/scaffolding/` for creating new
  extension packs with the approved v1 shape.
- Provide authoring guidance for:
  - `pack.yml`
  - skills fragments
  - commands fragments
  - templates catalog fragments
  - prompts catalog fragments
  - context catalog fragments
  - validation catalog fragments

## Workstream 9: Operator Workflows And Commands

- Add Octon-managed workflows or commands for:
  - validating an extension pack
  - compiling effective indexes
  - enabling or disabling a pack
  - auditing extension integrity
  - reporting extension-unavailable or stale-generation states
- Keep these operational entrypoints inside `/.octon/`, not under
  `/.octon.extensions/`.

## Workstream 10: Proving Packs And Legacy Conversion Examples

- Author a small first-party example set directly under `/.octon.extensions/`:
  - `nextjs/` for a broad multi-bucket pack
  - `docs/` for a docs-focused template example plus an ARE-derived skill
  - `node-ts/` for a Node.js/TypeScript template example
- Use those examples to prove the preferred bucket mapping for removed scoped
  Octon surfaces:
  - template-shaped specialization becomes `templates/`
  - workflow-like specialist guidance becomes `skills/`
- Prove that Octon can discover, validate, compile, and consume those packs
  through effective indexes without adding new governance, orchestration, or
  agency surfaces outside `/.octon/`.
