# Implementation Plan

## Dependencies

- `public-distribution-repository-role-contracts` must satisfy its declared verification gate.
- `public-distribution-portable-base-clearance` must satisfy its declared verification gate.
- `public-distribution-local-storage-evidence` must satisfy its declared verification gate.

## Phases

1. Define portable_dropin schema, component inputs, installability classes, and invariant denylist in `.octon/octon.yml`.
2. Amend `.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh`, which today hard-rejects any profile beyond bootstrap_core, repo_snapshot, pack_bundle, and full_fidelity, to admit portable_dropin, with a negative case proving every other unknown profile name is still rejected.
3. Implement exact-commit Git-object extraction into an empty staging directory in `.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`.
4. Emit canonical file and aggregate manifests without volatile fields, labeling every exported path installable or public-repository-only (PD-025).
5. Add deterministic rebuild, source-mutation, adversarial leak, labeling, and public-tree parity gates in `.octon/framework/assurance/runtime/_ops/scripts/validate-portable-dropin-export.sh` and `.octon/framework/assurance/runtime/_ops/tests/test-portable-dropin-export.sh`.

## Migration And Compatibility

- Keep bootstrap_core, repo_snapshot, and pack_bundle for their internal purposes while removing public-boundary claims.
- Narrow export-harness behavior or add a dedicated implementation without breaking internal callers.
- Do not update generated proposal or publication state during migration.

## Validation Plan

- Two exports of the same commit and closure have identical tree and manifest digests.
- Dirty, ignored, and untracked sentinel files never appear in output.
- A source status and tracked-content fingerprint is unchanged before and after export.
- Each strict excluded root and an unknown-path fixture is rejected.
- An export containing any path without an installable or public-repository-only label fails closed.
- The amended root-profile validator admits portable_dropin and still rejects an unknown-profile fixture.
- Public-tree parity rejects both extra and missing files, and workspace-ancestry checks confirm the candidate tree contains no `.git` directory or workspace commit references and the staged import has no parent commit from the workspace.

## Rollback And Interrupted Operation

- Delete the staging output; the source workspace is unchanged by invariant.
- Retain existing internal profiles if portable_dropin validation fails.
- Interrupted export leaves only an unapproved staging directory and no passing manifest receipt.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
