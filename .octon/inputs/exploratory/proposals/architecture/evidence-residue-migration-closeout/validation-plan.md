# Validation Plan

_Status: Accepted child validation plan_

| Validation | Purpose | Command or Artifact |
| --- | --- | --- |
| Proposal standard | Validate manifest, lifecycle, navigation, and packet structure | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout --skip-registry-check --skip-promotion-target-checks` |
| Architecture proposal | Validate required architecture packet surfaces and implementation readiness | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout` |
| Review gate | Validate fresh accepted review and implementation authorization | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout --require-implementation-authorization` |
| validate-proposal-standard.sh | Child-specific validation required before or during durable implementation | `validate-proposal-standard.sh` |
| validate-architecture-proposal.sh | Child-specific validation required before or during durable implementation | `validate-architecture-proposal.sh` |
| future evidence residue migration validator | Child-specific validation required before or during durable implementation | `future evidence residue migration validator` |
| validate-proposal-program-structure.sh | Child-specific validation required before or during durable implementation | `validate-proposal-program-structure.sh` |

No validation in this packet may substitute for retained evidence or post-implementation receipts after durable changes land.
