# Aggregate Validation Plan

_Status: In-review parent-program validation plan_

| Validation | Purpose | Command or Artifact |
| --- | --- | --- |
| Proposal standard validation | Validate parent manifest, lifecycle, catalog, targets, and registry projection posture | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program --skip-registry-check --skip-promotion-target-checks` |
| Architecture proposal validation | Validate architecture subtype surface completeness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program` |
| Program structure validation | Validate parent registry, human index, sequence, child contract, closeout plan, and no nested child packets | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program` |
| Parent review gate | Validate current parent review receipt, verdict/status alignment, and digest posture; implementation authorization requires the strict accepted-review gate | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program` |
| Child readiness validation | Revalidate current child-owned lifecycle/readiness state before any parent implementation authorization claim | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program` |
| Child registry schema validation | Validate `resources/child-packet-index.yml` against proposal-program child registry schema | `proposal-program-child-registry.schema.json` |
| Child relationship consistency | Ensure `related_proposals`, YAML child registry, Markdown child index, and packet sequence agree | Program review |
| Parent/child authority boundary review | Ensure parent coordinates only and does not own child truth | `architecture/child-packet-contract.md` plus program structure validator |
| Local evidence publication safety | Ensure `.octon/state/evidence/local/**` cannot be tracked or used for hosted closeout | `evidence-tier-validator-gates` child prompt |
| Publishable receipt sufficiency | Ensure publishable receipts prove claims without raw transcript dumping | `publishable-evidence-receipts` child prompt |
| Disclosure/read-model non-authority review | Ensure disclosure is evidence-derived and generated read models remain derived-only | `disclosure-and-read-model-alignment` child prompt |
| Closeout hosted/local boundary review | Ensure hosted/shared closeout depends only on publishable receipts and disclosure | `closeout-repo-hygiene-evidence-flow` child prompt |
| Migration safety review | Ensure existing residue moves only after inventory, local archive, and rollback posture | `evidence-residue-migration-closeout` child prompt |

No validation in this parent may substitute for child-owned validation,
promotion receipts, implementation-conformance receipts, or post-implementation
drift/churn receipts.
