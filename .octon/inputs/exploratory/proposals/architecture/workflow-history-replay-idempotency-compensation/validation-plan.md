# Validation Plan

_Status: Draft child validation plan_

| Validation | Purpose | Command Or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate manifest, lifecycle, catalog, targets, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Implementation readiness validation | Confirm draft readiness receipt state and blockers | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` |
| Checksum verification | Confirm packet files match `SHA256SUMS.txt` | `cd .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation && shasum -a 256 -c SHA256SUMS.txt` |
| Child-specific validation | Replay reconstruction fixtures for valid, drifted, incomplete, and unsupported histories. | Proposed follow-on validator or receipt |
| Child-specific validation | Idempotency and retry policy negative tests. | Proposed follow-on validator or receipt |
| Child-specific validation | Compensation plan validation and unsupported-rollback disclosure checks. | Proposed follow-on validator or receipt |

No validation in this child may substitute for durable promotion receipts, implementation-conformance receipts, post-implementation drift/churn receipts, or the final migration/cutover child.
