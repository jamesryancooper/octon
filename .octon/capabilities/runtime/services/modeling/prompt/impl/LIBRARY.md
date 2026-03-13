# Prompt Implementation

Prompt service is implemented as a harness-native shell entrypoint:

- `impl/prompt.sh`

## Invocation Contract

- `interface_type`: `shell`
- Input schema: `../schema/input.schema.json`
- Output schema: `../schema/output.schema.json`

## Behavior

- Deterministic prompt rendering based on `promptId`, `variables`, and options.
- Approximate token estimation for budgeting.
- Optional SHA-256 hash output for reproducibility tracking.
