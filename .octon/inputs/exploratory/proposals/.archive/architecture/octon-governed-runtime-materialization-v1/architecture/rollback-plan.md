# Rollback Plan

## Rollback principles

- Preserve failed validation evidence.
- Delete or mark stale regenerated outputs that depend on reverted code/specs.
- Never leave a generated artifact that claims support or health from a reverted
  authority path.
- Restore prior material API behavior only if doing so is explicitly recorded as
  a rollback and not as a live support claim expansion.

## Rollback triggers

- Reconciliation gate produces false live support.
- Reconciliation gate fails to detect a known mismatch.
- A material API accepts ambient permission or unverified token.
- A negative bypass test unexpectedly succeeds.
- Run-health artifact omits a blocking condition.
- Generated artifact is consumed as authority.
- Evidence completeness cannot be proven.

## Rollback sequence

1. Stop publication of generated support-envelope and run-health artifacts.
2. Revert promoted runtime code changes.
3. Revert promoted runtime spec/schema changes only after dependent generated
   artifacts are removed or marked stale.
4. Revert assurance scripts/tests/fixtures.
5. Remove regenerated outputs or regenerate from the prior authority set.
6. Retain failed attempt evidence under state/evidence.
7. Publish a rollback disclosure that current support remains pre-migration.

## Partial rollback

If Phase 3 fails but Phases 1 and 2 pass, retain support reconciliation and
token enforcement if validators prove they are independent. If Phase 1 or Phase
2 fails, do not retain Phase 3 as an operator feature because health depends on
reconciled support and trustworthy effect posture.
