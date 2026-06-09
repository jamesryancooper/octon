# Executable Implementation Prompt

Implement `mcp-integration-evaluation` as a child-owned lab evaluation packet.

## Promotion Targets

- `.octon/framework/lab/adapter-evaluations/`
- `.octon/instance/governance/connector-admissions/mcp/integration-evaluation/admission.yml`
- `.octon/state/evidence/lab/adapter-evaluations/mcp-integration-evaluation/`
- `.octon/framework/constitution/contracts/adapters/deferred-adapter-evaluation-boundaries-v1.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-deferred-adapter-evaluation-boundaries.sh`

## Workstreams

1. Promote MCP lab evaluation records and retained lab proof.
2. Promote a non-live connector admission boundary record for MCP
   integration-evaluation.
3. Promote the shared deferred adapter evaluation boundary contract.
4. Promote validator coverage proving MCP cannot widen authority, support,
   permission, policy, or retained evidence truth.

## Evidence And Receipts

Retain child validation evidence under
`.octon/state/evidence/validation/proposals/mcp-integration-evaluation/`.
Write `support/implementation-run.md`, `support/validation.md`,
`support/implementation-conformance-review.md`, and
`support/post-implementation-drift-churn-review.md`.

## Validation

Run:

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation --require-implementation-authorization`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`
- `validate-deferred-adapter-evaluation-boundaries.sh`
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`

## Rollback

Remove MCP integration-evaluation lab, admission, and retained proof records;
remove shared boundary artifacts only if no sibling child still owns them; then
rerun validators and registry checks.

## Closeout Refusal Criteria

Refuse closeout or archive if MCP is claimed as live support, execution
authority, permission, runtime policy, retained evidence, or support admission;
if conformance/drift receipts are missing; or if validators fail.
