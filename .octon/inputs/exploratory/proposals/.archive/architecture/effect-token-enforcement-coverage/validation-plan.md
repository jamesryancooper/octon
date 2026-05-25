# Validation Plan

_Status: Draft child validation plan_

| Validation | Purpose | Command Or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate manifest, lifecycle, catalog, targets, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Implementation readiness validation | Confirm draft readiness receipt state and blockers | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` |
| Checksum verification | Confirm packet files match `SHA256SUMS.txt` | `cd .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage && shasum -a 256 -c SHA256SUMS.txt` |
| Child-specific validation | Material side-effect inventory completeness validation. | Proposed follow-on validator or receipt |
| Child-specific validation | Authorized effect token enforcement validator and bypass tests. | Proposed follow-on validator or receipt |
| Child-specific validation | Runtime crate test coverage for successful and rejected token consumption. | Proposed follow-on validator or receipt |

No validation in this child may substitute for durable promotion receipts, implementation-conformance receipts, post-implementation drift/churn receipts, or the final migration/cutover child.
