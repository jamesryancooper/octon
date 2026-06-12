# Source Of Truth Map

Proposal: `change-closeout-state-machine`

## Proposal-Local Lifecycle Sources

1. `proposal.yml`
2. `architecture-proposal.yml`

## Proposal-Local Working Sources

1. `architecture/target-architecture.md`
2. `architecture/implementation-plan.md`
3. `architecture/acceptance-criteria.md`
4. `validation-plan.md`
5. `support/implementation-grade-completeness-review.md`
6. `support/revisions/change-closeout-state-machine-pre-review-gap-closure-2026-05-20.md`
7. `support/proposal-review.md`

These files guide review of this packet only. They are not durable closeout
authority, and promoted targets must stand on their own without proposal-path
dependencies.

## Durable Promotion Targets

Durable authority after promotion must live only in:

- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Derived Or Discovery-Only Surfaces

- `.octon/generated/proposals/registry.yml`
- `.octon/generated/effective/capabilities/**`
- `.codex/skills/closeout-worktree/`

The generated proposal registry, capability routing projections, and host skill
projection are discovery or adapter surfaces only. They do not outrank
`proposal.yml`, `architecture-proposal.yml`, or later durable promoted targets.

## Boundary Rules

- This proposal packet is non-authoritative under `inputs/**`.
- Durable closeout behavior must not depend on proposal-local paths.
- `.octon/inputs/**` must not become runtime, policy, generated,
  state/control, publication, retained evidence, or host-projection authority.
- GitHub, host adapters, generated outputs, chat, model memory, and tool
  availability may be evidence or projections only when a durable contract says
  so.
