# Implementation Plan

## Dependencies

- No child-packet dependency. Parent sequencing and human review still apply.

## Phases

1. Define the structured role, ownership, Git-posture, and publication-safety registry in `.octon/framework/engine/runtime/spec/core-path-ownership-v1.yml`, with narrative architecture in `.octon/framework/cognition/_meta/architecture/public-distribution-topology.md`.
2. Revise architecture documentation to name the reserved portable_dropin role and the sibling ownership handoffs without editing the root manifest or implementing export behavior.
3. Add `.octon/framework/assurance/runtime/_ops/scripts/validate-repository-role-contracts.sh` and `.octon/framework/assurance/runtime/_ops/tests/test-repository-role-contracts.sh` for role completeness, disjoint ownership, exclusion invariants, and update-authority invariant presence, with negative fixtures under `.octon/framework/assurance/runtime/_ops/fixtures/repository-role-contracts/`.
4. Cross-check the export and downstream-delivery sibling contracts for contradictions without modifying or claiming their implementation and proof surfaces.

## Migration And Compatibility

- Leave bootstrap_core and every existing root-manifest profile unchanged in this child.
- Reserve portable_dropin as the public-boundary role; `public-distribution-portable-dropin-export` alone admits it and amends root-profile validation.
- State the project-owned hash-preservation invariant; `public-distribution-downstream-core-delivery` alone implements adoption/update behavior and proves the invariant against concrete operations.
- Perform no repository migration in this packet.

## Validation Plan

- The role registry classifies every major class root and host projection.
- Core-owned and project-owned path sets are disjoint.
- Repository-role validation rejects every strict public-boundary exclusion, with each rejection exercised against a checked-in negative fixture by the test harness, without requiring or validating root-manifest admission.
- The ownership contract states the project-owned hash-preservation invariant and a negative fixture proves the invariant cannot be omitted; concrete install/update proof remains outside this packet.
- Documentation and the machine-readable YAML contract agree on all four surfaces.

## Rollback And Interrupted Operation

- Revert the role, path, update-authority, documentation, and validator contract changes as one atomic change if ownership cannot be made unambiguous.
- No data moves occur in this packet, so rollback restores the prior documentation and ownership-contract state.
- Interrupted validation writes no authority or generated publication output.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
