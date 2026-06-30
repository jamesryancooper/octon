# Validation Plan

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing`
- `validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --mode pre-integration-architecture-review --require-pass`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --print-digest`

Future implementation validators:

- `cargo test -p kernel lifecycle_program`
- `validate-proposal-program-structure.sh --package <fixture-program>`
- `validate-proposal-program-child-readiness.sh --package <fixture-program>`
- extension command, skill, lifecycle contract, publication, and freshness
  validators after additive extension inputs change
- Proposal Program Delivery profile and receipt validators for handoff
  evidence
- negative controls for parent-summary substitution, generated-output
  authority, stale receipt refresh, unsafe resume, retry-budget exhaustion, and
  delivery mutation without owning-route evidence
