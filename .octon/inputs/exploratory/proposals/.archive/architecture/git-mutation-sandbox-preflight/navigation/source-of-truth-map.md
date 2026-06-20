# Source Of Truth Map

## Proposal-Local

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`

## Durable Targets

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`

## Boundaries

Diagnostics do not authorize git mutation. Fetch, checkout, landing, sync,
cleanup, and branch deletion remain bound by their owning authorization routes.
