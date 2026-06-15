# Enforcement Plan

## Validation

Run the normal policy and terminal closeout validators:

- `validate-policy-proposal.sh`
- `validate-proposal-implementation-readiness.sh`
- `validate-proposal-implementation-conformance.sh`
- `validate-proposal-post-implementation-drift.sh`
- `validate-proposal-packet-terminal-closeout-receipt.sh`

## Enforcement

The fixture passes only when the route derives packet-specific values from the fixture manifest and current repo state.

