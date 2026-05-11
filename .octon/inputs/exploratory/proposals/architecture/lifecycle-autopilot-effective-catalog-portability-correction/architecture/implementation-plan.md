# Implementation Plan

_Status: Draft implementation plan_

Implementation is not authorized by this draft packet. If accepted, use the
following sequence.

## Phase 1: Reproduce And Pin The Failure

1. Add a focused failing test or fixture showing that `proposal-program`
   lifecycle planning is blocked by a pack with `lifecycle_contracts: []` and no
   `lifecycle-contract` capability profile.
2. Add a negative fixture showing that a non-empty lifecycle contract list
   without `lifecycle-contract` still fails closed.

## Phase 2: Correct Runtime Discovery

1. Update lifecycle contract discovery to treat empty lifecycle contract arrays
   as absent contracts.
2. Keep denial for missing projections, malformed non-empty lifecycle contracts,
   and non-empty lifecycle contracts without the required capability profile.
3. Add or update lifecycle runner and proposal-program acceptance tests.

## Phase 3: Correct Validator Portability

1. Decide whether the registry generator must require Bash 4+ or be rewritten to
   avoid Bash associative arrays.
2. Ensure `validate-proposal-standard.sh` invokes the registry generator through
   a supported interpreter or fails with a clear, actionable diagnostic.
3. Add a shell portability regression test where practical.

## Phase 4: Evidence And Documentation

1. Define where fallback/manual lifecycle creation evidence must be retained.
2. Update Lifecycle Autopilot documentation to state the supported route behavior
   and any unsupported fallback limitations.
3. Ensure product documentation does not claim proposal-program route execution
   unless runtime tests and retained evidence prove it.

## Phase 5: Validation And Closeout

1. Run packet validators, runtime lifecycle tests, and proposal registry checks.
2. Regenerate derived projections only through approved generation commands.
3. Retain implementation conformance and drift/churn receipts before closeout.
