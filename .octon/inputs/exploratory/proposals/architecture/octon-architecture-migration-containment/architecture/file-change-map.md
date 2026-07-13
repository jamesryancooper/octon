# File Change Map

All entries are planned, not implemented. `Octon governance` owns policy and
support changes; `Octon runtime` owns runtime contracts and validators. The
trusted integrator must prevent concurrent edits with later packets.

| Durable promotion target | Current assumption | Required RP-00 change | Priority and rationale |
| --- | --- | --- | --- |
| `.octon/framework/product/contracts/default-work-unit.yml` | Active Change routing includes autonomous direct-main semantics. | Make every Octon-owned direct-main route unreachable and bind the accepted ROD-006 no-route disposition; ordinary human Git remains outside Octon. | P0: removes an ambient privileged route. |
| `.octon/framework/product/contracts/default-work-unit.md` | Narrative projects the machine route. | Align operator-facing semantics with deny/preserve containment and a protected PR only when independently review-selected and proved safe. | P0: prevents policy/document drift. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh` | Local landing remains an Octon-owned checkout-to-target path. | Hard-disable/retire the effectful entrypoint while preserving the candidate. | P0: enforces no direct-main. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh` | Current hosted no-PR runs from a credential-bearing checkout before the safety spine exists. | Hard-disable the effectful entrypoint during containment; RP-05 later owns its closed replacement. | P0: prevents unsafe autonomous publication. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh` | Legacy cleanup can delete closed-unmerged work. | Hard-disable destructive unlanded cleanup; later conditional cleanup belongs to RP-08 using an RP-05 primitive. | P0: preserves work. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Useful path inventory exists but is not the reconciled full physical inventory. | Cover every writer/credentialed effect plane and owner/disposition. | P0: FD-015/PG-00 source. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json` | Current schema validates existing entries. | Require the identity, ownership, boundary, evidence, and disposition fields needed for complete physical traceability. | P0: unknown writers must fail structurally. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Existing coverage does not prove all agent/child launch families. | Register every physical launcher and decision-input plane without implementing RP-01 repair. | P0: blocks hidden launch authority. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Documents current coverage classes. | Define Gate 0 inventory and unregistered-launch failure semantics. | P0: contract clarity. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.schema.json` | Validates current coverage records. | Require complete owner, classification, request builder, receipt, rollback, and disposition metadata. | P0: deterministic coverage. |
| `.octon/framework/orchestration/governance/delegated-governance-inventory-v1.yml` | Contains delegated routes and workflow references. | Identify lifecycle-local or candidate-controlled authority/launch surfaces and assign later repair/retirement ownership. | P1: prevents competing authority from remaining invisible. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` | Validates declared inventory. | Add exhaustive discovery comparison and unknown-writer negative fixture support. | P0: inventory must be enforced. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | Validates known boundary coverage. | Add exhaustive launcher and candidate-decision-input census checks. | P0: hidden launchers fail closed. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | Checks GitHub and execution governance posture. | Prove candidate-head writers and every Octon-owned human or agent direct-main route are unreachable. | P0: containment proof. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh` | Validates host projection alignment. | Assert projections remain non-authoritative and match the contained route. | P0: projection cannot become control truth. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh` | Validates support proof linkage. | Distinguish direct execution from referenced-only evidence and reject stale/overstated proof. | P0: claim truthfulness. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh` | Checks live support claims. | Reject live claims beyond admitted, directly proved tuples. | P0: fail-closed support posture. |
| `.octon/framework/assurance/runtime/_ops/scripts/generate-harness-card.sh` | Generates disclosure from durable sources and evidence. | Ensure output cannot upgrade evidence classification or include unproved live claims. | P1: truthful operator disclosure. |
| `.octon/framework/assurance/runtime/_ops/scripts/generate-support-target-matrix.sh` | Generates a derived support matrix. | Preserve claim-state and proof distinctions after correction. | P1: derived view parity. |
| `.octon/instance/governance/support-targets.yml` | Declares the bounded admitted universe. | Narrow only rows that exceed direct evidence; never widen. | P0: live support authority. |
| `.octon/instance/governance/disclosure/harness-card.yml` | Authored HarnessCard source declares system claims. | Correct complete/live/executed/signed wording to retained proof. | P0: operator-facing claim integrity. |
| `.octon/instance/governance/support-target-admissions/` | Partitioned admissions bind tuple claim states. | Update only affected rows needed to preserve truthful claim-state parity. | P1: support declaration coherence. |
| `.octon/instance/governance/support-dossiers/` | Dossiers cite proof and limitations. | Update only affected dossiers and preserve unresolved limitations. | P1: proof lineage. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-containment/` | No RP-00 implementation evidence exists at packet creation. | Retain direct, classified baseline, containment, inventory, claim, burden, validation, and rollback receipts. | P0: future implementation proof; never authority. |

## Affected Non-Target Surfaces

`.github/workflows/**` and hosted GitHub configuration are affected projections
or external state. They require governed projection/provider operations and
receipts but are excluded from this `octon-internal` promotion-target list.
Generated support views must be refreshed through their existing generators;
they are not authored promotion targets.
