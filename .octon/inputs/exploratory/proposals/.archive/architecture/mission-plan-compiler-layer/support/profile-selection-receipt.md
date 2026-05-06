# Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: none

## Rationale

The workspace charter and constitutional charter declare `pre-1.0` and default
atomic mode. This change creates a proposal packet only. It does not promote
durable runtime behavior, mutate support-target claims, or require a staged
transitional live migration.

## Impact Map

- code: none in this packet
- tests: proposal validators only
- docs: proposal-local architecture documents
- contracts: proposal-local manifests only
- generated outputs: proposal registry projection after validation
- retained evidence: proposal-local support receipts

## Evidence Plan

Record the validator commands and outcomes in `support/validation.md`, and
regenerate `support/SHA256SUMS.txt` after packet content stabilizes.
