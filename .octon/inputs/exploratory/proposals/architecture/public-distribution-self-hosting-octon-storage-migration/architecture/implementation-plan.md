# Implementation Plan

## Dependencies

- `public-distribution-repository-role-contracts` must satisfy its declared verification gate.
- `public-distribution-local-storage-evidence` must satisfy its declared verification gate.
- `public-distribution-self-hosting-workspace-migration` must satisfy its declared verification gate.

## Phases

1. Freeze the exact migration commit and classify all tracked state,
   generated, and input paths by the explicit input subtypes in AC-01 without
   inspecting human-led ideation content.
2. Author `.octon/framework/constitution/contracts/retention/octon-storage-migration-allowlist-v1.yml` enumerating the keep-set, high-value raw evidence, and storage classes; obtain maintainer approval of that enumeration; verify encrypted backups and test restore.
3. Deliver `.octon/framework/assurance/runtime/_ops/scripts/validate-octon-storage-migration.sh`, `.octon/framework/assurance/runtime/_ops/tests/test-octon-storage-migration.sh`, and fixtures under `.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`, including leak/denylist fixtures for the receipt and log sensitivity check.
4. Apply the reviewed local-private selection to
   `.octon/instance/governance/contracts/disclosure-retention.yml`, recording
   before and after digests and leaving all other instance authority unchanged.
5. Apply index-only untracking in bounded, subtype-aware batches with
   working-file preservation, active-proposal protection, and re-tracking
   negative tests.
6. Regenerate derived outputs and verify framework, instance-exception, and
   retained-receipt hashes.
7. Record forward migration and index rollback receipts without rewriting
   history, retaining evidence under
   `.octon/state/evidence/validation/proposals/public-distribution-self-hosting-octon-storage-migration/`.

## Migration And Compatibility

- Root workspace migration must land first so ignored local paths are not re-added.
- Untracking occurs in reviewable batches while local bytes remain present.
- Existing hosted history remains unchanged and is covered by the exposure review.

## Validation Plan

- The dry run names every index change and zero working-file deletions.
- A restore test reproduces the high-value evidence enumerated in the allowlist contract by digest.
- The framework tree and all instance files except the exact approved
  disclosure-retention contract are byte-identical before and after migration.
- Generated outputs can be rebuilt from retained authored source and local state.
- The hosted keep-set contains exactly the compact receipts enumerated in the allowlist contract.
- `validate-octon-storage-migration.sh` runs a leak/denylist negative check over every migration receipt and log: it must fail on the checked-in sensitive fixtures and pass on the checked-in clean fixtures under `.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`.
- `test-octon-storage-migration.sh` exercises the validator's positive, negative, and boundary cases against those fixtures.
- Re-tracking fixtures fail for every local-only input subtype and pass only for
  exact hosted exceptions in the allowlist.

## Rollback And Interrupted Operation

- Before commit, restore index entries from the exact pre-migration manifest.
- After commit, use a forward revert that re-tracks required files without touching local bytes.
- Revert the instance disclosure-retention authority change together with the
  index batch if the local-private transition cannot pass its compatibility
  checks; never leave policy and tracking posture in a mixed state.
- Interrupted batches resume from a journal or restore the last complete index snapshot.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
