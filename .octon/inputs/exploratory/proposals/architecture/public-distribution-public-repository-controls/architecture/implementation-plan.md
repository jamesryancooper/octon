# Implementation Plan

## Dependencies

- `public-distribution-portable-base-clearance` must satisfy its declared verification gate.
- `public-distribution-portable-dropin-export` must satisfy its declared verification gate.

## Phases

1. Author the public-repository-only scaffold and generated-mirror documentation in `.octon/framework/scaffolding/runtime/templates/public-repository/`, assembled from paths the approved export manifest labels public-repository-only.
2. Implement the desired-state manifest, immutable repository-ID bindings,
   stale-writer and original-name-reuse preconditions, API diff, dry-run
   default, and explicit apply plan in
   `.octon/framework/orchestration/runtime/_ops/scripts/plan-public-repository-state.sh`.
3. Implement secure public CI, draft release-candidate generation, and the candidate receipt contract `.octon/framework/constitution/contracts/disclosure/public-release-candidate-v1.schema.json`.
4. Implement candidate verification in `.octon/framework/assurance/runtime/_ops/scripts/validate-public-release-candidate.sh` plus the exact maintainer publication command, post-publication verification, and rollback guidance.
5. Validate all behavior through `.octon/framework/orchestration/runtime/_ops/tests/test-public-repository-state-plan.sh` against mocked API fixtures before any approved live operation.

## Migration And Compatibility

- Create public-repository-only source under framework templates, not in the workspace public tree.
- Use a separate public checkout for later approved import and publication.
- Replace workspace release behavior through the root workspace migration packet rather than this packet.

## Validation Plan

- Desired-state dry run is idempotent and makes zero API mutations.
- Mocked rename-redirect and original-name-reuse fixtures reject stale writers,
  repository-ID drift, and a first import before private-remote cutover.
- Mocked settings detect missing PR requirements, tag rules, scanning, push protection, least privilege, vulnerability reporting, and immutable releases.
- Untrusted pull-request fixtures cannot access secrets or write permissions.
- A candidate build produces verified checksums, SBOM, attestations, and manifest parity.
- Publication requires exact commit, version, and manifest digest confirmation and cannot be triggered by merge.

## Rollback And Interrupted Operation

### Reversible Class With Compensating Operations

- Repository settings, branch and tag rulesets, Actions permissions, secret-scanning and push-protection toggles, and vulnerability-reporting settings: the desired-state apply records each prior value in an exact operation log, and the compensating operation reapplies that recorded prior value through the same plan-then-apply path.
- A failed or wrong public-tree import: discard the import branch before merge; nothing published, no compensation needed beyond branch deletion.
- A bad draft release candidate: delete or replace the draft without publishing; drafts carry no external commitment.

### Irreversible Class

- A published immutable release, its assets, and its protected tag cannot be overwritten, edited, or silently deleted; publication is the one-way transition in this packet.

### Withdraw Or Supersede Runbook For The Irreversible Class

- Mark the published release as withdrawn in its release notes without altering assets or tag.
- Publish a superseding release with a new version, commit, and manifest digest through the same candidate-verification and deliberate-publication gates.
- Update public advisories and documentation to point consumers at the superseding release.
- Record a maintainer decision receipt naming the withdrawn version, the reason, and the superseding version.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
