# Validation Plan

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
- `validate-run-program-clean-delivery.sh --receipt <proposal-program-delivery-receipt>`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `validate-change-closeout-state-machine.sh --receipt <receipt>`
- `validate-hosted-no-pr-landing.sh --receipt <receipt>`
- `validate-change-closeout-lifecycle-alignment.sh --receipt <receipt> --verify-live-refs`
- `validate-evidence-disclosure-tiers.sh --change-receipt <receipt>`
- `classify-change-closeout-residue.sh --root <repo>`
