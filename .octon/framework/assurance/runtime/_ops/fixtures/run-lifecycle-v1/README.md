# Run Lifecycle v1 Fixtures

These fixtures exercise the assurance-facing lifecycle state machine contract
without mutating runtime crates or proposal inputs.

- `transition-matrix.yml` declares the expected state exits and denied controls.
- `lifecycle-fixtures.yml` defines positive and negative fixture journals.
- `validate-run-lifecycle-v1.sh` derives journal hashes and runtime-state
  materialization from the fixture transitions, then verifies closeout and
  boundary composition.
