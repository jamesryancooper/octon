# Validation Plan

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`
- `validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --mode pre-integration-architecture-review --require-pass`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --print-digest`

Acceptance review gates:

- Rerun `review-packet` after revision so `support/proposal-review.md` records
  the current reviewed packet digest.
- Then run `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`.
- Only an accepted review with `implementation_prompt_authorized: yes` may
  authorize implementation prompt generation.

Future implementation validators:

- `validate-evidence-disclosure-tiers.sh --change-receipt <receipt>`
- `validate-terminal-closeout-local-evidence.sh --manifest <manifest>`
- `validate-lifecycle-terminal-current-state-proof.sh --proof <proof> --require-cleaned`
- `validate-proposal-artifact-index-spine.sh`
- Generator refresh checks for proposal registry, artifact catalog, artifact
  index, handoff capsule, and navigation inventory source/output digests.
- Negative controls for local/private terminal refs inside hosted/shared
  landing, cleanup, delivery, archive, and Change receipt evidence.
