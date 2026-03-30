# Validation Plan

This packet turns the next round into a **binary closure certification** by
requiring one positive proof path, multiple negative proof paths, and explicit
release-blocking publication evidence.

## 1. Supported-envelope positive certification

### Objective

Prove that the certified supported envelope can produce the full constitutional
bundle end to end.

### Certified tuple

- model tier: `MT-B`
- workload tier: `WT-2`
- language/resource tier: `LT-REF`
- locale tier: `LOC-EN`
- host adapter: `repo-shell`
- model adapter: `repo-local-governed`

### Required proof

The validator must fail unless the certified run emits:

- `run-contract.yml`
- `run-manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- stage-attempt root
- checkpoint root
- decision artifact
- approval grant bundle
- evidence classification
- replay pointers
- external replay index
- intervention log
- measurement summary
- RunCard

### Pass condition

The supported-envelope run succeeds, emits the full bundle, and its RunCard
proof refs resolve.

## 2. Reduced-tuple negative certification

### Objective

Prove that reduced support stays reduced.

### Required proof

At least one reduced tuple must be exercised in a way that produces staged or
`stage_only` behavior instead of an allowed certification result.

### Pass condition

The run is explicitly staged, not certified, and cannot be misread as a fully
realized supported claim.

## 3. Unsupported-tuple negative certification

### Objective

Prove that unsupported work denies by default.

### Required proof

At least one unsupported tuple must be exercised and must fail closed through
`deny` or the repo’s equivalent deny posture.

### Pass condition

No hidden widen, fallback allow, or implicit approval occurs.

## 4. Missing-evidence fail-closed test

### Objective

Prove that a supported tuple without its full evidence set does not silently
remain eligible.

### Required proof

Run the positive supported fixture with one required artifact intentionally
missing.

### Pass condition

The closure validator fails and the release claim is blocked.

## 5. Disclosure-parity resolver

### Objective

Prove that disclosure is evidence-backed rather than narrative-backed.

### Required proof

- resolve every `proof_plane_ref` in the candidate RunCard
- resolve every `proof_bundle_ref` in the candidate HarnessCard
- verify the HarnessCard claim wording matches the closure manifest exactly

### Pass condition

Any broken reference or wording drift fails the release.

## 6. Shim-independence static audit

### Objective

Prove that retained shims are not path-critical authorities.

### Required proof

Statically scan launchers, workflows, validators, ingress, and bootstrap paths
for reads against historical-shim surfaces in ways that could influence
authority.

### Pass condition

Only explicit adapter/projection reads are allowed; authoritative reads fail.

## 7. Build-to-delete publication proof

### Objective

Prove that retirement discipline is live, not aspirational.

### Required proof

Publish at least one deletion or demotion receipt under the canonical retained
publication root, with owner, removal trigger, and resulting state.

### Pass condition

Closure fails if retirement evidence is absent.

## Publication and retained evidence

The certification run should publish a retained evidence bundle under a stable
publication root such as:

- `.octon/state/evidence/validation/publication/unified-execution-constitution-closure/`

Recommended retained artifacts:

- `supported-envelope-positive.md`
- `reduced-stage-only.md`
- `unsupported-deny.md`
- `missing-evidence-fail-closed.md`
- `disclosure-parity.md`
- `shim-independence.md`
- `build-to-delete-receipt.md`
- `summary.md`

## Binding rule

The repo-local workflow that runs these checks is a **downstream binding
surface** only. The canonical proof contract remains the `.octon/**` validator
and the retained publication evidence.
