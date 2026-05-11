# Validation Plan

_Status: Draft child validation plan_

| Validation | Purpose | Command Or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate manifest, lifecycle, catalog, targets, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Implementation readiness validation | Confirm draft readiness receipt state and blockers | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` |
| Checksum verification | Confirm packet files match `SHA256SUMS.txt` | `cd .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract && shasum -a 256 -c SHA256SUMS.txt` |
| Child-specific validation | Agent-node schema positive and negative fixtures. | Proposed follow-on validator or receipt |
| Child-specific validation | Model-call receipt completeness validation. | Proposed follow-on validator or receipt |
| Child-specific validation | Context-pack digest binding validation. | Proposed follow-on validator or receipt |
| Child-specific validation | Forbidden authority claim scan for agent outputs and prompts. | Proposed follow-on validator or receipt |

No validation in this child may substitute for durable promotion receipts, implementation-conformance receipts, post-implementation drift/churn receipts, or the final migration/cutover child.
