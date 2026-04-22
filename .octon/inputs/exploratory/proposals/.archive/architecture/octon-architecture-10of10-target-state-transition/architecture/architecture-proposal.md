# Architecture Proposal

## Decision request

Adopt a target-state architecture program that hardens the executable chain from authored authority
to runtime enforcement and evidence disclosure while reducing structural ambiguity in support,
pack, extension, and publication paths.

## Architectural thesis

Octon's foundation is strong enough to preserve. The required transition is not a refoundation. It
is a targeted architecture hardening program with moderate restructuring in four areas:

1. **Runtime-resolution hardening**: split dense runtime-resolution truth out of the root manifest
   into a typed runtime-resolution contract and fresh generated/effective route bundle.
2. **Publication/freshness enforcement**: make generated/effective consumption impossible unless
   the output, artifact map, generation lock, publication receipt, source digests, and freshness
   window all validate at runtime.
3. **Support/pack/extension normalization**: prevent support-path drift, pack-admission widening,
   and bulky extension active-state sprawl by normalizing claim-state partitions, compiling pack
   route views into generated/effective outputs, and slimming active state to digest pointers.
4. **Proof/operator closure**: make architecture health, support proof, authorization coverage,
   generated non-authority, and operator read models inspectable from `octon doctor --architecture`
   and retained evidence bundles.

## Decision type

`boundary-change`: the proposal strengthens boundaries between authored authority, mutable control,
retained evidence, generated/effective runtime-facing outputs, generated/cognition read models,
raw additive inputs, and proposal discovery.

## Scope

In scope:

- root manifest thinning and delegated runtime-resolution contract
- runtime-effective route-bundle schema and resolver
- publication freshness v2 contract and hard-gate runtime access
- authorization-boundary coverage tests and negative controls
- support-target path normalization into declared claim-state partitions
- pack route compilation and runtime admission simplification
- extension active-state compaction
- operator architecture-health projection
- closure evidence and promotion receipts
- retirement of transitional shims when durable replacements land

Out of scope:

- changing Octon's five-class super-root model
- inventing a rival control plane
- making generated/cognition or proposal discovery authoritative
- expanding the live support universe
- admitting browser/API/frontier surfaces as live support merely because contracts exist
- changing the product category or external messaging
