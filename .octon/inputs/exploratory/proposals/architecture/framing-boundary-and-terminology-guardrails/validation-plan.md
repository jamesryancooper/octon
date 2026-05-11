# Validation Plan

_Status: Draft child validation plan_

| Validation | Purpose | Command Or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate manifest, lifecycle, catalog, targets, and registry projection | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Implementation readiness validation | Confirm draft readiness receipt state and blockers | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` |
| Checksum verification | Confirm packet files match `SHA256SUMS.txt` | `cd .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails && shasum -a 256 -c SHA256SUMS.txt` |
| Child-specific validation | Terminology scan proving canonical surfaces avoid unsupported future-state claims. | Proposed follow-on validator or receipt |
| Child-specific validation | Naming-constitution and glossary consistency review. | Proposed follow-on validator or receipt |
| Child-specific validation | Generated/input non-authority scan for proposal-local and generated references. | Proposed follow-on validator or receipt |

No validation in this child may substitute for durable promotion receipts, implementation-conformance receipts, post-implementation drift/churn receipts, or the final migration/cutover child.
