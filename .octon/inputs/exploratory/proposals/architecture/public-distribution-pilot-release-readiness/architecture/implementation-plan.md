# Implementation Plan

## Dependencies

- `public-distribution-legacy-exposure-readiness` must satisfy its declared verification gate.
- `public-distribution-portable-dropin-export` must satisfy its declared verification gate.
- `public-distribution-downstream-core-delivery` must satisfy its declared verification gate.
- `public-distribution-local-storage-evidence` must satisfy its declared verification gate.
- `public-distribution-public-repository-controls` must satisfy its declared verification gate.
- `public-distribution-self-hosting-workspace-migration` must satisfy its declared verification gate.
- `public-distribution-self-hosting-octon-storage-migration` must satisfy its declared verification gate.

## Phases

1. Build disposable public-style, private, and offline pilot fixtures with no sensitive material under `.octon/framework/assurance/runtime/_ops/fixtures/public-distribution-release-readiness/`.
2. Add tier metadata to the five existing targets in `.octon/framework/engine/runtime/release-targets.yml` as a single revertible commit and re-run the file's current consumers to confirm compatibility.
3. Implement `.octon/framework/orchestration/runtime/_ops/scripts/run-public-distribution-pilots.sh` and run the Tier 1 install and initialization matrix plus non-blocking Tier 2 previews.
4. Run update, fault injection, recovery, rollback, and project-hash invariance tests.
5. Validate approved public checkout settings, tree parity, candidate assets, SBOM, checksums, and attestations.
6. Implement `.octon/framework/assurance/runtime/_ops/scripts/validate-public-distribution-release-readiness.sh` with `.octon/framework/assurance/runtime/_ops/tests/test-public-distribution-release-readiness.sh`, aggregate fresh child receipts, and issue a non-publishing release-readiness verdict.

## Migration And Compatibility

- Pilot harness is additive and uses disposable paths.
- The `release-targets.yml` change is additive tier metadata only: the five existing targets, their keys, and their values are unchanged, and the compatibility check re-runs the file's current consumers (`validate-runtime-target-parity.sh` and its test, `validate-harness-structure.sh`, and the `.github/workflows/runtime-binaries.yml` matrix derivation) against the amended file.
- Rollback route for the shared file: revert the single tier-metadata commit to restore the exact prior file, then re-run the same consumer validation set to confirm the revert.
- Live public checkout checks run only after approved repository setup.
- A failed pilot returns ownership to the responsible child packet without weakening gates.

## Validation Plan

- Each Tier 1 target runs the same declared lifecycle and fault matrix.
- Offline pilot completes from a local artifact with network disabled.
- Private and public-style pilots preserve project-owned hashes.
- Public candidate tree and release assets match exact manifests and digests.
- Aggregate readiness reports stale or missing child evidence as blockers.

## Rollback And Interrupted Operation

- Dispose of pilot repositories and local candidates after retaining compact receipts.
- A failed live desired-state check performs no apply action.
- Pilot orchestration can resume from child and platform checkpoints without changing verdict history.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test under the child evidence root
`.octon/state/evidence/validation/proposals/public-distribution-pilot-release-readiness/`.
Raw sensitive evidence remains local-private unless the maintainer explicitly
classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.

