# Implementation Plan

## Dependencies

- No child-packet dependency. Parent sequencing and human review still apply.

## Phases

1. Define finding classes, redaction rules, the compact disposition receipt, and the maintainer decision field set in `.octon/framework/constitution/contracts/disclosure/legacy-exposure-readiness-v1.schema.json`.
2. Implement exact-revision inventory, hosted-surface inventory, and scanners
   in `.octon/framework/assurance/runtime/_ops/scripts/validate-legacy-exposure-readiness.sh`
   with synthetic sensitive fixtures under
   `.octon/framework/assurance/runtime/_ops/fixtures/legacy-exposure-readiness/`.
3. Implement the no-mutation transition readiness gate in the same validator and the credential revoke-first runbook at `.octon/framework/orchestration/governance/legacy-exposure-response-runbook.md`.
4. Add the known-clone and repository-name-reuse precondition to the runbook,
   including the private-workspace remote cutover and residual-risk decision.
5. Validate through `.octon/framework/assurance/runtime/_ops/tests/test-legacy-exposure-readiness.sh`
   against sanitized history, mocked hosted-surface inventories, inaccessible
   surface cases, and stale-endpoint fixtures, retaining only redacted results.

## Migration And Compatibility

- The mechanism is additive and does not rewrite existing history.
- Existing exposure evidence remains local and can be re-run against later refs.
- Legacy disposition is a forward platform action performed separately.

## Validation Plan

- A fixture containing representative secret and private markers fails closed without echoing payloads.
- A clean fixture produces deterministic identical receipts.
- The tool proves no refs, files, remotes, credentials, or GitHub settings changed.
- Mocked enabled hosted surfaces cannot disappear from inventory when access is
  denied, pagination is incomplete, or the surface has zero items.
- A stale `owner/octon` endpoint and any known writer that still targets it
  block repository-name reuse.
- The transition gate rejects unresolved findings and any receipt missing a maintainer decision field: disposition, credential actions, timestamp, or reviewed revision.

## Rollback And Interrupted Operation

- Remove the additive review tooling if it emits sensitive content or cannot prove read-only behavior.
- An interrupted scan leaves no authoritative partial receipt; rerun from the same exact ref.
- Platform actions remain independently planned and reversible where GitHub permits.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
