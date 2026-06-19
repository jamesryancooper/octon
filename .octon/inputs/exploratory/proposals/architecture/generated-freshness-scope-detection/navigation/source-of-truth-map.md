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

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-support-envelope-reconciliation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`

## Boundaries

Generated outputs remain derived-only. This packet does not authorize parent
closeout, parent archive, branch cleanup, generated publication, or a `cleaned`
claim.
