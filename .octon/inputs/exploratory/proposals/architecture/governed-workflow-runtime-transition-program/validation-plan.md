# Aggregate Validation Plan

_Status: Draft parent-program validation plan_

| Validation | Purpose | Command or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate parent manifest, lifecycle, catalog, targets, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program` |
| Implementation readiness validation | Verify completeness receipt and architecture implementation surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program` |
| Child registry schema validation | Validate `resources/child-packet-index.yml` against proposal-program child registry schema | `proposal-program-child-registry.schema.json` |
| Child relationship consistency | Ensure `related_proposals`, YAML child registry, Markdown child index, and packet sequence agree | Program review |
| Parent/child authority boundary review | Ensure parent coordinates only and does not own child truth | `architecture/child-packet-contract.md` plus controller invariants |
| Generated/input non-authority review | Ensure generated and input surfaces are never authority | Aggregate review |
| Future capability overclaim review | Ensure statecharts, harness schemas, agent-node contracts, Durable Objects, MCP, external workflow engines, and universal replay/rollback are not claimed live early | Aggregate review |
| Deferred/rejected scope review | Ensure deferred/lab-only children remain non-required and rejected as authority | `deferred-and-rejected-scope.md` |
| Child receipt freshness review | Ensure required child receipts are fresh before aggregate closeout | Program closeout evidence |
| Aggregate closeout review | Ensure required child terminal outcomes and evidence completeness | `architecture/program-closeout-plan.md` |

No validation in this parent may substitute for child-owned validation,
promotion receipts, implementation-conformance receipts, or post-implementation
drift/churn receipts.

## Required Child Packet Validation

| Validation | Purpose | Command or Artifact |
| --- | --- | --- |
| Child framing-boundary-and-terminology-guardrails standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Child framing-boundary-and-terminology-guardrails architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Child framing-boundary-and-terminology-guardrails readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Child framing-boundary-and-terminology-guardrails checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails && shasum -a 256 -c SHA256SUMS.txt` |
| Child workflow-statechart-task-specific-execution-harness standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness` |
| Child workflow-statechart-task-specific-execution-harness architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness` |
| Child workflow-statechart-task-specific-execution-harness readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness` |
| Child workflow-statechart-task-specific-execution-harness checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness && shasum -a 256 -c SHA256SUMS.txt` |
| Child agent-node-model-call-contract standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Child agent-node-model-call-contract architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Child agent-node-model-call-contract readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Child agent-node-model-call-contract checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract && shasum -a 256 -c SHA256SUMS.txt` |
| Child workflow-history-replay-idempotency-compensation standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Child workflow-history-replay-idempotency-compensation architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Child workflow-history-replay-idempotency-compensation readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Child workflow-history-replay-idempotency-compensation checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation && shasum -a 256 -c SHA256SUMS.txt` |
| Child effect-token-enforcement-coverage standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Child effect-token-enforcement-coverage architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Child effect-token-enforcement-coverage readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Child effect-token-enforcement-coverage checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage && shasum -a 256 -c SHA256SUMS.txt` |
| Child evidence-provenance-hardening standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening` |
| Child evidence-provenance-hardening architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening` |
| Child evidence-provenance-hardening readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening` |
| Child evidence-provenance-hardening checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening && shasum -a 256 -c SHA256SUMS.txt` |
| Child connector-operation-admission standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission` |
| Child connector-operation-admission architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission` |
| Child connector-operation-admission readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission` |
| Child connector-operation-admission checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/connector-operation-admission && shasum -a 256 -c SHA256SUMS.txt` |
| Child migration-cutover-compatibility-retirement standard | Validate child packet manifest, catalog, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement` |
| Child migration-cutover-compatibility-retirement architecture | Validate child architecture subtype surfaces | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement` |
| Child migration-cutover-compatibility-retirement readiness | Validate draft implementation-readiness receipt | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement` |
| Child migration-cutover-compatibility-retirement checksum | Verify child checksum manifest | `cd .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement && shasum -a 256 -c SHA256SUMS.txt` |

Deferred/lab-only Durable Object, MCP, and external workflow-engine candidates have no child validation commands because implementation packets were intentionally not created.
