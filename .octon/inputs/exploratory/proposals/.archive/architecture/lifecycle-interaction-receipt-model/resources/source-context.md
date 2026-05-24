# Source Context

The source recommendation asks Octon to adopt a typed Lifecycle Interaction
Receipt Model with request and return receipts. The model must let one lifecycle
record that follow-on work is required in another lifecycle without
transferring authority.

The recommendation rejects a lifecycle bus, shared Phase-Loop state, and source
lifecycle authority over target action. It asks for:

- `lifecycle-interaction-request-v1`
- `lifecycle-interaction-return-v1`
- `handoff` as one interaction profile
- schema validation
- runner visibility
- non-authorizing request semantics
- target-owned gates
- return evidence before source dependency resolution

The packet accepts the recommendation after grounding it against current Octon
authority. The accepted scope is narrower than a bus and broader than a
one-off handoff string.
