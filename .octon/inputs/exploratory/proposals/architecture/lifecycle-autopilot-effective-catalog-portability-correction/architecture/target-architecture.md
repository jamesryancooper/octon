# Target Architecture

_Status: Draft target architecture_

Lifecycle Autopilot should be able to plan a proposal-program lifecycle through
the runtime path when the effective extension catalog is valid, while still
failing closed on genuine lifecycle-contract declaration defects.

## Corrected Lifecycle Discovery

Runtime lifecycle discovery should distinguish these cases:

1. A pack has no lifecycle contracts: do not require the `lifecycle-contract`
   capability profile.
2. A pack has an empty `lifecycle_contracts: []` array: treat it as no lifecycle
   contracts.
3. A pack has one or more lifecycle contracts: require the `lifecycle-contract`
   capability profile and validate the contract projection.

This preserves fail-closed behavior for unsafe declarations without blocking
unrelated packs that explicitly publish an empty lifecycle contract list.

## Corrected Validator Portability

Proposal registry generation and proposal standard validation should either:

- be portable across the supported shell baseline; or
- enforce a Bash version requirement with an actionable error and ensure nested
  validator calls use the same supported interpreter.

The validator should not succeed on registry drift, and it should not fail only
because the parent shell resolves `bash` to an unsupported implementation.

## Corrected Evidence Posture

When a lifecycle route is unavailable and a fallback/manual creation path is
used, the fallback should be visible in durable evidence or in a validator-checked
receipt contract. Proposal-local receipts may disclose the fallback, but they are
not sufficient to prove runtime lifecycle execution.

## Authority Boundary

The correction must not create a second control plane. Lifecycle Autopilot still
uses generated effective projections as runtime-discovered handles, not as
authored authority. Parent proposal programs coordinate only and must not own
child lifecycle truth.
