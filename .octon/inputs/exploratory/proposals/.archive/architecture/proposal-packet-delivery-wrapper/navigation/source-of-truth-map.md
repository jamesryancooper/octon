# Source Of Truth Map

## Durable Authority

- Constitutional authority: `.octon/framework/constitution/**`
- Program delivery model:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`,
  `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`,
  and `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- Packet lifecycle authority: published framework workflow, capability command,
  and capability skill surfaces that implement the packet lifecycle routes.
- Packet implementation authority: promoted packet implementation workflow,
  command, and skill surfaces. Additive extension context and prompts may
  inform lineage only; they are not durable runtime, policy, lifecycle, or
  implementation authority.
- Terminal closeout authority:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- Proposal promotion authority:
  `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- Packet closeout owner: the existing `closeout-packet` proposal lifecycle
  route writes `support/proposal-closeout.md`. Additive route sources and
  generated extension projections are publication/input evidence for that
  route, not authority for this proposal to override.
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
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
- `.octon/framework/product/features/proposal-packet-delivery.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`

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
- The proposed wrapper cannot mark a packet implemented directly; that status
  transition remains owned by `promote-proposal`.
- The proposed wrapper cannot mint archive authorization directly; that receipt
  remains owned by `closeout-packet`.
- The proposed delivery wrapper must be aggregate-only and must fail closed
  when target-owned receipts or authorization refs are missing, stale, denied,
  or mismatched.
- The proposed delivery wrapper must not introduce new proposal statuses or PR
  fallback for `route=branch-no-pr`.
