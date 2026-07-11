# Acceptance Criteria

## AC-01

Every tracked `.octon/state`, `.octon/generated`, and `.octon/inputs` path is
classified as keep-hosted, local-only, regenerate, or external-with-pointer
before index mutation. Input classification is separate for raw intake,
archives, normalized extension source, human-led ideation, proposals and
lineage, advisory plans, syntheses, and reports; ideation is inventoried by
path and minimal metadata without content inspection.

## AC-02

Every path enumerated as high-value raw evidence in `.octon/framework/constitution/contracts/retention/octon-storage-migration-allowlist-v1.yml` has verified encrypted system and disconnected backup coverage before becoming local-only. The allowlist contract enumeration is the sole definition of high-value raw evidence; no subjective judgment is applied at run time.

## AC-03

The migration removes only approved paths from the index, preserves all local working bytes, and performs no history rewrite.
The current parent and child proposal packets, their lifecycle receipts, and
the proposal-discovery entry needed to authorize and verify this migration
remain tracked through terminal closeout.

## AC-04

Canonical `.octon/framework` hashes and every `.octon/instance` hash except
`.octon/instance/governance/contracts/disclosure-retention.yml` remain
unchanged. The one allowed instance change selects truthful local-private
custody, rejects fabricated external-object claims, and has an explicit
maintainer-approved before/after digest.

## AC-05

The hosted keep-set contains only the compact governance, release, collaboration, or recovery receipts explicitly enumerated in `.octon/framework/constitution/contracts/retention/octon-storage-migration-allowlist-v1.yml`.

## AC-06

Generated outputs are reproducibly rebuilt and an index-only rollback succeeds
on a migration batch that covers every storage class and every input subtype
named in the allowlist contract at least once.

## AC-07

`validate-octon-storage-migration.sh` proves the negative control that no raw sensitive content appears in receipts or migration logs: its leak/denylist check fails on the checked-in sensitive fixtures, passes on the checked-in clean fixtures under `.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`, and passes on every actual migration receipt and log.

## AC-08

After migration, `.gitignore` and the migration validator reject re-adding
every local-only state, generated, evidence, and input path while allowing only
the exact hosted exceptions enumerated by the approved allowlist and contained
within an exception class predeclared by `repository-git-posture-v1.yml`. A
negative fixture proves an unclassified proposal, report, extension source,
and human-led ideation path cannot enter the index.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
