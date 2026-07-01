# Validation Plan

## Program Creation Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence`

## Child Packet Validation

Run the standard and architecture proposal validators for each child packet:

- `proposal-delivery-input-contract-alignment`
- `proposal-program-delivery-operator-alias`
- `proposal-program-delivery-host-projections`
- `proposal-program-review-loop-documentation`
- `proposal-lifecycle-surface-validation-hardening`

## Future Implementation Validation

Future child implementation must add child-owned validation evidence for:

- required delivery input coherence across commands, skills, workflows, contracts, manifests, validators, projections, and docs;
- host projection and product catalog coherence;
- alias delegation without independent authority;
- program review/revision documentation and child authority preservation;
- parent closeout, archive handoff, cleanup disposition, and terminal proof refusal cases;
- generated-output freshness and non-authority negative controls.
