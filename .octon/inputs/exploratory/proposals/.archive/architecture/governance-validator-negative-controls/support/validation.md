# Validation

- validation_run_id: `2026-06-09T22-04-20Z`
- evidence_root: `.octon/state/evidence/validation/proposals/governance-validator-negative-controls/2026-06-09T22-04-20Z/`

## Commands

Selected validation commands completed successfully:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-delegated-governance-negative-controls.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-delegated-governance-negative-controls.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authority-engine-typed-exception-grants.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authority-zone-policy.sh`
- `jq empty .octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-delegated-governance-negative-controls.sh .octon/framework/assurance/runtime/_ops/tests/test-delegated-governance-negative-controls.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls`
- `git diff --check`

## Evidence Files

Retained proposal evidence:

- `validate-proposal-standard.txt`
- `validate-architecture-proposal.txt`
- `validate-proposal-review-gate.txt`
- `validate-proposal-implementation-readiness.txt`
- `validate-delegated-governance-negative-controls.txt`
- `test-delegated-governance-negative-controls.txt`
- `test-authority-engine-typed-exception-grants.txt`
- `validate-authority-zone-policy.txt`
- `jq-delegated-governance-contract-schema.txt`
- `bash-n-delegated-governance-negative-controls.txt`
- `validate-proposal-implementation-conformance.txt`
- `validate-proposal-post-implementation-drift.txt`
- `git-diff-check.txt`

The packet does not maintain a checksum manifest, so no
`support/SHA256SUMS.txt` file was added.
