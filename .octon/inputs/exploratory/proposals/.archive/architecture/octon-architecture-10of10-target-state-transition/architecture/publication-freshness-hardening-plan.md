# Publication Freshness Hardening Plan

## Problem

Octon correctly models generated/effective outputs as runtime-facing derived publications, but target-state
quality requires runtime hard-gating rather than validator-only or advisory freshness checks.

## Target mechanism

Introduce a runtime-level `GeneratedEffectiveHandle` contract:

```rust
GeneratedEffectiveHandle::open(output_ref, required_class, runtime_context) -> Result<VerifiedArtifact>
```

The handle validates:

- output exists
- output is declared in the artifact map
- generation lock exists and matches current source digests
- publication receipt exists and matches generation ID
- freshness window has not expired
- output class is allowed for runtime consumption
- no source path is under `inputs/exploratory/**`
- no generated/cognition or generated/proposals path participates in authority routing
- output does not widen support, pack, extension, or runtime authority beyond canonical sources

## Required artifacts

- `publication-freshness-gates-v2.md`
- `route-bundle.lock.yml`
- `pack-routes.lock.yml`
- updated extension `generation.lock.yml`
- retained freshness receipt under `state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml`

## Failure behavior

- stale or missing lock: deny for protected/consequential runtime, stage-only for preview if policy allows
- missing receipt: deny
- source digest drift: deny
- generated/cognition source in runtime path: deny
- support widening: deny
- advisory warning only: forbidden for runtime-effective consumption
