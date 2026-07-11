# Implementation Plan

## Dependencies

- `public-distribution-repository-role-contracts` must satisfy its declared verification gate.
- `public-distribution-local-storage-evidence` must satisfy its declared verification gate.

## Phases

1. Add root-role detection, the versioned `.githooks/pre-push` public-remote
   guard, and a dry-run tracking inventory; consume the legacy packet's known
   writer inventory, repoint the active workspace to the private identity,
   and activate the guard with `core.hooksPath` as manual migration steps
   recorded in the run journal.
2. Freeze or replace unsafe workspace release publication in `.github/workflows/release-please.yml` and `.github/workflows/runtime-binaries.yml`, then correct placeholder ownership metadata.
3. Generate and validate local-first ignore rules and bounded exception classes
   from `repository-git-posture-v1.yml`, covering state, generated output,
   classified input subtypes, and host projections without depending on the
   later Octon storage allowlist; add regeneration checks.
4. Apply forward-only root untracking only after maintainer approval and preserve local files.

## Migration And Compatibility

- Commit root policy changes separately from .octon storage untracking.
- Preserve host files locally while removing them from future hosted history where classified local.
- Retain existing history and route exposure concerns to the legacy review packet.

## Validation Plan

- The `.githooks/pre-push` guard rejects a simulated push to the public distribution identity from the workspace while approved private workspace destinations pass.
- The guard also rejects the stale original-name URL after name reuse, and the
  transition preflight rejects any known writer that still targets it.
- Workflow scans find no cross-repository PAT or automatic public release path.
- Root tracking dry run lists only approved root files and never deletes working files.
- Ignore-policy validation proves each local-only `.octon` subtype remains
  ignored after index migration and that only predeclared hosted-exception
  classes can later receive an exact allowlisted path.
- Host projections regenerate or produce an explicit bounded drift report.
- CODEOWNERS is valid for the personal account or absent.

## Rollback And Interrupted Operation

- Revert the root policy commit if required workspace collaboration breaks.
- Restore prior index entries without deleting local host files.
- An interrupted root migration leaves a manifest of intended versus completed index changes and can be rerun.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
