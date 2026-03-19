# Effective Index Merge And Precedence

## Purpose

Define the proposed v1 merge rules that Octon uses when compiling effective
discovery indexes from core `/.octon/` content plus enabled `/.octon.extensions/`
content.

This contract assumes a single repo-root harness.

## Inputs

- native Octon manifests and registries under `/.octon/`
- root-harness extension contract values from `/.octon/octon.yml`
- enabled extension entries from `/.octon.extensions/catalog.yml`
- validated pack manifests from `/.octon.extensions/<pack-id>/pack.yml`
- validated fragment files from each enabled pack

## Output

Octon writes derived effective indexes under:

- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/extensions/artifact-map.yml`
- `/.octon/generated/effective/extensions/generation.lock.yml`

These effective catalogs are runtime-facing projections. They are not
hand-edited.

## Merge Rules

1. Start with native Octon content as the base.
2. Resolve enabled packs from `catalog.yml`.
3. Validate every enabled pack before merge.
4. Topologically order packs by declared dependencies.
5. Apply additive fragments in deterministic order:
   - dependency order first
   - lexical pack id tie-break second
6. Rebase every extension-relative artifact path into a repo-relative artifact
   entry inside `artifacts.yml`, including source digest metadata.
7. Reject on any hard conflict rather than overriding.

## Rebased Permission And Output Rules

If an extension artifact declares runtime writes or durable output paths,
Octon must rebase those declarations into Octon-owned destinations and
record the result in `artifacts.yml`.

Allowed rebased destination classes include:

- `/.octon/state/evidence/runs/skills/**`
- `/.octon/generated/effective/extensions/**`
- `/.octon/state/evidence/validation/**`

The compiler must reject:

- writes that would resolve inside `/.octon.extensions/**`
- writes that escape approved Octon-owned roots
- ambiguous relative output declarations

## Precedence

Precedence is strict:

1. native Octon authority
2. enabled extension contributions
3. disabled or invalid packs are excluded entirely

Native Octon entries are never overridden by extension content.

Compatibility is strict:

- `pack.yml.compatibility.octon_version` must match
  `octon.yml.versioning.harness.release_version`
- `pack.yml.compatibility.extensions_api_version` must match
  `octon.yml.versioning.extensions.api_version`
- every dependency edge must satisfy the required version range

Catalog selection is strict:

- `catalog.yml` chooses enabled packs and pinned versions
- `pack.yml` provides the authoritative pack identity, trust, provenance, and
  dependency contract
- any mismatch between catalog selection data and `pack.yml` fails closed

## Collision Policy

- core id vs extension id: reject
- extension id vs extension id: reject
- malformed namespacing: reject
- duplicate trigger text: allow only if ambiguity handling remains explicit
- duplicate template, prompt, context, or validation ids: reject

## Allowed Surface Effects

V1 compiled effective indexes may include additive content for:

- skills manifest
- skills registry
- commands manifest
- templates catalog
- prompts catalog
- context catalog
- validation catalog

V1 compiled effective indexes must not introduce:

- governance overrides
- practices overlays
- methodology changes
- orchestration workflows
- services

## Failure Handling

Compilation fails closed when:

- an enabled pack is unreadable
- a fragment is missing or invalid
- compatibility fails
- dependencies cycle
- forbidden content appears
- id collisions occur
- catalog selection mismatches pack identity or version
- any artifact path cannot be rebased into `artifacts.yml`
- any declared write scope or durable output path cannot be rebased into an
  approved Octon-owned destination

When compilation fails, Octon must not publish a partial effective generation.

## Freshness And Invalidation

`lock.yml` must record:

- active generation id
- catalog digest
- pack manifest digests
- fragment digests
- artifact map digest
- compile timestamp

Before runtime consumption, Octon must verify that current source digests
still match the active lock.

If the lock is stale:

1. recompile
2. if compile succeeds, atomically swap the active generation
3. if compile fails, do not consume the stale extension generation
4. fall back to core-only behavior and record the extension layer as unavailable

## Withdrawal And Cleanup

When fallback excludes a previously active pack or rejects a stale generation,
Octon must:

1. rebuild host-visible projections from the surviving generation
2. rebuild extension-aware policy catalogs from the surviving generation
3. remove stale extension-derived entries from active projections
4. update `lock.yml` to the surviving active generation or explicit
   extension-unavailable state

## Publish Model

Compilation must publish atomically:

1. write a new generation to a temporary location
2. validate the generation contents and lock
3. promote the generation in one atomic swap
4. only then expose the new active generation to runtime consumers

## Host And Policy Consumption

Host-visible skill and command projections and deny-by-default policy
compilation must consume the effective catalogs and artifact map, not raw
extension fragments.

## Example Outcome

If core defines `refine-prompt` and an enabled `nextjs` pack defines
`nextjs--app-router-runtime`, the effective skill manifest contains both
entries. If the `nextjs` pack also attempts to define `refine-prompt`, the
compile fails.
