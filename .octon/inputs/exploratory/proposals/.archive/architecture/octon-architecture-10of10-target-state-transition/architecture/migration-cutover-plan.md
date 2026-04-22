# Migration and Cutover Plan

## Cutover principle

Use staged cutover with hard gates. Do not make a big-bang transition that lets old and new runtime
routes silently coexist.

## Cutover stages

### Stage 1 — Parallel generation

Generate new runtime-effective route bundle, pack routes, support matrix, and extension locks while
runtime still uses existing paths. Validate no source drift.

### Stage 2 — Shadow validation

Run validators comparing old and new routes:

- support tuple equivalence
- pack route no-widening
- extension active-state equivalence
- generated/effective freshness
- authorization boundary coverage

### Stage 3 — Runtime binding

Switch runtime consumption to the new route bundle through `GeneratedEffectiveHandle`.
Existing paths remain readable only for compatibility validators and generated read models.

### Stage 4 — Hard gate activation

Fail closed on stale generated/effective outputs, missing route bundle lock, support-path mismatch,
unadmitted pack, or unpublished extension.

### Stage 5 — Shim retirement

Retire flat support files, old runtime pack projection, and legacy workflow wrappers after retained
closure evidence proves runtime and operator surfaces use the target-state paths.

## Rollback

Rollback is permitted only by restoring the previous root manifest/runtime-resolution pointers and
recording a rollback receipt under `state/evidence/validation/architecture/10of10-target-transition/**`.
Rollback must not restore generated/cognition or proposal paths as runtime authority.
