# Source Of Truth Map

## Proposal Sources

- `proposal.yml`
- `architecture-proposal.yml`

## Durable Targets

- `.octon/framework/orchestration/runtime/workflows/meta/verify-implementation-conformance/`
- `.octon/framework/orchestration/runtime/workflows/meta/audit-post-implementation-drift/`
- `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/`
- `.octon/framework/assurance/evaluators/lifecycle-postmortem/`

## Boundary

Closeout authority stays with durable lifecycle gates. Post-integration review
and lifecycle postmortem reports are retained evidence unless a later accepted
policy explicitly changes their status.
