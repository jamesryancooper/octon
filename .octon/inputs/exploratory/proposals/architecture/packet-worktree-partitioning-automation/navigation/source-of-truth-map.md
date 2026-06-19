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

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`

## Boundaries

Deletion and cleanup remain receipt-backed. Protected retained evidence and
local run evidence must not be deleted as branch cleanup.
