# Implementation Plan

1. Define the no-dispatch key and attempt ledger fields.
2. Add lifecycle logic that detects repeated unchanged no-dispatch attempts.
3. Append bounded attempt metadata instead of full duplicate compact evidence.
4. Keep fresh evidence behavior for changed inputs, changed blocker
   fingerprints, and route dispatch.
5. Add fixtures for repeated no-dispatch, max-step exhaustion, changed input,
   and dispatched route cases.
