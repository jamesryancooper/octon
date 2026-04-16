# Scenario: Touched Paths Extension Pack

## Input

- `touched_paths` includes one or more paths under
  `/.octon/inputs/additive/extensions/<pack-id>/`

## Expected Route

- `touched-paths`

## Expected Validation Floor

- `validate-extension-pack-contract.sh`
- `publish-extension-state.sh`
- `validate-extension-publication-state.sh`
- `validate-extension-local-tests.sh`
- `publish-capability-routing.sh`
- `validate-capability-publication-state.sh`

## Expected Next Step

- finish extension publication before recommending downstream work
