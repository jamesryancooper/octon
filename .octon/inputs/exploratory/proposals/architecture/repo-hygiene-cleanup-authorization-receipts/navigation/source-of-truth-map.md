# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/instance/governance/policies/repo-hygiene.yml` governs cleanup
  classes, eligible patterns, protected surfaces, and fail-closed posture.
- `.octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json`
  defines the cleanup authorization receipt contract.
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
  implements classification, authorization emission, receipt revalidation, and
  file deletion for eligible local-run residue.
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
  provides the narrow operator-facing cleanup workflow after promotion.

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`

## Supporting Lineage

- `resources/source-prompt.md` records the originating prompt.
- `resources/source-findings.md` records the findings used to draft this
  proposal.
- `support/implementation-grade-completeness-review.md` records readiness for
  proposal review and future implementation prompt generation.
- `support/proposal-review.md` records the proposal review verdict and future
  implementation prompt authorization.
- `support/executable-implementation-prompt.md` records the operational prompt
  for the future implementation route.

## Non-Authority Boundaries

Generated proposal registry entries, generated run-health projections, host
projections, provider metadata, ignored local files, chat state, proposal-local
lineage, and tool availability may inform routing but cannot authorize cleanup.

## Integration Boundaries

`Closeout Worktree` may inventory, classify, route, and report repo-hygiene
residue. It must not delete residue. `Closeout Change` may clean only within
the selected Change route boundary and must not claim global hygiene cleanup.
Run-health pruning remains in the run-health generator path.
