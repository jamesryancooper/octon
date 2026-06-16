# Source Of Truth Map

## Durable Authority

- Constitutional authority: `.octon/framework/constitution/**`
- Program delivery model:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`,
  `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`,
  and `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- Packet lifecycle authority:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/**`
  and the published packet lifecycle route surfaces.
- Packet implementation authority:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/run-packet-implementation/`
  and the promoted packet implementation skill surfaces.
- Terminal closeout authority:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- Archive authority:
  `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- Change closeout authority:
  `.octon/framework/product/contracts/default-work-unit.*`,
  `.octon/framework/product/contracts/change-closeout-state-machine.*`,
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`,
  and `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- Repo hygiene cleanup authority:
  `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/`
  and `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- Branch-no-pr helper authority:
  `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh`,
  `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`,
  `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh`,
  and `.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh`

## Proposed New Durable Surfaces

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `support/implementation-grade-completeness-review.md`

## Source Lineage

- `resources/source-prompt.md`
- `resources/delivery-wrapper-analysis.md`

## Derived And Evidence Surfaces

- `.octon/generated/proposals/registry.yml` is discovery-only.
- `.octon/generated/proposals/artifacts/**` is a derived proposal artifact
  projection.
- `.codex/commands/**`, `.codex/skills/**`, and other host projections remain
  generated or publication outputs and must only be refreshed through owning
  publication scripts.
- `.octon/state/evidence/**` is retained evidence, not authority to mutate
  lifecycle, branch, cleanup, archive, publication, or final sync state.

## Boundary Rules

- This proposal packet cannot authorize implementation, terminal closeout,
  archive, branch landing, cleanup, final sync, clean-worktree proof, or
  generated projection refresh.
- The proposed delivery wrapper must be aggregate-only and must fail closed
  when target-owned receipts or authorization refs are missing, stale, denied,
  or mismatched.
- The proposed delivery wrapper must not introduce new proposal statuses or PR
  fallback for `route=branch-no-pr`.
