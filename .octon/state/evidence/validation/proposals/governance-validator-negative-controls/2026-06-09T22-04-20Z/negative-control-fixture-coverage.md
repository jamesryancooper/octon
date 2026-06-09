# Negative-Control Fixture Coverage

proposal_id: governance-validator-negative-controls
run_id: 2026-06-09T22-04-20Z
verdict: pass

## Covered Failure Classes

`test-delegated-governance-negative-controls.sh` exercises fixture-mode denial
for every named failure class:

- approval-default-primitive
- dispatch-without-retained-proof
- missing-proof
- stale-digest
- scope-mismatch
- generated-output-authority-misuse
- read-model-authority-misuse
- child-authority-takeover
- unsupported-mode
- unsafe-resume
- policy-override
- governance-mutation-without-typed-exception
- external-irreversible-effect-without-proof

The test also includes a generated-authority misuse fixture that must fail.
