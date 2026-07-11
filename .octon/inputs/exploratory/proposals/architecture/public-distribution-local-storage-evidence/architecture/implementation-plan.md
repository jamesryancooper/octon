# Implementation Plan

## Dependencies

- `public-distribution-repository-role-contracts` must satisfy its declared verification gate.

## Phases

1. Define the class-root and input-subtype Git-posture matrix plus hosted-evidence minimums in `repository-git-posture-v1.yml`, with commit-default alignment in `.octon/octon.yml`.
2. Define `local-private` and real-external-object semantics across the active
   retention, replay, evidence-store, disclosure, registry, engine, and lab
   contracts as one atomic compatibility closure.
3. Correct both evidence producers (`write-run.sh` and the Rust authority
   engine), their consumers, and their existing tests; preserve
   `external-immutable` only for a configured backend that proves object
   existence and digest equality.
4. Add `validate-local-storage-policy.sh`,
   `test-local-storage-policy.sh`, checked-in fixtures, and tracking guards for
   state, generated, evidence, logs, caches, host projections, and classified
   input subtypes.
5. Update disclosure-tier validation to reuse the existing
   `publishable-evidence-receipt-v1.schema.json` contract and prove compact
   hosted receipts never embed raw local-private payloads.
6. Document the bounded hosted surface in `hosted-repository-footprint.md`,
   then document and test encrypted backup, restore, retention, and explicit
   deletion authorization while keeping compaction execution deferred.

## Migration And Compatibility

- Classify currently tracked material before changing ignore or tracking state.
- Move forward without history rewriting; existing history receives separate exposure review.
- Regenerate derived output and host projections after untracking rather than preserving copies as authority.
- Retain compact receipts and required governance records before removing high-churn files from future commits.

## Validation Plan

- Evidence writers compute SHA-256 from actual bytes and never synthesize external object claims.
- The shell and Rust producers pass the same storage-class fixture matrix, and
  every active schema and consumer accepts or rejects the same classes.
- Git-posture tests cover raw intake, archives, extension source, ideation, proposals, plans, syntheses, reports, state, generated, and host projections.
- Backup restore produces byte-identical high-value evidence in a disconnected test.
- Retention selection never deletes and produces a maintainer-reviewable candidate receipt.
- Hosted receipt fixtures satisfy collaboration and release claims without embedding raw sensitive payloads.
- A fixture that supplies a local digest with an `immutable://`-shaped locator
  but no external object fails every producer and validator path.

## Rollback And Interrupted Operation

This packet uses the registry `rollback-route` posture: the contract, producer,
consumer, validator, and test closure is one revertible promotion boundary.

- Preserve current files until classification, backup, and forward-untracking checks pass.
- Revert Git-posture policy if required collaboration evidence becomes unavailable.
- An interrupted evidence migration leaves original bytes and classification records intact.
- Restore prior evidence from verified backup when a local storage transition fails.
- Promote the schema, producer, consumer, validator, and test closure in one
  atomic change. If any compatibility test fails, revert the complete closure;
  do not retain a mixed state in which writers and readers disagree.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
